import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/modules/Track/Widget/Track_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart'
    show MapFilterBadge;
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  final HomeController controller = Get.find<HomeController>();

  GoogleMapController? _googleMapController;

  final Rx<Set<Marker>> _markers = Rx<Set<Marker>>(<Marker>{});

  final Rx<Set<Circle>> _circles = Rx<Set<Circle>>(<Circle>{});

  final Map<String, BitmapDescriptor> _markerIconCache = {};

  Worker? _locationWorker;
  Worker? _currentLocationWorker;
  Worker? _radiusWorker;

  int _markerRequestId = 0;

  @override
  void initState() {
    super.initState();

    _locationWorker = ever<List<LiveLocationModel>>(
      controller.liveLocations,
      (_) {
        _loadMarkers();
      },
    );

    _currentLocationWorker = ever<LatLng?>(
      controller.currentLocation,
      (_) {
        _loadMarkers();
      },
    );

    _radiusWorker = ever<String>(
      controller.selectedRadius,
      (_) {
        _loadMarkers();
      },
    );

    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final int requestId = ++_markerRequestId;

    try {
      final List<LiveLocationModel> locations = List<LiveLocationModel>.from(
        controller.liveLocations,
      );

      final Set<Marker> initialMarkers = <Marker>{};

      for (final member in locations) {
        final String cacheKey =
            '${member.userId}_${member.profileImage}_${member.isOnline}';
        final BitmapDescriptor icon = _markerIconCache[cacheKey] ??
            BitmapDescriptor.defaultMarkerWithHue(
              member.isOnline
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            );

        initialMarkers.add(
          Marker(
            markerId: MarkerId(
              'member_${member.userId}_${member.latitude}_${member.longitude}',
            ),
            position: LatLng(
              member.latitude,
              member.longitude,
            ),
            icon: icon,
            anchor: const Offset(0.5, 1.0),
            infoWindow: InfoWindow(
              title: member.fullName,
              snippet: member.isOnline ? 'Online' : 'Offline',
            ),
            onTap: () {
              _showMemberDetails(member);
            },
          ),
        );
      }

      final LatLng? myLocation = controller.currentLocation.value;
      if (myLocation != null &&
          myLocation.latitude != 0.0 &&
          myLocation.longitude != 0.0) {
        final String myImg = controller.userData.value.profileImage ?? '';
        final String cacheKey = 'me_$myImg';
        final BitmapDescriptor myIcon = _markerIconCache[cacheKey] ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            );

        initialMarkers.add(
          Marker(
            markerId: const MarkerId('current_user_marker'),
            position: myLocation,
            icon: myIcon,
            anchor: const Offset(0.5, 1.0),
            zIndex: 10.0,
            infoWindow: const InfoWindow(
              title: 'You',
              snippet: 'Current Location',
            ),
          ),
        );
      }

      if (!mounted) return;

      _markers.value = initialMarkers;
      _circles.value = _buildRadiusCircle(locations);

      _fitAllMembers();

      final List<Future<void>> iconTasks = [];
      for (final member in locations) {
        final String cacheKey =
            '${member.userId}_${member.profileImage}_${member.isOnline}';
        if (!_markerIconCache.containsKey(cacheKey)) {
          iconTasks.add(() async {
            try {
              final custom = await getCustomIcon(
                member.profileImage,
                member.isOnline,
              );
              _markerIconCache[cacheKey] = custom;
            } catch (_) {}
          }());
        }
      }

      if (myLocation != null) {
        final String myImg = controller.userData.value.profileImage ?? '';
        final String cacheKey = 'me_$myImg';
        if (!_markerIconCache.containsKey(cacheKey)) {
          iconTasks.add(() async {
            try {
              final custom = await getCustomIcon(myImg, true, isMe: true);
              _markerIconCache[cacheKey] = custom;
            } catch (_) {}
          }());
        }
      }

      if (iconTasks.isNotEmpty) {
        await Future.wait(iconTasks);
        if (mounted && requestId == _markerRequestId) {
          final Set<Marker> updatedMarkers = <Marker>{};
          for (final member in locations) {
            final String cacheKey =
                '${member.userId}_${member.profileImage}_${member.isOnline}';
            final icon = _markerIconCache[cacheKey] ??
                BitmapDescriptor.defaultMarkerWithHue(
                  member.isOnline
                      ? BitmapDescriptor.hueGreen
                      : BitmapDescriptor.hueRed,
                );
            updatedMarkers.add(
              Marker(
                markerId: MarkerId(
                  'member_${member.userId}_${member.latitude}_${member.longitude}',
                ),
                position: LatLng(
                  member.latitude,
                  member.longitude,
                ),
                icon: icon,
                anchor: const Offset(0.5, 1.0),
                infoWindow: InfoWindow(
                  title: member.fullName,
                  snippet: member.isOnline ? 'Online' : 'Offline',
                ),
                onTap: () {
                  _showMemberDetails(member);
                },
              ),
            );
          }
          if (myLocation != null) {
            final String myImg = controller.userData.value.profileImage ?? '';
            final String cacheKey = 'me_$myImg';
            final myIcon = _markerIconCache[cacheKey] ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                );
            updatedMarkers.add(
              Marker(
                markerId: const MarkerId('current_user_marker'),
                position: myLocation,
                icon: myIcon,
                anchor: const Offset(0.5, 1.0),
                zIndex: 10.0,
                infoWindow: const InfoWindow(
                  title: 'You',
                  snippet: 'Current Location',
                ),
              ),
            );
          }
          _markers.value = updatedMarkers;
        }
      }
    } catch (error) {
      debugPrint('Live marker error: $error');
    }
  }

  Set<Circle> _buildRadiusCircle(
    List<LiveLocationModel> locations,
  ) {
    final LatLng? centerLocation = controller.currentLocation.value ??
        (locations.isNotEmpty
            ? LatLng(locations.first.latitude, locations.first.longitude)
            : null);

    if (centerLocation == null) {
      return <Circle>{};
    }

    final double radiusKm =
        double.tryParse(controller.selectedRadius.value) ?? 2.0;

    return <Circle>{
      Circle(
        circleId: const CircleId(
          'live_tracking_radius',
        ),
        center: centerLocation,
        radius: radiusKm * 1000,
        fillColor: const Color(0xFF6B4DFF).withValues(alpha: 0.12),
        strokeColor: const Color(0xFF6B4DFF).withValues(alpha: 0.50),
        strokeWidth: 1,
      ),
    };
  }

  LatLng? _getInitialPosition() {
    if (controller.currentLocation.value != null &&
        controller.currentLocation.value!.latitude != 0.0 &&
        controller.currentLocation.value!.longitude != 0.0) {
      return controller.currentLocation.value;
    }

    if (controller.liveLocations.isNotEmpty) {
      final LiveLocationModel firstMember = controller.liveLocations.first;
      return LatLng(
        firstMember.latitude,
        firstMember.longitude,
      );
    }

    return null;
  }

  Future<void> _fitAllMembers() async {
    final GoogleMapController? mapController = _googleMapController;

    final List<LiveLocationModel> locations = List<LiveLocationModel>.from(
      controller.liveLocations,
    );

    final LatLng? myLocation = controller.currentLocation.value;

    if (mapController == null) {
      return;
    }

    if (locations.isEmpty && myLocation == null) {
      return;
    }

    if (locations.isEmpty && myLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: myLocation, zoom: 15),
        ),
      );
      return;
    }

    double minLatitude = myLocation?.latitude ?? locations.first.latitude;
    double maxLatitude = myLocation?.latitude ?? locations.first.latitude;
    double minLongitude = myLocation?.longitude ?? locations.first.longitude;
    double maxLongitude = myLocation?.longitude ?? locations.first.longitude;

    for (final member in locations) {
      if (member.latitude < minLatitude) {
        minLatitude = member.latitude;
      }

      if (member.latitude > maxLatitude) {
        maxLatitude = member.latitude;
      }

      if (member.longitude < minLongitude) {
        minLongitude = member.longitude;
      }

      if (member.longitude > maxLongitude) {
        maxLongitude = member.longitude;
      }
    }

    if (minLatitude == maxLatitude) {
      minLatitude -= 0.005;
      maxLatitude += 0.005;
    }

    if (minLongitude == maxLongitude) {
      minLongitude -= 0.005;
      maxLongitude += 0.005;
    }

    try {
      await mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              minLatitude,
              minLongitude,
            ),
            northeast: LatLng(
              maxLatitude,
              maxLongitude,
            ),
          ),
          55,
        ),
      );
    } catch (error) {
      debugPrint('Map camera error: $error');
      try {
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                (minLatitude + maxLatitude) / 2,
                (minLongitude + maxLongitude) / 2,
              ),
              zoom: 14,
            ),
          ),
        );
      } catch (_) {}
    }
  }

  String getProfileImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    return '${ConstRes.aImageBaseUrl}$imagePath';
  }

  void _showMemberDetails(
      LiveLocationModel member,
      ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: const Color(0xFFE8E8FF),
                backgroundImage: member.profileImage.isNotEmpty
                    ? NetworkImage(
                  getProfileImageUrl(
                    member.profileImage,
                  ),
                )
                    : null,
                child: member.profileImage.isEmpty
                    ? Icon(
                  Icons.person,
                  size: 32.sp,
                  color: const Color(0xFF6B4DFF),
                )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      member.fullName,
                      fontsize: 16.sp,
                      fontfamily: FontFamily.interBold,
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Container(
                          width: 9.w,
                          height: 9.w,
                          decoration: BoxDecoration(
                            color: member.isOnline ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        reausabletext(
                          member.isOnline ? 'Online' : 'Offline',
                          fontsize: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 5.h,
        ),
        child: Column(
          children: [
            _header(),
            SizedBox(height: 15.h),

            LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                final double mapHeight = (constraints.maxWidth * 0.56)
                    .clamp(180.0, 270.0)
                    .toDouble();

                return Container(
                  height: mapHeight,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Stack(
                    children: [
                      Obx(
                        () => GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _getInitialPosition() ??
                                const LatLng(18.969458, 72.830956),
                            zoom: 15,
                          ),
                          markers: _markers.value,
                          circles: _circles.value,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: false,
                          mapToolbarEnabled: false,
                          compassEnabled: false,
                          buildingsEnabled: true,
                          mapType: MapType.normal,
                          onMapCreated: (mapController) {
                            _googleMapController = mapController;

                            Future.delayed(
                              const Duration(
                                milliseconds: 600,
                              ),
                              _fitAllMembers,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 16.h,
                        right: 12.w,
                        child: Column(
                          children: [
                            _mapButton(
                              icon: Icons.add,
                              onTap: () {
                                _googleMapController?.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              },
                            ),
                            SizedBox(height: 5.h),
                            _mapButton(
                              icon: Icons.remove,
                              onTap: () {
                                _googleMapController?.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            _mapButton(
                              icon: Icons.my_location,
                              onTap: _fitAllMembers,
                            ),
                            SizedBox(height: 8.h),
                            _sosButton(),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 12.w,
                        bottom: 12.h,
                        child: _membersCountView(
                          controller,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Color(0xFF6B4DFF),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            reausabletext(
              'Live Tracking',
              fontsize: 12.sp,
              fontfamily: FontFamily.interBold,
            ),
          ],
        ),
        MapFilterBadge(
          text: 'All Groups',
          icon: Icons.keyboard_arrow_down,
          onTap: () {},
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          flex: 2,
          child: Obx(() {
            return PopupMenuButton<String>(
              offset: const Offset(0, 46),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                controller.updateRadius(double.parse(value));
              },
              itemBuilder: (context) => ["2", "4", "6", "8"]
                  .map(
                    (r) => PopupMenuItem<String>(
                  value: r,
                  height: 40.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$r km",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (controller.selectedRadius.value == r)
                        Icon(Icons.check,
                            color: Color(0xFF5C4CFF), size: 16),
                    ],
                  ),
                ),
              )
                  .toList(),
              child: Container(
                height: 35.h,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, color: Color(0xFF5C4CFF), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Radius: ${controller.selectedRadius.value} km",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _loadingView() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6B4DFF),
        ),
      ),
    );
  }

  Widget _membersCountView(
    HomeController homeController,
  ) {
    return Obx(() {
      final int totalMembers = homeController.liveLocations.length;
      final int onlineCount = homeController.liveLocations
          .where((member) => member.isOnline)
          .length;
      final int countToShow = onlineCount > 0 ? onlineCount : totalMembers;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 7.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.group,
              size: 15.sp,
              color: const Color(0xFF6B4DFF),
            ),
            SizedBox(width: 6.w),
            reausabletext(
              '$countToShow Members Live',
              fontsize: 11.sp,
              fontfamily: FontFamily.interSemiBold,
            ),
          ],
        ),
      );
    });
  }

  Widget _radiusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.my_location,
            size: 15.sp,
            color: const Color(0xFF6B4DFF),
          ),
          SizedBox(width: 5.w),
          reausabletext(
            'Radius: 2 km',
            fontsize: 11.sp,
          ),
        ],
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(9.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9.r),
        child: Padding(
          padding: EdgeInsets.all(7.w),
          child: Icon(
            icon,
            size: 18.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _sosButton() {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.SOSScreen);
      },
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "SOS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.interBold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationWorker?.dispose();
    _currentLocationWorker?.dispose();
    _radiusWorker?.dispose();
    _googleMapController = null;

    super.dispose();
  }
}
