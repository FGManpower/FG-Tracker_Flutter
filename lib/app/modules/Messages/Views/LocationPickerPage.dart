import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';

import '../../../Model/LocationMessage.dart';
import '../../../config/themes_data.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final Location _location = Location();

  GoogleMapController? _mapController;

  LocationData? _currentLocation;

  LatLng? _selectedLatLng;

  String _selectedAddress = "Fetching location...";

  bool _isLoading = true;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();

        if (!serviceEnabled) {
          if (mounted) Navigator.pop(context);
          return;
        }
      }

      PermissionStatus permission =
      await _location.hasPermission();

      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();

        if (permission != PermissionStatus.granted) {
          if (mounted) Navigator.pop(context);
          return;
        }
      }

      final location = await _location.getLocation();

      _currentLocation = location;

      _selectedLatLng = LatLng(
        location.latitude!,
        location.longitude!,
      );

      _markers.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: _selectedLatLng!,
          draggable: true,
          onDragEnd: (latLng) {
            _updateSelectedLocation(latLng);
          },
        ),
      );

      await _getAddress(
        _selectedLatLng!,
      );

      setState(() {
        _isLoading = false;
      });

      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                _selectedLatLng!,
                17,
              ),
            );
          }
        },
      );
    } catch (e) {
      Get.snackbar(
        "Location Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _updateSelectedLocation(LatLng latLng,) async {
    _selectedLatLng = latLng;

    _markers.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId("selected_location"),
        position: latLng,
        draggable: true,
        onDragEnd: (value) {
          _updateSelectedLocation(value);
        },
      ),
    );

    setState(() {});

    await _getAddress(latLng);
  }

  Future<void> _getAddress(LatLng latLng,) async {
    try {
      final placemarks =
      await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return;

      final place = placemarks.first;

      _selectedAddress = [
        place.name,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ]
          .where(
            (e) =>
        e != null &&
            e
                .toString()
                .trim()
                .isNotEmpty,
      )
          .join(", ");

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _selectedAddress = "Unknown Location";

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ToggleThemeData.Appcolor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Share Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng!,
              zoom: 17,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) async {
              await _updateSelectedLocation(latLng);
            },
          ),

          Positioned(
            left: 15.w,
            right: 15.w,
            bottom: 20.h,
            child: _buildAddressCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  ToggleThemeData.Appcolor.withOpacity(.12),
                  child: Icon(
                    Icons.location_on,
                    color: ToggleThemeData.Appcolor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedAddress,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ToggleThemeData.Appcolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: _sendLocation,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Send Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ToggleThemeData.Appcolor,
                        side: BorderSide(
                          color: ToggleThemeData.Appcolor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: _shareLocation,
                      icon: Icon(
                        Icons.share,
                        color: ToggleThemeData.Appcolor,
                      ),
                      label: Text(
                        "Share Location",
                        style: TextStyle(
                          color: ToggleThemeData.Appcolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareLocation() {
    if (_selectedLatLng == null) return;

    final mapsUrl =
        "https://maps.google.com/?q=${_selectedLatLng!.latitude},${_selectedLatLng!.longitude}";

    final shareText = "$_selectedAddress\n$mapsUrl";

    Share.share(shareText);
  }

  void _sendLocation() {
    if (_selectedLatLng == null) return;

    final location = LocationMessage(
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
      locationName: _selectedAddress,
    );

    debugPrint(
      "SendLocation -> lat: ${location.latitude}, lng: ${location.longitude}, name: ${location.locationName}",
    );

    Get.back(result: location);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}