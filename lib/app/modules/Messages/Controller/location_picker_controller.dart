import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';

import '../../../Model/LocationMessage.dart';

class LocationPickerController extends GetxController {
  final Location _location = Location();

  GoogleMapController? mapController;

  final Rxn<LocationData> currentLocation = Rxn<LocationData>();
  final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();
  final RxString selectedAddress = "Fetching location...".obs;
  final RxBool isLoading = true.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onReady() {
    super.onReady();
    _initializeLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          Get.back();
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          Get.back();
          return;
        }
      }

      final LocationData location = await _location.getLocation();
      currentLocation.value = location;

      selectedLatLng.value = LatLng(
        location.latitude!,
        location.longitude!,
      );

      _updateMarker(selectedLatLng.value!);

      await _getAddress(selectedLatLng.value!);

      isLoading.value = false;

      /// Animate camera after slight delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mapController != null && selectedLatLng.value != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(selectedLatLng.value!, 17),
          );
        }
      });
    } catch (e) {
      Get.snackbar(
        "Location Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  void _updateMarker(LatLng latLng) {
    markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: latLng,
          draggable: true,
          onDragEnd: updateSelectedLocation,
        ),
      );
  }

  Future<void> updateSelectedLocation(LatLng latLng) async {
    selectedLatLng.value = latLng;
    _updateMarker(latLng);
    await _getAddress(latLng);
  }

  Future<void> _getAddress(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return;

      final Placemark place = placemarks.first;

      selectedAddress.value = [
        place.name,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ]
          .where(
            (e) => e != null && e.toString().trim().isNotEmpty,
      )
          .join(", ");
    } catch (_) {
      selectedAddress.value = "Unknown Location";
    }
  }

  void shareLocation() {
    if (selectedLatLng.value == null) return;

    final String mapsUrl =
        "https://maps.google.com/?q=${selectedLatLng.value!.latitude},${selectedLatLng.value!.longitude}";

    final String shareText = "${selectedAddress.value}\n$mapsUrl";

    Share.share(shareText);
  }

  void sendLocation() {
    if (selectedLatLng.value == null) return;

    final LocationMessage location = LocationMessage(
      latitude: selectedLatLng.value!.latitude,
      longitude: selectedLatLng.value!.longitude,
      locationName: selectedAddress.value,
    );

    debugPrint(
      "SendLocation -> lat: ${location.latitude}, "
          "lng: ${location.longitude}, name: ${location.locationName}",
    );

    Get.back(result: location);
  }
}