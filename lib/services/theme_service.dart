import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurora_app/logger.dart';

class ThemeService extends GetxService {
  final RxBool _isDarkMode = true.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    // Apply the dark theme immediately during initialization
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    logger.i('ThemeService initialized with dark mode: $_isDarkMode');
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    logger.i('Theme changed to: ${_isDarkMode.value ? "dark" : "light"} mode');
  }
}
