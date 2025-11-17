import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Track/Widget/Track_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';

import '../../../routes/app_pages.dart';
import '../Widget/TrackLAppBar.dart';

class LocationTrackingPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const LocationTrackingPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  final controller = TrackingController.instance;
  final groupController = Get.put(GroupController());
  final TextEditingController _searchController = TextEditingController();
  final RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    controller.clearMapMarkers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getGroupLocationData(context, widget.groupId);
      controller.initGroupTracking(widget.groupId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildTrackAppBar(
        context,
        groupName: widget.groupName,
        onPressMembers: () {
          BottomSheetUi().showMemberBottomSheet(context,
              controller.groupWiseUserData[widget.groupId.toString()] ?? []);
        },
        onPressRefresh: () {
          controller.getGroupLocationData(context, widget.groupId);
          controller.initGroupTracking(widget.groupId.toString());
        },
        onSearch: () {
          Get.toNamed(Routes.SearchMembers, arguments: {
            "GroupMembers":
                controller.groupWiseUserData[widget.groupId.toString()]
          })?.then(
            (value) {
              if (value.toString().isNotEmpty) {
                controller.searchUserAndZoom(widget.groupId.toString(), value);
              }
            },
          );
        },
      ),
      body: Stack(
        children: [
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.locationService.currentPosition != null
                      ? LatLng(
                          controller.locationService.currentPosition!.latitude!,
                          controller
                              .locationService.currentPosition!.longitude!,
                        )
                      : const LatLng(19.093394, 72.9137016),
                  zoom: 15,
                ),
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: (mapController) =>
                    controller.mapController = mapController,
                markers: controller.markers.toSet(),
                // polylines: controller.polylines.toSet(),
              )),
          Positioned(
            top: 30.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.only(top: 7.h, left: 10.w, bottom: 7.h),
                decoration: BoxDecoration(
                  color: ToggleThemeData.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isSearching.value ? 30.h : -120.h,
              left: 16.w,
              right: 16.w,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSearching.value ? 1.0 : 0.0,
                child: Material(
                  borderRadius: BorderRadius.circular(16.r),
                  elevation: 6,
                  shadowColor: Colors.black26,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search member by name',
                              hintStyle: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                TrackingController.instance.searchUserAndZoom(
                                    widget.groupId.toString(), value);

                                isSearching.value = false;
                              }
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            isSearching.value = false;
                            controller.clearSearchZoomOut();
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Icon(Icons.close,
                                size: 18.sp, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
        ],
      ),
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(25.r),
      //       topRight: Radius.circular(25.r),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black12,
      //         blurRadius: 10.r,
      //         offset: Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       reausabletext(
      //         "Group: ${widget.groupName}",
      //         fontsize: 16,
      //         fontweight: FontWeight.w600,
      //         color: Colors.black87,
      //       ),
      //       SizedBox(height: 10.h),
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           buildNavActionButton(Icons.search, "Search", () {
      //             isSearching.value = !isSearching.value;
      //           }),
      //           // buildNavActionButton(Icons.my_location, "My Location", () async {
      //           //
      //           // }),
      //           buildNavActionButton(Icons.people_alt_outlined, "Members", () {
      //             BottomSheetUi().showMemberBottomSheet(
      //                 context,
      //                 controller.groupWiseUserData[widget.groupId.toString()] ??
      //                     []);
      //           }),
      //           buildNavActionButton(Icons.refresh, "Reload", () {
      //             controller.getGroupLocationData(context, widget.groupId);
      //             controller.initGroupTracking(widget.groupId.toString());
      //           }),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
