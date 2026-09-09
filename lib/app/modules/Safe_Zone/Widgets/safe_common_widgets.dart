import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../global_widget/common_widget.dart';

class SafeColors {
  static const Color primary = Color(0xFF5A3EFE);
  static const Color bg = Color(0xFFF5F3FF);
  static const Color cardBg = Colors.white;
  static const Color cardOuter = Color(0xFFF8F7FD);
  static const Color searchBg = Color(0xFFF5F6FA);
  static const Color border = Color(0xFFE8E6F0);
}

class SafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  const SafeAppBar({Key? key, required this.title, required this.subtitle, })
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SafeColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 56.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: SafeColors.border),
            ),
            child: Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 16.sp),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reausabletext(
            title,
            fontsize: 16,
            fontfamily: FontFamily.interSemiBold,
            color: Colors.black,
          ),
          reausabletext(
            subtitle,
            fontsize: 10,
            fontweight: FontWeight.w500,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline,
              color: SafeColors.primary, size: 22.sp),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

class SafeTabBar extends StatelessWidget {
  final TabController controller;
  const SafeTabBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SafeColors.border),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: SafeColors.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 18),
                SizedBox(width: 6),
                Text("Individual"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 18),
                SizedBox(width: 6),
                Text("Group"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SafeCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double gapAfterTitle;
  final EdgeInsetsGeometry? padding;
  final bool innerCard;
  final EdgeInsetsGeometry? innerPadding;

  const SafeCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
    this.gapAfterTitle = 10,
    this.padding,
    this.innerCard = true,
    this.innerPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = innerCard
        ? Container(
      width: double.infinity,
      padding: innerPadding ??
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: SafeColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SafeColors.border),
      ),
      child: child,
    )
        : child;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: SafeColors.cardOuter,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SafeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reausabletext(
            title,
            fontsize: 12,
            fontfamily: FontFamily.interSemiBold,
            color: Colors.black87,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            reausabletext(
              subtitle!,
              fontsize: 10,
              color: Colors.grey.shade600,
            ),
          ],
          SizedBox(height: gapAfterTitle.h),
          content,
        ],
      ),
    );
  }
}

class SafeInnerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const SafeInnerCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color ?? SafeColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SafeColors.border),
      ),
      child: child,
    );
  }
}

class SafeMemberCard extends StatelessWidget {
  final String name;
  final String phone;
  final String avatarUrl;
  final VoidCallback? onTap;
  final bool showContainer;

  const SafeMemberCard({
    Key? key,
    required this.name,
    required this.phone,
    this.avatarUrl = 'https://i.pravatar.cc/150?img=11',
    this.onTap,
    this.showContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(name,
                  fontsize: 12,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black),
              SizedBox(height: 2.h),
              reausabletext(phone, fontsize: 10, color: Colors.grey),
            ],
          ),
        ),
        Icon(Icons.keyboard_arrow_down, color: SafeColors.primary),
      ],
    );

    if (!showContainer) return GestureDetector(onTap: onTap, child: content);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: SafeColors.cardBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: SafeColors.border),
        ),
        child: content,
      ),
    );
  }
}

class SafeGroupCard extends StatelessWidget {
  final String groupName;
  final int totalMembers;
  final int previewCount;
  final VoidCallback? onViewAll;
  final bool showContainer;

  const SafeGroupCard({
    Key? key,
    required this.groupName,
    this.totalMembers = 12,
    this.previewCount = 5,
    this.onViewAll,
    this.showContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int extra = totalMembers - previewCount;
    final content = Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: SafeColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
              Icon(Icons.people, color: SafeColors.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(groupName,
                      fontsize: 12,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.black),
                  reausabletext("Total $totalMembers Members",
                      fontsize: 10, color: Colors.grey.shade500),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: SafeColors.primary),
          ],
        ),
        Divider(color: Colors.grey.shade100, height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                for (int i = 0; i < previewCount; i++)
                  Align(
                    widthFactor: 0.7,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 12.r,
                        backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=${i + 10}'),
                      ),
                    ),
                  ),
                if (extra > 0)
                  Align(
                    widthFactor: 0.7,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 12.r,
                        backgroundColor: const Color(0xFFF0EFFF),
                        child: reausabletext("+$extra",
                            fontsize: 10,
                            color: SafeColors.primary,
                            fontweight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  reausabletext("View All Members",
                      fontsize: 11,
                      color: SafeColors.primary,
                      fontweight: FontWeight.w600),
                  Icon(Icons.chevron_right,
                      size: 16.sp, color: SafeColors.primary),
                ],
              ),
            ),
          ],
        )
      ],
    );

    if (!showContainer) return content;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: SafeColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SafeColors.border),
      ),
      child: content,
    );
  }
}

