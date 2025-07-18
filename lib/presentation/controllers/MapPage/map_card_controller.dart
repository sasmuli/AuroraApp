import 'dart:io';
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/services/location_serivce.dart';
import 'package:get/get.dart';

class MapCardController extends GetxController {
  MapCardController({required this.locationService});

  // Map API keys
  static const String _androidApiKey =
      'AIzaSyBgV2sSA-2aCXA_rUoLfhclYaABG_uA7Xw'; //TODO hide this
  static const String _iosApiKey =
      'AIzaSyCCUbDanqN5tRLvHN3YVDgcOe0UVcLpHOo'; //TODO hide this
  static const int defaultZoom = 3;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString apiKey = ''.obs;
  final LocationService locationService;
  double get latitude => locationService.hasLocation
      ? locationService.latitude
      : LocationService.defaultLatitude;

  double get longitude => locationService.hasLocation
      ? locationService.longitude
      : LocationService.defaultLongitude;

  @override
  void onInit() {
    super.onInit();
    logger.i('[MapCardController] Initializing');
    apiKey.value = Platform.isAndroid ? _androidApiKey : _iosApiKey;
    initializeLocation();
  }

  void initializeLocation() {
    logger.i('[MapCardController] Initializing location');
    isLoading.value = true;
    errorMessage.value = '';
    
    // Log current location state
    logger.i('[MapCardController] Location service has location: ${locationService.hasLocation}');
    logger.i('[MapCardController] Permission granted: ${locationService.locationPermissionGranted.value}');
    
    if (!locationService.hasLocation) {
      logger.i('[MapCardController] Requesting user location');
      locationService
          .getUserLocation()
          .then((position) {
            isLoading.value = false;
            if (locationService.errorMessage.isNotEmpty) {
              logger.w('[MapCardController] Location error: ${locationService.errorMessage.value}');
              errorMessage.value = locationService.errorMessage.value;
            } else if (position != null) {
              logger.i('[MapCardController] Got position: ${position.latitude}, ${position.longitude}, accuracy: ${position.accuracy}m');
            } else {
              logger.w('[MapCardController] No position returned but no error either');
            }
          })
          .catchError((e) {
            errorMessage.value = 'Failed to get location: $e';
            isLoading.value = false;
            logger.e('[MapCardController] Error getting user location: $e');
          });
    } else {
      logger.i('[MapCardController] Using existing location: ${locationService.latitude}, ${locationService.longitude}');
      isLoading.value = false;
    }
    _setupLocationListeners();
  }

  void _setupLocationListeners() {
    logger.i('[MapCardController] Setting up location listeners');
    
    ever(locationService.isLoading, (loading) {
      logger.i('[MapCardController] Location service loading state changed: $loading');
      isLoading.value = loading;
    });
    
    ever(locationService.errorMessage, (error) {
      if (error.isNotEmpty) {
        logger.w('[MapCardController] Location service error: $error');
        errorMessage.value = error;
      }
    });
    
    // Listen for position changes
    ever(locationService.currentPosition, (position) {
      if (position != null) {
        logger.i('[MapCardController] Position updated: ${position.latitude}, ${position.longitude}, accuracy: ${position.accuracy}m');
      } else {
        logger.w('[MapCardController] Position cleared');
      }
    });
  }

  void retryLocationFetch() {
    logger.i('[MapCardController] Retrying location fetch');
    isLoading.value = true;
    errorMessage.value = '';
    locationService.getUserLocation().then((position) {
      if (position != null) {
        logger.i('[MapCardController] Retry successful: ${position.latitude}, ${position.longitude}');
      } else {
        logger.w('[MapCardController] Retry returned null position');
      }
    });
  }

  // Get the map URL for the current location
  String getMapUrl(double width, double height) {
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

    final url =
        'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=$defaultZoom'
        '&size=${width.toInt()}x${height.toInt()}'
        '&maptype=roadmap'
        '$encodedStyles'
        '&key=${apiKey.value}';

    logger.i(
      'Static map URL: ${url.replaceAll(apiKey.value, "API_KEY_HIDDEN")}',
    );
    return url;
  }
}
