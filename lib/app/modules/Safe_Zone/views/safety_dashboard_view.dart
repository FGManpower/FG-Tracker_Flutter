import 'package:fgtracker/app/modules/Safe_Zone/views/safe_route_view.dart';
import 'package:fgtracker/app/modules/Safe_Zone/views/safe_zone_view.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/safety_dashboard_controller.dart';

// 👈 BOTTOM SHEET WALI FILE IMPORT KI HAI
import '../Widgets/safe_common_widgets.dart';

class SafetyDashboardView extends StatelessWidget {
  const SafetyDashboardView({Key? key}) : super(key: key);

  final Color _textColorDark = const Color(0xFF1A1A2C);
  final Color _textColorGrey = const Color(0xFF7A7A8C);
  final Color _primaryColor = const Color(0xFF6B4DFF);

  final Color _featureIconBg = const Color(0xFFF3F0FF);
  final Color _safeNowIconBg = const Color(0xFFE3F6EA);
  final Color _alertIconBg = const Color(0xFFFCE9E9);
  final Color _zoneAlertIconBg = const Color(0xFFFCE6E6);
  final Color _routeAlertIconBg = const Color(0xFFFDF0E1);

  List<BoxShadow> get _cardShadow => [
    BoxShadow(
      color: const Color(0xFF6B4DFF).withOpacity(0.04),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 6),
    )
  ];

  Widget _circleIconBg(
      Widget child, {
        required Color bgColor,
        double size = 56,
      }) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafetyDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            SizedBox(height: 18.h),
            _buildSectionTitle("Choose a Safety Feature"),
            SizedBox(height: 13.h),
            _buildFeatureCard(
              title: "Safe Zone",
              tag: "Area Protection",
              desc:
              "Define a safe geographic area for your team. Get instant alerts if someone steps outside the safe zone.",
              image: Assets.icons.safeZone.image(
                height: 40.w,
                width: 40.w,
                fit: BoxFit.contain,
              ),
              onTap: () => Get.to(() => const SafeZoneView()),
            ),
            SizedBox(height: 13.h),
            _buildFeatureCard(
              title: "Safe Route",
              tag: "Route Protection",
              desc:
              "Set predefined routes for your team members. Get alerts if someone deviates from the safe route.",
              image: Assets.icons.safeRoute.image(
                height: 40.w,
                width: 40.w,
                fit: BoxFit.contain,
              ),
              onTap: () => Get.to(() => const SafeRouteView()),
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle("Quick Overview"),
            SizedBox(height: 13.h),
            _buildQuickOverviewCard(controller),
            SizedBox(height: 22.h),
            _buildSectionTitle("Recent Alerts"),
            SizedBox(height: 13.h),
            _buildRecentAlertsList(controller),
            SizedBox(height: 28.h),
            _buildNeedHelpCard(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 70.w,
      leading: Center(
        child: InkWell(
          onTap: () => Get.back(),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: _cardShadow,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: _primaryColor,
              size: 18.sp,
            ),
          ),
        ),
      ),
      title: Transform.translate(
        offset: Offset(-32.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Safety",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _textColorDark,
              ),
            ),
            Text(
              "Stay protected. Stay connected.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _textColorGrey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: _cardShadow,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: _primaryColor,
                  size: 22.sp,
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150.w,
            height: 150.w,
            child: Assets.icons.yourSafetyOurPrioty.image(
              width: 150.w,
              height: 150.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Safety, Our Priority",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _textColorDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Monitor and protect your team with smart safety features.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: _textColorGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: _textColorDark,
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String tag,
    required String desc,
    required Widget image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: _cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _circleIconBg(image, bgColor: _featureIconBg, size: 58),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.w,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: _textColorDark,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: _textColorGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4DFF).withOpacity(0.06),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOverviewCard(
      SafetyDashboardController controller,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: _cardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _circleIconBg(
                    Icon(
                      Icons.verified_user_rounded,
                      color: const Color(0xFF00B960),
                      size: 30.sp,
                    ),
                    bgColor: _safeNowIconBg,
                    size: 52,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                              () => Text(
                            controller.safeNowCount.value.toString(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00B960),
                            ),
                          ),
                        ),
                        Text(
                          "Safe Now",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00B960),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Members are within safe zone/route",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: _textColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: VerticalDivider(
                color: Colors.grey.shade200,
                thickness: 1,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _circleIconBg(
                    Icon(
                      Icons.warning_rounded,
                      color: const Color(0xFFFF3B30),
                      size: 30.sp,
                    ),
                    bgColor: _alertIconBg,
                    size: 52,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                              () => Text(
                            controller.alertsCount.value
                                .toString()
                                .padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                        Text(
                          "Alerts",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Require immediate attention",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: _textColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsList(SafetyDashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: _cardShadow,
      ),
      child: Obx(() {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.recentAlerts.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade100,
            height: 1,
            indent: 70.w,
            endIndent: 20.w,
          ),
          itemBuilder: (context, index) {
            final alert = controller.recentAlerts[index];
            final bool isZone = alert.isZone;

            // 👈 YAHAN InkWell ADD KIYA HAI BOTTOM SHEET OPEN KARNE KE LIYE
            return InkWell(
              onTap: () {
                if (isZone) {
                  showSafeZoneAlertSheet(context);
                } else {
                  showSafeRouteAlertSheet(context);
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _circleIconBg(
                      isZone
                          ? Assets.icons.safeZoneAlart.image(
                        height: 34.w,
                        width: 34.w,
                        fit: BoxFit.contain,
                      )
                          : Assets.icons.safeRoute.image(
                        height: 34.w,
                        width: 34.w,
                        fit: BoxFit.contain,
                      ),
                      bgColor: isZone ? _zoneAlertIconBg : _routeAlertIconBg,
                      size: 44,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            alert.type,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _textColorDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            alert.desc,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _textColorGrey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  alert.location,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _textColorGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alert.time,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _textColorGrey,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNeedHelpCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: const Color(0xFFF3F0FF),
            child: Icon(
              Icons.headset_mic_rounded,
              color: _primaryColor,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Help?",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: _textColorDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Contact support team for any safety related assistance.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: _textColorGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 31.h,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(Icons.headset_mic_rounded, size: 14.sp),
              label: Text(
                "Contact Support",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}