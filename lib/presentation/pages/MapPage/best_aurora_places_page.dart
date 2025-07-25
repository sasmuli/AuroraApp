import 'package:aurora_app/config/theme/aurora_theme.dart';
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
      appBar: AppBar(
        title: const Text('Best Aurora Places'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.selectedCountries.isNotEmpty
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: controller.selectedCountries.isNotEmpty
                    ? AuroraTheme.auroraOrange
                    : null,
              ),
              onPressed: () => Get.dialog(_buildFilterDialog()),
            ),
          ),
        ],
      ),
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
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AuroraTheme.auroraRed,
                      ),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: largePadding),
                      const Text('No aurora spots found'),
                      const SizedBox(height: smallPadding),
                      Text(
                        'Try adjusting your filters',
                        style: Get.theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                            style: Get.theme.textTheme.labelMedium,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            controller.moveToPlace(index);
                          },
                        );
                      },
                    ),
                  ),
                ],
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

  Widget _buildFilterDialog() {
    return AlertDialog(
      title: const Text('Filter Aurora Places'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Probability Filter
            Text(
              'Minimum Aurora Probability',
              style: Get.theme.textTheme.labelLarge,
            ),
            const SizedBox(height: smallPadding),
            Obx(
              () => Column(
                children: [
                  Slider(
                    value: controller.minProbability.value,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${controller.minProbability.value.toInt()}%',
                    onChanged: (value) {
                      controller.minProbability.value = value;
                    },
                  ),
                  Text(
                    'Current: ${controller.minProbability.value.toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: largePadding),

            Text('Countries', style: Get.theme.textTheme.titleMedium),
            const SizedBox(height: smallPadding),
            Text(
              'Select countries to filter (leave empty for all):',
              style: Get.theme.textTheme.labelMedium,
            ),
            const SizedBox(height: smallPadding),
            Obx(
              () => SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.availableCountries.length,
                  itemBuilder: (context, index) {
                    final country = controller.availableCountries[index];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(country),
                        dense: true,
                        value: controller.selectedCountries.contains(country),
                        onChanged: (bool? value) {
                          if (value == true) {
                            controller.selectedCountries.add(country);
                          } else {
                            controller.selectedCountries.remove(country);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.clearFilters();
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            controller.applyFilters();
            Get.back();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
