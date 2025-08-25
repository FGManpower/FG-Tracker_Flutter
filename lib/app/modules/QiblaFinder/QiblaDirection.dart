import 'dart:math';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:fgtracker/app/modules/QiblaFinder/QiblaOnMap.dart';
import 'package:fgtracker/app/widgets/cutom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';

import '../../global_widget/common_widget.dart';
import 'compass_customPainter.dart';

class Qibladirection extends StatefulWidget {
  const Qibladirection({super.key});

  @override
  State<Qibladirection> createState() => _HomePageState();
}

class _HomePageState extends State<Qibladirection> {
  Future<Position>? getPosition;

  @override
  void initState() {
    super.initState();
    getPosition = _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isFacingQibla = false;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: reusableAppbar(
      //   "Qibla Direction",
      // ),

        body: Stack(
          children: [
            // 🔹 Background Image

            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.fitHeight,
              ),
            ),

            // 🔹 Blue fading shade overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.blue.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Qibla and Location Logic
            Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: FutureBuilder<Position>(
                future: getPosition,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final position = snapshot.data!;
                  final coordinates = Coordinates(position.latitude, position.longitude);
                  final qiblaDirection = Qibla.qibla(coordinates);

                  return FutureBuilder<List<Placemark>>(
                    future: placemarkFromCoordinates(position.latitude, position.longitude),
                    builder: (context, addressSnapshot) {
                      Widget locationWidget = const Text(
                        'Fetching location...',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      );

                      if (addressSnapshot.hasData && addressSnapshot.data!.isNotEmpty) {
                        final placemark = addressSnapshot.data!.first;
                        locationWidget = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "${placemark.locality}, ${placemark.country}",
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          locationWidget,
                          SizedBox(height: 10.h),

                          Expanded(
                            child: StreamBuilder<CompassEvent>(
                              stream: FlutterCompass.events,
                              builder: (context, compassSnapshot) {
                                if (compassSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                                }
                                if (compassSnapshot.hasError) {
                                  return Text('Error reading heading: ${compassSnapshot.error}');
                                }

                                final direction = compassSnapshot.data?.heading;
                                bool isFacingQibla = false;
                                if (direction != null) {
                                  final normalized = (direction + 360) % 360;
                                  isFacingQibla = normalized >= 270 && normalized <= 300;
                                }

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Direction: ${direction?.toStringAsFixed(1)}° | Qibla: ${qiblaDirection.toStringAsFixed(1)}°',
                                        style: const TextStyle(color: Colors.black, fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 220.h),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(200.r),
                                            topRight: Radius.circular(200.r),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isFacingQibla ? Colors.green : Colors.grey.shade400,
                                              width: 5,
                                            ),
                                            boxShadow: isFacingQibla
                                                ? [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.4),
                                                blurRadius: 25,
                                                spreadRadius: 8,
                                              ),
                                            ]
                                                : [],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CustomPaint(size: size, painter: CompassBackgroundPainter()),
                                              Transform.rotate(
                                                angle: -2 * pi * (direction! / 360),
                                                child: Transform(
                                                  alignment: Alignment.center,
                                                  transform: Matrix4.rotationZ(qiblaDirection * pi / 180),
                                                  child: Image.asset('assets/images/kaaba.png', width: 60),
                                                ),
                                              ),
                                              CircleAvatar(
                                                backgroundColor: Colors.transparent,
                                                radius: 140,
                                                child: Transform.rotate(
                                                  angle: -2 * pi * (direction / 360),
                                                  child: Transform(
                                                    alignment: Alignment.center,
                                                    transform: Matrix4.rotationZ(qiblaDirection * pi / 180),
                                                    child: const Align(
                                                      alignment: Alignment.topCenter,
                                                      child: Icon(
                                                        Icons.expand_less_outlined,
                                                        color: Colors.black,
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (isFacingQibla)
                                                 Align(
                                                  alignment: Alignment(0, 0.45),
                                                  child: reausabletext(
                                                    "You're facing Makkah!",

                                                      color: Colors.green,
                                                      fontweight: FontWeight.bold,
                                                      fontsize: 16,

                                                  ),
                                                ),
                                              Positioned (
                                                  bottom: -0.h,
                                                  left: 235.w,
                                                  right: -10,
                                                  child:
                                              reausablebutton(backgroundColor: Colors.transparent,
                                                fontSize: 12,borderradiues: 5,
                                                title: "View On Map",
                                                height: 20,
                                                width: 80,
                                                textcolor: Colors.black,
                                                ontap: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> QiblaOnMap()));
                                                },)
                                              )
                                            ],
                                          ),

                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: 60.h, // adjust as needed for safe area
              left: 16.w,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 7.h,left: 7.w,bottom: 7.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  size: 25,
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

String showHeading(double currentHeading, double qibla) {
  List<String> headings = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  int index = (((currentHeading + 22.5) % 360) / 45).floor();
  return headings[index % 8];
}

class CompassBackgroundPainter extends CustomPainter {
  final List<String> directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw 8 directional labels
    final directionStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < 8; i++) {
      double angle = (i * 45) * pi / 180;
      final dx = center.dx + (radius - 20) * cos(angle);
      final dy = center.dy + (radius - 20) * sin(angle);

      final text = TextSpan(text: directions[i], style: directionStyle);
      final tp = TextPainter(
        text: text,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(dx - tp.width / 2, dy - tp.height / 2));
    }

    // Draw degree labels every 30°
    final degreeStyle = TextStyle(color: Colors.grey.shade800, fontSize: 10);
    for (int i = 0; i < 360; i += 30) {
      double angle = i * pi / 180;
      final dx = center.dx + (radius - 8) * cos(angle);
      final dy = center.dy + (radius - 8) * sin(angle);

      final label = TextSpan(text: '$i°', style: degreeStyle);
      final tp = TextPainter(
        text: label,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(dx - tp.width / 2, dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
