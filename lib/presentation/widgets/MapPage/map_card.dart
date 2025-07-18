import 'package:aurora_app/logger.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_card_controller.dart';
import 'package:aurora_app/presentation/pages/MapPage/full_screen_map_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapCard extends GetView<MapCardController> {
  final double height;
  final double width;

  const MapCard({super.key, this.height = 175, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    // Log location data when building the map card
    logger.i('[MapCard] Building with location: ${controller.latitude}, ${controller.longitude}');
    
    if (controller.locationService.hasLocation) {
      final pos = controller.locationService.currentPosition.value!;
      logger.i('[MapCard] Location accuracy: ${pos.accuracy}m, timestamp: ${pos.timestamp}');
    } else {
      logger.w('[MapCard] No location data available');
    }
    
    return Obx(
      () => GestureDetector(
        onTap: () {
          logger.i('[MapCard] Navigating to full screen map');
          Get.to(
            () => FullScreenMapPage(
              initialLatitude: controller.latitude,
              initialLongitude: controller.longitude,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: height,
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Positioned.fill(child: _buildMapContent()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color.fromARGB(94, 0, 0, 0),
                  child: Text(
                    'Aurora Map',
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    final mapWidth = width.isInfinite ? 400 : width;
    final mapHeight = height;
    final mapUrl = controller.getMapUrl(mapWidth.toDouble(), mapHeight);

    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.retryLocationFetch,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Image.network(
      mapUrl,
      width: mapWidth.toDouble(),
      height: mapHeight.toDouble(),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        logger.e('Error loading map image: $error');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Unable to load map',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
