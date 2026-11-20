import 'dart:convert';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';

import '../../../Model/LocationMessage.dart';
import 'package:fgtracker/app/Core/util/app_log.dart';

class NearbyPlaceItem {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? distanceMeters;

  NearbyPlaceItem({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });
}

class LocationPickerController extends GetxController {
  final Location _location = Location();

  GoogleMapController? mapController;

  final Rxn<LocationData> currentLocation = Rxn<LocationData>();
  final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();

  static const String fetchingLocationValue = "Fetching location...";
  static const String unknownLocationValue = "Unknown Location";

  final RxString selectedPlaceName = "".obs;
  final RxString selectedAddress = fetchingLocationValue.obs;
  final RxString currentAddress = "".obs;
  final RxInt accuracyMeters = 15.obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingNearby = false.obs;
  final RxBool isSearching = false.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  final RxList<NearbyPlaceItem> nearbyPlaces = <NearbyPlaceItem>[].obs;
  final RxList<NearbyPlaceItem> searchResults = <NearbyPlaceItem>[].obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController liveCommentController = TextEditingController();

  /// Selected live location duration in minutes: 15, 60, 480
  final RxInt selectedLiveDuration = 60.obs;

  final RxnString errorMessage = RxnString();
  final RxBool permissionDenied = false.obs;

  @override
  void onReady() {
    super.onReady();
    _initializeLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    searchController.dispose();
    liveCommentController.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> retry() {
    errorMessage.value = null;
    permissionDenied.value = false;
    isLoading.value = true;
    return _initializeLocation();
  }

  bool _isGranted(PermissionStatus p) =>
      p == PermissionStatus.granted || p == PermissionStatus.grantedLimited;

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          errorMessage.value = appL10n.chat_locationServicesOff;
          isLoading.value = false;
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
      }
      if (!_isGranted(permission)) {
        permissionDenied.value = true;
        errorMessage.value = permission == PermissionStatus.deniedForever
            ? appL10n.chat_locationPermissionOff
            : appL10n.chat_locationPermissionNeeded;
        isLoading.value = false;
        return;
      }

