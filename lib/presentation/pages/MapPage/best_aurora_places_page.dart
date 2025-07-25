import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/MapPage/best_aurora_places_controller.dart';

class BestAuroraPlacesPage extends GetView<BestAuroraPlacesController> {
  const BestAuroraPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Best Aurora Places')),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.5,
            child: Obx(
              () => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.initialCameraTarget,
                  zoom: 4,
                ),
                mapType: MapType.normal,
                onMapCreated: controller.onMapCreated,
                markers: controller.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                rotateGesturesEnabled: false,
                compassEnabled: true,
                style: controller.styleString.value.isEmpty
                    ? null
                    : controller.styleString.value,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: largePadding),
                      Text('Loading best aurora spots...'),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: largePadding),
                      Text(controller.errorMessage.value),
                      SizedBox(height: largePadding),
                      ElevatedButton(
                        onPressed: controller.refreshData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.bestAuroraPlaces.isEmpty) {
                return const Center(child: Text('No aurora spots found'));
              }

              return ListView.builder(
                itemCount: controller.bestAuroraPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.bestAuroraPlaces[index];
                  final probabilityColor = _getProbabilityColor(
                    place.probability,
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: probabilityColor,
                      child: Text(
                        '${place.probability.toStringAsFixed(0)}%',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text('${place.name}, ${place.country}'),
                    subtitle: Text(
                      'Distance: ${place.distanceKm.toStringAsFixed(0)} km',
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      controller.moveToPlace(index);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 80) {
      return Colors.purple;
    } else if (probability >= 50) {
      return Colors.red;
    } else if (probability >= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
