import 'package:aurora_app/domain/models/kp_index_entry.dart';

abstract class ForecastRepository {
  /// Fetches the historical KP index data from NOAA
  Future<KpHistoryData> getKpHistoryData();

  /// Fetches all KP index data (history, short-term, and long-term) in a single call
  Future<({KpHistoryData history})> getAllKpData();
}
