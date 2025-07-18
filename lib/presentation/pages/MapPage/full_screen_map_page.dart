import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:aurora_app/presentation/controllers/MapPage/full_screen_map_controller.dart';

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
          style: controller.mapStyle.value,
          onMapCreated: controller.onMapCreated,
        ),
      ),
    );
  }
}
