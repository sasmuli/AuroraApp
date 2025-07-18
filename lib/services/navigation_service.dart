import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurora_app/logger.dart';

class NavigationService extends GetxService {
  final RxInt currentIndex = 0.obs;

  late final PageController pageController;

  final List<String> pageTitles = [
    'Aurora Map',
    'Aurora Forecast',
    'Aurora Gallery',
    'Sun Activity',
    'Settings',
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
    logger.i('NavigationService initialized with page: ${currentIndex.value}');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    logger.i('Changing page to: $index');
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  String get currentTitle => pageTitles[currentIndex.value];
}
