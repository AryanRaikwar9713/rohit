import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/screens/dashboard/dashboard_controller.dart';
import 'package:streamit_laravel/screens/subscription/model/subscription_plan_model.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/video_players/model/ad_config.dart';
import 'package:streamit_laravel/video_players/model/overlay_ad.dart';
import 'package:streamit_laravel/video_players/model/vast_ad_response.dart';
import 'package:streamit_laravel/video_players/model/vast_media.dart';
import 'package:streamit_laravel/video_players/y_player_widget.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import 'package:y_player/y_player.dart';

import '../configs.dart';
import '../network/core_api.dart';
import '../screens/home/home_controller.dart';
import '../screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import '../screens/profile/profile_controller.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';
import 'model/video_model.dart';

class VideoPlayersController extends GetxController {
  Rx<VideoPlayerModel> videoModel = VideoPlayerModel().obs;
  final LiveShowModel liveShowModel;

  Rx<PodPlayerController> podPlayerController = PodPlayerController(playVideoFrom: PlayVideoFrom.youtube("")).obs;
  Rx<YPlayerController> youtubePlayerController = YPlayerController().obs;

  RxBool isAutoPlay = true.obs;
  RxBool isTrailer = true.obs;
  RxBool isBuffering = false.obs;
  RxBool isSubtitleBuffering = false.obs;
  RxBool canChangeVideo = true.obs;
  RxBool playNextVideo = false.obs;
  RxBool isVideoCompleted = false.obs;
  RxBool isVideoPlaying = false.obs;
  RxBool? isFromDownloads = false.obs;

  RxBool isPipEnable = false.obs;
  RxString currentQuality = QualityConstants.defaultQuality.toLowerCase().obs;
  RxString errorMessage = ''.obs;
  RxList<int> availableQualities = <int>[].obs;
  RxList<VideoLinks> videoQualities = <VideoLinks>[].obs;

  RxString videoUrlInput = "".obs;
  RxString videoUploadType = "".obs;

  RxInt selectedSettingTab = 0.obs;

  RxBool isVideoControlsVisible = false.obs;

  // Video Settings Dialog State

  RxString currentSubtitle = ''.obs;
  RxList<Subtitle> availableSubtitleList = <Subtitle>[].obs;

  RxList<SubtitleModel> subtitleList = <SubtitleModel>[].obs;
  Rx<SubtitleModel> selectedSubtitleModel = SubtitleModel().obs;

  Rx<WebViewController> webViewController = WebViewController().obs;

  // Ads Properties
  late Player adPlayer;
  late VideoController adVideoController;
  RxBool isAdPlaying = false.obs;
  RxInt adSkipTimer = 5.obs;
  Timer? adSkipTimerController;
  Set<int> midRollAdSeconds = {};
  int adFrequency = 0;
  final Set<int> shownMidRollAds = {};
  RxBool isPostRollAdShown = false.obs;
  final RxBool isCurrentAdSkippable = false.obs;
  RxInt currentAdIndex = 0.obs;

  List<AdConfig> preRollAds = [];
  List<AdConfig> midRollAds = [];
  List<AdConfig> postRollAds = [];

  Completer<void>? _currentAdCompleter;

  RxInt lastPlaybackPosition = 0.obs;

  RxList<OverlayAd> overlayAds = <OverlayAd>[].obs;
  Rx<OverlayAd?> currentOverlayAd = Rx<OverlayAd?>(null);
  Timer? overlayAdTimer;
  final Set<int> shownOverlayAds = {};

  UniqueKey uniqueKey = UniqueKey();

  RxBool hasShownCustomAd = true.obs;

  /// Get all ad break points including midroll, postroll, and overlay ads
  ///
  /// This method consolidates all ad break points from different ad types:
  /// - Midroll ads: Scheduled at specific time intervals during video playback
  /// - Overlay ads: Displayed as overlays at specific time points
  /// - Postroll ads: Displayed at 90% of video duration
  ///
  /// Returns a sorted list of unique Duration objects representing all ad break points
  List<Duration> getAllAdBreaks() {
    final List<Duration> allBreaks = [];

    // Add midroll ad breaks
    if (midRollAdSeconds.isNotEmpty) {
      allBreaks.addAll(midRollAdSeconds.map((seconds) => Duration(seconds: seconds)));
    }

    // Add overlay ad breaks
    if (overlayAds.isNotEmpty) {
      allBreaks.addAll(overlayAds.map((ad) => Duration(seconds: ad.startTime)));
    }

    // Add postroll ad break (at 90% of video duration)
    if (postRollAds.isNotEmpty && !isPostRollAdShown.value) {
      final videoDuration = podPlayerController.value.videoPlayerValue?.duration ?? Duration.zero;
      if (videoDuration.inSeconds > 0) {
        final postRollPosition = (videoDuration.inSeconds * 0.9).round();
        allBreaks.add(Duration(seconds: postRollPosition));
      }
    }

    // Remove duplicates and sort by time
    final uniqueBreaks = allBreaks.toSet().toList();
    uniqueBreaks.sort((a, b) => a.inSeconds.compareTo(b.inSeconds));

    return (videoModel.value.isPurchased || isFromDownloads?.value == true || isTrailer.value == true) ? [] : uniqueBreaks;
  }

  GlobalKey<YPlayerWidgetState> yPlayerWidgetKey = GlobalKey<YPlayerWidgetState>();

  Rx<Duration?> lastYoutubePositionBeforeAd = Rx<Duration?>(null);

  final VoidCallback? onWatchNextEpisode;

  VideoPlayersController({
    required this.videoModel,
    required this.liveShowModel,
    required this.isTrailer,
    required this.onWatchNextEpisode,
    this.isFromDownloads,
  });

  @override
  Future<void> onInit() async {
    if (!kDebugMode) {
      await secureScreen();
    }
    super.onInit();
    isBuffering(true);
    // Initialize adPlayer and adVideoController
    adPlayer = Player();
    adVideoController = VideoController(adPlayer);
    _setupDynamicAds().then(
      (value) {
        isBuffering(false);
        initializePlayer().whenComplete(
          () => hasShownCustomAd(videoModel.value.isPurchased),
        );
      },
    ).onError(
      (error, stackTrace) {
        isBuffering(false);
      },
    );

    WakelockPlus.enable();   
    onChangePodVideo();
    onUpdateSubtitle();
    onUpdateQualities();
    onPauseVideo();
  }

