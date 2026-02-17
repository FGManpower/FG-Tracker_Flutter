import 'dart:io';

import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/CreatedGroupUi.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../gen/assets.gen.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import '../../../Core/global/global_notification_handler.dart';

import '../../../Core/global/launchedFromCall.dart';
import '../../../Core/util/CallUtils.dart';
import '../../../Core/util/decomPress.dart';
import '../Home_Widget/NewlyGroupUi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final groupController = Get.put(GroupController());
  final controller = Get.put(HomeController());
  final dashController = Get.put(DashboardCtr());
  final joinGroupController = Get.put(JoinGroupController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final firebaseNotificationServices notificationServices =
      firebaseNotificationServices();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      handleTerminatedCallIfAny();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkAndRequestPermissions(context);

    });



    controller.getProfileData();
    groupController.getGroupData();

    notificationServices.setupInteractMessage(context);
    checkDeeplink();
  }

  Future<void> checkAndRequestPermissions(BuildContext context) async {
    // await WalkieNativeService.saveUserId(
    //   Global.storageServices.get(PrefConst.userId).toString(),
    // );
    final settings = await FirebaseMessaging.instance.requestPermission();

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.locationAlways,
      Permission.notification,
      Permission.audio,
      Permission.photos,
      Permission.contacts,
    ];

    // await permissions.request();
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Debug: Print all permissions' statuses
    statuses.forEach((permission, status) {
      // debugPrint('${permission.toString()} status: ${status.toString()}');
    });

    // PermissionStatus overlayStatus = PermissionStatus.granted;
    // if (Platform.isAndroid) {
    //   overlayStatus = await Permission.systemAlertWindow.request();
    //   debugPrint(
    //       'Overlay (System Alert Window) status: ${overlayStatus.toString()}');
    // }

    bool anyDenied = statuses.values.any((status) => status.isDenied);
    bool anyPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);

    // if ( !overlayStatus.isGranted) {
    //   await Permission.systemAlertWindow.request();
    // }
  }

  Future<void> checkActiveCallOnStart() async {
    final calls = await FlutterCallkitIncoming.activeCalls();

    if (calls is List && calls.isNotEmpty) {
      final callData = calls[0];

      CallSessionState.isCallActive = true;
      CallSessionState.launchedFromCall = true;

      final extra = decomPress().extractExtra(callData);

      CallUtils.instance.navigateToCallScreen(extra);
    }
  }


  @override
  void dispose() {
    super.dispose();
  }


  Future<void> checkDeeplink() async {
   // await Permission.systemAlertWindow.request();
    await UniServices.init(onCompletion: (success) {

    },);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: Sidemenu(scaffoldKey: _scaffoldKey),
      appBar: HomeAppBar(
        scaffoldKey: _scaffoldKey,
        controller: controller,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: ListView(
          children: [
            headerUi(controller),
            BannerUi(),
            Padding(
              padding: EdgeInsets.only(left: 5.w, top: 10.h, bottom: 10.h),
              child: reausabletext(
                "Newly Created Group",
                fontfamily: FontFamily.interSemiBold,
                fontsize: 18,
              ),
            ),
            Obx(() {
              if (groupController.responseError.value.isNotEmpty) {
                return LostinternetConnection(
                  retry: groupController.getGroupData,
                  messgae: groupController.responseError.value.toString(),
                );
              } else if (groupController.groupDataLoading.value) {
                return NewlyGroupUi(
                  isLoading: true,
                  groupController: groupController,
                );
              } else if (groupController.newlyCreatedGroups.isEmpty) {
                return Center(
                  child: reausabletext(
                    AppText.youHaventJoindOrCreatedGroup,
                    align: TextAlign.center,
                    color: Colors.grey[600],
                    fontsize: 14,
                  ),
                );
              } else {
                return NewlyGroupUi(
                  groupData: groupController.newlyCreatedGroups,
                  isLoading: false,
                  groupController: groupController,
                );
              }
            }),
            Padding(
              padding: EdgeInsets.only(left: 5.w, top: 15.h),
              child: reausabletext(
                "Created Group",
                fontfamily: FontFamily.interSemiBold,
                fontsize: 18,
              ),
            ),
            Obx(() {
              return groupController.createdGroups.isEmpty
                  ? Center(
                      child: DataEmpty(
                        imgname: Assets.images.notFount.path,
                        type: "png",
                      ),
                    )
                  : CreatedGroupUi(
                      groupData: groupController.createdGroups,
                      isLoading: false,
                      groupController: groupController,
                    );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: reausablebutton(
                title: AppText.joinGroup,
                icon: Icons.group,
                fontSize: 12,
                borderradiues: 50,
                height: 55,
                ontap: () {
                  DialogBox().showQRScanOptions(
                    context,
                    controller: joinGroupController,
                    groupController: groupController,
                  );
                },
              ),
            ),
            SizedBox(width: 40.w),
            Expanded(
              child: reausablebutton(
                title: AppText.createGroup,
                icon: Icons.group_add,
                fontSize: 12,
                borderradiues: 50,
                height: 55,
                ontap: () {
                  DialogBox().showCreateGroupBottomSheet(
                    context: context,
                    controller: groupController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
