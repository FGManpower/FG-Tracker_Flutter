import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/PermissionGuard.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/global_widget/crown_icon.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/app/modules/home/Views/LiveStatus/StatsGrid.dart';
import 'package:fgtracker/app/modules/home/Views/bottom_actions_bar.dart';
import 'package:fgtracker/app/modules/home/Views/quick_actions_section.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upgrader/upgrader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final groupController = Get.put(GroupController());
  final controller = Get.put(HomeController());
  final joinGroupController = Get.put(JoinGroupController());
  final trackingController = Get.put(GroupTrackingController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final firebaseNotificationServices notificationServices =
  firebaseNotificationServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkAndRequestPermissions(context);
        notificationServices.setupInteractMessage(context);
      }
    });
    notificationServices.askPermission();

    requestCallPermissions();
  }

  Future<void> requestCallPermissions() async {
    await [
      Permission.microphone,
      Permission.camera,
      Permission.audio,
      Permission.notification,
      Permission.contacts,
    ].request();
  }

  Future<void> checkAndRequestPermissions(BuildContext context) async {
    await PermissionGuard.checkAndRequestAllPermissions(
      context,
      autoFetchLocation: true,
    );

    await trackingController.loadLocationSharing();
    await SocketService.instance.init(ConstRes.socketUrl);
    trackingController.initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Obx(
            () => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF4F6FC),
          key: _scaffoldKey,
          drawer: Sidemenu(scaffoldKey: _scaffoldKey),
          appBar: Utility.isNotNullEmptyOrFalse(
              controller.InitializeResponeMessage.isNotEmpty)
              ? null
              : HomeAppBar(
            scaffoldKey: _scaffoldKey,
            controller: controller,
            trackingController: trackingController,
          ),
          body: Utility.isNotNullEmptyOrFalse(
              controller.InitializeResponeMessage.isNotEmpty)
              ? LostinternetConnection(
            retry: () async {
              controller.init();
            },
            messgae: controller.InitializeResponeMessage.value,
          )
              : RefreshIndicator(
            onRefresh: () async {
              controller.init();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ListView(
                padding: EdgeInsets.only(bottom: 8.h),
                children: [
                  BannerUi(),
                  const StatsGrid(),
                  SizedBox(height: 10.h),
                  const _UpgradeToPremiumCard(),
                  SizedBox(height: 12.h),
                  QuickActionsSection(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Utility.isNotNullEmptyOrFalse(
              controller.InitializeResponeMessage.isNotEmpty)
              ? null
              : BottomActionsBar(
            groupController: groupController,
            joinGroupController: joinGroupController,
          ),
        ),
      ),
    );
  }
}

class _UpgradeToPremiumCard extends StatelessWidget {
  const _UpgradeToPremiumCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(Routes.walkieTalkieTrialDetails);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5B45F8),
              Color(0xFF7E64FF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B45F8).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CrownIcon(
                  width: 22.w,
                  height: 16.h,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Upgrade to Premium",
                    style: TextStyle(
                      fontFamily: FontFamily.interBold,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Unlock advanced features for your team",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontFamily.interRegular,
                      fontSize: 9.5.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View Plans",
                    style: TextStyle(
                      fontFamily: FontFamily.interSemiBold,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B45F8),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF5B45F8),
                    size: 13.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}