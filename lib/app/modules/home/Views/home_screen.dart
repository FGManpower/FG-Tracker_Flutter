import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Data/Repositories/NotificationServices.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/CreatedGroupUi.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Data/Services/FireStore_services.dart';
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
  String? groupCode = '';
  firebaseNotificationServices notificationServices =
      firebaseNotificationServices();

  @override
  void initState() {
    super.initState();

    FireStoreServices().createUserDocument();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndRequestPermissions(context);
    });

    controller.getProfileData();
    groupController.getGroupData();
    if (dashController.DeeplinkWithStartJob.value == false) {
    }

    // notificationServices.getDiviceToken();
    notificationServices.setupInteractMessage(context);
  }

  Future<void> checkDeeplink() async {
    await UniServices.init(
      context,
      onCompletion: (success) {
        if (success) {
          // notificationServices.setupInteractMessage(context);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkAndRequestPermissions(BuildContext context) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.locationAlways,
      // Permission.audio,
      Permission.notification,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    statuses.forEach((permission, status) {
      debugPrint('${permission.toString()} status: ${status.toString()}');
    });

    // PermissionStatus overlayStatus = PermissionStatus.granted;
    // if (Platform.isAndroid) {
    //   overlayStatus = await Permission.systemAlertWindow.request();
    //   debugPrint(
    //       'Overlay (System Alert Window) status: ${overlayStatus.toString()}');
    // }
    //
    // bool anyDenied = statuses.values.any((status) => status.isDenied);
    // bool anyPermanentlyDenied =
    //     statuses.values.any((status) => status.isPermanentlyDenied);
    //
    // if ( !overlayStatus.isGranted) {
    //   await Permission.systemAlertWindow.request();
    // } else {
    //   await firebaseNotificationServices().getDiviceToken();
    // }
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
              padding: EdgeInsets.only(left: 5.w, top: 10.h,bottom: 10.h),
              child: reausabletext("Newly Created Group",
                  fontfamily: FontFamily.interSemiBold, fontsize: 18),
            ),
            Obx(() {
              if (groupController.responseError.value.isNotEmpty) {
                return LostinternetConnection(
                    retry: () {
                      groupController.getGroupData();
                    },
                    messgae: groupController.responseError.value.toString());
              } else if (groupController.groupDataLoading.value) {
                return NewlyGroupUi(isLoading: true,groupController: groupController,);
              } else if (groupController.groupData.isEmpty) {
                return Center(
                  child:  reausabletext(AppText.youHaventJoindOrCreatedGroup,
                      align: TextAlign.center,
                      color: Colors.grey[600],
                      fontsize: 14),
                );
              } else {
                return NewlyGroupUi(groupData: groupController.groupData,isLoading: false,groupController: groupController,);
              }
            }),

            Padding(
              padding: EdgeInsets.only(left: 5.w, top: 15.h,bottom: 10.h),
              child: reausabletext("Created Group",
                  fontfamily: FontFamily.interSemiBold, fontsize: 18),
            ),
            Obx(() {
              if (groupController.responseError.value.isNotEmpty) {
                return LostinternetConnection(
                    retry: () {
                      groupController.getGroupData();
                    },
                    messgae: groupController.responseError.value.toString());
              } else if (groupController.groupDataLoading.value) {
                return NewlyGroupUi(isLoading: true,groupController: groupController,);
              } else if (groupController.groupData.isEmpty) {
                return Center(
                  child:  reausabletext(AppText.youHaventJoindOrCreatedGroup,
                      align: TextAlign.center,
                      color: Colors.grey[600],
                      fontsize: 14),
                );
              } else {
                return CreatedGroupUi(groupData: groupController.groupData,isLoading: false,groupController: groupController,);
              }
            }),


          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 0.h),
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            children: [


              Expanded(
                child: InkWell(
                  onTap: () async {
                    DialogBox().showQRScanOptions(context,
                        controller: joinGroupController,
                        groupController: groupController);
                  },
                  child: Container(
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      color: ToggleThemeData.darkPurple,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reausableIcon(
                            icon: Icons.group, color: ToggleThemeData.white),
                        SizedBox(width: 8.w),
                        reausabletext(AppText.joinGroup,
                            color: ToggleThemeData.white, fontsize: 12),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 40.w),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    DialogBox().showCreateGroupBottomSheet(
                      context: context,
                      controller: groupController,
                    );
                  },

                  child: Container(
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      color: ToggleThemeData.darkPurple,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reausableIcon(
                            icon: Icons.group_add,
                            color: ToggleThemeData.white),
                        SizedBox(width: 8.w),
                        reausabletext(AppText.createGroup,
                            color: ToggleThemeData.white, fontsize: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
