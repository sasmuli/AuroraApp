import 'package:aurora_app/config/bindings/app_bindings.dart';
import 'package:aurora_app/presentation/pages/home_page.dart';
import 'package:aurora_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:aurora_app/config/theme/aurora_theme.dart';
import 'package:get/get.dart';

void main() {
  AppBindings().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        initialBinding: AppBindings(),
        title: 'Aurora App',
        theme: AuroraTheme.lightTheme,
        darkTheme: AuroraTheme.darkTheme,
        themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: HomePage(),
      ),
    );
  }
}
