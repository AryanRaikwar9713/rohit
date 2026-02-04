import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';

class LocationApi {
  static LocationPermission? _locationPermission;
  static final Logger _logger = Logger();

  Future<bool> handleLocationPermission() async {
    try {
      _logger.d('handleLocationPermission: started');

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        toast("Turn On Location");
        print("Askin for permission");
        final bool d = await Geolocator.openLocationSettings();
        print("loation is done $d");
        toast("Lcoation $d");
      }

      _logger.d('handleLocationPermission: checking permission');
      _locationPermission = await Geolocator.checkPermission();

      if (_locationPermission == LocationPermission.denied) {
        _logger.w('handleLocationPermission: Location permissions are denied');
        _logger.d('handleLocationPermission: requesting permission');
        _locationPermission = await Geolocator.requestPermission();
        if (_locationPermission == LocationPermission.denied) {
          _logger
              .w('handleLocationPermission: Location permissions are denied');
          return false;
        }
      }

      if (_locationPermission == LocationPermission.deniedForever) {
        _logger.w(
            'handleLocationPermission: Location permissions are permanently denied',);
        return false;
      }

      _logger.d(
          'handleLocationPermission: location permission granted: $_locationPermission',);
      return true;
    } catch (e) {
      _logger.e(
          'handleLocationPermission: Error handling location permission: $e',);
      return false;
    }
  }

  Future<Position?> getUserLocation() async {
    try {
      final bool hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission not granted');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _logger
          .d('Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error getting user location: $e');
      return null;
    }
  }

  Future<Placemark?> getUserPlacemark() async {
    try {
      final Position? position = await getUserLocation();
      if (position == null) {
        _logger.w('Could not get user location');
        return null;
      }

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _logger.w('No placemark found for location');
        return null;
      }

      final Placemark placemark = placemarks.first;
      _logger.d('Placemark obtained: $placemark');
      return placemark;
    } catch (e) {
      _logger.e('Error getting user placemark: $e');
      return null;
    }
  }

  Future<Placemark?> getPlacemarkFromLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        _logger.w('No placemark found for location: $latitude, $longitude');
        return null;
      }

      final Placemark placemark = placemarks.first;
      _logger.d('Placemark obtained: $placemark');
      return placemark;
    } catch (e) {
      _logger.e('Error getting placemark from location: $e');
      return null;
    }
  }

  Future<Placemark?> getPlacemarkFromPosition(Position position) async {
    return getPlacemarkFromLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Get user's country name
  Future<String?> getUserCountry() async {
    try {
      final Placemark? placemark = await getUserPlacemark();
      if (placemark != null) {
        _logger.d('Country obtained: ${placemark.country}');
        return placemark.country;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user country: $e');
      return null;
    }
  }

  /// Mandatory location permission check - app cannot proceed without it
  /// Returns true if permission is granted, false otherwise
  /// Shows dialog to open settings if permission is denied forever
  Future<bool> checkMandatoryLocationPermission(BuildContext context) async {
    try {
      _logger.d('checkMandatoryLocationPermission: started');

      // Check if location service is enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location service is disabled');
        // Show dialog to enable location
        await _showLocationRequiredDialog(
          context,
          title: 'Location Required',
          message:
              'Please enable location services to use this app. Location is required to access shop features.',
          isLocationService: true,
        );
        // Wait a bit for user to return from settings
        await Future.delayed(const Duration(milliseconds: 500));
        // Check again after user returns
        final bool serviceEnabledAfter =
            await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabledAfter) {
          return false;
        }
        // Location service is now enabled, continue to check permission
      }

      // Check permission status
      _locationPermission = await Geolocator.checkPermission();

      if (_locationPermission == LocationPermission.denied) {
        _logger.w('Location permission denied, requesting...');
        _locationPermission = await Geolocator.requestPermission();

        if (_locationPermission == LocationPermission.denied) {
          _logger.w('Location permission still denied');
          await _showLocationRequiredDialog(
            context,
            title: 'Location Permission Required',
            message:
                'This app requires location permission to function properly. Please grant location permission to continue.',
            isLocationService: false,
          );
          // Wait a bit after dialog closes
          await Future.delayed(const Duration(milliseconds: 500));
          // Re-check permission after dialog
          _locationPermission = await Geolocator.checkPermission();
          if (_locationPermission == LocationPermission.denied ||
              _locationPermission == LocationPermission.deniedForever) {
            return false;
          }
        }
      }

      if (_locationPermission == LocationPermission.deniedForever) {
        _logger.w('Location permission permanently denied');
        await _showLocationRequiredDialog(
          context,
          title: 'Location Permission Required',
          message:
              'Location permission is required to use this app. Please enable it from app settings.',
          isLocationService: false,
          isPermanentlyDenied: true,
        );
        // Wait a bit after dialog closes
        await Future.delayed(const Duration(milliseconds: 500));
        // Re-check permission after user returns from settings
        _locationPermission = await Geolocator.checkPermission();
        if (_locationPermission == LocationPermission.deniedForever ||
            _locationPermission == LocationPermission.denied) {
          return false;
        }
      }

      _logger.d('Location permission granted: $_locationPermission');
      return true;
    } catch (e) {
      _logger.e('Error checking mandatory location permission: $e');
      return false;
    }
  }

  /// Show dialog to request location permission or open settings
  Future<void> _showLocationRequiredDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isLocationService,
    bool isPermanentlyDenied = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false, // Prevent back button
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (isPermanentlyDenied)
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // Open app settings
                    await Geolocator.openAppSettings();
                    // Wait a bit and check again
                    await Future.delayed(const Duration(seconds: 1));
                    // Re-check permission
                    final permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.deniedForever ||
                        permission == LocationPermission.denied) {
                      // Show dialog again
                      _showLocationRequiredDialog(
                        context,
                        title: title,
                        message: message,
                        isLocationService: isLocationService,
                        isPermanentlyDenied: true,
                      );
                    }
                  },
                  child: const Text('Open Settings'),
                )
              else if (isLocationService)
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await Geolocator.openLocationSettings();
                    // Wait for user to return from settings and enable location
                    await Future.delayed(const Duration(seconds: 2));
                    final serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      // Show dialog again if location still not enabled
                      _showLocationRequiredDialog(
                        context,
                        title: title,
                        message: message,
                        isLocationService: true,
                      );
                    }
                    // If location service is enabled, dialog will close and
                    // checkMandatoryLocationPermission will continue to check permission
                  },
                  child: const Text('Open Location Settings'),
                )
              else
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // Request permission again
                    final permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied ||
                        permission == LocationPermission.deniedForever) {
                      _showLocationRequiredDialog(
                        context,
                        title: title,
                        message: message,
                        isLocationService: false,
                        isPermanentlyDenied:
                            permission == LocationPermission.deniedForever,
                      );
                    }
                  },
                  child: const Text('Grant Permission'),
                ),
            ],
          ),
        );
      },
    );
  }
}
