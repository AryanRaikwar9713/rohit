import 'dart:io';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class FCCast extends GetxController {
  RxBool isSearchingForDevice = false.obs;
  RxBool isCastingVideo = false.obs;
  RxBool isInitialized = false.obs;
  String? videoURL;
  String? contentType;
  String? title;
  String? studio;
  String? subtitle;
  String? thumbnailImage;
  String? releaseDate;
  GoogleCastDevice? device;

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
    
    // Listen to connection state changes
    GoogleCastSessionManager.instance.currentSessionStream.listen((session) {
      if (session != null) {
        log("🎬 Session state changed: ${GoogleCastSessionManager.instance.connectionState}");
        if (GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected) {
          log("✅ Successfully connected to cast device");
        } else if (GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.disconnected) {
          log("❌ Disconnected from cast device");
          isCastingVideo(false);
        }
      }
    }).onError((e) {
      log('Error During Session Stream -- $e');
    });
  }

  void setChromeCast({
    required String videoURL,
    String? contentType,
    String? title,
    String? subtitle,
    String? studio,
    String? thumbnailImage,
    String? releaseDate,
    required GoogleCastDevice device,
  }) {
    this.videoURL = videoURL;
    this.contentType = contentType ?? 'video/mp4'; // Default to mp4 if not provided
    this.title = title.validate();
    this.subtitle = subtitle.validate();
    this.studio = studio.validate();
    this.thumbnailImage = thumbnailImage.validate();
    this.device = device;
    this.releaseDate = releaseDate;

    log("🎬 Chrome Cast configured:");
    log("   Video URL: $videoURL");
    log("   Content Type: $contentType");
    log("   Title: $title");
    log("   Device: ${device.friendlyName}");
  }

  Future<void> initPlatformState() async {
    try {
      const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
      GoogleCastOptions? options;
      
      if (Platform.isIOS) {
        options = IOSGoogleCastOptions(
          GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
        );
      } else if (Platform.isAndroid) {
        options = GoogleCastOptionsAndroid(
          appId: appId,
        );
      }
      
      if (options != null) {
        await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
        isInitialized(true);
        log("✅ Chrome Cast initialized successfully");
      } else {
        log("❌ Failed to create Chrome Cast options for platform");
      }
      // Check initial discovery state for iOS
      if (Platform.isIOS) {
        try {
          await GoogleCastDiscoveryManager.instance.isDiscoveryActiveForDeviceCategory(appId);
        } catch (e) {
          log('❌Error checking discovery state: $e');
        }
      }
    } catch (e) {
      log("❌ Error initializing Chrome Cast: $e");
      isInitialized(false);
    }
   
  }

  Future<void> stopDiscovery() async {
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
      isSearchingForDevice(false);
      log("============== Stop discovery ===================");
    } catch (e) {
      log("❌ Error stopping discovery: $e");
    }
  }

  Future<void> startDiscovery() async {
    if (!isInitialized.value) {
      log("⚠️ Chrome Cast not initialized. Initializing now...");
      await initPlatformState();
    }

    try {
      log("============== Start discovery ===================");
      await GoogleCastDiscoveryManager.instance.startDiscovery();
      isSearchingForDevice(true);
      Future.delayed(const Duration(seconds: 10), () => isSearchingForDevice(false));
    } catch (e) {
      log("❌ Error starting discovery: $e");
      isSearchingForDevice(false);
    }
  }

  Future<void> loadMedia() async {
    if (device == null) {
      log("❌ No device selected for casting");
      toast("Please select a casting device first");
      return;
    }

    if (videoURL == null || videoURL!.isEmpty) {
      log("❌ No video URL provided for casting");
      toast("No video URL available for casting");
      return;
    }

    if (contentType == null || contentType!.isEmpty) {
      log("❌ No content type provided for casting");
      toast("Content type not available for casting");
      return;
    }

    // Validate video URL format
    try {
      Uri.parse(videoURL!);
    } catch (e) {
      log("❌ Invalid video URL format: $videoURL");
      toast("Invalid video URL format");
      return;
    }

    try {
      // Debug casting information
      debugCastingInfo();

      DateTime? parsedReleaseDate;
      if (releaseDate.validate().isNotEmpty) {
        try {
          parsedReleaseDate = DateTime.tryParse(releaseDate!);
          if (parsedReleaseDate == null) {
            log("⚠️ Failed to parse releaseDate: $releaseDate, using current date");
            parsedReleaseDate = DateTime.now();
          }
        } catch (e) {
          log("⚠️ Exception while parsing releaseDate: $e, using current date");
          parsedReleaseDate = DateTime.now();
        }
      } else {
        parsedReleaseDate = DateTime.now();
      }

      // Create metadata with proper null handling
      GoogleCastMovieMediaMetadata? metadata;
      try {
        metadata = GoogleCastMovieMediaMetadata(
          title: title?.isNotEmpty == true ? title : "Unknown Title",
          studio: studio?.isNotEmpty == true ? studio : "Unknown Studio",
          subtitle: subtitle?.isNotEmpty == true ? subtitle : "",
          releaseDate: parsedReleaseDate,
          images: thumbnailImage?.isNotEmpty == true ? [GoogleCastImage(url: Uri.parse(thumbnailImage!))] : [],
        );
        log("✅ Metadata created successfully");
      } catch (e) {
        log("⚠️ Error creating metadata: $e, using minimal metadata");
        metadata = GoogleCastMovieMediaMetadata(
          title: "Video",
          studio: "Unknown",
          subtitle: "",
          releaseDate: DateTime.now(),
          images: [],
        );
      }

      // Try to create media with metadata first, fallback to basic if needed
      GoogleCastMediaInformation media;
      try {
        media = GoogleCastMediaInformation(
          contentId: videoURL!,
          contentUrl: Uri.parse(videoURL!),
          streamType: CastMediaStreamType.buffered,
          contentType: 'video/mp4',
          metadata: metadata,
          duration: Duration.zero,
        );
        log("✅ Media information created with metadata");
      } catch (e) {
        log("⚠️ Error creating media with metadata: $e, using basic media info");
        media = createBasicMediaInfo();
      }

      log('🎬 Casting media with metadata: ${metadata.title}');

      try {
        log("🎬 Attempting to load media...");
        await GoogleCastRemoteMediaClient.instance.loadMedia(
          media,
        );
        
        log("✅ Media loaded successfully");
      } catch (e) {
        log("❌ Error loading media: $e, trying with minimal parameters");
      }
      
      isCastingVideo(true);
      log("✅ Casting started successfully");
      
    } catch (e) {
      log("❌ Error during casting: $e");
      isCastingVideo(false);
      rethrow;
    }
  }

  Future<void> endSession() async {
    try {
      await GoogleCastSessionManager.instance.endSession();
      isCastingVideo(false);
      log("✅ Cast session ended");
    } catch (e) {
      log("❌ Error ending session: $e");
    }
  }

  void debugCastingInfo() {
    log("🔍 === Casting Debug Info ===");
    log("Video URL: $videoURL");
    log("Content Type: $contentType");
    log("Title: $title");
    log("Studio: $studio");
    log("Subtitle: $subtitle");
    log("Thumbnail: $thumbnailImage");
    log("Release Date: $releaseDate");
    log("Device: ${device?.friendlyName ?? 'None'}");
    log("Connection State: ${GoogleCastSessionManager.instance.connectionState}");
    log("=============================");
  }

  GoogleCastMediaInformation createBasicMediaInfo() {
    return GoogleCastMediaInformation(
      contentId: videoURL!,
      contentUrl: Uri.parse(videoURL!),
      streamType: CastMediaStreamType.buffered,
      contentType: 'video/mp4',
    );
  }

}