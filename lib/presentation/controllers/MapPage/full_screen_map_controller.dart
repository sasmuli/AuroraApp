import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:aurora_app/logger.dart';

class AuroraMarker {
  final double latitude;
  final double longitude;
  final double probability;
  final Color color;

  AuroraMarker({
    required this.latitude,
    required this.longitude,
    required this.probability,
    required this.color,
  });
}

class FullScreenMapController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxDouble latitude = 65.0.obs;
  final RxDouble longitude = 25.0.obs;
  final mapController = MapController();

  final RxList<AuroraMarker> auroraMarkers = <AuroraMarker>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late TabController tabController;
  final List<String> tabLabels = ['Aurora', 'Clouds', 'All'];

  static const String _noaaOvationUrl =
      'https://services.swpc.noaa.gov/json/ovation_aurora_latest.json';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabLabels.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      onTabChanged(tabController.index);
    });
    fetchAuroraData();
  }

  Future<void> fetchAuroraData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      logger.i('Fetching aurora data from NOAA...');

      final response = await http
          .get(
            Uri.parse(_noaaOvationUrl),
            headers: {
              'User-Agent': 'AuroraApp/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _processAuroraData(data);
        logger.i(
          'Successfully processed ${auroraMarkers.length} aurora markers',
        );
      } else {
        throw Exception('Failed to fetch aurora data: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching aurora data: $e');
      errorMessage.value = 'Failed to load aurora data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _processAuroraData(Map<String, dynamic> data) {
    final List<dynamic> coordinates = data['coordinates'] ?? [];
    final List<AuroraMarker> markers = [];

    // Sample every Nth point to reduce rendering load
    const int sampleRate = 4; // Take every 4th point
    
    for (int i = 0; i < coordinates.length; i += sampleRate) {
      final coord = coordinates[i];
      if (coord is List && coord.length >= 3) {
        final double longitude = (coord[0] as num).toDouble();
        final double latitude = (coord[1] as num).toDouble();
        final int auroraValue = (coord[2] as num).toInt();

        // Skip zero values (no aurora activity)
        if (auroraValue == 0) continue;

        // Skip equatorial points (latitude between -10 and 10)
        if (latitude > -10 && latitude < 10) continue;

        // Convert aurora value (0-100) to probability percentage
        final double probability = auroraValue / 100.0;

        // Determine color based on aurora value
        Color markerColor;
        if (auroraValue >= 80) {
          markerColor = Colors.purple.withValues(alpha: 0.8);
        } else if (auroraValue >= 50) {
          markerColor = Colors.red.withValues(alpha: 0.8);
        } else if (auroraValue >= 30) {
          markerColor = Colors.orange.withValues(alpha: 0.7);
        } else if (auroraValue >= 10) {
          markerColor = Colors.yellow.withValues(alpha: 0.6);
        } else {
          markerColor = Colors.green.withValues(alpha: 0.5);
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

    auroraMarkers.value = markers;
  }

  Future<void> refreshData() async {
    await fetchAuroraData();
  }

  void onTabChanged(int index) {
    logger.d('Tab changed to: ${tabLabels[index]}');
    // You can add different functionality for different tabs here
    // For now, all tabs show aurora data
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
