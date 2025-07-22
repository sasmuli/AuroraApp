import 'dart:math';

import 'package:latlong2/latlong.dart';
import '../../domain/models/aurora_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../logger.dart';

abstract class AuroraProbabilityDataSource {
  Future<AuroraData?> fetchAuroraProbability({
    required LatLng location,
    required String locationName,
  });
}

class AuroraProbabilityDataSourceImpl implements AuroraProbabilityDataSource {
  static const _noaaOvationUrl =
      'https://services.swpc.noaa.gov/json/ovation_aurora_latest.json';

  @override
  Future<AuroraData?> fetchAuroraProbability({
    required LatLng location,
    required String locationName,
  }) async {
    try {
      final response = await http.get(Uri.parse(_noaaOvationUrl));

      if (response.statusCode != 200) {
        logger.e('[AuroraAPI] Failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      logger.d('[AuroraAPI] Response received');

      return _parseOvationData(
        data,
        locationName,
        location.latitude,
        location.longitude,
      );
    } catch (e) {
      logger.e('[AuroraAPI] Error: $e');
      return null;
    }
  }

  AuroraData _parseOvationData(
    Map<String, dynamic> ovationData,
    String location,
    double userLat,
    double userLng,
  ) {
    final forecastTimeStr = ovationData['Forecast Time'] ?? '';
    DateTime forecastTime;
    try {
      forecastTime = DateTime.parse(forecastTimeStr);
    } catch (e) {
      forecastTime = DateTime.now();
      logger.w('[AuroraAPI] Invalid forecast time: $e');
    }

    final coordinates = ovationData['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) {
      logger.w('[AuroraAPI] No coordinates in response');
      return AuroraData(
        kp: 0.0,
        location: location,
        chancePercentage: 0,
        latitude: userLat,
        longitude: userLng,
        forecastTime: forecastTime,
      );
    }

    List closestPoint = [];
    double minDistance = double.infinity;

    for (final point in coordinates) {
      if (point is! List || point.length < 3) continue;

      final pointLng = (point[0] as num).toDouble();
      final pointLat = (point[1] as num).toDouble();

      final distance = _haversine(userLat, userLng, pointLat, pointLng);
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    final int probability = (closestPoint.length >= 3)
        ? (closestPoint[2] as num).toInt()
        : 0;

    final double kp = _calculateKp(probability);

    logger.i(
      '[AuroraAPI] Closest aurora: $probability% (Kp: ${kp.toStringAsFixed(2)}) @ ${minDistance.toStringAsFixed(1)}km',
    );

    return AuroraData(
      kp: kp,
      location: location,
      chancePercentage: probability,
      latitude: userLat,
      longitude: userLng,
      forecastTime: forecastTime,
    );
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  double _calculateKp(int probability) {
    const calibration = [
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

    for (int i = 0; i < calibration.length - 1; i++) {
      if (probability >= calibration[i][0] &&
          probability < calibration[i + 1][0]) {
        final x1 = calibration[i][0].toDouble();
        final y1 = calibration[i][1].toDouble();
        final x2 = calibration[i + 1][0].toDouble();
        final y2 = calibration[i + 1][1].toDouble();
        return y1 + (probability - x1) * (y2 - y1) / (x2 - x1);
      }
    }

    return 9.0;
  }
}
