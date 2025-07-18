import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aurora_app/logger.dart';

class FullScreenMapController extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  final Rx<CameraPosition> initialPosition = CameraPosition(
    target: const LatLng(0, 0),
    zoom: 3.0,
  ).obs;

  final RxString mapStyle = ''.obs;

  void initialize(double initialLatitude, double initialLongitude) async {
    latitude.value = initialLatitude;
    longitude.value = initialLongitude;

    initialPosition.value = CameraPosition(
      target: LatLng(initialLatitude, initialLongitude),
      zoom: 5.0,
    );

    try {
      final styleJson = await rootBundle.loadString(
        'assets/map_styles/dark_map.json',
      );
      mapStyle.value = styleJson;
    } catch (e) {
      logger.e('Failed to load map style: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  @override
  void onClose() {
    // Clean up map controller when the controller is disposed
    mapController.future.then((controller) => controller.dispose());
    super.onClose();
  }
}
