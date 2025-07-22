class AuroraData {
  final double kp;
  final String location;
  final int chancePercentage;
  final double latitude;
  final double longitude;
  final DateTime forecastTime;

  const AuroraData({
    required this.kp,
    required this.location,
    required this.chancePercentage,
    required this.latitude,
    required this.longitude,
    required this.forecastTime,
  });
}