class SafeMapCard extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmit;
  final VoidCallback onClearSearch;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final CameraPosition initialCamera;
  final Key? mapKey;
  final bool showSearchBar;
  final bool showContainer;
  final double mapHeight;

  const SafeMapCard({
    Key? key,
    required this.searchController,
    required this.onSearchSubmit,
    required this.onClearSearch,
    required this.onMapCreated,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.initialCamera,
    this.markers = const {},
    this.circles = const {},
    this.polylines = const {},
    this.polygons = const {},
    this.mapKey,
    this.showSearchBar = true,
    this.showContainer = true,
    this.mapHeight = 220,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (showSearchBar) ...[
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: SafeColors.border),
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Icon(Icons.search, color: Colors.grey.shade500, size: 25.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onSubmitted: onSearchSubmit,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search Location...",
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.grey.shade400, size: 18.sp),
                  onPressed: onClearSearch,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: mapHeight.h,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  key: mapKey,
                  initialCameraPosition: initialCamera,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: onMapCreated,
                  markers: markers,
                  circles: circles,
                  polylines: polylines,
                  polygons: polygons,
                ),
                Positioned(
                  left: 10.w,
                  bottom: 10.h,
                  child: GestureDetector(
                    onTap: onRecenter,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location,
                              color: SafeColors.primary, size: 14.sp),
                          SizedBox(width: 4.w),
                          reausabletext("Re-center",
                              fontsize: 11,
                              color: SafeColors.primary,
                              fontweight: FontWeight.bold),
                        ],
                      ),
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
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onZoomIn,
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: Icon(Icons.add,
                                size: 16.sp, color: Colors.grey.shade700),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        InkWell(
                          onTap: onZoomOut,
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
          ),
        ),
      ],
    );

    if (!showContainer) return content;

    return Container(
      decoration: BoxDecoration(
        color: SafeColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SafeColors.border),
      ),
      padding: EdgeInsets.all(8.w),
      child: content,
    );
  }
}

class SafeSaveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const SafeSaveButton({Key? key, required this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return reausablebutton(
      title: text,
      ontap: onPressed ?? () {},
      width: double.maxFinite,
      height: 46,
      fontSize: 13,
      borderradiues: 12,
      backgroundColor: SafeColors.primary,
      trailingIcon: Icons.chevron_right,
    );
  }
}

class SafeFooterNote extends StatelessWidget {
  const SafeFooterNote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 14.sp, color: Colors.grey.shade500),
          SizedBox(width: 4.w),
          reausabletext(
            "You can edit or deactivate anytime later.",
            fontsize: 11,
            fontweight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}

class SafeLocationInput extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;
  final VoidCallback? onLocate;

  const SafeLocationInput({
    Key? key,
    required this.label,
    required this.value,
    required this.dotColor,
    this.onLocate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SafeColors.border),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(label, fontsize: 10, color: Colors.grey.shade600),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8.sp, color: dotColor),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: reausabletext(
                        value,
                        fontsize: 12,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black87,
                        textoverflow: TextOverflow.ellipsis,
                        maxline: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLocate,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: SafeColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(Icons.my_location,
                  color: SafeColors.primary, size: 14.sp),
            ),
          )
        ],
      ),
    );
  }



}
void showSafeZoneAlertSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SafeAlertBottomSheet(
      type: SafeAlertType.zone,
    ),
  );
}

void showSafeRouteAlertSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SafeAlertBottomSheet(
      type: SafeAlertType.route,
    ),
  );
}

enum SafeAlertType { zone, route }

class SafeAlertBottomSheet extends StatelessWidget {
  final SafeAlertType type;

  const SafeAlertBottomSheet({
    Key? key,
    required this.type,
  }) : super(key: key);

