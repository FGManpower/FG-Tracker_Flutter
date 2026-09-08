import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../global_widget/common_widget.dart';
import '../Widgets/safe_common_widgets.dart';
import '../controller/safe_zone_controller.dart';

class SafeZoneView extends StatelessWidget {
  const SafeZoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafeZoneController());

    return Scaffold(
      backgroundColor: SafeColors.bg, // #F5F3FF lavender
      appBar: const SafeAppBar(
        title: "Safe Zone",
        subtitle:
        "Define a safe area. Get alerts if someone\nsteps outside the safe zone.",
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          SafeTabBar(controller: controller.tabController),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildIndividualTab(controller),
                _buildGroupTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= INDIVIDUAL =================
  Widget _buildIndividualTab(SafeZoneController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outer card + Inner card (member)
          SafeCard(
            title: "1. Select Member",
            innerCard: true,
            child: Obx(() => SafeMemberCard(
              name: controller.selectedIndividualMember.value,
              phone: controller.memberPhone.value,
              showContainer: false,
            )),
          ),
          SizedBox(height: 16.h),

          // Map: outer card, content direct (search+map already styled)
          SafeCard(
            title: "2. Select Location on Map",
            innerCard: false,
            padding: EdgeInsets.all(12.w),
            child: _buildMapCard(controller, isGroup: false),
          ),
          SizedBox(height: 16.h),

          // Radius: outer card, slider direct + inner selected-location card
          _buildCombinedRadiusLocationCard(controller, isGroup: false),
          SizedBox(height: 16.h),

          // Preview: outer + inner
          SafeCard(
            title: "4. Preview Safe Zone",
            innerCard: true,
            child: _buildPreviewContent(isGroup: false),
          ),
          SizedBox(height: 24.h),
          const SafeSaveButton(text: "Save & Activate Safe Zone"),
          const SafeFooterNote(),
        ],
      ),
    );
  }

  // ================= GROUP =================
  Widget _buildGroupTab(SafeZoneController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeCard(
            title: "1. Select Group",
            innerCard: true,
            child: Obx(() => SafeGroupCard(
              groupName: controller.selectedGroup.value,
              showContainer: false,
            )),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: "2. Select Location on Map",
            innerCard: false,
            padding: EdgeInsets.all(12.w),
            child: _buildMapCard(controller, isGroup: true),
          ),
          SizedBox(height: 16.h),
          _buildCombinedRadiusLocationCard(controller, isGroup: true),
          SizedBox(height: 16.h),
          SafeCard(
            title: "4. Preview Safe Zone",
            innerCard: true,
            child: _buildPreviewContent(isGroup: true),
          ),
          SizedBox(height: 24.h),
          const SafeSaveButton(text: "Save & Activate Safe Zone for Group"),
          const SafeFooterNote(),
        ],
      ),
    );
  }

  // ================= MAP =================
  Widget _buildMapCard(SafeZoneController controller, {required bool isGroup}) {
    return Obx(() {
      final LatLng pos = controller.selectedLocation.value;
      final double radius = isGroup
          ? controller.radiusOptions[controller.groupRadiusIndex.value]
          : controller.radiusOptions[controller.individualRadiusIndex.value];

      return SafeMapCard(
        showContainer: false,
        mapKey: ValueKey('map_${isGroup}_$radius'),
        searchController: controller.searchController,
        onSearchSubmit: (val) => controller.searchLocation(val),
        onClearSearch: controller.clearSearch,
        onMapCreated: (mapCtrl) =>
            controller.onMapCreated(mapCtrl, isGroup: isGroup),
        onRecenter: () => controller.reCenterMap(isGroup: isGroup),
        onZoomIn: () => controller.zoomIn(isGroup: isGroup),
        onZoomOut: () => controller.zoomOut(isGroup: isGroup),
        initialCamera:
        CameraPosition(target: pos, zoom: controller.getZoomLevel(radius)),
        mapHeight: 200,
        markers: {
          Marker(
            markerId: const MarkerId('location'),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        },
        circles: {
          Circle(
            circleId: CircleId('radius_$radius'),
            center: pos,
            radius: radius,
            fillColor: SafeColors.primary.withOpacity(0.18),
            strokeColor: SafeColors.primary.withOpacity(0.6),
            strokeWidth: 2,
          ),
        },
      );
    });
  }

  // ================= RADIUS (outer card + nested inner cards) =================
  Widget _buildCombinedRadiusLocationCard(
      SafeZoneController controller, {
        required bool isGroup,
      }) {
    return SafeCard(
      title: "3. Set Safe Zone Radius",
      gapAfterTitle: 16,
      innerCard: false, // slider direct; location row alag inner card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slider block
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                Obx(() {
                  final int index = isGroup
                      ? controller.groupRadiusIndex.value
                      : controller.individualRadiusIndex.value;
                  final double alignX = -1.0 + (index / 5.0) * 2.0;
                  final radius = controller.radiusOptions[index];

                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment(alignX, 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: SafeColors.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: reausabletext(controller.formatRadius(radius),
                          fontsize: 11,
                          color: Colors.white,
                          fontweight: FontWeight.w600),
                    ),
                  );
                }),
                Obx(() {
                  final double sliderValue = (isGroup
                      ? controller.groupRadiusIndex.value
                      : controller.individualRadiusIndex.value)
                      .toDouble();

                  return SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: SafeColors.primary,
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: Colors.white,
                      overlayColor: SafeColors.primary.withOpacity(0.1),
                      trackHeight: 3.h,
                      thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 9.r, elevation: 2),
                    ),
                    child: Slider(
                      value: sliderValue,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      onChanged: (val) =>
                          controller.onSliderChanged(val, isGroup: isGroup),
                    ),
                  );
                }),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                    controller.radiusOptions.asMap().entries.map((e) {
                      return Obx(() {
                        final activeIndex = isGroup
                            ? controller.groupRadiusIndex.value
                            : controller.individualRadiusIndex.value;
                        final isActive = e.key == activeIndex;
                        return Column(
                          children: [
                            Container(
                                width: 1,
                                height: 5.h,
                                color: Colors.grey.shade400),
                            SizedBox(height: 2.h),
                            reausabletext(
                              controller.formatRadius(e.value),
                              fontsize: 10,
                              color: isActive
                                  ? SafeColors.primary
                                  : Colors.grey.shade600,
                              fontweight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                            ),
                          ],
                        );
                      });
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Inner card: Selected Location + Radius
          SafeInnerCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: SafeColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: SafeColors.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(Icons.shield_outlined,
                      color: SafeColors.primary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reausabletext("Selected Location",
                          fontsize: 11,
                          fontweight: FontWeight.w500,
                          color: Colors.grey.shade600),
                      SizedBox(height: 2.h),
                      reausabletext(
                        controller.searchController.text.isEmpty
                            ? "Chembur, Mumbai"
                            : controller.searchController.text,
                        fontsize: 12,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 30.h,
                    width: 1,
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    reausabletext("Radius",
                        fontsize: 11, color: Colors.grey.shade600),
                    SizedBox(height: 2.h),
                    Obx(() {
                      final radius = isGroup
                          ? controller
                          .radiusOptions[controller.groupRadiusIndex.value]
                          : controller.radiusOptions[
                      controller.individualRadiusIndex.value];
                      return reausabletext(
                        controller.formatRadius(radius),
                        fontsize: 15,
                        fontfamily: FontFamily.interSemiBold,
                        color: SafeColors.primary,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Group banner — another inner style card
          if (isGroup) ...[
            SizedBox(height: 10.h),
            SafeInnerCard(
              color: SafeColors.primary.withOpacity(0.06),
              child: Row(
                children: [
                  Icon(Icons.group_outlined,
                      color: SafeColors.primary, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: reausabletext(
                      "This safe zone will be applied to all 12 members in the selected group.",
                      fontsize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= PREVIEW CONTENT =================
  Widget _buildPreviewContent({required bool isGroup}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration:
          BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.gpp_good_rounded, color: Colors.green, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: "Status: ",
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "Active (Preview)",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              reausabletext(
                isGroup
                    ? "All 12 members will be monitored\nwithin this safe zone."
                    : "Members will be monitored within\nthis safe zone.",
                fontsize: 9,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        Assets.icons.singleSafeZone.image(
          width: 100.w,
          height: 60.w,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}