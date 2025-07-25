import 'package:aurora_app/presentation/pages/MapPage/full_image_page.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ForecastImagesController extends GetxController {
  final List<Map<String, String>> forecastImages = [
    {
      'title': "Tonight's Aurora Forecast",
      'url':
          'https://services.swpc.noaa.gov/experimental/images/aurora_dashboard/tonights_static_viewline_forecast.png',
    },
    {
      'title': "Tomorrow Night's Aurora Forecast",
      'url':
          'https://services.swpc.noaa.gov/experimental/images/aurora_dashboard/tomorrow_nights_static_viewline_forecast.png',
    },
    {
      'title': "Northern Hemisphere - Real-time Forecast",
      'url':
          'https://services.swpc.noaa.gov/images/animations/ovation/north/latest.jpg',
    },
    {
      'title': "Southern Hemisphere - Real-time Forecast",
      'url':
          'https://services.swpc.noaa.gov/images/animations/ovation/south/latest.jpg',
    },
  ];

  final refreshKey = RxInt(0);

  void reloadImages() {
    refreshKey.value++;
  }

  void openInFullscreen(String url) {
    Get.to(() => FullscreenImagePage(imageUrl: url));
  }

  void openSource() async {
    final uri = Uri.parse(
      'https://www.swpc.noaa.gov/communities/aurora-dashboard-experimental',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch URL');
    }
  }
}
