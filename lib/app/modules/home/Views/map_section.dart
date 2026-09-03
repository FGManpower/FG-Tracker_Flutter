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


  final Rx<Set<Marker>> _markers =
  Rx<Set<Marker>>(<Marker>{});

  final Rx<Set<Circle>> _circles =
  Rx<Set<Circle>>(<Circle>{});

  final Map<String, BitmapDescriptor> _markerIconCache = {};

  Worker? _locationWorker;

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

    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final int requestId = ++_markerRequestId;

    try {
      final List<LiveLocationModel> locations =
      List<LiveLocationModel>.from(
        controller.liveLocations,
      );

      final Set<Marker> newMarkers = <Marker>{};

      for (final member in locations) {
        final String cacheKey =
            '${member.userId}_${member.profileImage}_${member.isOnline}';

        BitmapDescriptor? customIcon =
        _markerIconCache[cacheKey];

        if (customIcon == null) {
          /*
           * Pass the relative path here:
           *
           * uploads/Auth/1766030180766.jpg
           *
           * getCustomIcon() should add ConstRes.aImageBaseUrl.
           */
          customIcon = await getCustomIcon(
            member.profileImage,
            member.isOnline,
          );

          _markerIconCache[cacheKey] = customIcon;
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(
              'member_${member.userId}',
            ),
            position: LatLng(
              member.latitude,
              member.longitude,
            ),
            icon: customIcon,
            anchor: const Offset(0.5, 1.0),
            infoWindow: InfoWindow(
              title: member.fullName,
              snippet: member.isOnline
                  ? 'Online'
                  : 'Offline',
            ),
            onTap: () {
              _showMemberDetails(member);
            },
          ),
        );
      }

      if (!mounted || requestId != _markerRequestId) {
        return;
      }

      // Reactive update. No setState().
      _markers.value = newMarkers;
      _circles.value = _buildRadiusCircle(locations);

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (mounted && requestId == _markerRequestId) {
        await _fitAllMembers();
      }
    } catch (error) {
      debugPrint('Live marker error: $error');
    }
  }

  Set<Circle> _buildRadiusCircle(
      List<LiveLocationModel> locations,
      ) {
    if (locations.isEmpty) {
      return <Circle>{};
    }

    final LiveLocationModel firstMember = locations.first;

    return <Circle>{
      Circle(
        circleId: const CircleId(
          'live_tracking_radius',
        ),
        center: LatLng(
          firstMember.latitude,
          firstMember.longitude,
        ),
        radius: 2000,
        fillColor: const Color(0xFF6B4DFF).withValues(alpha: 0.12),
        strokeColor: const Color(0xFF6B4DFF).withValues(alpha: 0.50),
        strokeWidth: 1,
      ),
    };
  }

  LatLng? _getInitialPosition() {
    if (controller.liveLocations.isEmpty) {
      return null;
    }

    final LiveLocationModel firstMember =
        controller.liveLocations.first;

    return LatLng(
      firstMember.latitude,
      firstMember.longitude,
    );
  }

  Future<void> _fitAllMembers() async {
    final GoogleMapController? mapController =
        _googleMapController;

    final List<LiveLocationModel> locations =
    List<LiveLocationModel>.from(
      controller.liveLocations,
    );

    if (mapController == null || locations.isEmpty) {
      return;
    }

    double minLatitude = locations.first.latitude;
    double maxLatitude = locations.first.latitude;
    double minLongitude = locations.first.longitude;
    double maxLongitude = locations.first.longitude;

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
      minLatitude -= 0.001;
      maxLatitude += 0.001;
    }

    if (minLongitude == maxLongitude) {
      minLongitude -= 0.001;
      maxLongitude += 0.001;
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                            color: member.isOnline
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        reausabletext(
                          member.isOnline
                              ? 'Online'
                              : 'Offline',
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

            /*
             * GetX listens to controller.liveLocations.
             *
             * This solves the initial loading problem:
             * when socket data arrives, the GoogleMap is created.
             */
            GetX<HomeController>(
              builder: (homeController) {
                final LatLng? initialPosition =
                _getInitialPosition();

                return LayoutBuilder(
                  builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                      ) {
                    final double mapHeight =
                    (constraints.maxWidth * 0.56)
                        .clamp(180.0, 270.0)
                        .toDouble();

                    return Container(
                      height: mapHeight,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(20.r),
                      ),
                      child: initialPosition == null
                          ? _loadingView()
                          : Stack(
                        children: [
                          /*
                                 * This small Obx listens only to
                                 * marker and circle changes.
                                 */
                          Obx(
                                () => GoogleMap(
                              initialCameraPosition:
                              CameraPosition(
                                target: initialPosition,
                                zoom: 16,
                              ),
                              markers: _markers.value,
                              circles: _circles.value,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled:
                              false,
                              myLocationEnabled: false,
                              mapToolbarEnabled: false,
                              compassEnabled: false,
                              buildingsEnabled: true,
                              mapType: MapType.normal,
                              onMapCreated:
                                  (mapController) {
                                _googleMapController =
                                    mapController;

                                Future.delayed(
                                  const Duration(
                                    milliseconds: 500,
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
                                    _googleMapController
                                        ?.animateCamera(
                                      CameraUpdate
                                          .zoomIn(),
                                    );
                                  },
                                ),
                                SizedBox(height: 5.h),
                                _mapButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    _googleMapController
                                        ?.animateCamera(
                                      CameraUpdate
                                          .zoomOut(),
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
                            child:
                            _membersCountView(
                              homeController,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
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

        _radiusBadge(),
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
    final int onlineCount = homeController.liveLocations
        .where((member) => member.isOnline)
        .length;

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
            '$onlineCount Members Live',
            fontsize: 11.sp,
            fontfamily: FontFamily.interSemiBold,
          ),
        ],
      ),
    );
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
        padding: EdgeInsets.all(9.w),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationWorker?.dispose();
    _googleMapController = null;

    super.dispose();
  }
}