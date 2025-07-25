import 'package:aurora_app/presentation/controllers/MapPage/forecast_images_controller.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastImagesPage extends GetView<ForecastImagesController> {
  const ForecastImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecast Images'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.reloadImages,
            tooltip: 'Refresh Images',
          ),
        ],
      ),
      body: Obx(() {
        final refreshKey = controller.refreshKey.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...controller.forecastImages.map((img) {
                final refreshedUrl = '${img['url']}?t=$refreshKey';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(img['title']!, style: Get.textTheme.titleMedium),
                    const SizedBox(height: smallPadding),
                    GestureDetector(
                      onTap: () => controller.openInFullscreen(img['url']!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mediumPadding),
                        child: Image.network(
                          refreshedUrl,
                          loadingBuilder: (ctx, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(mediumPadding),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: largePadding),
                  ],
                );
              }),
              const SizedBox(height: extraLargePadding),
              Center(
                child: TextButton(
                  onPressed: controller.openSource,
                  child: const Text('Source: NOAA SWPC'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
