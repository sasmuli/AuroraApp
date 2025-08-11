class KpIndexEntry {
  final DateTime timestamp;
  final double kpValue;

  KpIndexEntry({required this.timestamp, required this.kpValue});

  // Helper to determine color based on KP value
  String get colorCategory {
    if (kpValue >= 4) {
      return 'red';
    } else if (kpValue >= 3) {
      return 'yellow';
    } else {
      return 'green';
    }
  }
}

class KpHistoryData {
  final List<KpIndexEntry> entries;

  KpHistoryData({required this.entries});
}

class KpShortTermForecastData {
  final List<KpIndexEntry> entries;

  KpShortTermForecastData({required this.entries});
}

class KpLongTermForecastData {
  final List<KpIndexEntry> entries;

  KpLongTermForecastData({required this.entries});
}