      // Configure location settings for high accuracy GPS
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 5,
      );

      final LocationData location = await _location.getLocation();
      currentLocation.value = location;
      accuracyMeters.value = (location.accuracy ?? 15).round();

      final initialLatLng = LatLng(
        location.latitude!,
        location.longitude!,
      );
      selectedLatLng.value = initialLatLng;

      _updateMarker(initialLatLng);
      await _getAddress(initialLatLng, isCurrentLoc: true);
      _fetchNearbyPlaces(initialLatLng);

      isLoading.value = false;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mapController != null && selectedLatLng.value != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(selectedLatLng.value!, 17),
          );
        }
      });
    } catch (e) {
      AppLog.d("Location picker error: $e");
      errorMessage.value = appL10n.chat_locationFetchFailed;
      isLoading.value = false;
    }
  }

  void _updateMarker(LatLng latLng) {
    final double themeHue =
        HSVColor.fromColor(ToggleThemeData.Appcolor).hue;
    markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: latLng,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(themeHue),
          onDragEnd: updateSelectedLocation,
        ),
      );
  }

  Future<void> updateSelectedLocation(LatLng latLng) async {
    selectedLatLng.value = latLng;
    _updateMarker(latLng);
    await _getAddress(latLng);
    _fetchNearbyPlaces(latLng);
  }

  Future<void> recenterToCurrentLocation() async {
    if (currentLocation.value?.latitude != null &&
        currentLocation.value?.longitude != null) {
      final currentLatLng = LatLng(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );
      selectedLatLng.value = currentLatLng;
      _updateMarker(currentLatLng);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 17),
      );
      await _getAddress(currentLatLng);
      _fetchNearbyPlaces(currentLatLng);
    } else {
      _initializeLocation();
    }
  }

  Future<void> _getAddress(LatLng latLng, {bool isCurrentLoc = false}) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) {
        selectedAddress.value = unknownLocationValue;
        selectedPlaceName.value = "Selected Location";
        return;
      }

      final Placemark place = placemarks.first;
      final name = place.name?.trim().isNotEmpty == true
          ? place.name!.trim()
          : (place.street?.trim().isNotEmpty == true
              ? place.street!.trim()
              : (place.subLocality?.trim().isNotEmpty == true
                  ? place.subLocality!.trim()
                  : "Location"));

      final addrList = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();

      final fullAddress = addrList.join(", ");
      selectedPlaceName.value = name;
      selectedAddress.value = fullAddress.isNotEmpty ? fullAddress : name;

      if (isCurrentLoc) {
        currentAddress.value = selectedAddress.value;
      }
    } catch (_) {
      selectedAddress.value = unknownLocationValue;
      selectedPlaceName.value = "Selected Location";
    }
  }

  Future<void> _fetchNearbyPlaces(LatLng center) async {
    isLoadingNearby.value = true;
    try {
      final places = <NearbyPlaceItem>[];
      final apiKey = ConstRes.gMapApiKey;

      if (apiKey.isNotEmpty) {
        final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
          "?location=${center.latitude},${center.longitude}"
          "&radius=1000"
          "&key=$apiKey",
        );
        final response = await http.get(url).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["results"] is List) {
            for (final item in (data["results"] as List).take(15)) {
              final name = item["name"]?.toString() ?? "";
              final vicinity = item["vicinity"]?.toString() ?? "";
              final loc = item["geometry"]?["location"];
              if (name.isNotEmpty && loc != null) {
                final lat = (loc["lat"] as num).toDouble();
                final lng = (loc["lng"] as num).toDouble();
                final distance = Geolocator.distanceBetween(
                  center.latitude,
                  center.longitude,
                  lat,
                  lng,
                ).round();
                places.add(
                  NearbyPlaceItem(
                    name: name,
                    address: vicinity.isNotEmpty ? vicinity : name,
                    latitude: lat,
                    longitude: lng,
                    distanceMeters: distance,
                  ),
                );
              }
            }
          }
        }
      }

      // Fallback or augment with placemarks around center
      if (places.isEmpty) {
        final placemarks = await placemarkFromCoordinates(
          center.latitude,
          center.longitude,
        );
        for (final p in placemarks.take(6)) {
          final name = p.name ?? p.street ?? p.subLocality ?? "Nearby Place";
          final full = [p.street, p.subLocality, p.locality]
              .where((e) => e != null && e.isNotEmpty)
              .join(", ");
          places.add(
            NearbyPlaceItem(
              name: name,
              address: full.isNotEmpty ? full : name,
              latitude: center.latitude,
              longitude: center.longitude,
              distanceMeters: 0,
            ),
          );
        }
      }

      nearbyPlaces.assignAll(places);
    } catch (e) {
      AppLog.d("Error fetching nearby places: $e");
    } finally {
      isLoadingNearby.value = false;
    }
  }

  Future<void> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      final results = <NearbyPlaceItem>[];
      final apiKey = ConstRes.gMapApiKey;
      final center = selectedLatLng.value ??
          (currentLocation.value != null
              ? LatLng(currentLocation.value!.latitude!,
                  currentLocation.value!.longitude!)
              : const LatLng(28.6139, 77.2090));

      if (apiKey.isNotEmpty) {
        final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=${Uri.encodeComponent(q)}"
          "&location=${center.latitude},${center.longitude}"
          "&radius=50000"
          "&key=$apiKey",
        );
        final response =
            await http.get(url).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["predictions"] is List) {
            for (final p in (data["predictions"] as List).take(10)) {
              final desc = p["description"]?.toString() ?? "";
              final mainText = p["structured_formatting"]?["main_text"]
                      ?.toString() ??
                  desc;
              final secText = p["structured_formatting"]?["secondary_text"]
                      ?.toString() ??
                  "";
              results.add(
                NearbyPlaceItem(
                  name: mainText,
                  address: secText.isNotEmpty ? secText : desc,
                  latitude: center.latitude,
                  longitude: center.longitude,
                ),
              );
            }
          }
        }
      }

      // Fallback to native geocoding
      if (results.isEmpty) {
        final locations = await locationFromAddress(q);
        for (final loc in locations.take(5)) {
          final placemarks = await placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          final p = placemarks.isNotEmpty ? placemarks.first : null;
          final name = p?.name ?? q;
          final addr = [p?.street, p?.subLocality, p?.locality, p?.country]
              .where((e) => e != null && e.isNotEmpty)
              .join(", ");
          results.add(
            NearbyPlaceItem(
              name: name,
              address: addr.isNotEmpty ? addr : q,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          );
        }
      }

      searchResults.assignAll(results);
    } catch (e) {
      AppLog.d("Search error: $e");
    } finally {
      isSearching.value = false;
    }
  }

  void selectSearchResult(NearbyPlaceItem place) async {
    searchController.clear();
    searchResults.clear();
    isSearching.value = false;

    // If coordinates are exact, move map
    final target = LatLng(place.latitude, place.longitude);
    selectedLatLng.value = target;
    _updateMarker(target);
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 17),
    );
    await _getAddress(target);
    _fetchNearbyPlaces(target);
  }

  void sendCurrentLocation() {
    if (currentLocation.value?.latitude == null ||
        currentLocation.value?.longitude == null) {
      sendSelectedLocation();
      return;
    }

    final LocationMessage location = LocationMessage(
      latitude: currentLocation.value!.latitude!,
      longitude: currentLocation.value!.longitude!,
      locationName: currentAddress.value.isNotEmpty
          ? currentAddress.value
          : (selectedPlaceName.value.isNotEmpty
              ? selectedPlaceName.value
              : "Current Location"),
      address: currentAddress.value,
      isLive: false,
    );

    Get.back(result: location);
  }

  void sendSelectedLocation() {
    if (selectedLatLng.value == null) return;

    final LocationMessage location = LocationMessage(
      latitude: selectedLatLng.value!.latitude,
      longitude: selectedLatLng.value!.longitude,
      locationName: selectedPlaceName.value.isNotEmpty
          ? selectedPlaceName.value
          : selectedAddress.value,
      address: selectedAddress.value,
      isLive: false,
    );

    Get.back(result: location);
  }

  void sendNearbyPlace(NearbyPlaceItem place) {
    final LocationMessage location = LocationMessage(
      latitude: place.latitude,
      longitude: place.longitude,
      locationName: place.name,
      address: place.address,
      isLive: false,
    );

    Get.back(result: location);
  }

  void sendLiveLocation() {
    final lat = currentLocation.value?.latitude ??
        selectedLatLng.value?.latitude ??
        0.0;
    final lng = currentLocation.value?.longitude ??
        selectedLatLng.value?.longitude ??
        0.0;

    final now = DateTime.now().toUtc();
    final durationMins = selectedLiveDuration.value;
    final endTime = now.add(Duration(minutes: durationMins));
    final comment = liveCommentController.text.trim();

    final LocationMessage location = LocationMessage(
      latitude: lat,
      longitude: lng,
      locationName: selectedPlaceName.value.isNotEmpty
          ? selectedPlaceName.value
          : "Live Location",
      address: selectedAddress.value,
      isLive: true,
      durationMinutes: durationMins,
      startTime: now,
      endTime: endTime,
      comment: comment.isNotEmpty ? comment : null,
    );

    Get.back(result: location);
  }

  void shareLocation() {
    if (selectedLatLng.value == null) return;
    final String mapsUrl =
        "https://maps.google.com/?q=${selectedLatLng.value!.latitude},${selectedLatLng.value!.longitude}";
    final String shareText = "${selectedAddress.value}\n$mapsUrl";
    Share.share(shareText);
  }

  void sendLocation() {
    sendSelectedLocation();
  }
}
