import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoModal extends StatelessWidget {
  final int auroraMarkersCount;

  const InfoModal({super.key, required this.auroraMarkersCount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(mediumPadding),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aurora Information',
                  style: Get.theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: smallPadding),
            Text(
              'Aurora Probability chart',
              style: Get.theme.textTheme.titleSmall,
            ),
            const SizedBox(height: mediumPadding),
            buildInfoItem(Colors.grey, '1-9%', 'Low'),
            const SizedBox(height: smallPadding),
            buildInfoItem(Colors.green, '10-29%', 'Medium-Low'),
            const SizedBox(height: smallPadding),
            buildInfoItem(Colors.orange, '30-49%', 'Medium'),
            const SizedBox(height: smallPadding),
            buildInfoItem(Colors.red, '50-79%', 'High'),
            const SizedBox(height: smallPadding),
            buildInfoItem(Colors.purple, '80%+', 'Very High'),
            const SizedBox(height: extraLargePadding),
            Container(
              padding: const EdgeInsets.all(mediumPadding),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(smallPadding),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: smallPadding),
                  Expanded(
                    child: Text(
                      'Currently showing $auroraMarkersCount aurora probability points on the map',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: largePadding),
            Text(
              'The aurora probability data is updated regularly and shows the likelihood of aurora visibility in different regions.',
              style: Get.theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem(Color color, String percentage, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: mediumPadding,
          height: mediumPadding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withValues(alpha: 1.0), width: 0.5),
          ),
        ),
        const SizedBox(width: smallPadding),
        Text('$percentage ($label)', style: Get.theme.textTheme.bodySmall),
      ],
    );
  }
}
