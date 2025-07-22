import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/aurora_marker.dart';

abstract class AuroraRemoteDataSource {
  Future<List<AuroraMarker>> fetchAuroraMarkers();
}

class AuroraRemoteDataSourceImpl implements AuroraRemoteDataSource {
  final http.Client client;

  AuroraRemoteDataSourceImpl(this.client);

  static const String _noaaOvationUrl =
      'https://services.swpc.noaa.gov/json/ovation_aurora_latest.json';

  @override
  Future<List<AuroraMarker>> fetchAuroraMarkers() async {
    final response = await client.get(
      Uri.parse(_noaaOvationUrl),
      headers: {'User-Agent': 'AuroraApp/1.0', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch aurora data: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return _mapToAuroraMarkers(data);
  }

  List<AuroraMarker> _mapToAuroraMarkers(Map<String, dynamic> data) {
    final List<dynamic> coordinates = data['coordinates'] ?? [];
    final List<AuroraMarker> markers = [];

    const int sampleRate = 4;

    for (int i = 0; i < coordinates.length; i += sampleRate) {
      final coord = coordinates[i];
      if (coord is List && coord.length >= 3) {
        final double longitude = (coord[0] as num).toDouble();
        final double latitude = (coord[1] as num).toDouble();
        final int auroraValue = (coord[2] as num).toInt();

        if (auroraValue == 0 || (latitude > -10 && latitude < 10)) continue;

        final double probability = auroraValue / 100.0;

        Color markerColor;
        if (auroraValue >= 80) {
          markerColor = Colors.purple.withValues(alpha: 0.4);
        } else if (auroraValue >= 50) {
          markerColor = Colors.red.withValues(alpha: 0.4);
        } else if (auroraValue >= 30) {
          markerColor = Colors.orange.withValues(alpha: 0.4);
        } else if (auroraValue >= 10) {
          markerColor = Colors.green.withValues(alpha: 0.4);
        } else {
          markerColor = Colors.grey.withValues(alpha: 0.1);
        }

        markers.add(
          AuroraMarker(
            latitude: latitude,
            longitude: longitude,
            probability: probability,
            color: markerColor,
          ),
        );
      }
    }

    return markers;
  }
}
