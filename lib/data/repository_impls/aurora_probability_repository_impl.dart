import 'package:aurora_app/data/data_sources/aurora_probability_data_source.dart';
import 'package:latlong2/latlong.dart';
import 'package:aurora_app/domain/models/aurora_data.dart';
import 'package:aurora_app/domain/repositories/aurora_probability_repository.dart';

class AuroraProbabilityRepositoryImpl implements AuroraProbabilityRepository {
  final AuroraProbabilityDataSource dataSource;

  AuroraProbabilityRepositoryImpl(this.dataSource);

  @override
  Future<AuroraData?> getAuroraProbability({
    required LatLng location,
    required String locationName,
  }) {
    return dataSource.fetchAuroraProbability(
      location: location,
      locationName: locationName,
    );
  }
}
