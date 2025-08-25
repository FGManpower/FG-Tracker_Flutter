import 'dart:io';

import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/LiquidPullToRefresh_Indicatore.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Data/Repositories/NotificationServices.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Group/Views/MemberScreen.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Data/Services/FireStore_services.dart';
import '../../../routes/app_pages.dart';
import '../../Group/Views/QrScreen.dart';

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
      // checkDeeplink();
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

    // Debug: Print all permissions' statuses
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
      body: Column(
        children: [
          SizedBox(),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.QiblaScreen);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Container(
                width: double.maxFinite,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.green.shade300,
                    width: 1.2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          color: Colors.green.shade300,
                          'assets/images/qibla.png',
                          height: 50.h,
                          width: 50.w,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Center(
                          child: reausabletext("Qibla Direction",
                              fontsize: 16.sp)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (groupController.responseError.value.isNotEmpty) {
                return LostinternetConnection(
                    retry: () {
                      groupController.getGroupData();
                    },
                    messgae: groupController.responseError.value.toString());
              } else if (groupController.groupDataLoading.value) {
                return groupListUi(isLoading: true);
              } else if (groupController.groupData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/empty_group.png',
                        height: 200.h,
                      ),
                      const SizedBox(height: 20),
                      reausabletext(AppText.noGroupFround,
                          fontsize: 20, fontweight: FontWeight.bold),
                      const SizedBox(height: 8),
                      reausabletext(AppText.youHaventJoindOrCreatedGroup,
                          align: TextAlign.center,
                          color: Colors.grey[600],
                          fontsize: 14),
                      const SizedBox(height: 25),
                    ],
                  ),
                );
              } else {
                return groupListUi(groupData: groupController.groupData);
              }
            }),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 15.h),
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
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: ToggleThemeData.Appcolor,
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
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: ToggleThemeData.Appcolor,
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

  Widget groupListUi({
    List<GroupData>? groupData,
    bool isLoading = false,
  }) {
    return MyCustomPullToRefresh(
      onTapCallback: () {
        groupController.groupDataLoading.value = true;
      },
      onTap2Callback: () {
        groupController.getGroupData();
      },
      Indicatorekey: GlobalKey<LiquidPullToRefreshState>(),
      child: Skeletonizer(
        enabled: isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(), // Allow pull-to-refresh
            itemCount: groupData?.length ?? 10,
            itemBuilder: (context, index) {
              final data = groupData?[index];
              final isActive = data?.isActive ?? true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Opacity(
                  opacity: isActive ? 1 : 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isActive
                            ? Colors.green.shade300
                            : Colors.grey.shade400,
                        width: 1.2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      leading: Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      title: reausabletext(
                        data?.groupName ?? AppText.unnamedTrip,
                        fontsize: 17,
                        fontweight: FontWeight.w600,
                        color: Colors.blueGrey.shade900,
                        maxline: 1,
                        textoverflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reausabletext(
                              data?.groupDesc ?? AppText.noDscrptionAvailable,
                              fontsize: 13,
                              color: Colors.grey[700],
                              maxline: 1,
                              textoverflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                reausabletext(
                                  AppText.groupCode,
                                  fontsize: 13,
                                  color: Colors.grey[700],
                                  maxline: 1,
                                  textoverflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  data?.groupCode ?? "",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                      fontFamily: FontFamily.interSemiBold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            isActive
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QrCodeScreen(
                                              groupCode: data?.groupCode ?? ""),
                                        ),
                                      );
                                    },
                                    child: reausabletext(AppText.showQr,
                                        fontsize: 12),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      trailing: data?.isCreator == true
                          ? SizedBox(
                              width: 50.w,
                              child: CupertinoSwitch(
                                value: data?.isActive ?? false,
                                activeColor: AppColors.darkBlue,
                                onChanged: (value) {
                                  if (data?.isCreator == true) {
                                    groupController.updateGroup(
                                      groupController,
                                      groupId: data!.id.toString(),
                                      groupStatus: value.toString(),
                                    );
                                  }
                                },
                              ),
                            )
                          : Icon(
                              (data?.isActive ?? false)
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_sharp,
                              color: (data?.isActive ?? false)
                                  ? Colors.green
                                  : Colors.redAccent,
                              size: 25.sp),
                      onTap: () {
                        if (data?.isActive == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberscreenScreen(
                                groupId: data!.id.toString(),
                                isCreator: data.isCreator!,
                                isActive: data.isActive!,
                                groupName: data.groupName!,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              groupController.getGroupData();
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
