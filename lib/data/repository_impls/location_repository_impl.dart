import 'package:aurora_app/data/data_sources/location_data_source.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<LatLng?> getCurrentLocation() {
    return dataSource.fetchCurrentLocation();
  }

  @override
  Future<LatLng?> getLastKnownLocation() {
    return dataSource.fetchLastKnownLocation();
  }
}
