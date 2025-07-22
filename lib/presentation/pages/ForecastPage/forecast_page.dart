import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 80),
          const SizedBox(height: largePadding),
          Text('Aurora Forecast', style: Get.textTheme.headlineMedium),
          const SizedBox(height: smallPadding),
          Text(
            'Forecast data will appear here',
            style: Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
