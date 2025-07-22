import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:aurora_app/presentation/controllers/MapPage/full_screen_map_controller.dart';
import 'package:aurora_app/presentation/widgets/FullScreenMapPage/info_modal.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithLocation(initialLatitude, initialLongitude);
    });

    return DefaultTabController(
      length: controller.tabLabels.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Aurora Probability Map',
            style: Get.theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: controller.tabController,
            tabs: controller.tabLabels
                .map((label) => Tab(text: label))
                .toList(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent,
            labelStyle: Get.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => Get.dialog(
                    InfoModal(
                      auroraMarkersCount: controller.auroraMarkers.length,
                    ),
                  ),
                  tooltip: 'Info',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                  tooltip: 'Gallery',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        body: Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: largePadding),
                  Text(
                    'Error loading aurora data',
                    style: Get.theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.red[300],
                    ),
                  ),
                  const SizedBox(height: smallPadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: extraExtraLargePadding,
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: extraLargePadding),
                  ElevatedButton(
                    onPressed: controller.fetchAuroraData,
                    child: Text('Retry', style: Get.theme.textTheme.labelLarge),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    controller.latitude.value,
                    controller.longitude.value,
                  ),
                  initialZoom: 3,
                  minZoom: 1,
                  maxZoom: 10,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(-85.0, -180.0),
                      const LatLng(85.0, 180.0),
                    ),
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.aurora_app',
                    additionalOptions: const {
                      'attribution': '© OpenStreetMap contributors © CARTO',
                    },
                  ),
                  // Aurora markers layer
                  MarkerLayer(
                    markers: controller.auroraMarkers.map((auroraMarker) {
                      return Marker(
                        point: LatLng(
                          auroraMarker.latitude,
                          auroraMarker.longitude,
                        ),
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: auroraMarker.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: auroraMarker.color.withValues(alpha: 1.0),
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Obx(() {
                    final userLoc = controller.userLocation.value;
                    if (userLoc == null) return const SizedBox.shrink();

                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: userLoc,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        }),
        floatingActionButton: Obx(() {
          final userLoc = controller.userLocation.value;
          if (userLoc == null) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: controller.centerOnUserLocation,
            backgroundColor: Theme.of(context).primaryColor,
            child: controller.isLocationLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location, color: Colors.white),
          );
        }),
      ),
    );
  }
}
