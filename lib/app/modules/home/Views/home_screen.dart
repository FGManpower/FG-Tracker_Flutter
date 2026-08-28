import 'dart:io';
import 'dart:ui'; 

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/PermissionGuard.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../gen/assets.gen.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';

import '../../../Core/util/callkit_service.dart';
import '../../../Model/GetMessage.dart';
import '../../../routes/app_pages.dart';
import '../../Messages/Views/create_group_screen.dart';
import '../../Messages/Views/groups_list_screen.dart';
import '../../Messages/Views/walkie_group_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final bluePathPaint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, bluePathPaint);

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.4, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.8, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeScreenState extends State<HomeScreen> {
  final groupController = Get.put(GroupController());
  final controller = Get.put(HomeController());
  final dashController = Get.put(DashboardCtr());
  final joinGroupController = Get.put(JoinGroupController());
  final trackingController = Get.put(TrackingController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final firebaseNotificationServices notificationServices =
      firebaseNotificationServices();

  @override
  void initState() {
    super.initState();

    checkAndRequestPermissions(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.askPermission();
    firebaseNotificationServices().getDiviceToken().then(
      (value) {
        debugPrint("token=>${value}");
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isIOS) {
        await CallKitService.instance.checkCallOnLaunch();
      }
    });
  }

  Future<void> checkAndRequestPermissions(BuildContext context) async {
    await PermissionGuard.checkAndRequestAllPermissions(
      context,
      autoFetchLocation: true,
    );

    await controller.getProfileData();
    await groupController.getGroupData();
    await trackingController.loadLocationSharing();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        drawer: Sidemenu(scaffoldKey: _scaffoldKey),
        appBar: HomeAppBar(
          scaffoldKey: _scaffoldKey,
          controller: controller,
          trackingController: trackingController,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView(
            padding: EdgeInsets.only(bottom: 20.h),
            children: [
              headerUi(controller),
              BannerUi(),
              SizedBox(height: 15.h),
              _buildStatsGrid(),
              SizedBox(height: 25.h),
              _buildMapSection(),
              SizedBox(height: 25.h),
              _buildQuickActions(),
              SizedBox(height: 10.h),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomButtons(context),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildStatCard(
              icon: Icons.groups,
              iconColor: const Color(0xFF6B4DFF),
              title: "Groups",
              value: groupController.createdGroups.length.toString(),
              subtitle: "Total",
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.person,
            iconColor: const Color(0xFF10B981),
            title: "Online",
            value: "4",
            subtitle: "Now",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_alt,
            iconColor: const Color(0xFF3B82F6),
            title: "Members",
            value: "10",
            subtitle: "Total",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.supervised_user_circle,
            iconColor: const Color(0xFFF59E0B),
            title: "Ghost mode",
            value: "2",
            subtitle: "Ongoing",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(height: 8.h),
              reausabletext(
                title,
                fontsize: 11.sp,
                color: Colors.black87,
                fontfamily: FontFamily.interSemiBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                value,
                fontsize: 18.sp,
                color: Colors.black,
                fontfamily: FontFamily.interBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                subtitle,
                fontsize: 10.sp,
                color: Colors.grey,
                align: TextAlign.center, // Text Alignment Center
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        Row(
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
                reausabletext("Live Tracking",
                    fontsize: 16.sp, fontfamily: FontFamily.interBold),
              ],
            ),
            Row(
              children: [
                _buildMapFilterBadge("All Groups", Icons.keyboard_arrow_down),
                SizedBox(width: 8.w),
                _buildMapFilterBadge("Radius: 2 km", Icons.my_location),
              ],
            )
          ],
        ),
        SizedBox(height: 15.h),
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),
                Positioned(top: 25.h, left: 35.w, child: _buildMapAvatarPin()),
                Positioned(top: 35.h, right: 85.w, child: _buildMapAvatarPin()),
                Positioned(
                    bottom: 50.h, left: 55.w, child: _buildMapAvatarPin()),
                Positioned(
                    bottom: 40.h, right: 95.w, child: _buildMapAvatarPin()),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6B4DFF).withOpacity(0.15),
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4DFF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: reausabletext("You",
                          color: Colors.white,
                          fontsize: 10.sp,
                          fontfamily: FontFamily.interBold),
                    ),
                  ),
                ),
                Positioned(
                  right: 12.w,
                  top: 30.h,
                  child: Column(
                    children: [
                      _buildMapControlBtn(Icons.add),
                      SizedBox(height: 4.h),
                      _buildMapControlBtn(Icons.remove),
                      SizedBox(height: 8.h),
                      _buildMapControlBtn(Icons.my_location),
                    ],
                  ),
                ),
                Positioned(
                  left: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group,
                            size: 14.sp, color: const Color(0xFF6B4DFF)),
                        SizedBox(width: 6.w),
                        reausabletext("8 Members Live",
                            fontsize: 11.sp,
                            fontfamily: FontFamily.interSemiBold),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.12),
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4DFF),
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFF6B4DFF).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_filled,
                                color: Colors.white, size: 18.sp),
                            SizedBox(width: 8.w),
                            reausabletext(
                              "Coming Soon",
                              color: Colors.white,
                              fontsize: 16.sp,
                              fontfamily: FontFamily.interBold,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildMapAvatarPin() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: CircleAvatar(
            radius: 14.r,
            backgroundColor: const Color(0xFFE8F0FE),
            child:
                Icon(Icons.person, size: 16.sp, color: const Color(0xFF6B4DFF)),
          ),
        ),
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5.w),
          ),
        )
      ],
    );
  }

  Widget _buildMapControlBtn(IconData icon) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)
        ],
      ),
      child: Icon(icon, size: 16.sp, color: Colors.black87),
    );
  }

  Widget _buildMapFilterBadge(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          if (icon != Icons.keyboard_arrow_down) ...[
            Icon(icon, size: 14.sp, color: const Color(0xFF6B4DFF)),
            SizedBox(width: 4.w),
          ],
          reausabletext(text, fontsize: 11.sp, color: Colors.black87),
          if (icon == Icons.keyboard_arrow_down) ...[
            SizedBox(width: 4.w),
            Icon(icon, size: 16.sp, color: Colors.black87),
          ]
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            reausabletext(
              "Quick Actions",
              fontsize: 16.sp,
              fontfamily: FontFamily.interBold,
            ),
            Row(
              children: [
                reausabletext(
                  "View All",
                  fontsize: 12.sp,
                  color: const Color(0xFF6B4DFF),
                  fontfamily: FontFamily.interSemiBold,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 14.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 15.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.0,
          children: [
            _buildActionCard("Calling", Icons.phone, isComingSoon: true),
            _buildActionCard(
              "Walkie Talkie",
              Icons.settings_cell,
              // onTap: () => Get.toNamed(Routes.WalkieGroupSelect),
              // bina route ke:
              onTap: () => Get.to(() => const WalkieGroupSelectScreen()),
            ),
            _buildActionCard("Tracking", Icons.location_on, isComingSoon: true),
            _buildActionCard("Video Call", Icons.videocam, isComingSoon: true),
            _buildActionCard("Chatting", Icons.chat_bubble, isComingSoon: true),
            _buildActionCard(
              "Group Chat",
              Icons.groups,
              onTap: () {
                Get.toNamed(Routes.GroupsList);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F8FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF6B4DFF).withOpacity(0.05),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: const Color(0xFF6B4DFF),
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      reausabletext(
                        title,
                        fontsize: 12.sp,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black87,
                        align: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      if (!isComingSoon)
                        Container(
                          width: 12.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4DFF),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        )
                      else
                        SizedBox(height: 14.h),
                    ],
                  ),
                ),
                if (isComingSoon) ...[
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      color: Colors.black.withOpacity(0.85),
                      alignment: Alignment.center,
                      child: Text(
                        "COMING SOON",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
            EdgeInsets.only(left: 16.w, right: 16.w, bottom: 15.h, top: 10.h),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  DialogBox().showQRScanOptions(
                    context,
                    controller: joinGroupController,
                    groupController: groupController,
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B78FF), Color(0xFF5A3FFF)]),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_add, color: Colors.white, size: 24.sp),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          reausabletext("Join Group",
                              color: Colors.white,
                              fontsize: 14.sp,
                              fontfamily: FontFamily.interBold),
                          reausabletext("Join existing group",
                              color: Colors.white70, fontsize: 10.sp),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  try {
                    groupController.groupName.clear();
                    groupController.groupDesc.clear();
                  } catch (e) {
                    debugPrint("Clear error: $e");
                  }

                  Get.to(() => CreateGroupScreen());
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: const Color(0xFF6B4DFF), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF6B4DFF), width: 1.5),
                        ),
                        child: Icon(Icons.add,
                            color: const Color(0xFF6B4DFF), size: 18.sp),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          reausabletext("Create Group",
                              color: const Color(0xFF6B4DFF),
                              fontsize: 14.sp,
                              fontfamily: FontFamily.interBold),
                          reausabletext("Create new group",
                              color: Colors.grey, fontsize: 10.sp),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward,
                          color: const Color(0xFF6B4DFF), size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
