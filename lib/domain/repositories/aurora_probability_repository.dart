import 'package:latlong2/latlong.dart';
import '../models/aurora_data.dart';

abstract class AuroraProbabilityRepository {
  Future<AuroraData?> getAuroraProbability({
    required LatLng location,
    required String locationName,
  });
}
