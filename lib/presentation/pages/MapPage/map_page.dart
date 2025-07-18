import 'package:aurora_app/presentation/controllers/MapPage/map_controller.dart';
import 'package:aurora_app/presentation/widgets/MapPage/kp_card.dart';
import 'package:aurora_app/presentation/widgets/MapPage/map_card.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapPage extends GetView<MapController> {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => controller.isLoading.value
                ? const CircularProgressIndicator()
                : controller.errorMessage.value.isNotEmpty
                ? _buildErrorWidget()
                : controller.auroraData.value != null
                ? Column(
                    children: [
                      KpCard(
                        kpValue: controller.auroraData.value!.kp,
                        location: controller.auroraData.value!.location,
                        chancePercentage:
                            controller.auroraData.value!.chancePercentage,
                        updateTime: controller.lastUpdateTime.value,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updates automatically every ${controller.updateIntervalMinutes} minutes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MapCard(),
                    ],
                  )
                : const Text('No data available'),
          ),
        ],
      ),
    );
  }

  // Build the error widget
  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () => controller.refreshData(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