  bool get isZone => type == SafeAlertType.zone;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.64,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),

          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD0CDE0),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isZone
                        ? SafeColors.primary.withOpacity(0.10)
                        : const Color(0xFFFFF0E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isZone
                        ? Icons.shield_outlined
                        : Icons.route_outlined,
                    color: isZone
                        ? SafeColors.primary
                        : const Color(0xFFFF8A3D),
                    size: 21.sp,
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      reausabletext(
                        isZone
                            ? "Safe Zone Alert"
                            : "Safe Route Alert",
                        fontsize: 15,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black,
                      ),
                      SizedBox(height: 1.h),
                      reausabletext(
                        isZone
                            ? "Real-time alerts when team members leave the safe zone"
                            : "Real-time alerts when team members deviate from the safe route",
                        fontsize: 9,
                        color: Colors.grey.shade600,
                        fontweight: FontWeight(600),
                        height: 1.15,
                        maxline: 2,
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 21.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ================= ACTIVE ZONE / ROUTE =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: SafeColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        reausabletext(
                          isZone
                              ? "Active Safe Zone"
                              : "Active Safe Route",
                          fontsize: 9,
                          color: Colors.grey.shade600,
                          fontweight: FontWeight(600)
                        ),

                        SizedBox(height: 2.h),

                        reausabletext(
                          isZone
                              ? "Chembur Zone"
                              : "Mumbai Delivery Route",
                          fontsize: 13,
                          fontfamily: FontFamily.interSemiBold,
                          color: Colors.black,
                        ),

                        SizedBox(height: 2.h),

                        reausabletext(
                          isZone
                              ? "Radius: 500 m  •  Center: Chembur, Mumbai"
                              : "Total Distance: 12.5 km  •  Allowed Deviation: 500 m",
                          fontsize: 9,
                          color: Colors.grey.shade600,
                          fontweight: FontWeight(600),
                          maxline: 1,
                          textoverflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 6.w),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F9EE),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: reausabletext(
                      "Active",
                      fontsize: 10,
                      color: const Color(0xFF1DBF73),
                      fontweight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 5.w),

                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 19.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // ================= RECENT ALERTS TITLE =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                reausabletext(
                  "Recent Alerts",
                  fontsize: 12,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),

                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      reausabletext(
                        "View All",
                        fontsize: 11,
                        color: SafeColors.primary,
                        fontweight: FontWeight.w600,
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 15.sp,
                        color: SafeColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 7.h),

          // ================= RECENT ALERTS SINGLE CARD =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: SafeColors.border,
                ),
              ),
              child: Column(
                children: isZone
                    ? [
                  _alertTile(
                    name: "Rahul Verma",
                    status: "Exited safe zone",
                    location:
                    "Near Ghatkopar (Outside Chembur Zone)",
                    time: "04:32 PM",
                    ago: "2 min ago",
                    avatar:
                    "https://i.pravatar.cc/150?img=12",
                    isZone: true,
                  ),

                  Divider(
                    height: 1,
                    color: SafeColors.border,
                  ),

                  _alertTile(
                    name: "Aamir Khan",
                    status: "Exited safe zone",
                    location:
                    "Vikhroli (Outside Chembur Zone)",
                    time: "04:45 PM",
                    ago: "5 min ago",
                    avatar:
                    "https://i.pravatar.cc/150?img=13",
                    isZone: true,
                  ),
                ]
                    : [
                  _alertTile(
                    name: "Aamir Khan",
                    status: "Deviated from safe route",
                    location:
                    "Vikhroli (Deviation: 780 m)",
                    time: "04:45 PM",
                    ago: "3 min ago",
                    avatar:
                    "https://i.pravatar.cc/150?img=13",
                    isZone: false,
                  ),

                  Divider(
                    height: 1,
                    color: SafeColors.border,
                  ),

                  _alertTile(
                    name: "Sameer Shaikh",
                    status: "Deviated from safe route",
                    location:
                    "Kurla (Deviation: 650 m)",
                    time: "04:32 PM",
                    ago: "6 min ago",
                    avatar:
                    "https://i.pravatar.cc/150?img=15",
                    isZone: false,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // ================= ALERT SETTINGS =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 9.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: SafeColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: SafeColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: SafeColors.primary,
                      size: 19.sp,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        reausabletext(
                          "Alert Settings",
                          fontsize: 12,
                          fontfamily: FontFamily.interSemiBold,
                          color: Colors.black,
                        ),

                        SizedBox(height: 1.h),

                        reausabletext(
                          isZone
                              ? "Manage safe zone, alert distance and notification preferences"
                              : "Manage safe route alerts, deviation limits and notification preferences.",
                          fontsize: 9,
                          color: Colors.grey.shade600,
                          fontweight: FontWeight(600),
                          height: 1.15,
                          maxline: 2,
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 19.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // ================= EDIT BUTTON =================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafeColors.primary,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isZone
                          ? Icons.shield_outlined
                          : Icons.route_outlined,
                      color: Colors.white,
                      size: 17.sp,
                    ),

                    SizedBox(width: 7.w),

                    reausabletext(
                      isZone
                          ? "Edit Safe Zone"
                          : "Edit Safe Route",
                      fontsize: 13,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(
            height:
            MediaQuery.of(context).padding.bottom + 10.h,
          ),
        ],
      ),
    );
  }

  Widget _alertTile({
    required String name,
    required String status,
    required String location,
    required String time,
    required String ago,
    required String avatar,
    required bool isZone,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= AVATAR =================
          Stack(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(avatar),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: isZone
                        ? Colors.red
                        : const Color(0xFFFF8A3D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isZone
                        ? Icons.priority_high
                        : Icons.alt_route,
                    color: Colors.white,
                    size: 9.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 10.w),

          // ================= USER DETAILS =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                reausabletext(
                  name,
                  fontsize: 12,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black,
                ),

                SizedBox(height: 1.h),

                reausabletext(
                  status,
                  fontsize: 10,
                  color: Colors.red,
                  fontweight: FontWeight.w600,
                ),

                SizedBox(height: 1.h),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11.sp,
                      color: Colors.grey.shade600,
                    ),

                    SizedBox(width: 2.w),

                    Flexible(
                      child: reausabletext(
                        location,
                        fontsize: 9,
                        color: Colors.grey.shade600,
                        fontweight: FontWeight(600),
                        maxline: 1,
                        textoverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 6.w),

          // ================= TIME =================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              reausabletext(
                time,
                fontsize: 10,
                color: Colors.grey.shade600,
              ),

              SizedBox(height: 1.h),

              reausabletext(
                ago,
                fontsize: 9,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}