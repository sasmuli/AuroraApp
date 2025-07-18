import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/presentation/controllers/MapPage/full_screen_map_controller.dart';
import 'package:aurora_app/services/location_serivce.dart';

class FullScreenMapPage extends GetView<FullScreenMapController> {
  final double initialLatitude;
  final double initialLongitude;

  const FullScreenMapPage({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the coordinates
    controller.initialize(initialLatitude, initialLongitude);

    // Get location service to check status
    final locationService = Get.find<LocationService>();

    // Log location status for diagnostic purposes
    logger.i(
      '[FullScreenMapPage] Building page - Location permission granted: ${locationService.locationPermissionGranted.value}',
    );
    logger.i(
      '[FullScreenMapPage] Has current position: ${locationService.currentPosition.value != null}',
    );
    if (locationService.currentPosition.value != null) {
      final pos = locationService.currentPosition.value!;
      logger.i('[FullScreenMapPage] Current location: ${locationService.locationString}');
      logger.i('[FullScreenMapPage] Position timestamp: ${pos.timestamp}, accuracy: ${pos.accuracy}m');
    } else {
      logger.w('[FullScreenMapPage] User location data is not available');
      // Attempt to get location if not available
      locationService.getUserLocation().then((position) {
        if (position != null) {
          logger.i('[FullScreenMapPage] Location retrieved: ${position.latitude}, ${position.longitude}');
        }
      }).catchError((error) {
        logger.e('[FullScreenMapPage] Error getting location: $error');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Map'),
        elevation: 0,
        backgroundColor: Get.theme.primaryColor,
      ),
      body: Obx(
        () => GoogleMap(
          initialCameraPosition: controller.initialPosition.value,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          //style: controller.mapStyle.value,
          onMapCreated: controller.onMapCreated,
        ),
      ),
    );
  }
}
