import 'dart:io';

import 'package:aurora_app/presentation/pages/MapPage/full_screen_map_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/repositories/location_repository.dart';
import '../../../logger.dart';

class MapCardController extends GetxController {
  MapCardController({required this.locationRepository});

  final LocationRepository locationRepository;

  static const int defaultZoom = 3;
  static const LatLng defaultLocation = LatLng(65.0, 25.0);

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString apiKey = ''.obs;
  final Rx<LatLng> currentLocation = defaultLocation.obs;

  @override
  void onInit() {
    super.onInit();
    apiKey.value = Platform.isAndroid
        ? dotenv.env['ANDROID_MAP_API_KEY'] ?? ''
        : dotenv.env['IOS_MAP_API_KEY'] ?? '';

    _initializeLocation();
  }

  void _initializeLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final location = await locationRepository.getCurrentLocation();

      if (location != null) {
        currentLocation.value = location;
        logger.i('[MapCardController] Location set: $location');
      } else {
        logger.w('[MapCardController] Location is null, using default');
      }
    } catch (e) {
      errorMessage.value = 'Failed to get location: $e';
      logger.e('[MapCardController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retryLocationFetch() {
    _initializeLocation();
  }

  void toMapPage() {
    Get.to(
      () => FullScreenMapPage(
        initialLatitude: currentLocation.value.latitude,
        initialLongitude: currentLocation.value.longitude,
      ),
    );
  }

  String getMapUrl(double width, double height) {
    final LatLng location = currentLocation.value;

    final List<String> styleParams = [
      'element:geometry|color:0x1d2c4d',
      'element:labels.text.fill|color:0x8ec3b9',
      'element:labels.text.stroke|color:0x1a3646',
      'feature:administrative.country|element:geometry.stroke|color:0x4b6878',
      'feature:administrative.land_parcel|element:labels.text.fill|color:0x64779e',
      'feature:administrative.province|element:geometry.stroke|color:0x4b6878',
      'feature:landscape.man_made|element:geometry.stroke|color:0x334e87',
      'feature:landscape.natural|element:geometry|color:0x023e58',
      'feature:poi|element:geometry|color:0x283d6a',
      'feature:poi|element:labels.text.fill|color:0x6f9ba5',
      'feature:poi|element:labels.text.stroke|color:0x1d2c4d',
      'feature:poi.park|element:geometry.fill|color:0x023e58',
      'feature:poi.park|element:labels.text.fill|color:0x3C7680',
      'feature:road|element:geometry|color:0x304a7d',
      'feature:road|element:labels.text.fill|color:0x98a5be',
      'feature:road|element:labels.text.stroke|color:0x1d2c4d',
      'feature:road.highway|element:geometry|color:0x2c6675',
      'feature:road.highway|element:geometry.stroke|color:0x255763',
      'feature:road.highway|element:labels.text.fill|color:0xb0d5ce',
      'feature:road.highway|element:labels.text.stroke|color:0x023e58',
      'feature:transit|element:labels.text.fill|color:0x98a5be',
      'feature:transit|element:labels.text.stroke|color:0x1d2c4d',
      'feature:transit.line|element:geometry.fill|color:0x283d6a',
      'feature:transit.station|element:geometry|color:0x3a4762',
      'feature:water|element:geometry|color:0x0e1626',
      'feature:water|element:labels.text.fill|color:0x4e6d70',
    ];

    final encodedStyles = styleParams
        .map((e) => '&style=${Uri.encodeComponent(e)}')
        .join();

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=${location.latitude},${location.longitude}'
        '&zoom=$defaultZoom'
        '&size=${width.toInt()}x${height.toInt()}'
        '&maptype=roadmap'
        '$encodedStyles'
        '&key=${apiKey.value}';
  }
}
