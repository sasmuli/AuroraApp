import 'package:flutter/material.dart';

class AuroraMarker {
  final double latitude;
  final double longitude;
  final double probability;
  final Color color;

  AuroraMarker({
    required this.latitude,
    required this.longitude,
    required this.probability,
    required this.color,
  });
}
