import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/LiquidPullToRefresh_Indicatore.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Repositories/NotificationServices.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/DashboardController.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Group/Views/MemberScreen.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/bannerUi.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/modules/Group/Controller/Group_Controller.dart';
import 'package:fgtracker/app/widgets/Appbar.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Data/Services/FireStore_services.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerUi(controller),
            BannerUi(),
            Padding(
              padding: EdgeInsets.only(left: 5.w, top: 10.h),
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
            })
          ],
        ),
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
    return Expanded(child: ListView.separated(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: groupData?.length ?? 8,
      padding: EdgeInsets.only(bottom: 110.h),
      separatorBuilder: (context, index) => SizedBox(width: 12.w),
      itemBuilder: (context, index) {
        final data = groupData?[index];
        final bool isActive = data?.isActive ?? false;
        final bool isCreator = data?.isCreator ?? false;

        return GestureDetector(
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
          child: Opacity(
            opacity: isActive ? 1 : 0.7,
            child: Container(
              width: 190.w,
              decoration: BoxDecoration(
                color: const Color(0xffF2F0FF),
                borderRadius: BorderRadius.circular(15.r),
                // border: Border.all(
                //   color: const Color(0xff5045B9).withOpacity(0.3),
                //   width: 1,
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: const Color(0xffE4E0FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 8.h),
                    child: reausabletext(
                      data?.groupName ?? AppText.unnamedTrip,
                      fontsize: 18,
                      fontfamily: FontFamily.interSemiBold,
                      color:ToggleThemeData.black,
                      maxline: 2,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            reausabletext(
                              "Team Code",
                              fontfamily: FontFamily.interRegular,
                              fontsize: 12,
                            ),
                            isCreator
                                ? Transform.scale(
                              scale: 0.9,
                              child: CupertinoSwitch(
                                value: isActive,
                                onChanged: (value) {
                                  groupController.updateGroup(
                                    groupController,
                                    groupId: data!.id.toString(),
                                    groupStatus: value.toString(),
                                  );
                                },
                                activeColor: const Color(0xff5045B9),
                                trackColor: Colors.black26,
                              ),
                            )

                                : Icon(
                              isActive
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_sharp,
                              color: isActive
                                  ? Colors.green
                                  : Colors.redAccent,
                              size: 20.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h,),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            reausabletext(
                              data?.groupCode ?? "",
                              fontfamily: FontFamily.interSemiBold,
                              fontsize: 11,
                              color: const Color(0xff5045B9),
                              maxline: 1,
                              textoverflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: 10.w,),
                            reausableIcon(icon: Icons.copy,size: 16,color: Colors.black45,ontap: () {
                              Clipboard.setData(ClipboardData(
                                  text: data?.groupCode ?? ""));
                              Utils()
                                  .fluttertoast("Group code copied!");
                            },)

                          ],
                        ),
                        SizedBox(height: 4.h),
                        GestureDetector(
                          onTap: () {
                            if (isActive) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QrCodeScreen(
                                      groupCode: data?.groupCode ?? ""),
                                ),
                              );
                            } else {
                              Utils().fluttertoast(
                                  "Activate the group to view QR");
                            }
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              reausabletext(
                                "Show QR Code",
                                fontfamily: FontFamily.interSemiBold,
                                fontsize: 12,
                                color: ToggleThemeData.darkPurple
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xff5045B9),
                                    width: 1.8.w,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: reausableIcon(
                                    icon: FontAwesomeIcons.walkieTalkie,
                                    size: 18,
                                    color: const Color(0xff5045B9),
                                  ),
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
          ),
        );
      },
    ));
  }
}
