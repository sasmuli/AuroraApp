import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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
    return DefaultTabController(
      length: controller.tabLabels.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aurora Probability Map'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: controller.tabController,
            tabs: controller.tabLabels
                .map((label) => Tab(text: label))
                .toList(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent,
          ),
          actions: [
            Obx(
              () => controller.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.refreshData,
                      tooltip: 'Refresh Aurora Data',
                    ),
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
                  const SizedBox(height: 16),
                  Text(
                    'Error loading aurora data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshData,
                    child: const Text('Retry'),
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
                  minZoom: 2,
                  maxZoom: 10,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  // Dark-themed tile layer
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
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: auroraMarker.color,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: auroraMarker.color.withValues(alpha: 1.0),
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Legend
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aurora Probability',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.green, '1-9%', 'Low'),
                      const SizedBox(height: 4),
                      _buildLegendItem(Colors.yellow, '10-29%', 'Medium-Low'),
                      const SizedBox(height: 4),
                      _buildLegendItem(Colors.orange, '30-49%', 'Medium'),
                      const SizedBox(height: 4),
                      _buildLegendItem(Colors.red, '50-79%', 'High'),
                      const SizedBox(height: 4),
                      _buildLegendItem(Colors.purple, '80%+', 'Very High'),
                    ],
                  ),
                ),
              ),
              // Data info
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Text(
                    '${controller.auroraMarkers.length} aurora points',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String percentage, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: color.withValues(alpha: 1.0),
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage ($label)',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}
