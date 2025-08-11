import 'dart:convert';

import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/logger.dart';
import 'package:http/http.dart' as http;

abstract class ForecastDataSource {
  /// Fetches historical KP index data from NOAA
  Future<KpHistoryData> fetchKpHistoryData();

  /// Fetches short-term KP index forecast data from NOAA (3-day forecast)
  Future<KpShortTermForecastData> fetchKpForecastData();
}

class ForecastDataSourceImpl implements ForecastDataSource {
  final http.Client _httpClient;

  // NOAA SWPC API endpoints
  static const String _kpHistoryUrl =
      'https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json';
  static const String _kpShortTermUrl =
      'https://services.swpc.noaa.gov/text/3-day-geomag-forecast.txt';
  // Reserved for future implementation - Long-term predictions (not currently used)
  // static const String _kpLongTermUrl = 'https://services.swpc.noaa.gov/text/27-day-outlook.txt';

  ForecastDataSourceImpl({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  @override
  Future<KpHistoryData> fetchKpHistoryData() async {
    try {
      final response = await _httpClient.get(Uri.parse(_kpHistoryUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Skip header row
        final dataRows = jsonData.sublist(1);

        final entries = dataRows.map((row) {
          return KpIndexEntry(
            timestamp: DateTime.parse(row[0]),
            kpValue: double.parse(row[1].toString()),
          );
        }).toList();

        final now = DateTime.now();
        final oneDayAgo = now.subtract(const Duration(hours: 24));

        final last24HoursEntries = entries.where((entry) {
          return entry.timestamp.isAfter(oneDayAgo);
        }).toList();

        last24HoursEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        logger.d(
          'Fetched ${last24HoursEntries.length} KP history entries for the last 24 hours',
        );
        return KpHistoryData(entries: last24HoursEntries);
      } else {
        throw Exception('Failed to load KP Index data');
      }
    } catch (e) {
      logger.e('Error fetching KP Index data: $e');
      rethrow;
    }
  }

  @override
  Future<KpShortTermForecastData> fetchKpForecastData() async {
    try {
      final response = await _httpClient.get(Uri.parse(_kpShortTermUrl));

      if (response.statusCode == 200) {
        final String forecastText = response.body;
        return _parseKpForecastData(forecastText);
      } else {
        throw Exception('Failed to load KP Index forecast data');
      }
    } catch (e) {
      logger.e('Error fetching KP Index forecast data: $e');
      rethrow;
    }
  }

  /// Parses the NOAA "3-day-geomag-forecast.txt" KP table (UTC bins)
  KpShortTermForecastData _parseKpForecastData(String text) {
    final entries = <KpIndexEntry>[];

    try {
      // 1) Find the KP section
      final sec = RegExp(
        r'NOAA Kp index forecast[^\n]*\n(?:.*\n){0,2}', // line with the title
        multiLine: true,
      ).firstMatch(text);
      if (sec == null) return KpShortTermForecastData(entries: []);

      final start = sec.start;
      // Grab from the title line to the end of file (we’ll parse only what we need)
      final kpBlock = text.substring(start);

      // 2) Get the 3 column dates from the header row like: "Aug 11    Aug 12    Aug 13"
      final dateHeader = RegExp(
        r'^\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2})\s+'
        r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2})\s+'
        r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2})\s*$',
        multiLine: true,
      ).firstMatch(kpBlock);

      if (dateHeader == null) return KpShortTermForecastData(entries: []);

      // Year from the :Issued: line
      final y = RegExp(r':Issued:\s+(\d{4})').firstMatch(text);
      final year = y != null ? int.parse(y.group(1)!) : DateTime.now().year;

      DateTime parseCol(int mIdx, int dIdx) {
        final m = _monthNumber(dateHeader.group(mIdx)!);
        final d = int.parse(dateHeader.group(dIdx)!);
        return DateTime.utc(year, m, d);
      }

      final day1Base = parseCol(1, 2);
      final day2Base = parseCol(3, 4);
      final day3Base = parseCol(5, 6);

      // 3) Parse each table line like: "00-03UT   3.33   4.00   3.00"
      final lineRe = RegExp(
        r'^\s*(\d{2})-(\d{2})UT\s+([0-9]+(?:\.[0-9]+)?)\s+([0-9]+(?:\.[0-9]+)?)\s+([0-9]+(?:\.[0-9]+)?)\s*$',
        multiLine: true,
      );

      for (final m in lineRe.allMatches(kpBlock)) {
        final startHour = int.parse(m.group(1)!);
        final v1 = double.parse(m.group(3)!);
        final v2 = double.parse(m.group(4)!);
        final v3 = double.parse(m.group(5)!);

        entries.add(
          KpIndexEntry(
            timestamp: DateTime.utc(
              day1Base.year,
              day1Base.month,
              day1Base.day,
              startHour,
            ),
            kpValue: v1,
          ),
        );
        entries.add(
          KpIndexEntry(
            timestamp: DateTime.utc(
              day2Base.year,
              day2Base.month,
              day2Base.day,
              startHour,
            ),
            kpValue: v2,
          ),
        );
        entries.add(
          KpIndexEntry(
            timestamp: DateTime.utc(
              day3Base.year,
              day3Base.month,
              day3Base.day,
              startHour,
            ),
            kpValue: v3,
          ),
        );
      }

      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return KpShortTermForecastData(entries: entries);
    } catch (e) {
      logger.e('Error parsing KP forecast data: $e');
      return KpShortTermForecastData(entries: []);
    }
  }

  int _monthNumber(String mon) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[mon]!;
  }
}
