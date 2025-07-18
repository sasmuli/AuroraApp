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
          const SizedBox(height: 16),
          Text('Aurora Forecast', style: Get.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Forecast data will appear here',
            style: Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
