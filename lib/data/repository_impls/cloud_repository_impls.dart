import 'package:aurora_app/data/data_sources/cloud_data_source.dart';
import 'package:aurora_app/domain/repositories/cloud_repository.dart';

class CloudRepositoryImpl implements CloudRepository {
  final CloudDataSource dataSource;

  CloudRepositoryImpl(this.dataSource);

  @override
  String getCloudTiles() {
    return dataSource.getCloudTileUrlTemplate();
  }
}
