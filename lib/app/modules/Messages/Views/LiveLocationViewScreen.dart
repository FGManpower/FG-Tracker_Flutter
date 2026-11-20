import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Model/LocationMessage.dart';
import '../../Track/Controller/TrackLiveLocationSocketService.dart';

class LiveLocationViewScreen extends StatefulWidget {
  final LocationMessage location;
  final bool isSentByMe;
  final String? senderName;
  final String? senderImage;
  final VoidCallback? onStopSharing;

  const LiveLocationViewScreen({
    super.key,
    required this.location,
    required this.isSentByMe,
    this.senderName,
    this.senderImage,
    this.onStopSharing,
  });

  @override
  State<LiveLocationViewScreen> createState() => _LiveLocationViewScreenState();
}

class _LiveLocationViewScreenState extends State<LiveLocationViewScreen> {
  GoogleMapController? _mapController;
  late LocationMessage _currentLocation;
  late bool _isEnded;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.location;
    _isEnded = widget.location.isEnded;
    _updateMarker();

    // Listen to real-time location stream
    TrackLiveLocationSocketService.instance.locationStream.listen((event) {
      if (mounted) {
        setState(() {
          _currentLocation = _currentLocation.copyWith(
            latitude: event.lat,
            longitude: event.lng,
          );
          _updateMarker();
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(event.lat, event.lng)),
        );
      }
    });
  }

  void _updateMarker() {
    final double themeHue =
        HSVColor.fromColor(ToggleThemeData.Appcolor).hue;
    _markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId("live_user_marker"),
          position: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(themeHue),
          infoWindow: InfoWindow(
            title: widget.senderName ?? "Live Location",
            snippet: _currentLocation.address ?? _currentLocation.locationName,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.senderName?.trim().isNotEmpty == true
        ? widget.senderName!
        : (widget.isSentByMe ? "You" : "Contact");

    final image = widget.senderImage ?? "";
    final imageUrl = image.startsWith('http://') || image.startsWith('https://')
        ? image
        : "${ConstRes.aImageBaseUrl}$image";

    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDark ? ToggleThemeData.darkThemeBackground : ToggleThemeData.Appcolor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.white24,
              backgroundImage:
                  image.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null,
              child: image.isEmpty
                  ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isEnded
                        ? "Live location ended"
                        : _currentLocation.liveUntilText,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: _isEnded ? Colors.white60 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentLocation.latitude,
                _currentLocation.longitude,
              ),
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
            markers: _markers,
            onMapCreated: (ctrl) => _mapController = ctrl,
          ),

          // Bottom Info Card
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 24.h,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? ToggleThemeData.BlackMatte : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: _isEnded
                              ? Colors.grey.shade200
                              : ToggleThemeData.Appcolor.withValues(alpha: 0.15),
                          child: Icon(
                            _isEnded
                                ? Icons.location_off_outlined
                                : Icons.share_location_rounded,
                            color: _isEnded
                                ? Colors.grey.shade600
                                : ToggleThemeData.Appcolor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEnded
                                    ? "Live location ended"
                                    : "Live location active",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E202B),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _currentLocation.address ??
                                    _currentLocation.locationName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_currentLocation.comment != null &&
                        _currentLocation.comment!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.comment_outlined,
                                size: 16.sp, color: Colors.grey.shade600),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _currentLocation.comment!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: _openDirections,
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text("Directions"),
                            ),
                          ),
                        ),
                        if (widget.isSentByMe && !_isEnded) ...[
                          SizedBox(width: 10.w),
                          Expanded(
                            child: SizedBox(
                              height: 44.h,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => _isEnded = true);
                                  widget.onStopSharing?.call();
                                  Get.back();
                                },
                                icon: const Icon(Icons.stop_rounded, size: 18),
                                label: const Text("Stop sharing"),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${_currentLocation.latitude},${_currentLocation.longitude}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
