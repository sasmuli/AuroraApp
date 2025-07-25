import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:aurora_app/domain/models/aurora_viewing_location.dart';
import 'package:aurora_app/domain/repositories/aurora_repository.dart';
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/presentation/controllers/MapPage/map_controller.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

class BestAuroraPlacesController extends GetxController {
  final MapController mapController_ = Get.find<MapController>();
  final AuroraRepository auroraRepository = Get.find<AuroraRepository>();

  late GoogleMapController mapController;
  final styleString = ''.obs;
  final Rx<latlong.LatLng?> userLocation = Rx<latlong.LatLng?>(null);

  final RxList<AuroraViewingLocation> bestAuroraPlaces =
      <AuroraViewingLocation>[].obs;
  final RxList<AuroraViewingLocation> allAuroraPlaces =
      <AuroraViewingLocation>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxSet<Marker> markers = <Marker>{}.obs;

  // Timer for automatic updates every 5 minutes
  Timer? _updateTimer;

  // Filter properties
  final RxList<String> selectedCountries = <String>[].obs;
  final RxList<String> availableCountries = <String>[].obs;
  final RxDouble minProbability = 10.0.obs;

  LatLng get initialCameraTarget {
    final current = mapController_.currentLocation.value;
    if (current != null) {
      return LatLng(current.latitude, current.longitude);
    }
    return const LatLng(64.0, 26.0);
  }

  @override
  void onInit() {
    super.onInit();
    loadMapStyle();
    loadBestAuroraPlaces();
    startAutoUpdate();

    ever(mapController_.currentLocation, (location) {
      if (location != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 5,
            ),
          ),
        );
      }
    });
  }

  Future<void> loadBestAuroraPlaces() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<AuroraViewingLocation> allPlaces =
          await loadAuroraPlacesFromJson();
      logger.i('Loaded ${allPlaces.length} places from JSON');

      final auroraMarkers = await auroraRepository.getAuroraMarkers();
      logger.i('Loaded ${auroraMarkers.length} aurora markers from repository');

      final List<AuroraViewingLocation> placesWithProbabilities = [];

      for (final place in allPlaces) {
        final probability = calculateProbabilityForLocation(
          place,
          auroraMarkers,
        );
        final userLoc = mapController_.currentLocation.value;
        final distance = userLoc != null
            ? Geolocator.distanceBetween(
                    userLoc.latitude,
                    userLoc.longitude,
                    place.latitude,
                    place.longitude,
                  ) /
                  1000.0
            : 0.0;

        placesWithProbabilities.add(
          place.copyWith(probability: probability, distanceKm: distance),
        );
      }

      // Store all places with probabilities
      allAuroraPlaces.value = placesWithProbabilities;

      // Extract available countries
      final countries = placesWithProbabilities
          .map((place) => place.country)
          .toSet()
          .toList();
      countries.sort();
      availableCountries.value = countries;

      // Apply filters
      applyFilters();
      logger.i('Loaded ${allAuroraPlaces.length} places with probabilities');
      logger.i('Available countries: ${availableCountries.join(", ")}');
      logger.i('Final filtered list has ${bestAuroraPlaces.length} places');

      createMarkers();
    } catch (e) {
      errorMessage.value = 'Failed to load aurora places: $e';
      logger.i('Error loading aurora places: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<AuroraViewingLocation>> loadAuroraPlacesFromJson() async {
    final String jsonString = await rootBundle.loadString('aurora_places.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<AuroraViewingLocation> allPlaces = [];

    jsonData.forEach((country, places) {
      if (places is List) {
        for (final place in places) {
          allPlaces.add(AuroraViewingLocation.fromJson(place, country));
        }
      }
    });

    return allPlaces;
  }

  double calculateProbabilityForLocation(
    AuroraViewingLocation location,
    List auroraMarkers,
  ) {
    double maxProbability = 0.0;
    const double searchRadius = 10.0;

    for (final marker in auroraMarkers) {
      final distance =
          Geolocator.distanceBetween(
            location.latitude,
            location.longitude,
            marker.latitude,
            marker.longitude,
          ) /
          1000.0;

      final distanceInDegrees = distance / 111.0;

      if (distanceInDegrees <= searchRadius) {
        final probabilityPercentage = marker.probability * 100;
        maxProbability = max(maxProbability, probabilityPercentage);
      }
    }

    return maxProbability;
  }

  void createMarkers() {
    markers.clear();
    logger.i('Creating markers for ${bestAuroraPlaces.length} places');

    for (int i = 0; i < bestAuroraPlaces.length; i++) {
      final place = bestAuroraPlaces[i];
      final marker = Marker(
        markerId: MarkerId('place_$i'),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: '${place.name}, ${place.country}',
          snippet:
              '${place.probability.toStringAsFixed(1)}% aurora probability',
        ),
        anchor: const Offset(0.5, 1.0),
      );
      markers.add(marker);
    }

    markers.refresh();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void moveToPlace(int index) {
    if (index < bestAuroraPlaces.length) {
      final place = bestAuroraPlaces[index];
      final location = LatLng(place.latitude, place.longitude);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 8),
        ),
      );
    }
  }

  void refreshData() {
    loadBestAuroraPlaces();
    startAutoUpdate();
  }

  Future<void> loadMapStyle() async {
    final style = await rootBundle.loadString(
      'assets/map_styles/dark_map.json',
    );
    styleString.value = style;
  }

  void applyFilters() {
    List<AuroraViewingLocation> filtered = allAuroraPlaces.toList();

    filtered = filtered
        .where((place) => place.probability >= minProbability.value)
        .toList();

    if (selectedCountries.isNotEmpty) {
      filtered = filtered
          .where((place) => selectedCountries.contains(place.country))
          .toList();
    }

    filtered.sort((a, b) => b.probability.compareTo(a.probability));

    bestAuroraPlaces.value = filtered.take(30).toList();

    logger.i(
      'Applied filters: minProbability=${minProbability.value}%, countries=${selectedCountries.join(", ")}',
    );
    logger.i('Filtered results: ${bestAuroraPlaces.length} places');

    createMarkers();
  }

  void updateCountryFilter(List<String> countries) {
    selectedCountries.value = countries;
    applyFilters();
  }

  void updateProbabilityFilter(double minProb) {
    minProbability.value = minProb;
    applyFilters();
  }

  void clearFilters() {
    selectedCountries.clear();
    minProbability.value = 10.0;
    applyFilters();
  }

  void startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      logger.i('Auto-updating aurora places data...');
      loadBestAuroraPlaces();
    });

    logger.i('Started automatic updates every 5 minutes');
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    logger.i('Cancelled automatic updates timer');
    super.onClose();
  }
}
