import 'dart:async';
import 'dart:convert';

import 'package:aurora_app/logger.dart';
import 'package:aurora_app/domain/models/aurora_data.dart' hide logger;
import 'package:aurora_app/services/location_serivce.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuroraService extends GetxService {
  // NOAA OVATION aurora forecast API
  final String _noaaOvationUrl =
      'https://services.swpc.noaa.gov/json/ovation_aurora_latest.json';

  // Location service reference
  late final LocationService _locationService;

  // Constructor
  AuroraService() {
    _locationService = Get.find<LocationService>();
  }

  // Fetch aurora data based on user's current location using the NOAA OVATION API
  Future<AuroraData?> getAuroraData() async {
    try {
      double latitude;
      double longitude;
      String locationName = '';

      try {
        // Try to get current position from LocationService
        if (!_locationService.hasLocation) {
          await _locationService.getUserLocation();
        }

        if (_locationService.hasLocation) {
          latitude = _locationService.latitude;
          longitude = _locationService.longitude;
          logger.i('User location from service: lat=$latitude, lng=$longitude');
          locationName = await _getLocationName(latitude, longitude);
        } else {
          // If LocationService couldn't get a position, try last known position
          final lastPosition = await _locationService.getLastKnownPosition();
          if (lastPosition != null) {
            latitude = lastPosition.latitude;
            longitude = lastPosition.longitude;
            logger.i(
              ' Using last known location: lat=$latitude, lng=$longitude',
            );
            locationName = await _getLocationName(latitude, longitude);
          } else {
            // Fallback to default location if position is null
            logger.w(' Using default location as fallback');
            latitude = LocationService.defaultLatitude;
            longitude = LocationService.defaultLongitude;
            locationName = 'Default Location';
          }
        }
      } catch (locError) {
        // Handle location errors by using default location
        logger.e(' Location error: $locError');
        logger.w(' Using default location due to error');
        latitude = LocationService.defaultLatitude;
        longitude = LocationService.defaultLongitude;
        locationName = 'Default Location';
      }

      // Get data from NOAA OVATION API
      final url = Uri.parse(_noaaOvationUrl);
      logger.d('Fetching aurora data from NOAA OVATION API: $url');

      // Make API request
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final ovationData = jsonDecode(response.body);
        logger.d('NOAA OVATION API response received');

        final auroraData = AuroraData.fromOvationData(
          ovationData,
          locationName,
          latitude,
          longitude,
        );

        logger.i(
          ' Aurora data: Probability=${auroraData.chancePercentage}%, Location=${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}',
        );
        return auroraData;
      } else {
        logger.e('Failed to fetch NOAA OVATION data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching aurora data: $e');
      return null;
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    return ""; //TODO implement reverse geocoding
  }
}
