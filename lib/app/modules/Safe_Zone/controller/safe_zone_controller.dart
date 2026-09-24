import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String description;
  final double latitude;
  final double longitude;

  PlaceSuggestion({
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}

class SafeZoneController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  GoogleMapController? individualMapController;
  GoogleMapController? groupMapController;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<PlaceSuggestion> suggestions = <PlaceSuggestion>[].obs;
  final RxBool isSearching = false.obs;

  final GetConnect _connect = GetConnect();

  final RxString selectedIndividualMember = 'Vikram Singh'.obs;
  final RxString memberPhone = '+91 98765 43211'.obs;

  final RxString selectedGroup = 'FG Manpower Team'.obs;

  final List<double> radiusOptions = [100.0, 250.0, 500.0, 1000.0, 2000.0, 5000.0];
  final RxInt individualRadiusIndex = 2.obs;
  final RxInt groupRadiusIndex = 2.obs;

  final Rx<LatLng> selectedLocation = const LatLng(19.0522, 72.8973).obs;
  final RxString locationName = 'Chembur, Mumbai'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    searchController.text = "Chembur, Mumbai";

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        updateMapZoom(isGroup: tabController.index == 1);
      }
    });

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (String query) {
      if (query.trim().length >= 3) {
        fetchAutocompleteSuggestions(query);
      } else {
        suggestions.clear();
      }
    }, time: const Duration(milliseconds: 200));
  }

  @override
  void onClose() {
    tabController.dispose();
    individualMapController?.dispose();
    groupMapController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  bool get isGroupTab => tabController.index == 1;

  double get individualRadius => radiusOptions[individualRadiusIndex.value];
  double get groupRadius => radiusOptions[groupRadiusIndex.value];

  double get currentRadius => isGroupTab ? groupRadius : individualRadius;

  double radiusFor({required bool isGroup}) {
    return isGroup ? groupRadius : individualRadius;
  }

  Future<void> fetchAutocompleteSuggestions(String query) async {
    if (query.trim() == locationName.value) return;

    try {
      isSearching.value = true;
      final response = await _connect.get(
        'https://nominatim.openstreetmap.org/search',
        query: {
          'q': query,
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
        },
        headers: {
          'User-Agent': 'SafeZoneApp/1.0',
        },
      );

      if (response.status.hasError) {
        isSearching.value = false;
        return;
      }

      final List<dynamic> data = response.body ?? [];
      suggestions.value = data.map((item) {
        final String displayName = item['display_name'] ?? '';
        final double lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
        final double lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
        return PlaceSuggestion(
          description: displayName,
          latitude: lat,
          longitude: lon,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    } finally {
      isSearching.value = false;
    }
  }

  void selectSuggestion(PlaceSuggestion suggestion) {
    selectedLocation.value = LatLng(suggestion.latitude, suggestion.longitude);

    final List<String> parts = suggestion.description.split(',');
    if (parts.length > 1) {
      final cleanText = "${parts[0].trim()}, ${parts[1].trim()}";
      locationName.value = cleanText;
      searchController.text = cleanText;
    } else {
      locationName.value = suggestion.description;
      searchController.text = suggestion.description;
    }

    suggestions.clear();
    updateMapZoom(isGroup: isGroupTab);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void searchLocation(String query) {
    if (query.trim().isEmpty) return;
    if (suggestions.isNotEmpty) {
      selectSuggestion(suggestions.first);
    } else {
      locationName.value = query.trim();
      reCenterMap(isGroup: isGroupTab);
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void clearSearch() {
    searchController.clear();
    suggestions.clear();
  }

  void onSliderChanged(double value, {required bool isGroup}) {
    if (isGroup) {
      groupRadiusIndex.value = value.round();
    } else {
      individualRadiusIndex.value = value.round();
    }
    updateMapZoom(isGroup: isGroup);
  }

  void onMapCreated(GoogleMapController controller, {required bool isGroup}) {
    if (isGroup) {
      groupMapController = controller;
    } else {
      individualMapController = controller;
    }
    updateMapZoom(isGroup: isGroup);
  }

  void updateMapZoom({required bool isGroup}) {
    final mapController = isGroup ? groupMapController : individualMapController;
    if (mapController == null) return;

    final radius = radiusFor(isGroup: isGroup);
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        selectedLocation.value,
        getZoomLevel(radius),
      ),
    );
  }

  void reCenterMap({required bool isGroup}) {
    updateMapZoom(isGroup: isGroup);
  }

  void zoomIn({required bool isGroup}) {
    final mapController = isGroup ? groupMapController : individualMapController;
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut({required bool isGroup}) {
    final mapController = isGroup ? groupMapController : individualMapController;
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  String formatRadius(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return "${km % 1 == 0 ? km.toInt() : km} km";
    }
    return "${meters.toInt()} m";
  }

  double getZoomLevel(double radiusMeters) {
    if (radiusMeters <= 100) return 16.8;
    if (radiusMeters <= 250) return 15.8;
    if (radiusMeters <= 500) return 14.8;
    if (radiusMeters <= 1000) return 13.8;
    if (radiusMeters <= 2000) return 12.8;
    return 11.5;
  }
}