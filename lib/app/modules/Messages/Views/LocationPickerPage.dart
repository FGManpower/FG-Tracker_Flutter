import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../Controller/location_picker_controller.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final LocationPickerController controller =
      Get.put(LocationPickerController());

  bool _isSearchActive = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final error = controller.errorMessage.value;
        if (error != null) {
          return _buildError(controller, error);
        }
        if (controller.isLoading.value ||
            controller.selectedLatLng.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: ToggleThemeData.Appcolor,
            ),
          );
        }

        return Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.selectedLatLng.value!,
                zoom: 17,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              markers: controller.markers.toSet(),
              onMapCreated: controller.onMapCreated,
              onTap: controller.updateSelectedLocation,
            ),

            // Recenter GPS floating button
            Positioned(
              right: 16.w,
              bottom: 0.42.sh + 16.h,
              child: FloatingActionButton.small(
                heroTag: "recenter_gps_btn",
                backgroundColor:
                    isDark ? ToggleThemeData.BlackMatte : Colors.white,
                foregroundColor: ToggleThemeData.Appcolor,
                elevation: 4,
                onPressed: controller.recenterToCurrentLocation,
                child: const Icon(Icons.my_location, size: 22),
              ),
            ),

            // Search Results Overlay
            if (_isSearchActive && controller.searchResults.isNotEmpty)
              Positioned.fill(
                child: Container(
                  color: isDark
                      ? ToggleThemeData.darkThemeBackground
                      : Colors.white,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark
                          ? ToggleThemeData.BlackMatteLight
                          : Colors.grey.shade200,
                    ),
                    itemBuilder: (ctx, index) {
                      final item = controller.searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ToggleThemeData.Appcolor.withValues(
                              alpha: 0.12),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: ToggleThemeData.Appcolor,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E202B),
                          ),
                        ),
                        subtitle: Text(
                          item.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        onTap: () {
                          setState(() => _isSearchActive = false);
                          controller.selectSearchResult(item);
                        },
                      );
                    },
                  ),
                ),
              ),

            // Bottom Draggable Sheet
            if (!_isSearchActive) _buildDraggableSheet(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bool isDark = Get.isDarkMode;
    return AppBar(
      backgroundColor: isDark
          ? ToggleThemeData.darkThemeBackground
          : ToggleThemeData.Appcolor,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.white),
      title: _isSearchActive
          ? TextField(
              controller: controller.searchController,
              autofocus: true,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Search or enter address...",
                hintStyle: TextStyle(color: Colors.white70, fontSize: 15.sp),
                border: InputBorder.none,
              ),
              onChanged: (val) => controller.searchPlaces(val),
              onSubmitted: (val) => controller.searchPlaces(val),
            )
          : Text(
              context.l10n.chat_shareLocation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        if (_isSearchActive)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearchActive = false;
                controller.searchController.clear();
                controller.searchResults.clear();
              });
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearchActive = true),
          ),
      ],
    );
  }

  Widget _buildDraggableSheet() {
    final bool isDark = Get.isDarkMode;
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.22,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              // ===================================================================
              // 1. Share Live Location Option (COMMENTED AS PER TASK 1 - DO NOT DELETE)
              // ===================================================================
              // ListTile(
              //   contentPadding:
              //       EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
              //   leading: CircleAvatar(
              //     backgroundColor:
              //         ToggleThemeData.Appcolor.withValues(alpha: 0.12),
              //     radius: 22.r,
              //     child: Icon(
              //       Icons.share_location_rounded,
              //       color: ToggleThemeData.Appcolor,
              //       size: 24,
              //     ),
              //   ),
              //   title: Text(
              //     "Share live location",
              //     style: TextStyle(
              //       fontSize: 15.sp,
              //       fontWeight: FontWeight.w600,
              //       color: isDark ? Colors.white : const Color(0xFF1E202B),
              //     ),
              //   ),
              //   subtitle: Text(
              //     "Share your real-time location with this chat",
              //     style: TextStyle(
              //       fontSize: 12.sp,
              //       color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              //     ),
              //   ),
              //   onTap: _showLiveLocationDurationSheet,
              // ),
              // Divider(
              //   height: 1,
              //   color: isDark
              //       ? ToggleThemeData.BlackMatteLight
              //       : Colors.grey.shade200,
              // ),

              // 2. Send Current Location Option
              Obx(() {
                final accuracy = controller.accuracyMeters.value;
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                  leading: CircleAvatar(
                    backgroundColor:
                        ToggleThemeData.Appcolor.withValues(alpha: 0.12),
                    radius: 22.r,
                    child: Icon(
                      Icons.my_location_rounded,
                      color: ToggleThemeData.Appcolor,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    "Send your current location",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E202B),
                    ),
                  ),
                  subtitle: Text(
                    "Accurate to $accuracy meters",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  onTap: controller.sendCurrentLocation,
                );
              }),

              Divider(
                height: 1,
                color: isDark
                    ? ToggleThemeData.BlackMatteLight
                    : Colors.grey.shade200,
              ),

              // 3. NEARBY PLACES Section Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Text(
                      "NEARBY PLACES",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: ToggleThemeData.Appcolor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    if (controller.isLoadingNearby.value)
                      SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ToggleThemeData.Appcolor,
                        ),
                      ),
                  ],
                ),
              ),

              // Nearby places items
              Obx(() {
                if (controller.nearbyPlaces.isEmpty &&
                    !controller.isLoadingNearby.value) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Text(
                      "Move the map to browse nearby places",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final place in controller.nearbyPlaces)
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 2.h),
                        leading: CircleAvatar(
                          backgroundColor: ToggleThemeData.Appcolor.withValues(
                              alpha: 0.12),
                          radius: 18.r,
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 20.sp,
                            color: ToggleThemeData.Appcolor,
                          ),
                        ),
                        title: Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1E202B),
                          ),
                        ),
                        subtitle: Text(
                          place.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        trailing: place.distanceMeters != null &&
                                place.distanceMeters! > 0
                            ? Text(
                                place.distanceMeters! >= 1000
                                    ? "${(place.distanceMeters! / 1000).toStringAsFixed(1)} km"
                                    : "${place.distanceMeters} m",
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500,
                                ),
                              )
                            : null,
                        onTap: () => controller.sendNearbyPlace(place),
                      ),
                  ],
                );
              }),

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  // ===================================================================
  // LIVE LOCATION MODAL & DURATION CHIP (COMMENTED AS PER TASK 1)
  // ===================================================================
  // void _showLiveLocationDurationSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
  //     ),
  //     builder: (ctx) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
  //           left: 20.w,
  //           right: 20.w,
  //           top: 14.h,
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: Container(
  //                 width: 40.w,
  //                 height: 4.h,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(10.r),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16.h),
  //             Row(
  //               children: [
  //                 CircleAvatar(
  //                   backgroundColor:
  //                       ToggleThemeData.Appcolor.withValues(alpha: 0.15),
  //                   radius: 20.r,
  //                   child: Icon(
  //                     Icons.share_location_rounded,
  //                     color: ToggleThemeData.Appcolor,
  //                     size: 22,
  //                   ),
  //                 ),
  //                 SizedBox(width: 12.w),
  //                 Expanded(
  //                   child: Text(
  //                     "Share Live Location",
  //                     style: TextStyle(
  //                       fontSize: 18.sp,
  //                       fontWeight: FontWeight.w700,
  //                       color: const Color(0xFF1E202B),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 8.h),
  //             Text(
  //               "Participants will see your real-time location even when you are not using the app.",
  //               style: TextStyle(
  //                 fontSize: 12.5.sp,
  //                 color: Colors.grey.shade600,
  //                 height: 1.35,
  //               ),
  //             ),
  //             SizedBox(height: 18.h),
  //
  //             // Duration selector pills: 15 min, 1 hour, 8 hours
  //             Text(
  //               "SELECT DURATION",
  //               style: TextStyle(
  //                 fontSize: 11.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.grey.shade500,
  //                 letterSpacing: 0.6,
  //               ),
  //             ),
  //             SizedBox(height: 8.h),
  //             Obx(() {
  //               final current = controller.selectedLiveDuration.value;
  //               return Row(
  //                 children: [
  //                   _buildDurationChip(
  //                     label: "15 minutes",
  //                     minutes: 15,
  //                     isSelected: current == 15,
  //                     onTap: () => controller.selectedLiveDuration.value = 15,
  //                   ),
  //                   SizedBox(width: 10.w),
  //                   _buildDurationChip(
  //                     label: "1 hour",
  //                     minutes: 60,
  //                     isSelected: current == 60,
  //                     onTap: () => controller.selectedLiveDuration.value = 60,
  //                   ),
  //                   SizedBox(width: 10.w),
  //                   _buildDurationChip(
  //                     label: "8 hours",
  //                     minutes: 480,
  //                     isSelected: current == 480,
  //                     onTap: () => controller.selectedLiveDuration.value = 480,
  //                   ),
  //                 ],
  //               );
  //             }),
  //             SizedBox(height: 18.h),
  //
  //             // Optional Comment Box + Send Button
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFF1F5F9),
  //                       borderRadius: BorderRadius.circular(24.r),
  //                     ),
  //                     padding: EdgeInsets.symmetric(horizontal: 16.w),
  //                     child: TextField(
  //                       controller: controller.liveCommentController,
  //                       decoration: InputDecoration(
  //                         hintText: "Add comment...",
  //                         hintStyle: TextStyle(
  //                           fontSize: 14.sp,
  //                           color: Colors.grey.shade500,
  //                         ),
  //                         border: InputBorder.none,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 12.w),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(ctx);
  //                     controller.sendLiveLocation();
  //                   },
  //                   child: CircleAvatar(
  //                     radius: 24.r,
  //                     backgroundColor: ToggleThemeData.Appcolor,
  //                     child: const Icon(
  //                       Icons.send_rounded,
  //                       color: Colors.white,
  //                       size: 22,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10.h),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // Widget _buildDurationChip({
  //   required String label,
  //   required int minutes,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 10.h),
  //         decoration: BoxDecoration(
  //           color: isSelected
  //               ? ToggleThemeData.Appcolor.withValues(alpha: 0.12)
  //               : const Color(0xFFF1F5F9),
  //           borderRadius: BorderRadius.circular(20.r),
  //           border: Border.all(
  //             color: isSelected ? ToggleThemeData.Appcolor : Colors.transparent,
  //             width: 1.5,
  //           ),
  //         ),
  //         child: Center(
  //           child: Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: 13.sp,
  //               fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
  //               color: isSelected
  //                   ? ToggleThemeData.Appcolor
  //                   : Colors.grey.shade700,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildError(LocationPickerController controller, String message) {
    final bool isDark = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 54.sp, color: Colors.grey.shade500),
            SizedBox(height: 14.h),
            Text(
              "Location Access Needed",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 22.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ToggleThemeData.Appcolor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              onPressed: () {
                if (controller.permissionDenied.value) {
                  openAppSettings();
                } else {
                  controller.retry();
                }
              },
              icon: Icon(
                controller.permissionDenied.value
                    ? Icons.settings
                    : Icons.refresh_rounded,
                size: 20.sp,
              ),
              label: Text(
                controller.permissionDenied.value
                    ? "Open Settings"
                    : "Turn on location",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
