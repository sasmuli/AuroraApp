import '../models/aurora_marker.dart';

abstract class AuroraRepository {
  Future<List<AuroraMarker>> getAuroraMarkers();
}
