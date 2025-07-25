import 'package:aurora_app/data/data_sources/aurora_data_source.dart';
import 'package:aurora_app/data/data_sources/aurora_probability_data_source.dart';
import 'package:aurora_app/data/data_sources/cloud_data_source.dart';
import 'package:aurora_app/data/data_sources/location_data_source.dart';
import 'package:aurora_app/data/repository_impls/aurora_probability_repository_impl.dart';
import 'package:aurora_app/data/repository_impls/aurora_repository_impls.dart';
import 'package:aurora_app/data/repository_impls/cloud_repository_impls.dart';
import 'package:aurora_app/data/repository_impls/location_repository_impl.dart';
import 'package:aurora_app/domain/repositories/aurora_probability_repository.dart';
import 'package:aurora_app/domain/repositories/aurora_repository.dart';
import 'package:aurora_app/domain/repositories/cloud_repository.dart';
import 'package:aurora_app/domain/repositories/location_repository.dart';
import 'package:aurora_app/presentation/controllers/MapPage/best_aurora_places_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/forecast_images_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/full_screen_map_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_controller.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_card_controller.dart';
import 'package:aurora_app/presentation/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:aurora_app/services/navigation_service.dart';
import 'package:aurora_app/services/theme_service.dart';
import 'package:http/http.dart' as http;

class AppBindings extends Bindings {
  @override
  void dependencies() {
    //Services
    Get.put(ThemeService());
    Get.put(NavigationService());

    //Http Client
    Get.put(http.Client());

    //DataSources
    Get.put<AuroraRemoteDataSource>(
      AuroraRemoteDataSourceImpl(Get.find<http.Client>()),
    );

    Get.put<AuroraProbabilityDataSource>(AuroraProbabilityDataSourceImpl());

    Get.put<LocationDataSource>(LocationDataSourceImpl());

    Get.put<CloudDataSource>(CloudDataSourceImpl());

    //Repositories Imps
    Get.put<AuroraRepository>(
      AuroraRepositoryImpl(Get.find<AuroraRemoteDataSource>()),
    );

    Get.put<LocationRepository>(
      LocationRepositoryImpl(Get.find<LocationDataSource>()),
    );

    Get.put<AuroraProbabilityRepository>(
      AuroraProbabilityRepositoryImpl(Get.find<AuroraProbabilityDataSource>()),
    );

    Get.put<CloudRepository>(CloudRepositoryImpl(Get.find<CloudDataSource>()));

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
      () =>
          MapCardController(locationRepository: Get.find<LocationRepository>()),
      fenix: true,
    );

    Get.lazyPut<FullScreenMapController>(
      () => FullScreenMapController(
        Get.find<AuroraRepository>(),
        Get.find<CloudRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ForecastImagesController>(
      () => ForecastImagesController(),
      fenix: true,
    );

    Get.lazyPut<BestAuroraPlacesController>(
      () => BestAuroraPlacesController(),
      fenix: true,
    );
  }
}
