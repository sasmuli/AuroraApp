import 'package:aurora_app/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurora_app/services/navigation_service.dart';

class BottomNavBar extends GetView<NavigationService> {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Obx to make the widget reactive to changes in the controller
    return Obx(
      () => BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
            tooltip: 'Aurora Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Forecast',
            tooltip: 'Aurora Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_outlined),
            label: 'Gallery',
            tooltip: 'Aurora Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny),
            label: 'Sun',
            tooltip: 'Sun Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            tooltip: 'App Settings',
          ),
        ],
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          // Direct navigation to the selected tab
          logger.i('Navigation tapped: $index');
          controller.changePage(index);
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
