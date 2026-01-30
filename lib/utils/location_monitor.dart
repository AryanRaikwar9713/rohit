import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:streamit_laravel/utils/colors.dart';

class LocationMonitor {
  static Timer? _locationCheckTimer;
  static bool _isOverlayShowing = false;
  static OverlayEntry? _overlayEntry;
  static final Logger _logger = Logger();

  /// Start monitoring location service
  static void startMonitoring(BuildContext context) {
    // Stop any existing timer
    stopMonitoring();

    // Check immediately
    _checkLocationService(context);

    // Check every 1 second (more frequent)
    _locationCheckTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkLocationService(context),
    );
  }

  /// Stop monitoring location service
  static void stopMonitoring() {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = null;
    _removeOverlay();
  }

  /// Check location service status
  static Future<void> _checkLocationService(BuildContext context) async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final LocationPermission permission = await Geolocator.checkPermission();

      final bool isLocationEnabled = serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;

      if (!isLocationEnabled) {
        _logger.w('Location service disabled or permission denied');
        if (!_isOverlayShowing) {
          _showLocationBlockingOverlay(context);
        }
      } else {
        // Location is enabled, remove overlay if showing
        if (_isOverlayShowing) {
          _removeOverlay();
        }
      }
    } catch (e) {
      _logger.e('Error checking location service: $e');
    }
  }

  /// Show full-screen blocking overlay when location is disabled
  static void _showLocationBlockingOverlay(BuildContext context) {
    if (_isOverlayShowing || _overlayEntry != null) return;

    _isOverlayShowing = true;
    final OverlayState? overlayState = Overlay.of(context);

    if (overlayState == null) {
      _isOverlayShowing = false;
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _LocationBlockingOverlay(
          onLocationEnabled: () {
            _removeOverlay();
          },
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  /// Remove the blocking overlay
  static void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isOverlayShowing = false;
    }
  }
}

/// Full-screen overlay that blocks app usage when location is off
class _LocationBlockingOverlay extends StatefulWidget {
  final VoidCallback onLocationEnabled;

  const _LocationBlockingOverlay({required this.onLocationEnabled});

  @override
  State<_LocationBlockingOverlay> createState() =>
      _LocationBlockingOverlayState();
}

class _LocationBlockingOverlayState extends State<_LocationBlockingOverlay> {
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    // Check location status every second
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkLocationStatus();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final LocationPermission permission = await Geolocator.checkPermission();

    final bool isLocationEnabled = serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;

    if (isLocationEnabled) {
      widget.onLocationEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Material(
        color: Colors.black.withOpacity(0.9),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.95),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: appColorPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_off,
                        size: 50,
                        color: appColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Location Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Message
                    Text(
                      'Location services must be enabled to use this app.\n\nPlease turn on location services to continue.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Button
                    ElevatedButton(
                      onPressed: () async {
                        // Check if location service is off or permission is denied
                        final bool serviceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        final LocationPermission permission =
                            await Geolocator.checkPermission();

                        if (!serviceEnabled) {
                          // Open location settings
                          await Geolocator.openLocationSettings();
                        } else if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          // Open app settings for permission
                          await Geolocator.openAppSettings();
                        } else {
                          // Request permission
                          await Geolocator.requestPermission();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColorPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Open Location Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper to monitor location on all screens
class LocationMonitorWidget extends StatefulWidget {
  final Widget child;

  const LocationMonitorWidget({super.key, required this.child});

  @override
  State<LocationMonitorWidget> createState() => _LocationMonitorWidgetState();
}

class _LocationMonitorWidgetState extends State<LocationMonitorWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start monitoring when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LocationMonitor.startMonitoring(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationMonitor.stopMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Check location when app resumes
      LocationMonitor.startMonitoring(context);
    } else if (state == AppLifecycleState.paused) {
      // Stop monitoring when app is paused to save resources
      LocationMonitor.stopMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
