import 'dart:math';
import 'package:logger/logger.dart';

final logger = Logger();

class AuroraData {
  final double kp; // Global KP index
  final String location; // User location name
  final int chancePercentage; // Local aurora visibility probability (0-100%)
  final double latitude; // User latitude
  final double longitude; // User longitude
  final DateTime forecastTime; // Time of the NOAA forecast

  AuroraData({
    required this.kp,
    required this.location,
    required this.chancePercentage,
    required this.latitude,
    required this.longitude,
    required this.forecastTime,
  });

  // Create Aurora data from NOAA OVATION data
  //
  // This finds the closest point in the OVATION grid to the user's location
  // and uses that point's probability as the aurora visibility chance
  factory AuroraData.fromOvationData(
    Map<String, dynamic> ovationData,
    String location,
    double userLat,
    double userLng,
  ) {
    // Parse the forecast time
    final forecastTimeStr = ovationData['Forecast Time'] ?? '';
    DateTime forecastTime;
    try {
      forecastTime = DateTime.parse(forecastTimeStr);
    } catch (e) {
      forecastTime = DateTime.now();
      logger.w('Failed to parse forecast time: $e');
    }

    // Get coordinates from the data - it's an array of arrays [longitude, latitude, aurora_probability]
    final coordinates = ovationData['coordinates'] ?? [];

    // Calculate KP value from probability
    double kpValue = 0.0;

    // If no coordinates are available, return defaults
    if (coordinates is! List || coordinates.isEmpty) {
      logger.w('No coordinates found in OVATION data');
      return AuroraData(
        kp: kpValue,
        location: location,
        chancePercentage: 0,
        latitude: userLat,
        longitude: userLng,
        forecastTime: forecastTime,
      );
    }

    // Find the closest point to the user
    List closestPoint = [];
    double minDistance = double.infinity;

    for (final point in coordinates) {
      if (point is! List || point.length < 3) continue;

      // Data format is [longitude, latitude, aurora_probability]
      final pointLng = (point[0] as num?)?.toDouble() ?? 0.0;
      final pointLat = (point[1] as num?)?.toDouble() ?? 0.0;

      // Calculate distance using Haversine formula
      final distance = _haversineDistance(userLat, userLng, pointLat, pointLng);

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    // Extract probability from closest point (3rd element in the array)
    int probability = 0;
    if (closestPoint.isNotEmpty && closestPoint.length > 2) {
      probability = (closestPoint[2] as num?)?.toInt() ?? 0;
    }

    // Calculate precise KP value from probability
    kpValue = _calculatePreciseKpFromProbability(probability);

    logger.i(
      'Found closest aurora probability: $probability% (KP: ${kpValue.toStringAsFixed(2)}) at distance: ${minDistance.toStringAsFixed(1)}km',
    );

    return AuroraData(
      kp: kpValue, // We don't get KP directly from OVATION, it would need another API call
      location: location,
      chancePercentage: probability,
      latitude: userLat,
      longitude: userLng,
      forecastTime: forecastTime,
    );
  }

  // Calculate distance between two coordinates using Haversine formula
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    // Convert degrees to radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    // Haversine formula
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Calculate a precise KP index value from aurora visibility probability
  //
  // Maps probability (0-100%) to KP index (0-9) with decimal precision
  // Returns a value between 0.0 and 9.0
  static double _calculatePreciseKpFromProbability(int probability) {
    if (probability <= 0) return 0.0;
    if (probability >= 100) return 9.0;

    // More realistic mapping of probability to Kp (manually calibrated)
    final calibrationPoints = [
      [0, 0.0],
      [1, 1.7],
      [5, 2.2],
      [10, 3.0],
      [15, 3.5],
      [20, 4.0],
      [30, 4.7],
      [40, 5.5],
      [50, 6.0],
      [60, 6.5],
      [70, 7.2],
      [80, 8.0],
      [90, 8.7],
      [100, 9.0],
    ];

    // Find lower and upper points for interpolation
    int lowerIndex = 0;
    for (int i = 0; i < calibrationPoints.length - 1; i++) {
      if (probability >= calibrationPoints[i][0] &&
          probability < calibrationPoints[i + 1][0]) {
        lowerIndex = i;
        break;
      }
    }

    final lower = calibrationPoints[lowerIndex];
    final upper = calibrationPoints[lowerIndex + 1];

    final x1 = lower[0].toDouble();
    final y1 = lower[1].toDouble();
    final x2 = upper[0].toDouble();
    final y2 = upper[1].toDouble();

    // Linear interpolation between two points
    final kp = y1 + (probability - x1) * ((y2 - y1) / (x2 - x1));

    return double.parse(kp.toStringAsFixed(2));
  }
}
