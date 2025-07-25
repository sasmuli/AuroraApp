import 'package:aurora_app/presentation/controllers/MapPage/map_controller.dart';
import 'package:aurora_app/presentation/widgets/MapPage/best_place_card.dart';
import 'package:aurora_app/presentation/widgets/MapPage/kp_card.dart';
import 'package:aurora_app/presentation/widgets/MapPage/map_card.dart';
import 'package:aurora_app/utils/constants/paddings.dart';

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
                      const SizedBox(height: extraSmallPadding),
                      Text(
                        'Updates automatically every ${controller.updateIntervalMinutes} minutes',
                        style: Get.theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: largePadding),
                      MapCard(),
                      const SizedBox(height: largePadding),
                      BestPlaceCard(),
                    ],
                  )
                : Text(
                    'No data available',
                    style: Get.theme.textTheme.bodyLarge,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: largePadding),
      padding: const EdgeInsets.all(largePadding),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(mediumPadding),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: smallPadding),
          Obx(
            () => Text(
              controller.errorMessage.value,
              style: Get.theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () => controller.refreshData(),
            child: Text('Try Again', style: Get.theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
