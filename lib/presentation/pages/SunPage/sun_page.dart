import 'package:flutter/material.dart';
import 'package:aurora_app/logger.dart';

class SunPage extends StatelessWidget {
  SunPage({super.key}) {
    logger.i('SunPage initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sunny, size: 80),
          const SizedBox(height: 16),
          Text(
            'Sun Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Solar activity data will appear here',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
