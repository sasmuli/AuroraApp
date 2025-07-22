import 'dart:async';
import 'package:aurora_app/domain/models/aurora_marker.dart';
import 'package:aurora_app/domain/repositories/aurora_repository.dart';
import 'package:aurora_app/logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullScreenMapController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuroraRepository auroraRepository;

  FullScreenMapController(this.auroraRepository);

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final mapController = MapController();

  final RxList<AuroraMarker> auroraMarkers = <AuroraMarker>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<LatLng> userLocation = Rxn<LatLng>();
  final RxBool isLocationLoading = false.obs;

  late TabController tabController;
  final List<String> tabLabels = ['Aurora', 'Clouds', 'All'];
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabLabels.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      onTabChanged(tabController.index);
    });
    fetchAuroraData();
    _startAutoRefresh();
  }

  void initializeWithLocation(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
    userLocation.value = LatLng(lat, lng);

    // Move map to the provided location
    mapController.move(LatLng(lat, lng), 4.0);

    logger.i('Initialized with passed location: $lat, $lng');
  }

  Future<void> fetchAuroraData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      logger.i('Fetching aurora data from repository...');

      final markers = await auroraRepository.getAuroraMarkers();
      auroraMarkers.value = markers;

      logger.i('Successfully loaded ${markers.length} markers');
    } catch (e) {
      logger.e('Error: $e');
      errorMessage.value = 'Failed to load aurora data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(int index) {
    logger.d('Tab changed to: ${tabLabels[index]}');
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      logger.i('Auto-refreshing aurora data');

      fetchAuroraData();
    });
    logger.i('Auto-refresh started: data will refresh every 10 minutes');
  }

  void centerOnUserLocation() {
    final location = userLocation.value;
    if (location != null) {
      mapController.move(location, 4);
      logger.d('Centered map on user location');
    } else {
      logger.w('No user location available to center on');
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    tabController.dispose();
    super.onClose();
  }
}
