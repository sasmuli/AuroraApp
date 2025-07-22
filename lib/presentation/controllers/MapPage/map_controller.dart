import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:aurora_app/domain/models/aurora_data.dart';
import 'package:aurora_app/domain/repositories/location_repository.dart';
import 'package:aurora_app/domain/repositories/aurora_probability_repository.dart';
import 'package:aurora_app/logger.dart';

class MapController extends GetxController {
  final LocationRepository _locationRepository = Get.find<LocationRepository>();
  final AuroraProbabilityRepository _auroraRepository =
      Get.find<AuroraProbabilityRepository>();

  final Rx<AuroraData?> auroraData = Rx<AuroraData?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> lastUpdateTime = DateTime.now().obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);

  Timer? _updateTimer;
  final int updateIntervalMinutes = 30;

  static const LatLng defaultLocation = LatLng(65.0, 25.0);

  @override
  void onInit() {
    super.onInit();
    logger.i('[MapController] Initialized');

    _initialize();

    _updateTimer = Timer.periodic(
      Duration(minutes: updateIntervalMinutes),
      (_) => fetchAuroraData(),
    );
  }

  Future<void> _initialize() async {
    await _fetchLocation();
    await fetchAuroraData();
  }

  Future<void> _fetchLocation() async {
    final location = await _locationRepository.getCurrentLocation();
    if (location != null) {
      currentLocation.value = location;
      logger.i(
        '[MapController] Location updated: ${location.latitude}, ${location.longitude}',
      );
    } else {
      logger.w('[MapController] Failed to fetch current location');
    }
  }

  Future<void> fetchAuroraData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final LatLng location = currentLocation.value ?? defaultLocation;

    logger.i('[MapController] Fetching aurora data for $location...');

    try {
      final data = await _auroraRepository.getAuroraProbability(
        location: location,
        locationName:
            "Current Location", // You could implement reverse geocoding here
      );

      if (data != null) {
        auroraData.value = data;
        lastUpdateTime.value = DateTime.now();
        isLoading.value = false;

        logger.i(
          '[MapController] Aurora data fetched: '
          'Visibility=${data.chancePercentage}%, '
          'Location=${data.latitude.toStringAsFixed(2)},${data.longitude.toStringAsFixed(2)}',
        );
      } else {
        errorMessage.value =
            'Could not fetch aurora data. Please try again later.';
        logger.w('[MapController] Aurora data fetch returned null');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      logger.e('[MapController] Error fetching aurora data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    logger.i('[MapController] Manual refresh requested');
    fetchAuroraData();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    logger.i('[MapController] Stopped periodic KP updates');
    super.onClose();
  }
}
