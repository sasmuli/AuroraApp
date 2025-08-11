import 'package:aurora_app/data/data_sources/forecast_data_source.dart';
import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/domain/repositories/forecast_repository.dart';
import 'package:logger/logger.dart';

class ForecastRepositoryImpl implements ForecastRepository {
  final ForecastDataSource _forecastDataSource;
  final Logger logger = Logger();

  ForecastRepositoryImpl(this._forecastDataSource);

  @override
  Future<KpHistoryData> getKpHistoryData() async {
    try {
      return await _forecastDataSource.fetchKpHistoryData();
    } catch (e) {
      logger.e('Error in getKpHistoryData: $e');
      rethrow;
    }
  }
  
  @override
  Future<KpShortTermForecastData> getKpForecastData() async {
    try {
      return await _forecastDataSource.fetchKpForecastData();
    } catch (e) {
      logger.e('Error in getKpForecastData: $e');
      rethrow;
    }
  }

  @override
  Future<({KpHistoryData history, KpShortTermForecastData shortTermForecast})> getAllKpData() async {
    try {
      // Fetch all data concurrently for better performance
      final results = await Future.wait([
        getKpHistoryData(),
        getKpForecastData(),
      ]);

      return (
        history: results[0] as KpHistoryData,
        shortTermForecast: results[1] as KpShortTermForecastData,
      );
    } catch (e) {
      logger.e('Error in getAllKpData: $e');
      rethrow;
    }
  }
}
