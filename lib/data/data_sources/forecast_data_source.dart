import 'dart:convert';

import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/logger.dart';
import 'package:http/http.dart' as http;

abstract class ForecastDataSource {
  /// Fetches historical KP index data from NOAA
  Future<KpHistoryData> fetchKpHistoryData();
}

class ForecastDataSourceImpl implements ForecastDataSource {
  final http.Client _httpClient;

  // NOAA SWPC API endpoints
  static const String _kpHistoryUrl =
      'https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json';
  /* static const String _kpShortTermUrl =
      'https://services.swpc.noaa.gov/json/planetary_k_index_1m.json';
  static const String _kpLongTermUrl =
      'https://services.swpc.noaa.gov/text/27-day-outlook.txt'; */

  ForecastDataSourceImpl({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  @override
  Future<KpHistoryData> fetchKpHistoryData() async {
    try {
      final response = await _httpClient.get(Uri.parse(_kpHistoryUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // First row is header, so we skip it
        final dataRows = jsonData.sublist(1);

        final entries = dataRows.map((row) {
          return KpIndexEntry(
            timestamp: DateTime.parse(row[0]),
            kpValue: double.parse(row[1].toString()),
          );
        }).toList();

        // Get current time and calculate 24 hours ago
        final now = DateTime.now();
        final oneDayAgo = now.subtract(const Duration(hours: 24));

        // Filter entries to include last 24 hours of data
        final last24HoursEntries = entries.where((entry) {
          return entry.timestamp.isAfter(oneDayAgo);
        }).toList();

        // Sort by timestamp ascending (earliest to latest)
        last24HoursEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        logger.d('Fetched ${last24HoursEntries.length} KP history entries for the last 24 hours');
        return KpHistoryData(entries: last24HoursEntries);
      } else {
        throw Exception(
          'Failed to load KP history data: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Error fetching KP history data: $e');
      rethrow;
    }
  }
}
