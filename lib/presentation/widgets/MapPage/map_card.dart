import 'package:aurora_app/logger.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_card_controller.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapCard extends GetView<MapCardController> {
  final double height;
  final double width;

  const MapCard({super.key, this.height = 175, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          logger.i('[MapCard] Navigating to full screen map');
          controller.toMapPage();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: largePadding,
            vertical: smallPadding,
          ),
          height: height,
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(mediumPadding),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _buildMapContent()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: mediumPadding),
                  color: const Color.fromARGB(94, 0, 0, 0),
                  child: Text(
                    'Aurora Map',
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.titleSmall,
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
          padding: const EdgeInsets.all(largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: largePadding),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: largePadding),
              ElevatedButton(
                onPressed: controller.retryLocationFetch,
                child: Text('Retry', style: Get.theme.textTheme.labelLarge),
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
              const SizedBox(height: largePadding),
              Text(
                'Unable to load map',
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
