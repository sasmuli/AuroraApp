import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:aurora_app/logger.dart';

abstract class LocationDataSource {
  Future<LatLng?> fetchCurrentLocation();
  Future<LatLng?> fetchLastKnownLocation();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<LatLng?> fetchCurrentLocation() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w('Permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w('Permission permanently denied');
        return null;
      }

      final pos = await Geolocator.getCurrentPosition();
      logger.i('Fetched location: ${pos.latitude}, ${pos.longitude}');
      return LatLng(pos.latitude, pos.longitude);
    }

    logger.w('Unsupported platform');
    return null;
  }

  //TODO implement reverse geocoding for location name

  @override
  Future<LatLng?> fetchLastKnownLocation() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        return LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      logger.e('Error fetching last known location: $e');
    }
    return null;
  }
}
