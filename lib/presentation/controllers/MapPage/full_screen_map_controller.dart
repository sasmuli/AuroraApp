import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/services/location_serivce.dart';

class FullScreenMapController extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  final Rx<CameraPosition> initialPosition = CameraPosition(
    target: const LatLng(0, 0),
    zoom: 3.0,
  ).obs;

  //final RxString mapStyle = ''.obs;

  void initialize(double initialLatitude, double initialLongitude) async {
    latitude.value = initialLatitude;
    longitude.value = initialLongitude;

    initialPosition.value = CameraPosition(
      target: LatLng(initialLatitude, initialLongitude),
      zoom: 5.0,
    );

    // Log initial coordinates and check current user location
    logger.i('Initializing map at: $initialLatitude, $initialLongitude');
    
    // Log the current user location if available
    final locationService = Get.find<LocationService>();
    logger.i('Location permission status: ${locationService.locationPermissionGranted.value}');
    if (locationService.currentPosition.value != null) {
      final pos = locationService.currentPosition.value!;
      logger.i('User location available: ${pos.latitude}, ${pos.longitude}, accuracy: ${pos.accuracy}m');
    } else {
      logger.w('User location not available yet');
    }

    /* try {
      final styleJson = await rootBundle.loadString(
        'assets/map_styles/dark_map.json',
      );
      mapStyle.value = styleJson;
      logger.i(' Map style loaded');
    } catch (e) {
      logger.e('Failed to load map style: $e');
    } */
  }

  void onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      logger.i('Map controller created');
      mapController.complete(controller);
      
      // Log user location when map is created
      final locationService = Get.find<LocationService>();
      if (locationService.currentPosition.value != null) {
        final pos = locationService.currentPosition.value!;
        logger.i('User location at map creation: ${pos.latitude}, ${pos.longitude}');
      } else {
        logger.w('User location not available at map creation');
        
        // Try to get location if not available
        try {
          final position = await locationService.getUserLocation();
          if (position != null) {
            logger.i('Retrieved user location: ${position.latitude}, ${position.longitude}');
          }
        } catch (e) {
          logger.e('Failed to get user location: $e');
        }
      }
    }
  }

  @override
  void onClose() {
    // Clean up map controller when the controller is disposed
    mapController.future.then((controller) => controller.dispose());
    super.onClose();
  }
}
