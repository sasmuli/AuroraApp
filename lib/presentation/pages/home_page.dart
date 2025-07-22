import 'package:aurora_app/presentation/controllers/home_controller.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aurora_app/presentation/widgets/bottom_nav_bar.dart';
import 'package:aurora_app/presentation/pages/MapPage/map_page.dart';
import 'package:aurora_app/presentation/pages/ForecastPage/forecast_page.dart';
import 'package:aurora_app/presentation/pages/GalleryPage/gallery_page.dart';
import 'package:aurora_app/presentation/pages/SunPage/sun_page.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentTitle,
            style: Get.theme.textTheme.titleLarge,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: controller.openSettings,
          padding: const EdgeInsets.all(smallPadding),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: smallPadding),
            child: Obx(
              () => IconButton(
                icon: Icon(
                  controller.isDarkMode
                      ? Icons.brightness_2_outlined
                      : Icons.brightness_5_outlined,
                ),
                onPressed: controller.toggleTheme,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MapPage(),
          ForecastPage(),
          GalleryPage(),
          SunPage(),
          const Scaffold(body: Center(child: Text('Settings'))),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
