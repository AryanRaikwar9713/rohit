import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/components/loader_widget.dart';
import 'package:streamit_laravel/utils/cast/controller/fc_cast_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

import '../../main.dart';

class FlutterChromeCastWidget extends StatefulWidget {
  const FlutterChromeCastWidget({super.key});

  @override
  State<FlutterChromeCastWidget> createState() => _FlutterChromeCastWidgetState();
}

class _FlutterChromeCastWidgetState extends State<FlutterChromeCastWidget> {
  final FCCast cast = Get.put(FCCast());
  final RxBool _isLoading = false.obs;
  final RxnString _errorMessage = RxnString();

  @override
  void initState() {
    super.initState();
    if (!cast.isInitialized.value) {
      cast.initPlatformState();
    }
    connectionStream();
  }

  void connectionStream() {
    GoogleCastSessionManager.instance.currentSessionStream.listen(
      (event) {
        if (event?.connectionState == GoogleCastConnectState.connecting || event?.connectionState == GoogleCastConnectState.disconnecting) {
          _isLoading.value = true;
        } else if (event?.connectionState == GoogleCastConnectState.connected || event?.connectionState == GoogleCastConnectState.disconnected) {
          _isLoading.value = false;
        }
      },
    );
  }

  Future<void> _handleConnect(bool isConnected) async {
    _isLoading.value = true;
    _errorMessage.value = null;
    try {
      if (isConnected) {
        await GoogleCastSessionManager.instance.endSessionAndStopCasting();
        _isLoading.value = false;
      } else {
        if (cast.device == null) {
          return;
        }
        await GoogleCastSessionManager.instance.startSessionWithDevice(cast.device!);
        _isLoading.value = false;
      }
    } catch (e) {
      log('Connecting Issue $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handlePlay() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    try {
      await cast.loadMedia();
    } catch (e) {
      log("Failed to play media: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      topBarBgColor: Colors.transparent,
      appBartitleText: locale.value.screenCast,
      body: Stack(
        alignment: Alignment.center,
        children: [
          StreamBuilder<GoogleCastSession?>(
            stream: GoogleCastSessionManager.instance.currentSessionStream,
            builder: (context, snapshot) {
              final bool isConnected = GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected;
              final String deviceName = cast.device?.friendlyName ?? 'Chromecast Device';

              return Obx(() => Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isConnected ? greenColor.withValues(alpha: 0.08) : grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected ? greenColor : grey,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isConnected ? Icons.cast_connected : Icons.cast,
                          size: 60,
                          color: isConnected ? greenColor : grey,
                        ),
                        20.height,
                        Text(
                          isConnected ? "${locale.value.connectTo} $deviceName." : locale.value.readyToCastToYourDevice,
                          style: boldTextStyle(
                            color: isConnected ? greenColor : grey,
                            size: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        8.height,
                        if (!isConnected)
                          Text(
                            locale.value.castConnectInfo,
                            style: secondaryTextStyle(size: 14, color: grey),
                            textAlign: TextAlign.center,
                          ),
                        if (_errorMessage.value != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _errorMessage.value!,
                              style: TextStyle(color: redColor, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        24.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isLoading.value ? null : () => _handleConnect(isConnected),
                              icon: Icon(
                                isConnected ? Icons.link_off : Icons.cast,
                                color: redColor,
                              ),
                              label: Text(
                                isConnected ? locale.value.disconnect : locale.value.connect,
                                style: primaryTextStyle(color: redColor),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: redColor,
                                side: const BorderSide(color: redColor),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ).expand(),
                            if (isConnected && cast.device != null) ...[
                              16.width,
                              OutlinedButton.icon(
                                onPressed: _isLoading.value ? null : _handlePlay,
                                icon: const Icon(Icons.play_arrow),
                                label: Text(
                                  locale.value.playOnTV,
                                  style: primaryTextStyle(color: appColorPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: appColorPrimary,
                                  side: BorderSide(color: appColorPrimary),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ).expand(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ));
            },
          ),
          GoogleCastMiniController(
            theme: GoogleCastPlayerTheme(
              backgroundColor: appScreenBackgroundDark,
              titleTextStyle: boldTextStyle(),
              deviceTextStyle: boldTextStyle(size: 12),
              iconColor: appColorPrimary,
              imageBorderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            showDeviceName: true,
          ),
          Obx(() => _isLoading.value
              ? LoaderWidget(
                  isBlurBackground: true,
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}