  Future<void> _setupDynamicAds() async {
    if (videoModel.value.isPurchased) return;
    if (isFromDownloads?.value == true) return;
    if (videoModel.value.videoUploadType == PlayerTypes.vimeo) return;

    final dashboardController = Get.find<DashboardController>();
    final allVastAds = dashboardController.vastAds;
    final applicableAds = _getApplicableVastAdsForContent(
      contentType: videoModel.value.type,
      contentId: videoModel.value.id,
      allAds: allVastAds,
    );
    final grouped = _groupVastAdsByType(applicableAds);

    preRollAds = await _mapVastAdsToAdConfigs(grouped['pre-roll'] ?? []);
    midRollAds = await _mapVastAdsToAdConfigs(grouped['mid-roll'] ?? []);
    postRollAds = await _mapVastAdsToAdConfigs(grouped['post-roll'] ?? []);
    overlayAds.value = await _mapVastAdsToOverlayAds(grouped['overlay'] ?? []);
    if ((grouped['mid-roll'] ?? []).isNotEmpty) {
      adFrequency = 1;
    }
  }

  Future<List<AdConfig>> _mapVastAdsToAdConfigs(List<VastAd> ads) async {
    final List<AdConfig> result = [];
    for (final ad in ads) {
      if ((ad.url ?? '').toLowerCase().endsWith('.xml')) {
        final vastMedia = await fetchVastMedia(ad.url!);
        if (vastMedia != null && vastMedia.mediaUrls.isNotEmpty) {
          final skipSeconds = vastMedia.skipDuration ?? (parseDurationToSeconds(ad.skipAfter) == 0 ? 5 : parseDurationToSeconds(ad.skipAfter));
          final lastIndex = vastMedia.mediaUrls.length - 1;
          for (int i = 0; i < vastMedia.mediaUrls.length; i++) {
            result.add(
              AdConfig(
                url: vastMedia.mediaUrls[i],
                isSkippable: i == lastIndex && skipSeconds > 0,
                skipAfterSeconds: skipSeconds,
                clickThroughUrl: (i < vastMedia.clickThroughUrls.length) ? vastMedia.clickThroughUrls[i] : null,
              ),
            );
          }
        }
      } else {
        result.add(_adConfigFromVastAd(ad));
      }
    }
    return result;
  }

  Future<List<OverlayAd>> _mapVastAdsToOverlayAds(List<VastAd> ads) async {
    final List<OverlayAd> result = [];
    for (final ad in ads) {
      if ((ad.url ?? '').toLowerCase().endsWith('.xml')) {
        final vastMedia = await fetchVastMedia(ad.url!);
        if (vastMedia != null) {
          result.addAll(overlayAds);
        }
      } else {
        result.add(_overlayAdFromVastAd(ad));
      }
    }
    return result;
  }

