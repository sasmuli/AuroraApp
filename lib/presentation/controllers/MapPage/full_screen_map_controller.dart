import 'package:aurora_app/domain/models/aurora_marker.dart';
import 'package:aurora_app/domain/repositories/aurora_repository.dart';
import 'package:aurora_app/logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class FullScreenMapController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuroraRepository auroraRepository;

  FullScreenMapController(this.auroraRepository);

  final RxDouble latitude = 65.0.obs;
  final RxDouble longitude = 25.0.obs;
  final mapController = MapController();

  final RxList<AuroraMarker> auroraMarkers = <AuroraMarker>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late TabController tabController;
  final List<String> tabLabels = ['Aurora', 'Clouds', 'All'];

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

  Future<void> refreshData() async {
    await fetchAuroraData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
