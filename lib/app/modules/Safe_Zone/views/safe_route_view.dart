import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../global_widget/common_widget.dart';
import '../Widgets/safe_common_widgets.dart';
import '../controller/safe_route_controller.dart';
import 'package:fgtracker/l10n/l10n.dart';

class SafeRouteView extends StatelessWidget {
  const SafeRouteView({Key? key}) : super(key: key);

  Color get primary => SafeColors.primary;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafeRouteController());

    return Scaffold(
      backgroundColor: SafeColors.bg,
      appBar: SafeAppBar(
        title: context.l10n.safeRoute_title,
        subtitle: context.l10n.safeRoute_appBarSubtitle,
        onInfoTap: () => _showSafeRouteHelp(context),
      ),
      body: Column(
        children: [
          SizedBox(height: 5.h),
          SafeTabBar(controller: controller.tabController),
          SizedBox(height: 4.h),
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

  Widget _buildIndividualTab(SafeRouteController c) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.w),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeCard(
            title: appL10n.safety_stepSelectMember(1),
            innerCard: true,
            child: Obx(() => SafeMemberCard(
                  name: c.selectedMember.value,
                  phone: c.memberPhone.value,
                  showContainer: false,
                )),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepStartDest(2),
            innerCard: true,
            child: _buildStartDestRow(c),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepSelectRoute(3),
            innerCard: false,
            padding: EdgeInsets.all(10.w),
            child: _buildFullMapWithRoutes(c, isGroup: false),
          ),
          SizedBox(height: 16.h),
          _buildDeviationSliderCard(c,
              isGroup: false, stepTitle: appL10n.safeRoute_stepDeviation(4)),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepPreviewRoute(5),
            innerCard: true,
            child: _buildPreviewContent(c, isGroup: false),
          ),
          SizedBox(height: 20.h),
          SafeSaveButton(text: appL10n.safeRoute_saveActivate),
          const SafeFooterNote(),
        ],
      ),
    );
  }

  Widget _buildGroupTab(SafeRouteController c) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.w),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeCard(
            title: appL10n.safety_stepSelectGroup(1),
            innerCard: true,
            child: Obx(() => SafeGroupCard(
                  groupName: c.selectedGroup.value,
                  showContainer: false,
                )),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepSetRoutesForMembers(2),
            subtitle: appL10n.safeRoute_setRoutesSubtitle,
            innerCard: false,
            child: _buildGroupMembersRow(c),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepStartDest(3),
            innerCard: true,
            child: _buildStartDestRow(c),
          ),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepSelectRoute(4),
            innerCard: false,
            padding: EdgeInsets.all(10.w),
            child: _buildFullMapWithRoutes(c, isGroup: true),
          ),
          SizedBox(height: 16.h),
          _buildDeviationSliderCard(c,
              isGroup: true, stepTitle: appL10n.safeRoute_stepDeviation(5)),
          SizedBox(height: 16.h),
          SafeCard(
            title: appL10n.safeRoute_stepPreviewApply(6),
            innerCard: true,
            child: _buildPreviewContent(c, isGroup: true),
          ),
          SizedBox(height: 20.h),
          SafeSaveButton(text: appL10n.safeRoute_saveActivateGroup),
          const SafeFooterNote(),
        ],
      ),
    );
  }

  Widget _buildStartDestRow(SafeRouteController c) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => SafeLocationInput(
                label: appL10n.safeRoute_startLocation,
                value: c.startLocation.value,
                dotColor: Colors.green,
              )),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: GestureDetector(
            onTap: c.swapLocations,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.swap_horiz, color: primary, size: 16.sp),
            ),
          ),
        ),
        Expanded(
          child: Obx(() => SafeLocationInput(
                label: appL10n.safeRoute_destination,
                value: c.destinationLocation.value,
                dotColor: Colors.red,
              )),
        ),
      ],
    );
  }

  Widget _buildGroupMembersRow(SafeRouteController c) {
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: c.groupMembers.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final m = c.groupMembers[i];
          return Obx(() {
            final selected = c.selectedGroupMemberIndex.value == i;
            return GestureDetector(
              onTap: () => c.selectedGroupMemberIndex.value = i,
              child: Container(
                width: 200.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF3F1FF) : Colors.white,
                  border: Border.all(
                    color: selected ? primary : SafeColors.border,
                    width: selected ? 1.2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundImage: NetworkImage(m.avatar),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: m.dot,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reausabletext(m.name,
                              fontsize: 12,
                              fontfamily: FontFamily.interSemiBold,
                              textoverflow: TextOverflow.ellipsis,
                              maxline: 1),
                          reausabletext("${m.start} → ${m.end}",
                              fontsize: 10,
                              color: Colors.grey.shade600,
                              textoverflow: TextOverflow.ellipsis,
                              maxline: 1),
                          reausabletext(m.routeName,
                              fontsize: 10,
                              color: primary,
                              fontweight: FontWeight.w600),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFullMapWithRoutes(SafeRouteController c,
      {required bool isGroup}) {
    return Container(
      height: 240.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SafeColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final selectedId = c.selectedRouteId.value;
              final poly = c.polylineFor(selectedId);
              return GoogleMap(
                key: ValueKey('route_map_${isGroup}_$selectedId'),
                initialCameraPosition:
                    CameraPosition(target: c.startLatLng, zoom: 12.2),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (m) => c.onMapCreated(m, isGroup: isGroup),
                markers: {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: c.startLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('end'),
                    position: c.endLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: PolylineId(selectedId),
                    points: poly,
                    color: primary,
                    width: 5,
                  ),
                },
              );
            }),
          ),
          Positioned(
            left: 10.w,
            top: 10.h,
            bottom: 10.h,
            width: 140.w,
            child: SingleChildScrollView(
              child: Column(
                children: c.routes.map((r) {
                  return Obx(() {
                    final selected = c.selectedRouteId.value == r.id;
                    return GestureDetector(
                      onTap: () => c.selectRoute(r.id),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          border: Border.all(
                            color: selected ? primary : SafeColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 14.sp,
                                  color:
                                      selected ? primary : Colors.grey.shade400,
                                ),
                                SizedBox(width: 4.w),
                                reausabletext(r.name,
                                    fontsize: 12,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: Colors.black),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            reausabletext(
                                appL10n.safeRoute_distanceEta("${r.distanceKm}", r.etaMin),
                                fontsize: 10,
                                color: Colors.grey.shade600),
                            if (r.recommended) ...[
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: reausabletext(appL10n.safeRoute_recommended,
                                    fontsize: 9,
                                    color: primary,
                                    fontweight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: 10.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 4)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => c.zoomIn(isGroup: isGroup),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(Icons.add,
                          size: 16.sp, color: Colors.grey.shade700),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  InkWell(
                    onTap: () => c.zoomOut(isGroup: isGroup),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(Icons.remove,
                          size: 16.sp, color: Colors.grey.shade700),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(Icons.layers_outlined,
                          size: 16.sp, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviationSliderCard(
    SafeRouteController c, {
    required bool isGroup,
    required String stepTitle,
  }) {
    return SafeCard(
      title: stepTitle,
      subtitle: appL10n.safeRoute_deviationSubtitle,
      gapAfterTitle: 16,
      innerCard: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final index = isGroup
                ? c.groupDeviationIndex.value
                : c.individualDeviationIndex.value;
            final alignX = -1.0 + (index / 5.0) * 2.0;
            final value = c.deviationOptions[index];
            return AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment(alignX, 0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: reausabletext(c.formatDeviation(value),
                    fontsize: 11,
                    color: Colors.white,
                    fontweight: FontWeight.w600),
              ),
            );
          }),
          Obx(() {
            final sliderValue = (isGroup
                    ? c.groupDeviationIndex.value
                    : c.individualDeviationIndex.value)
                .toDouble();

            return Transform.translate(
              offset: Offset(-5.w, 0),
              child: SizedBox(
                width: double.infinity + 20.w,
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: primary,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Colors.white,
                    overlayColor: primary.withOpacity(0.1),
                    trackHeight: 3.h,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 9.r,
                      elevation: 2,
                    ),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    onChanged: (val) =>
                        c.onDeviationSlider(val, isGroup: isGroup),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: c.deviationOptions.asMap().entries.map((e) {
                return Obx(() {
                  final activeIndex = isGroup
                      ? c.groupDeviationIndex.value
                      : c.individualDeviationIndex.value;
                  final isActive = e.key == activeIndex;
                  return Column(
                    children: [
                      Container(
                          width: 1, height: 5.h, color: Colors.grey.shade400),
                      SizedBox(height: 2.h),
                      reausabletext(
                        c.formatDeviation(e.value),
                        fontsize: 10,
                        fontweight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? primary : Colors.grey.shade600,
                      ),
                    ],
                  );
                });
              }).toList(),
            ),
          ),
          if (!isGroup) ...[
            SizedBox(height: 12.h),
            SafeInnerCard(
              color: primary.withOpacity(0.05),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18.sp, color: primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() {
                      final v = c.formatDeviation(c.individualDeviation);
                      final note = appL10n.safeRoute_deviationAlertNote(v);
                      final i = note.indexOf(v);
                      return RichText(
                        text: TextSpan(
                          style:
                              TextStyle(fontSize: 11.sp, color: Colors.black87),
                          children: [
                            TextSpan(text: i < 0 ? note : note.substring(0, i)),
                            if (i >= 0)
                              TextSpan(
                                text: v,
                                style: TextStyle(
                                    color: primary, fontWeight: FontWeight.bold),
                              ),
                            if (i >= 0)
                              TextSpan(text: note.substring(i + v.length)),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewContent(
      SafeRouteController c, {
        required bool isGroup,
      }) {
    return Obx(() {
      final r = c.selectedRoute;
      final dev = c.deviationFor(isGroup: isGroup);

      if (isGroup) {
        final m = c.groupMembers[c.selectedGroupMemberIndex.value];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _previewRow(
                      appL10n.track_groupTab,
                      appL10n.safeRoute_groupWithCount(c.selectedGroup.value, 12),
                      dot: Colors.green,
                    ),
                    _previewRow(
                      appL10n.safeRoute_routeFor(m.name),
                      "${m.start} → ${m.end} (${r.name})",
                      dot: Colors.red,
                      highlight: true,
                    ),
                    _previewRow(
                      appL10n.safeRoute_distance,
                      "${r.distanceKm} km",
                      suffix: appL10n.safeRoute_estTime(r.etaMin),
                    ),
                    _previewRow(
                      appL10n.safeRoute_deviationLimit,
                      c.formatDeviation(dev),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 88.w,
              height: 76.h,
              child: Align(
                alignment: Alignment.topRight,
                child: Assets.icons.singleSafeRoute.image(
                  width: 88.w,
                  height: 76.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.headset_mic_outlined,
                color: primary,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _previewRow(
                    appL10n.safeRoute_start,
                    c.startLocation.value,
                    dot: Colors.green,
                  ),
                  _previewRow(
                    appL10n.safeRoute_destination,
                    c.destinationLocation.value,
                    dot: Colors.red,
                  ),
                  _previewRow(
                    appL10n.safeRoute_selectedRoute,
                    appL10n.safeRoute_recommendedRoute(r.name),
                    highlight: true,
                  ),
                  _previewRow(
                    appL10n.safeRoute_distance,
                    "${r.distanceKm} km",
                    suffix: appL10n.safeRoute_estTime(r.etaMin),
                  ),
                  _previewRow(
                    appL10n.safeRoute_deviationLimit,
                    c.formatDeviation(dev),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 3.w),
          SizedBox(
            width: 88.w,
            height: 76.h,
            child: Align(
              alignment: Alignment.topRight,
              child: Assets.icons.singleSafeRoute.image(
                width: 88.w,
                height: 76.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _previewRow(
      String label,
      String value, {
        Color? dot,
        String? suffix,
        bool highlight = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dot != null)
            SizedBox(
              width: 13.w,
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Icon(
                  Icons.circle,
                  size: 6.sp,
                  color: dot,
                ),
              ),
            ),
          SizedBox(
            width: 70.w,
            child: reausabletext(
              "$label :",
              fontsize: 8.5,
              color: Colors.black87,
              fontweight: FontWeight.w500,
              maxline: 2,
              textoverflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color: highlight
                          ? primary
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (suffix != null)
                    TextSpan(
                      text: "  |  $suffix",
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showSafeRouteHelp(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.safeRoute_helpTitle,
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 64,
                right: 5,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: screenWidth * 0.485,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      14,
                      14,
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.safeRoute_helpTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff10205C),
                          ),
                        ),

                        const SizedBox(height: 15),

                        _routeHelpItem(
                          icon: Icons.location_on_rounded,
                          title: context.l10n.safeRoute_helpWhatTitle,
                          description: context.l10n.safeRoute_helpWhatBody,
                        ),

                        const SizedBox(height: 13),

                        _routeHelpItem(
                          icon: Icons.sync_alt_rounded,
                          title: context.l10n.safeRoute_helpHowTitle,
                          description: context.l10n.safeRoute_helpHowBody,
                        ),

                        const SizedBox(height: 13),

                        _routeHelpItem(
                          icon: Icons.shield_outlined,
                          title: context.l10n.safeRoute_helpDeviationTitle,
                          description: context.l10n.safeRoute_helpDeviationBody,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Arrow
              Positioned(
                top: 56,
                right: 28,
                child: CustomPaint(
                  size: const Size(16, 9),
                  painter: _HelpArrowPainter(),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, -0.02),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _routeHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xffF0EEFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: SafeColors.primary,
            size: 17,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff10205C),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 8,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff59658A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _HelpArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}