  List<VastAd> _getApplicableVastAdsForContent({
    required String contentType,
    required int contentId,
    required List<VastAd> allAds,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allAds.where((ad) {
      String normalizedContentType = contentType.toLowerCase();
      if (normalizedContentType == 'episode') {
        normalizedContentType = 'tvshow';
      }
      if ((ad.targetType ?? '').toLowerCase() != normalizedContentType) return false;
      if (ad.targetSelection == null) return false;
      final cleaned = ad.targetSelection!.replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
      final ids = cleaned.split(',').toSet();
      if (!ids.contains(contentId.toString())) return false;
      // Handle startDate
      if (ad.startDate != null) {
        final adStartDate = ad.startDate!;
        final adStartDay = DateTime(adStartDate.year, adStartDate.month, adStartDate.day);
        if (adStartDay.isAfter(today)) return false;
      }

      // Handle endDate
      if (ad.endDate != null) {
        final adEndDate = ad.endDate!;
        final adEndDay = DateTime(adEndDate.year, adEndDate.month, adEndDate.day);
        if (adEndDay.isBefore(today)) return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<VastAd>> _groupVastAdsByType(List<VastAd> ads) {
    final map = <String, List<VastAd>>{};
    for (final ad in ads) {
      final type = ad.type?.toLowerCase() ?? '';
      map.putIfAbsent(type, () => []).add(ad);
    }
    return map;
  }

  AdConfig _adConfigFromVastAd(VastAd ad) {
    return AdConfig(
      url: ad.url ?? '',
      isSkippable: ad.enableSkip ?? false,
      skipAfterSeconds: (parseDurationToSeconds(ad.skipAfter) == 0 ? 5 : parseDurationToSeconds(ad.skipAfter)),
    );
  }

  OverlayAd _overlayAdFromVastAd(VastAd ad) {
    return OverlayAd(
      imageUrl: ad.url ?? '',
      startTime: int.tryParse(ad.duration ?? '0') ?? 0,
      duration: ad.frequency ?? 10,
    );
  }

  void calculateMidRollTimes(Duration duration) {
    midRollAdSeconds.clear();
    final int totalDurationInSeconds = duration.inSeconds;

    for (int i = 1; i <= adFrequency; i++) {
      midRollAdSeconds.add((totalDurationInSeconds * i / (adFrequency + 1)).round());
    }
  }

  Future<void> playAd(AdConfig adConfig) async {
    if (isAdPlaying.value) return;

    final completer = Completer<void>();
    _currentAdCompleter = completer;
    late StreamSubscription sub;
    try {
      isAdPlaying(true);
      isCurrentAdSkippable.value = adConfig.isSkippable;

      // Pause main content (Pod or YouTube)
      if (podPlayerController.value.isInitialised) {
        podPlayerController.value.pause();
      }
      if (youtubePlayerController.value.isInitialized) {
        lastYoutubePositionBeforeAd(youtubePlayerController.value.player.state.position);
        youtubePlayerController.value.player.pause();
      }

      // Play ad
      await adPlayer.open(Media(adConfig.url));
      await adPlayer.play();

      // Start skip timer
      if (adConfig.isSkippable) {
        adSkipTimer(adConfig.skipAfterSeconds);

        adSkipTimerController = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (adSkipTimer.value > 0) {
            if (adPlayer.state.playing) {
              adSkipTimer.value--;
            }
          } else {
            timer.cancel();
          }
        });
      }

      // Listen for ad completion
      sub = adPlayer.stream.completed.listen((completed) async {
        if (completed) {
          await skipAd();
          if (!completer.isCompleted) completer.complete();
          await sub.cancel();
        }
      });

      // Optionally, if you have a manual skip (e.g., user presses skip button),
      // you should also complete the completer there.
    } catch (e) {
      log("Error playing ad: $e");
      await skipAd();
      if (!completer.isCompleted) completer.complete();
      try {
        await sub.cancel();
      } catch (_) {}
    }

    // Wait for the ad to finish
    await completer.future;
  }

  Future<void> skipAd() async {
    try {
      adSkipTimerController?.cancel();
      await adPlayer.stop();
      isAdPlaying(false);

      // Complete the ad's completer if it exists and is not completed
      if (_currentAdCompleter != null && !_currentAdCompleter!.isCompleted) {
        _currentAdCompleter!.complete();
      }

      // Resume main content (Pod or YouTube)
      if (podPlayerController.value.isInitialised) {
        podPlayerController.value.play();
      }
      if (youtubePlayerController.value.isInitialized) {
        if (lastYoutubePositionBeforeAd.value != null) {
          youtubePlayerController.value.player.seek(lastYoutubePositionBeforeAd.value ?? Duration.zero);
        }
        youtubePlayerController.value.player.play();
        lastYoutubePositionBeforeAd.value = null;
      }
    } catch (e) {
      log("Error skipping ad: $e");
    }
  }

  Future<void> playVastAd(String vastUrl) async {
    preRollAds.clear();
    final vastMedia = await fetchVastMedia(vastUrl);
    if (vastMedia != null) {
      for (int i = 0; i < vastMedia.mediaUrls.length; i++) {
        final isLastVideo = i == vastMedia.mediaUrls.length - 1;
        preRollAds.add(
          AdConfig(
            url: vastMedia.mediaUrls[i],
            isSkippable: isLastVideo,
            skipAfterSeconds: isLastVideo ? 5 : 0,
            clickThroughUrl: (i < vastMedia.clickThroughUrls.length) ? vastMedia.clickThroughUrls[i] : null,
          ),
        );
      }
    } else {
      log('No valid media file found in VAST');
    }
  }

  Future<VastMedia?> fetchVastMedia(String vastUrl) async {
    try {
      final response = await http.get(Uri.parse(vastUrl));

      if (response.statusCode != 200) return null;

      // Clean up malformed XML
      final String xmlString = response.body.replaceAll('<IconClicks>', '<Iconclicks>').replaceAll('</IconClicks>', '</Iconclicks>');

      final document = xml.XmlDocument.parse(xmlString);

      final mediaUrls = document.findAllElements('MediaFile').where((e) => e.getAttribute('type') == 'video/mp4').map((e) => e.innerText.trim()).toList();

      final clickThroughUrls = document.findAllElements('ClickThrough').map((e) => e.innerText.trim()).toList();

      final clickTrackingUrls = document.findAllElements('ClickTracking').map((e) => e.innerText.trim()).toList();

      // Parse skip duration from <Linear skipoffset="..."> if available
      int? vastSkipDuration;
      final Iterable<XmlElement> linearElements = document.findAllElements('Linear').where(
            (e) => e.getAttribute('skipoffset') != null,
          );
      final XmlElement? linear = linearElements.isNotEmpty ? linearElements.first : null;
      final skipOffset = linear?.getAttribute('skipoffset');
      if (skipOffset != null) {
        // Format can be HH:MM:SS or seconds
        final parts = skipOffset.split(':');
        if (parts.length == 3) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final s = int.tryParse(parts[2]) ?? 0;
          vastSkipDuration = h * 3600 + m * 60 + s;
        } else if (parts.length == 1) {
          vastSkipDuration = int.tryParse(skipOffset);
        }
      }

      // Clear and parse overlay ads
      overlayAds.clear();

      for (final creative in document.findAllElements('Creative')) {
        for (final nonLinear in creative.findAllElements('NonLinear')) {
          final staticResource = nonLinear.findElements('StaticResource').map((e) => e.innerText.trim()).firstWhere((e) => e.isNotEmpty, orElse: () => '');

          if (staticResource.isEmpty) continue;

          final clickThrough = nonLinear.findElements('NonLinearClickThrough').map((e) => e.innerText.trim()).firstWhere((e) => e.isNotEmpty, orElse: () => '');

          final minSuggestedDuration = nonLinear.getAttribute('minSuggestedDuration') ?? '00:00:05';

          int duration = 10;
          final parts = minSuggestedDuration.split(':');
          if (parts.length == 3) {
            final h = int.tryParse(parts[0]) ?? 0;
            final m = int.tryParse(parts[1]) ?? 0;
            final s = int.tryParse(parts[2]) ?? 0;
            duration = h * 3600 + m * 60 + s;
          }

          overlayAds.add(
            OverlayAd(
              imageUrl: staticResource,
              clickThroughUrl: clickThrough,
              startTime: 10,
              duration: duration,
            ),
          );
        }
      }

      // Determine final skip duration: VAST > custom > default 5
      final skipDuration = vastSkipDuration;

      return VastMedia(
        mediaUrls: mediaUrls,
        clickThroughUrls: clickThroughUrls,
        clickTrackingUrls: clickTrackingUrls,
        skipDuration: skipDuration,
      );
    } catch (e, st) {
      log('VAST parsing error: $e\n$st');
      return null;
    }
  }

  Future<void> initializePlayer({String videoURL = '', String videoType = ''}) async {
    log("Video Model in Controller ==> ${videoModel.value.toJson()}");
    log("Watched Duration ==> ${videoModel.value.watchedTime}");
    log('Live Show data =>> ${liveShowModel.toJson()}');

    if ((videoModel.value.type == VideoType.video || videoModel.value.type == VideoType.liveTv) || isAlreadyStartedWatching(videoModel.value.watchedTime)) {
      isTrailer(false);
    }

    yPlayerWidgetKey = GlobalKey<YPlayerWidgetState>();
    if (!isTrailer.value && preRollAds.isNotEmpty) {
      for (int i = 0; i < preRollAds.length; i++) {
        await playAd(preRollAds[i]);
      }
    }
    isPostRollAdShown.value = false;
    shownMidRollAds.clear();
    shownOverlayAds.clear();
    final (String, String) videoLinkType = getVideoLinkAndType();
    if (videoURL.isNotEmpty && videoType.isNotEmpty) {
      videoUploadType(videoType);
      videoUrlInput(videoURL);
    } else {
      videoUploadType(videoLinkType.$1);
      videoUrlInput(videoLinkType.$2);
    }

    if (videoUploadType.value.toLowerCase() == PlayerTypes.youtube.toLowerCase()) {
      if (videoModel.value.watchedTime.isNotEmpty) {
        try {
          final seekPosition = _parseWatchedTime(videoModel.value.watchedTime);
          if (youtubePlayerController.value.isInitialized) {
            youtubePlayerController.value.player.seek(seekPosition);
          }
        } catch (e) {
          log("Error parsing continueWatchDuration: $e");
        }
      }
    } else if (videoUploadType.value.toLowerCase() == PlayerTypes.embedded.toLowerCase() || videoUploadType.value.toLowerCase() == PlayerTypes.vimeo) {
      String url = videoLinkType.$2;
      if (videoUploadType.value.toLowerCase() == PlayerTypes.vimeo.toLowerCase()) {
        url = "https://player.vimeo.com/video/${url.split("/").last}";
        initializeWebViewPlayer(url);
      } else if (videoUploadType.value.toLowerCase() == PlayerTypes.embedded.toLowerCase()) {
        initializeWebViewPlayer(movieEmbedCode(videoUrlInput.value));
      }
    } else if (videoUploadType.value.toLowerCase() == PlayerTypes.url || videoUploadType.value.toLowerCase() == PlayerTypes.hls || videoUploadType.value.toLowerCase() == PlayerTypes.local || videoUploadType.value.toLowerCase() == PlayerTypes.file) {
      // _initializePodPlayer(videoUrlInput.value);
      if (!podPlayerController.value.isInitialised) {
        uniqueKey = UniqueKey();
        await Future.delayed(Duration.zero);
        _initializePodPlayer(videoUrlInput.value);
      } else {
        log("PodPlayer is already initialized.");
      }
    }
  }

  void initializeWebViewPlayer(String url) {
    playNextVideo(false);
    // Remove any existing video channel listener to avoid duplicates
    removeVideoChannelListener();

    //initialize the WebViewController with the provided URL
    final embedHtml = movieEmbedCode(url);

    webViewController.value = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            isPostRollAdShown.value = false;
            isBuffering(false);
          },
          onWebResourceError: (WebResourceError error) {
            isBuffering(false);
            handleError(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            //launchUrlCustomURL(request.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'VideoChannel',
        onMessageReceived: (message) {
          try {
            final decoded = jsonDecode(message.message);
            if (decoded['event'] == 'timeUpdate') {
              final int current = decoded['currentTime'].toString().toDouble().toInt();
              final int total = decoded['duration'].toString().toDouble().toInt();
              playNextVideo((total - current) < 30 && total > 30);

              final subtitle = availableSubtitleList.firstWhereOrNull((s) => s.start.inSeconds <= current && s.end.inSeconds >= current);
              if (subtitle != null && subtitle.data != currentSubtitle.value) {
                currentSubtitle(subtitle.data);
              } else if (subtitle == null && currentSubtitle.value.isNotEmpty) {
                currentSubtitle('');
              }
            }
          } catch (e) {
            switch (message.message) {
              case 'ready':
                playNextVideo(false);
                break;
              case 'playing':
                isVideoPlaying(true);
                break;
              case 'paused':
                isVideoPlaying(false);
                break;
              case 'ended':
                isVideoCompleted(true);
                if (!isTrailer.value && !isPostRollAdShown.value && postRollAds.isNotEmpty) {
                  isPostRollAdShown.value = true;
                  playAd(postRollAds[postRollAds.length - 1]);
                }
                isPostRollAdShown.value = false;
                shownMidRollAds.clear();
                break;
              case 'entered_fullscreen':
                isPipEnable(true);
                setOrientationLandscape();
                break;
              case 'exited_fullscreen':
                isPipEnable(false);
                setOrientationPortrait();
                break;
            }
          }
        },
      );
    if (videoUploadType.value.toLowerCase() == PlayerTypes.vimeo.toLowerCase()) {
      webViewController.value.loadRequest(
        Uri.parse(url),
        headers: {
          'referer': DOMAIN_URL,
        },
      );
    } else {
      webViewController.value.loadHtmlString(embedHtml, baseUrl: DOMAIN_URL);
    }
  }

  /// Quick scheme/host check. (Uri.hasAbsolutePath alone is not enough.)
  bool _isAbsoluteUrl(String input) {
    final uri = Uri.tryParse(input);
    return uri?.hasScheme == true && (uri?.host.isNotEmpty ?? false);
  }

  String movieEmbedCode(String iframeHtml, {bool autoplay = false}) {
    final cleanedHtml = iframeHtml.replaceAll('”', '"').replaceAll('“', '"').replaceAll("’", "'");

    final uriRegex = RegExp('src="([^"]+)"');

    final match = uriRegex.firstMatch(cleanedHtml);

    if (match == null) {
      if (_isAbsoluteUrl(cleanedHtml)) {
        return buildGenericIframeWrapper(cleanedHtml);
      } else {
        return buildHtmlCodeForWebViewPlay(cleanedHtml);
      }
    }

    final String url = match.group(1)!;

    final isYouTube = url.contains("youtube.com");

    if (!isYouTube) {
      if (!_isAbsoluteUrl(url)) {
        return buildHtmlCodeForWebViewPlay(cleanedHtml);
      } else {
        return buildGenericIframeWrapper(url);
      }
    }

    // Append enablejsapi=1 to allow JavaScript control
    final Uri uri = Uri.parse(url);
    final Map<String, String> params = Map.from(uri.queryParameters);
    params['enablejsapi'] = '1';
    params['autoplay'] = autoplay ? '1' : '0';
    params['mute'] = autoplay ? '1' : '0';

    final newUri = uri.replace(queryParameters: params);

    return '''
    <!DOCTYPE html>
    <html>
      <body style="margin:0; overflow:hidden;">
        <iframe id="player" width="100%" height="220px"
          src="$newUri"
          frameborder="0"
          allow="autoplay; encrypted-media"
          allowfullscreen>
        </iframe>

        <script>
          var tag = document.createElement('script');
          tag.src = "https://www.youtube.com/iframe_api";
          var firstScriptTag = document.getElementsByTagName('script')[0];
          firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

          var player;
          var intervalId;

          function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
              events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange
              }
            });
          }

          function onPlayerReady(event) {
            if (window.VideoChannel && VideoChannel.postMessage) {
              VideoChannel.postMessage("ready");
            }
          }

          function onPlayerStateChange(event) {
            if (event.data == YT.PlayerState.PLAYING) {
              VideoChannel.postMessage("playing");

              if (intervalId) clearInterval(intervalId);
              intervalId = setInterval(function() {
                var duration = player.getDuration();
                var currentTime = player.getCurrentTime();

                // Send current time update
                VideoChannel.postMessage(JSON.stringify({
                  event: "timeUpdate",
                  currentTime: currentTime,
                  duration: duration
                }));
              }, 1000);

            } else if (event.data == YT.PlayerState.ENDED) {
              VideoChannel.postMessage("ended");
              if (intervalId) clearInterval(intervalId);

            } else if (event.data == YT.PlayerState.PAUSED) {
              VideoChannel.postMessage("paused");
              if (intervalId) clearInterval(intervalId);
            }
            
            document.addEventListener('fullscreenchange', function () {
             if (document.fullscreenElement) {
               VideoChannel.postMessage("entered_fullscreen");
             } else {
               VideoChannel.postMessage("exited_fullscreen");
             }
            });
          }
      </script>
      </body>
    </html>
    ''';
  }

  String buildGenericIframeWrapper(String url) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      background-color: #000;
    }
    iframe {
      width: 100vw;
      height: 100vh;
      border: none;
    }
  </style>
</head>
<body>

<iframe id="playerFrame" src="$url" allowfullscreen></iframe>

<script>
  function postToFlutter(event) {
    if (window.VideoChannel && VideoChannel.postMessage) {
      VideoChannel.postMessage(event);
    }
  }

  function postTimeUpdate(currentTime, duration) {
    if (window.VideoChannel && VideoChannel.postMessage) {
      VideoChannel.postMessage(JSON.stringify({
        event: "timeUpdate",
        currentTime: currentTime,
        duration: duration
      }));
    }
  }

  // Listen to postMessage from iframe
  window.addEventListener("message", (event) => {
    try {
      const data = typeof event.data === "string" ? JSON.parse(event.data) : event.data;
      if (data.event) {
        // Let Flutter know
        postToFlutter(data.event);
      }
    } catch (e) {
      // Ignore malformed messages
    }
  });

  // Handle fullscreen changes
  document.addEventListener('fullscreenchange', () => {
    if (document.fullscreenElement) {
      postToFlutter("entered_fullscreen");
    } else {
      postToFlutter("exited_fullscreen");
    }
  });

  // Notify Flutter that iframe is loaded
  window.onload = () => {
    postToFlutter("iframe_loaded");
  };
</script>
</body>
</html>
''';

  String buildHtmlCodeForWebViewPlay(String url) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://vjs.zencdn.net/8.9.0/video-js.css" rel="stylesheet" />
  <style>
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      background-color: #000;
    }
    .video-js {
      width: 100vw;
      height: 100vh;
    }
  </style>
</head>
<body>

<video
  id="videoPlayer"
  class="video-js vjs-default-skin"
  controls
  autoplay
  muted
  playsinline
  data-setup='{"autoplay": true, "muted": true}'
>
  <source src="$url" type="video/mp4" />
</video>

<script src="https://vjs.zencdn.net/8.9.0/video.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const player = videojs('videoPlayer');

    if (window.VideoChannel && VideoChannel.postMessage) {
      VideoChannel.postMessage("ready");
    }

    var intervalId;

    player.on('play', function () {
      VideoChannel.postMessage("playing");
      clearInterval(intervalId);
      intervalId = setInterval(function () {
        const current = player.currentTime();
        const duration = player.duration();
        VideoChannel.postMessage(JSON.stringify({
          event: "timeUpdate",
          currentTime: current,
          duration: duration
        }));
      }, 1000);
    });

    player.on('pause', function () {
      VideoChannel.postMessage("paused");
      clearInterval(intervalId);
    });

    player.on('ended', function () {
      VideoChannel.postMessage("ended");
      clearInterval(intervalId);
    });

    // 🔥 Fullscreen detection for native player
    player.on('fullscreenchange', function () {
      if (player.isFullscreen()) {
        VideoChannel.postMessage("entered_fullscreen");
      } else {
        VideoChannel.postMessage("exited_fullscreen");
      }
    });
  });
</script>

</body>
</html>
''';

  Future<void> initializeYoutubePlayer(YPlayerController youtubeController) async {
    youtubePlayerController(youtubeController);
    isBuffering(false);

    // If we have a stored resume position, seek to it and play
    if (lastYoutubePositionBeforeAd.value != null) {
      youtubePlayerController.value.player.seek(lastYoutubePositionBeforeAd.value!);
      youtubePlayerController.value.player.play();
      lastYoutubePositionBeforeAd.value = null;
    }
    listenVideoEvent();
  }

  Future<void> _initializePodPlayer(String url) async {
    isBuffering(true);
    final controller = PodPlayerController(
      podPlayerConfig: PodPlayerConfig(
        autoPlay: isAutoPlay.value,
        wakelockEnabled: false,
        videoQualityPriority: availableQualities,
      ),
      playVideoFrom: getVideoPlatform(type: videoUploadType.value, videoURL: url),
    );
    await controller.initialise().then((_) {
      isBuffering(false);
      isPostRollAdShown.value = false;
      shownMidRollAds.clear();
      shownOverlayAds.clear();
      if (videoModel.value.watchedTime.isNotEmpty) {
        final seekPosition = _parseWatchedTime(videoModel.value.watchedTime);
        controller.videoSeekForward(seekPosition);
      }
    }).catchError((error, stackTrace) {
      isBuffering(false);
      log("Error during initialization: $error");
      log("Stack trace: $stackTrace");
    });
    if (midRollAds.isNotEmpty) {
      calculateMidRollTimes(controller.videoPlayerValue?.duration ?? Duration.zero);
    }

    podPlayerController(controller);
    listenVideoEvent();
  }

  bool isValidSubtitleFormat(String url) {
    return url.endsWith('.srt') || url.endsWith('.vtt');
  }

  Future<void> loadSubtitles(SubtitleModel subtitle) async {
    if (subtitle.subtitleFileURL.isNotEmpty) {
      await pause();
      isSubtitleBuffering(true);
      final rawUrl = subtitle.subtitleFileURL;
      final encodedUrl = Uri.encodeFull(rawUrl);

      if (rawUrl.validateURL() && isValidSubtitleFormat(rawUrl)) {
        final response = await http.get(Uri.parse(encodedUrl));

        if (response.statusCode == 200) {
          String content;

          try {
            content = utf8.decode(response.bodyBytes);
          } catch (e) {
            final filtered = response.bodyBytes.where((b) => b != 0x00).toList();

            try {
              content = utf8.decode(filtered);
            } catch (e2) {
              content = latin1.decode(filtered);
            } finally {
              isSubtitleBuffering(false);
            }
          } finally {
            isSubtitleBuffering(false);
          }

          // Run subtitle parsing in a background isolate
          final controller = await compute(
            (Map<String, dynamic> params) async {
              final provider = StringSubtitle(
                data: params['content'] as String,
                type: params['type'] as SubtitleType,
              );
              final controller = SubtitleController(provider: provider);
              await controller.initial();
              return controller;
            },
            {
              'content': content,
              'type': getSubtitleFormat(rawUrl),
            },
          );

          availableSubtitleList.clear();
          availableSubtitleList(controller.subtitles);
          selectedSubtitleModel(subtitle);

          if (youtubePlayerController.value.isInitialized) {
            await updateCurrentSubtitle(youtubePlayerController.value.position + const Duration(seconds: 1));
            youtubePlayerController.value.play();
          } else if (podPlayerController.value.isInitialised) {
            await updateCurrentSubtitle(podPlayerController.value.currentVideoPosition + const Duration(seconds: 1));
            podPlayerController.value.play();
          }
        } else {
          throw Exception('Subtitle file not found: HTTP ${response.statusCode}');
        }
      } else {
        throw Exception('Invalid subtitle URL or unsupported format');
      }
    } else {
      availableSubtitleList.clear();
      selectedSubtitleModel(SubtitleModel());
      currentSubtitle('');
      if (youtubePlayerController.value.isInitialized) {
        youtubePlayerController.value.play();
      } else if (podPlayerController.value.isInitialised) {
        podPlayerController.value.play();
      }

      isSubtitleBuffering(false);
    }
  }

  Future<void> updateCurrentSubtitle(Duration position) async {
    if (availableSubtitleList.isNotEmpty) {
      final subtitle = availableSubtitleList.firstWhereOrNull((s) => s.start <= position && s.end >= position);
      if (subtitle != null && subtitle.data != currentSubtitle.value) {
        currentSubtitle(subtitle.data);
      } else if (subtitle == null && currentSubtitle.value.isNotEmpty) {
        currentSubtitle('');
      }
    }
  }

  SubtitleType getSubtitleFormat(String url) {
    if (url.endsWith('.srt')) return SubtitleType.srt;
    if (url.endsWith('.vtt')) return SubtitleType.vtt;
    return SubtitleType.custom;
  }

  Future<void> pause() async {
    if (podPlayerController.value.isInitialised) {
      podPlayerController.value.pause();
    } else if (youtubePlayerController.value.status == YPlayerStatus.playing) {
      youtubePlayerController.value.pause();
    }
  }

  Duration _parseWatchedTime(String watchedTime) {
    final parts = watchedTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  (String, String) getVideoLinkAndType() {
    if (isTrailer.isTrue) {
      return (videoModel.value.trailerUrlType, videoModel.value.trailerUrl);
    } else if (videoModel.value.type == VideoType.liveTv) {
      if (liveShowModel.streamType == PlayerTypes.embedded) {
        return (liveShowModel.streamType, liveShowModel.embedUrl);
      }
      return (liveShowModel.streamType, liveShowModel.serverUrl);
    } else if (videoModel.value.videoUploadType.toLowerCase() == PlayerTypes.embedded.toLowerCase()) {
      return (videoModel.value.videoUploadType, videoModel.value.videoUrlInput);
    } else {
      return (videoModel.value.videoUploadType.trim().isEmpty && videoModel.value.videoUrlInput.trim().isEmpty ? (videoUploadType.value, videoUrlInput.value) : (videoModel.value.videoUploadType, videoModel.value.videoUrlInput));
    }
  }

  void checkIfVideoEnded() {
    if (podPlayerController.value.videoPlayerValue != null) {
      final position = podPlayerController.value.videoPlayerValue!.position;
      final duration = podPlayerController.value.videoPlayerValue!.duration;
      if (podPlayerController.value.isInitialised) {
        final subtitle = availableSubtitleList.firstWhereOrNull((s) => s.start <= position && s.end >= position);
        if (subtitle != null && subtitle.data != currentSubtitle.value) {
          currentSubtitle(subtitle.data);
        } else if (subtitle == null && currentSubtitle.isNotEmpty) {
          currentSubtitle('');
        }
      }

      final remaining = duration - position;
      final threshold = duration.inSeconds * 0.20;
      playNextVideo(remaining.inSeconds <= threshold);

      if (podPlayerController.value.videoPlayerValue?.isCompleted ?? false) {
        storeViewCompleted();
        podPlayerController.value.pause();

        // initializePlayer(videoModel.value.videoUrlInput, videoModel.value.videoUploadType);
      }
    }
  }

  Future<void> storeViewCompleted() async {
    final Map<String, dynamic> request = {
      "entertainment_id": videoModel.value.id,
      "user_id": loginUserData.value.id,
      "entertainment_type": getVideoType(type: videoModel.value.type),
      if (profileId.value != 0) "profile_id": profileId.value,
    };

    await CoreServiceApis().saveViewCompleted(request: request);
  }

  void listenVideoEvent() {
    if (youtubePlayerController.value.isInitialized) {
      isVideoPlaying(youtubePlayerController.value.status == YPlayerStatus.playing);
      bool midRollCalculated = false;
      youtubePlayerController.value.statusNotifier.addListener(
        () {
          if (youtubePlayerController.value.status == YPlayerStatus.stopped) {
            storeViewCompleted();
            // isPostRollAdShown.value = false;
            shownMidRollAds.clear();
            shownOverlayAds.clear();
          }
        },
      );
      youtubePlayerController.value.player.stream.position.listen((event) {
        final position = event.inSeconds;
        final duration = youtubePlayerController.value.duration.inSeconds;

        final midRollDuration = youtubePlayerController.value.duration;

        if (!isTrailer.value) {
          if (!midRollCalculated && midRollDuration.inSeconds > 0) {
            midRollCalculated = true;
            calculateMidRollTimes(midRollDuration);
          }

          // Overlay ad logic
          if (overlayAds.isNotEmpty && !isAdPlaying.value) {
            for (final ad in overlayAds) {
              if (position == ad.startTime && currentOverlayAd.value == null && !shownOverlayAds.contains(ad.startTime)) {
                currentOverlayAd.value = ad;
                shownOverlayAds.add(ad.startTime);
                overlayAdTimer?.cancel();
                overlayAdTimer = Timer(Duration(seconds: ad.duration), () {
                  currentOverlayAd.value = null;
                });
                break;
              }
            }
          }
          // Detect seek forward
          if (position > lastPlaybackPosition.value + 1) {
            // if (overlayAds.isEmpty) {
            final skippedAds = midRollAdSeconds.where((adPos) => adPos > lastPlaybackPosition.value && adPos <= position && !shownMidRollAds.contains(adPos)).toList();
            if (skippedAds.isNotEmpty && !isAdPlaying.value && midRollAds.isNotEmpty) {
              shownMidRollAds.addAll(skippedAds);
              playAd(midRollAds[midRollAds.length - 1]);
            }
            // }
          }
          lastPlaybackPosition(position);
          // Mid-roll ads
          if (position > 0 && midRollAdSeconds.contains(position) && !isAdPlaying.value && !shownMidRollAds.contains(position)) {
            shownMidRollAds.add(position);
            playAd(midRollAds[midRollAds.length - 1]);
          }
          // Post-roll ad at 90% of video duration
          if (duration > 0 && position >= (duration * 0.9).round() && !isAdPlaying.value && !isPostRollAdShown.value) {
            isPostRollAdShown.value = true;
            playAd(postRollAds[postRollAds.length - 1]);
          }
        } else {
          lastPlaybackPosition(position);
        }
      });
    } else {
      if (podPlayerController.value.isInitialised) {
        isVideoPlaying(podPlayerController.value.videoPlayerValue?.isPlaying ?? false);
      }
      podPlayerController.value.addListener(() {
        isBuffering(podPlayerController.value.isVideoBuffering);
        isVideoPlaying(podPlayerController.value.isVideoPlaying);
        final value = podPlayerController.value;
        final position = value.videoPlayerValue?.position.inSeconds ?? 0;
        final duration = value.videoPlayerValue?.duration.inSeconds ?? 0;

        if (!isTrailer.value) {
          // Overlay ad logic
          if (overlayAds.isNotEmpty && !isAdPlaying.value) {
            for (final ad in overlayAds) {
              if (position == ad.startTime && currentOverlayAd.value == null && !shownOverlayAds.contains(ad.startTime)) {
                currentOverlayAd.value = ad;
                shownOverlayAds.add(ad.startTime);
                overlayAdTimer?.cancel();
                overlayAdTimer = Timer(Duration(seconds: ad.duration), () {
                  currentOverlayAd.value = null;
                });
                break;
              }
            }
          }
          // Detect seek forward
          if (position > lastPlaybackPosition.value + 1) {
            // if (overlayAds.isEmpty) {
            final skippedAds = midRollAdSeconds.where((adPos) => adPos > lastPlaybackPosition.value && adPos <= position && !shownMidRollAds.contains(adPos)).toList();
            if (skippedAds.isNotEmpty && !isAdPlaying.value && midRollAds.isNotEmpty) {
              shownMidRollAds.addAll(skippedAds);
              playAd(midRollAds[midRollAds.length - 1]);
              // }
            }
          }
          lastPlaybackPosition(position);
          // Mid-roll ads
          if (midRollAdSeconds.contains(position) && !isAdPlaying.value && !shownMidRollAds.contains(position)) {
            shownMidRollAds.add(position);
            playAd(midRollAds[midRollAds.length - 1]);
          }
          // Post-roll ad at 90% of video duration
          if (duration > 0 && position >= (duration * 0.9).round() && !isAdPlaying.value && !isPostRollAdShown.value && postRollAds.isNotEmpty) {
            isPostRollAdShown.value = true;
            playAd(postRollAds[postRollAds.length - 1]);
          }
        } else {
          lastPlaybackPosition(position);
        }
        checkIfVideoEnded();
      });
    }
  }

  void handleError(String? errorDescription) {
    log("Video Player Error: $errorDescription");
    errorMessage.value = errorDescription ?? 'An unknown error occurred';
  }

  Future<void> changeVideo({
    required String url,
    required String type,
    VideoPlayerModel? newVideoData,
    bool isQualityChange = false,
  }) async {
    // Remove existing video listener to avoid duplicates
    removeVideoChannelListener();
    playNextVideo(false);
    isBuffering(true);
    try {
      if (newVideoData != null) {
        videoModel = newVideoData.obs;
      }

      if (subtitleList.any((element) => element.isDefaultLanguage.getBoolInt())) {
        selectedSubtitleModel(subtitleList.firstWhere((element) => element.isDefaultLanguage.getBoolInt()));
        await loadSubtitles(selectedSubtitleModel.value);
      } else {
        currentSubtitle('');
      }

      videoUploadType(type);
      videoUrlInput(url);

      log('Video URL -- ${videoUrlInput.value}');
      log('Video Type -- ${videoUploadType.value}');

      if (url.isNotEmpty) {
        if (videoUploadType.value.toLowerCase() == PlayerTypes.youtube.toLowerCase()) {
          if (youtubePlayerController.value.isInitialized) {
            youtubePlayerController.value.initialize(url.validate()).then((v) {
              isBuffering(false);
            });

            if (videoModel.value.watchedTime.isNotEmpty) {
              try {
                final currentPlaybackPosition = _parseWatchedTime(videoModel.value.watchedTime);
                youtubePlayerController.value.player.seek(currentPlaybackPosition);
              } catch (e) {
                log("Error parsing continueWatchDuration: $e");
              }
            }

            listenVideoEvent();
          } else {
            initializePlayer(videoType: type, videoURL: url);
          }
        } else if (videoUploadType.value.toLowerCase() == PlayerTypes.embedded.toLowerCase() || videoUploadType.value.toLowerCase() == PlayerTypes.vimeo.toLowerCase()) {
          initializeWebViewPlayer(url);
        } else if (videoUploadType.value.toLowerCase() == PlayerTypes.url.toLowerCase() ||
            videoUploadType.value.toLowerCase() == PlayerTypes.hls.toLowerCase() ||
            videoUploadType.value.toLowerCase() == PlayerTypes.local.toLowerCase() ||
            videoUploadType.value.toLowerCase() == PlayerTypes.file.toLowerCase()) {
          if (podPlayerController.value.isInitialised) {
            await podPlayerController.value.changeVideo(playVideoFrom: getVideoPlatform(type: type, videoURL: url)).then((v) {
              isBuffering(false);
            });

            if (videoModel.value.watchedTime.isNotEmpty) {
              try {
                final currentPlaybackPosition = _parseWatchedTime(videoModel.value.watchedTime);
                podPlayerController.value.videoSeekForward(currentPlaybackPosition);
              } catch (e) {
                log("Error parsing continueWatchDuration: $e");
              }
            }
            listenVideoEvent();
          } else {
            initializePlayer(videoURL: url, videoType: type);
          }
        }
      }

      isBuffering(false);
    } catch (e) {
      isBuffering(false);
      log("Error changing video: $e");
    }
  }

  /// Returns the correct video platform configuration for playback
  PlayVideoFrom getVideoPlatform({
    required String type,
    required String videoURL,
  }) {
    switch (type) {
      case URLType.youtube:
        return PlayVideoFrom.youtube(
          videoURL,
          httpHeaders: {
            'referer': DOMAIN_URL, // Set the referer header if needed
          },
        ); // Handling YouTube playback
      case URLType.vimeo:
        return PlayVideoFrom.vimeo(
          videoURL,
          httpHeaders: {
            'referer': DOMAIN_URL, // Set the referer header if needed
          },
        ); // Handling Vimeo playback (if required)
      case URLType.hls:
      case URLType.local:
      case URLType.url:
        return PlayVideoFrom.network(
          videoURL,
          httpHeaders: {
            'referer': DOMAIN_URL, // Set the referer header if needed
          },
        );

      case URLType.file:
        return PlayVideoFrom.file(
          File(videoURL),
        );
      default:
        throw ArgumentError('Unknown video platform type: $type');
    }
  }

  bool checkQualitySupported({required String quality, required int requirePlanLevel}) {
    if (requirePlanLevel == 0) return true;

    final currentPlanLimit = currentSubscription.value.planType.firstWhere((element) => element.slug == SubscriptionTitle.downloadStatus || element.limitationSlug == SubscriptionTitle.downloadStatus).limit;

    return _isQualitySupportedForPlan(currentPlanLimit, quality);
  }

  bool _isQualitySupportedForPlan(PlanLimit planLimit, String quality) {
    switch (quality) {
      case "480p":
        return planLimit.four80Pixel.getBoolInt();
      case "720p":
        return planLimit.seven20p.getBoolInt();
      case "1080p":
        return planLimit.one080p.getBoolInt();
      case "1440p":
        return planLimit.oneFourFour0Pixel.getBoolInt();
      case "2K":
        return planLimit.twoKPixel.getBoolInt();
      case "4K":
        return planLimit.fourKPixel.getBoolInt();
      case "8K":
        return planLimit.eightKPixel.getBoolInt();
      default:
        return false;
    }
  }

  void onChangePodVideo() {
    LiveStream().on(changeVideoInPodPlayer, (val) {
      playNextVideo(false);
      currentSubtitle('');
      selectedSubtitleModel(SubtitleModel());
      _handleVideoChange(val);
    });

    LiveStream().on(mOnWatchVideo, (val) {
      playNextVideo(false);
      currentSubtitle('');
      selectedSubtitleModel(SubtitleModel());
      _handleVideoChange(val);
    });
  }

  void onUpdateSubtitle() {
    LiveStream().on(REFRESH_SUBTITLE, (val) async {
      subtitleList.clear();
      if (val is List<SubtitleModel>) {
        if (val.isNotEmpty) {
          subtitleList.assignAll(val);
        }
      }
    });
  }

  void onUpdateQualities() {
    LiveStream().on(onAddVideoQuality, (val) {
      videoQualities.clear();
      if (val is List<VideoLinks>) {
        if (val.isNotEmpty) {
          availableQualities(val.map((link) => link.quality.replaceAll(RegExp('[pPkK]'), '').toInt()).toList());
          videoQualities(val);
        }
      }
    });
  }

  void onPauseVideo() {
    LiveStream().on(podPlayerPauseKey, (val) {
      if (podPlayerController.value.isInitialised) {
        if (podPlayerController.value.videoPlayerValue != null) {
          podPlayerController.value.pause();
        }
      } else if (youtubePlayerController.value.isInitialized) {
        youtubePlayerController.value.pause();
      }
    });
  }

  @override
  Future<void> onClose() async {
    if (!isTrailer.value && videoModel.value.type != VideoType.liveTv) await saveToContinueWatchVideo();
    if (podPlayerController.value.isInitialised) {
      podPlayerController.value.removeListener(() => podPlayerController.value);
      podPlayerController.value.dispose();
    }
    adPlayer.dispose();
    webViewController.close();
    adVideoController.player.dispose();
    youtubePlayerController.value.dispose();

    LiveStream().dispose(podPlayerPauseKey);
    LiveStream().dispose(changeVideoInPodPlayer);
    LiveStream().dispose(mOnWatchVideo);
    canChangeVideo(true);

    WakelockPlus.disable();
    removeVideoChannelListener();
    removeSecureScreen();
    super.onClose();
  }

  void removeVideoChannelListener() {
    try {
      webViewController.value.removeJavaScriptChannel('VideoChannel');
    } catch (e) {
      log("Error removing JavaScript channel: $e");
    }
  }

  void _handleVideoChange(dynamic val) {
    isAutoPlay(false);
    isTrailer(false);

    if ((val as List)[0] != null) {
      changeVideo(
        url: val[0],
        type: val[2],
        newVideoData: val[4],
      );
    }
  }

  Future<void> saveToContinueWatchVideo() async {
    if (videoModel.value.id != -1) {
      String watchedTime = '';
      String totalWatchedTime = '';
      if (videoModel.value.videoUploadType.toLowerCase() == PlayerTypes.youtube) {
        if (youtubePlayerController.value.isInitialized) {
          watchedTime = formatDuration(youtubePlayerController.value.position);
          totalWatchedTime = formatDuration(youtubePlayerController.value.duration);
        }
      } else {
        if (podPlayerController.value.videoPlayerValue != null) {
          watchedTime = formatDuration(podPlayerController.value.videoPlayerValue!.position);
          totalWatchedTime = formatDuration(podPlayerController.value.videoPlayerValue!.duration);
        }
      }

      if (watchedTime.isEmpty || totalWatchedTime.isEmpty) {
        log("No watched time to save");
        return;
      }

      await CoreServiceApis().saveContinueWatch(
        request: {
          "entertainment_id": videoModel.value.watchedTime.isNotEmpty ? videoModel.value.entertainmentId : videoModel.value.id,
          "watched_time": watchedTime,

          ///store actual value of video player there is chance duration might be set different then actual duration of video
          "total_watched_time": totalWatchedTime,
          "entertainment_type": getTypeForContinueWatch(type: videoModel.value.type.toLowerCase()),
          if (profileId.value != 0) "profile_id": profileId.value,
          if (getTypeForContinueWatch(type: videoModel.value.type.toLowerCase()) == VideoType.tvshow) "episode_id": videoModel.value.episodeId > 0 ? videoModel.value.episodeId : videoModel.value.id,
        },
      ).then((value) {
        final HomeController homeScreenController = Get.find<HomeController>();
        homeScreenController.getDashboardDetail();
        final ProfileController profileController = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

        profileController.getProfileDetail(showLoader: false);
      }).catchError((e) {
        log("Error ==> $e");
      });
    }
  }

  String getTypeForContinueWatch({required String type}) {
    final dynamic videoTypeMap = {
      "movie": VideoType.movie,
      "video": VideoType.video,
      "livetv": VideoType.liveTv,
      'tvshow': VideoType.tvshow,
      'episode': VideoType.tvshow,
    };
    return videoTypeMap[type] ?? '';
  }

  Future<void> startDate() async {
    await CoreServiceApis().startDate(
      request: {
        "entertainment_id": videoModel.value.id,
        "entertainment_type": getVideoType(type: videoModel.value.type),
        "user_id": loginUserData.value.id,
        if (profileId.value != 0) "profile_id": profileId.value,
      },
    );
  }

  String formatSecondsToHMS(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  int parseDurationToSeconds(String? duration) {
    if (duration == null || duration.isEmpty) return 0;
    final parts = duration.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.length == 3) {
      // hh:mm:ss
      return parts[0] * 3600 + parts[1] * 60 + parts[2];
    } else if (parts.length == 2) {
      // mm:ss
      return parts[0] * 60 + parts[1];
    } else if (parts.length == 1) {
      // ss
      return parts[0];
    }
    return 0;
  }
}
