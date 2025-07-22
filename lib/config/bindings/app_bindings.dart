import 'package:aurora_app/presentation/controllers/MapPage/full_screen_map_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_card_controller.dart';
import 'package:aurora_app/presentation/controllers/home_controller.dart';
import 'package:aurora_app/services/location_serivce.dart';
import 'package:get/get.dart';
import 'package:aurora_app/services/navigation_service.dart';
import 'package:aurora_app/services/theme_service.dart';
import 'package:aurora_app/services/aurora_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    //Services
    Get.put(ThemeService());
    Get.put(NavigationService());
    Get.put<LocationService>(LocationService());
    Get.put<AuroraService>(AuroraService());

    //Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(
        navigationService: Get.find<NavigationService>(),
        themeService: Get.find<ThemeService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MapController>(() => MapController(), fenix: true);

    Get.lazyPut<MapCardController>(
      () => MapCardController(locationService: Get.find<LocationService>()),
      fenix: true,
    );

    Get.lazyPut<FullScreenMapController>(
      () => FullScreenMapController(),
      fenix: true,
    );
  }
}
