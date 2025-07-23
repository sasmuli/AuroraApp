import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class CloudDataSource {
  String getCloudTileUrlTemplate();
}

class CloudDataSourceImpl implements CloudDataSource {
  @override
  String getCloudTileUrlTemplate() {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';
    return 'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$apiKey';
  }
}
