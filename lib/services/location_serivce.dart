import 'dart:async';
import 'dart:io';

import 'package:aurora_app/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  // Observables
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool locationPermissionGranted = false.obs;

  // Default location (northern latitudes where aurora might be visible)
  static const double defaultLatitude = 65.0;
  static const double defaultLongitude = 25.0;

  // Configuration
  final Duration locationTimeout = const Duration(seconds: 10);
  final LocationAccuracy desiredAccuracy = LocationAccuracy.lowest;
  
  // Internal state
  bool _isRequestingLocation = false;

  // Initialize the service
  Future<LocationService> init() async {
    logger.i('Initializing LocationService');
    await getUserLocation();
    return this;
  }

  // Get the user's current location
  Future<Position?> getUserLocation() async {
    // If already requesting location, don't start a new request
    if (_isRequestingLocation) {
      logger.i('Location request already in progress');
      return currentPosition.value;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    _isRequestingLocation = true;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Check if location services are enabled
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          errorMessage.value =
              'Location services are disabled. Please enable location services in your device settings.';
          isLoading.value = false;
          locationPermissionGranted.value = false;
          logger.w('Location services are disabled on this device.');

          // Optionally: open location settings (if needed)
          // await Geolocator.openLocationSettings();

          return null;
        }

        // Check location permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          logger.i('Requesting location permission');
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            errorMessage.value = 'Location permissions are denied.';
            isLoading.value = false;
            locationPermissionGranted.value = false;
            logger.w('Location permissions are denied');
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          errorMessage.value = 'Location permissions are permanently denied.';
          isLoading.value = false;
          locationPermissionGranted.value = false;
          logger.w('Location permissions are permanently denied');
          return null;
        }

        // Permissions granted, get position
        locationPermissionGranted.value = true;
        logger.i('Getting current position with timeout: ${locationTimeout.inSeconds}s');
        
        Position? position;
        try {
          // First try with a short timeout
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: desiredAccuracy,
            timeLimit: locationTimeout,
          );
          
          logger.i(
            'Position acquired: lat=${position.latitude}, lng=${position.longitude}, '
            'accuracy=${position.accuracy}m, timestamp=${position.timestamp}',
          );
        } catch (e) {
          logger.w('Could not get current position: $e');
          logger.i('Trying to get last known position instead');
          
          // Fallback to last known position
          position = await getLastKnownPosition();
          
          if (position != null) {
            logger.i('Using last known position: lat=${position.latitude}, lng=${position.longitude}');
          } else {
            logger.w('No last known position available');
          }
        }
        
        if (position != null) {
          // Update the observable position
          currentPosition.value = position;
        }
        
        isLoading.value = false;
        _isRequestingLocation = false;
        return position;
      } else {
        logger.w('Platform not supported for Geolocator');
        errorMessage.value = 'Platform not supported for location services.';
        isLoading.value = false;
        return null;
      }
    } catch (e) {
      logger.e('Error getting user location: $e');
      errorMessage.value = 'Failed to get location: $e';
      isLoading.value = false;
      _isRequestingLocation = false;
      return null;
    }
  }

  // Get the current latitude (with fallback)
  double get latitude => currentPosition.value?.latitude ?? defaultLatitude;

  // Get the current longitude (with fallback)
  double get longitude => currentPosition.value?.longitude ?? defaultLongitude;

  // Check if location is available
  bool get hasLocation => currentPosition.value != null;

  // Get the location as a formatted string
  String get locationString {
    if (currentPosition.value != null) {
      return '${currentPosition.value!.latitude.toStringAsFixed(4)}, '
          '${currentPosition.value!.longitude.toStringAsFixed(4)}';
    }
    return 'Unknown location';
  }

  // Get the last known position even if we can't get a new one
  Future<Position?> getLastKnownPosition() async {
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        logger.i('Using last known position');
        return lastPosition;
      }
      
      // If no last position, try getting one with a very low accuracy
      try {
        logger.i('No last position, trying with lowest accuracy and no timeout');
        final fallbackPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest,
          timeLimit: null, // No timeout
        );
        logger.i('Got fallback position: ${fallbackPosition.latitude}, ${fallbackPosition.longitude}');
        return fallbackPosition;
      } catch (innerE) {
        logger.e('Failed to get fallback position: $innerE');
      }
      
      return null;
    } catch (e) {
      logger.e('Error getting last known position: $e');
      return null;
    }
  }
}
