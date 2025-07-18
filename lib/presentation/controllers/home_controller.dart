import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurora_app/services/navigation_service.dart';
import 'package:aurora_app/services/theme_service.dart';

class HomeController extends GetxController {
  HomeController({required this.navigationService, required this.themeService});

  final NavigationService navigationService;
  final ThemeService themeService;

  String get currentTitle => navigationService.currentTitle;
  PageController get pageController => navigationService.pageController;
  bool get isDarkMode => themeService.isDarkMode;

  void toggleTheme() {
    themeService.toggleTheme();
  }

  void openSettings() {
    //TODO implement settings
  }
}
