import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/PermissionGuard.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/app/modules/home/Views/StatsGrid.dart';
import 'package:fgtracker/app/modules/home/Views/bottom_actions_bar.dart';
import 'package:fgtracker/app/modules/home/Views/map_section.dart';
import 'package:fgtracker/app/modules/home/Views/quick_actions_section.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        debugPrint("token=>$value");
      },
    );
    SocketDashboardService.instance.init();
    requestCallPermissions();
  }

  Future<void> requestCallPermissions() async {
    await [
      Permission.microphone,
      Permission.camera,
      Permission.audio,
      Permission.notification,
    ].request();
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
              BannerUi(),
              SizedBox(height: 15.h),
              StatsGrid(controller: controller),
              SizedBox(height: 25.h),
              const MapSection(),
              SizedBox(height: 25.h),
              const QuickActionsSection(),
              SizedBox(height: 10.h),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionsBar(
          groupController: groupController,
          joinGroupController: joinGroupController,
        ),
      ),
    );
  }
}
