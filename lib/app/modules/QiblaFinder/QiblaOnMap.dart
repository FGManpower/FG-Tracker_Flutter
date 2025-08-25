import 'dart:async';
import 'dart:math' show asin, atan2, cos, pi, sin, sqrt;

import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:flutter_compass/flutter_compass.dart';

class QiblaController extends GetxController {
  var currentPosition = Rxn<LatLng>();
  var distance = 0.0.obs;
  var bearing = 0.0.obs;
  var heading = 0.0.obs;
  BitmapDescriptor? kaabaIcon;

  final LatLng kaabaLocation = const LatLng(21.4225, 39.8262);

  @override
  void onInit() {
    super.onInit();
    _loadKaabaMarker();
    _getCurrentLocation();
    _listenToCompass();
  }

  Future<void> _loadKaabaMarker() async {
    final BitmapDescriptor bitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(02, 02)),
      'assets/images/kaaba.png',
    );
    kaabaIcon = bitmap;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      currentPosition.value = LatLng(position.latitude, position.longitude);
      distance.value = _calculateDistance(
        position.latitude,
        position.longitude,
        kaabaLocation.latitude,
        kaabaLocation.longitude,
      );
      bearing.value = _calculateBearing(
        position.latitude,
        position.longitude,
        kaabaLocation.latitude,
        kaabaLocation.longitude,
      );
    }
  }

  void _listenToCompass() {
    FlutterCompass.events!.listen((event) {
      heading.value = event.heading ?? 0;
    });
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double _calculateBearing(lat1, lon1, lat2, lon2) {
    final dLon = vector.radians(lon2 - lon1);
    final y = sin(dLon) * cos(vector.radians(lat2));
    final x = cos(vector.radians(lat1)) * sin(vector.radians(lat2)) -
        sin(vector.radians(lat1)) * cos(vector.radians(lat2)) * cos(dLon);
    final brng = atan2(y, x);
    return (vector.degrees(brng) + 360) % 360;
  }
}

class QiblaOnMap extends StatefulWidget {
  const QiblaOnMap({super.key});

  @override
  State<QiblaOnMap> createState() => _QiblaOnMapState(); // Capital "O"
}
class _QiblaOnMapState extends State<QiblaOnMap> {
  final controller = Get.put(QiblaController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => controller.currentPosition.value == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.currentPosition.value!,
              zoom: 0,
              bearing: 280,tilt: 1.35
            ),
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("current"),
                position: controller.currentPosition.value!,
                infoWindow: const InfoWindow(title: "You"),
              ),
              if (controller.kaabaIcon != null)
                Marker(
                  markerId: const MarkerId("kaaba"),
                  position: controller.kaabaLocation,
                  infoWindow: const InfoWindow(title: "Kaaba"),
                  icon: controller.kaabaIcon!,
                ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("path"),
                color: Colors.green,
                width: 4,
                points: [
                  controller.currentPosition.value!,
                  controller.kaabaLocation,
                ],
              )
            },
          )),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Compass Rotation & Info
          Positioned(
            bottom: 30.h,
            left: 16.w,
            right: 16.w,
            child: Obx(() => controller.distance.value == 0.0
                ? const SizedBox()
                : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                   reausabletext("Qibla Direction",

                          fontsize: 18.sp, fontweight: FontWeight.bold),
                   SizedBox(height: 8.h),
                  reausabletext(
                    "Distance to Kaaba: ${controller.distance.value.toStringAsFixed(2)} km",
                   fontsize: 16.sp
                  ),
                   SizedBox(height: 8.h),
                  Transform.rotate(
                    angle: -2 * pi * (controller.heading.value / 360),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(
                        controller.bearing.value * pi / 180,
                      ),
                      // child: Image.asset('assets/images/kaaba.png', width: 60),
                    ),
                  ),
                   SizedBox(height: 4.h),
                  reausabletext(
                    "Bearing: ${controller.bearing.value.toStringAsFixed(2)}°",
                        fontsize: 14.sp, color: Colors.grey),
                ],
              ),
            )),
          ),


        ],
      ),
    );
  }
}
