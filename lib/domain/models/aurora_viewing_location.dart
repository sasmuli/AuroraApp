class AuroraViewingLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final double probability;
  final double distanceKm;

  AuroraViewingLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.probability,
    required this.distanceKm,
  });

  factory AuroraViewingLocation.fromJson(
    Map<String, dynamic> json,
    String country,
  ) {
    return AuroraViewingLocation(
      name: json['name'],
      country: country,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      probability: 0.0,
      distanceKm: 0.0,
    );
  }

  AuroraViewingLocation copyWith({
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    double? probability,
    double? distanceKm,
  }) {
    return AuroraViewingLocation(
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      probability: probability ?? this.probability,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
