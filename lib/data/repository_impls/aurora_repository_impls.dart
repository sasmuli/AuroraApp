import 'package:aurora_app/data/data_sources/aurora_data_source.dart';
import 'package:aurora_app/domain/models/aurora_marker.dart';
import 'package:aurora_app/domain/repositories/aurora_repository.dart';

class AuroraRepositoryImpl implements AuroraRepository {
  final AuroraRemoteDataSource remoteDataSource;

  AuroraRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AuroraMarker>> getAuroraMarkers() {
    return remoteDataSource.fetchAuroraMarkers();
  }
}
