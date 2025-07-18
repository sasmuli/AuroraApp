import 'dart:async';
import 'package:aurora_app/domain/models/aurora_data.dart' hide logger;
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/services/aurora_service.dart';
import 'package:aurora_app/services/location_serivce.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  final AuroraService _auroraService = AuroraService();
  final LocationService _locationService = Get.find<LocationService>();

  // Observable state variables
  final Rx<AuroraData?> auroraData = Rx<AuroraData?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = RxString('');
  final Rx<DateTime> lastUpdateTime = DateTime.now().obs;

  Timer? _updateTimer;
  final int updateIntervalMinutes = 30;

  @override
  void onInit() {
    super.onInit();
    logger.i('[MapController] Initialized');

    fetchAuroraData();
    _updateTimer = Timer.periodic(
      Duration(minutes: updateIntervalMinutes),
      (_) => fetchAuroraData(),
    );

    logger.i(
      '[MapController] Scheduled KP updates every $updateIntervalMinutes minutes',
    );

    // Monitor location changes
    ever(_locationService.currentPosition, (position) {
      if (position != null) {
        logger.i(
          '[MapController] Location updated: ${position.latitude}, ${position.longitude}',
        );
      }
    });
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    logger.i('[MapController] Stopped periodic KP updates');
    super.onClose();
  }

  Future<void> fetchAuroraData() async {
    isLoading.value = true;
    errorMessage.value = '';

    logger.i('[MapController] Fetching aurora data from NOAA OVATION...');

    try {
      final data = await _auroraService.getAuroraData();
      if (data != null) {
        auroraData.value = data;
        lastUpdateTime.value = DateTime.now();
        isLoading.value = false;

        logger.i(
          '[MapController] Aurora data fetched: Visibility=${data.chancePercentage}%, '
          'Location=${data.latitude.toStringAsFixed(2)},${data.longitude.toStringAsFixed(2)}, '
          'Forecast Time=${data.forecastTime.toIso8601String()}',
        );
      } else {
        errorMessage.value =
            'Could not fetch aurora data. Please check your internet connection and try again.';
        isLoading.value = false;
        logger.w('[MapController] Aurora data fetch returned null');
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      logger.e('[MapController] Error fetching aurora data: $e');
    }
  }

  // Manually trigger a refresh of the aurora data
  void refreshData() {
    logger.i('[MapController] Manual refresh requested');
    fetchAuroraData();
  }
}
