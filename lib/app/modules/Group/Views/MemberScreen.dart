import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/BottomSheets/userSheet_Ui.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/LiquidPullToRefresh_Indicatore.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Group/controller/search_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/widgets/MobileNumberView.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Core/util/DateTime_Format.dart';
import '../../../Data/Services/Tracking.dart';
import '../../Track/Widget/TrackLAppBar.dart';
import 'QrScreen.dart';

class MemberscreenScreen extends GetView<MemberController> {
  const MemberscreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          backgroundColor: ToggleThemeData.white,
          automaticallyImplyLeading: false,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            icon: Container(
              height: 33.w,
              width: 33.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: ToggleThemeData.darkPurple, width: 2.w),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_outlined,
                  color: ToggleThemeData.darkPurple,
                  size: 24.sp,
                ),
              ),
            ),
          ),
          title: controller.isSearching.value
              ? Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: ToggleThemeData.darkPurple),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.onSearch(value);
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        icon: Icon(Icons.search,
                            size: 20.sp, color: Colors.grey.shade600),
                        hintText: "Search member...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h)),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : reausabletext(
                  "Members",
                  fontsize: 20,
                  color: Colors.black,
                  fontweight: FontWeight.bold,
                ),
          actions: [
            IconButton(
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: ToggleThemeData.darkPurple,
                size: 26.sp,
              ),
              onPressed: () {
                controller.isSearching.toggle();
                controller.searchController.clear();
                controller.filteredMembers.assignAll(controller.memberData);
              },
            ),
            if (!controller.isSearching.value)
              PopupMenuButton<String>(
                onSelected: (value) {},
                color: Colors.white,
                elevation: 5,
                offset: Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: ToggleThemeData.darkPurple,
                  size: 26.sp,
                ),
                itemBuilder: (context) => [
                  if (bool.parse(controller.arguments!['isCreator'].toString()))
                    popupItem(
                      context: context,
                      value: 'delete',
                      icon: Icons.delete_outline,
                      text: 'Group Delete',
                      onTap: () {
                        CommonDialog.ConfirmationDialog(
                          title: AppText.areYouSure,
                          content: AppText.doYouWantToDeleteGroup,
                          onConfirm: () {
                            controller.deleteGroup(
                              context,
                              groupId:
                                  controller.arguments!['groupId'].toString(),
                            );
                          },
                        );
                      },
                    )
                  else
                    popupItem(
                      context: context,
                      value: 'exit',
                      icon: Icons.exit_to_app,
                      text: 'Exit Group',
                      onTap: () {
                        CommonDialog.ConfirmationDialog(
                          title: AppText.areYouSure,
                          content: AppText.doYouWantToExitGroup,
                          onConfirm: () {
                            controller.exitGroup(
                              context,
                              groupId:
                                  controller.arguments!['groupId'].toString(),
                              userId: Global.storageServices
                                  .get(PrefConst.userId)
                                  .toString(),
                              onSuccess: (success) {
                                if(success){
                                  Get.offAllNamed(Routes.Home_Screen);
                                }
                              },

                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            SizedBox(width: 5.w),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: controller.filteredMembers.isEmpty
              ? SizedBox()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.h, vertical: 10.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      reausablebutton(
                          title: "Walkie-Talkie",
                          icon: Icons.wifi_calling_3_outlined,
                          fontSize: 12,
                          borderradiues: 50,
                          ontap: () {
                            // Get.toNamed(Routes.LocationTracking, arguments: {
                            //   "groupId": int.parse(controller
                            //       .arguments!['groupId']
                            //       .toString()),
                            //   "groupName": controller.arguments!['groupName'],
                            // });


                            Get.toNamed(
                              Routes.groupWalkieScreen,
                              arguments: {
                                "groupId":  int.parse(controller
                                    .arguments!['groupId']
                                    .toString()),
                                "groupName": controller.arguments!['groupName'],
                                "isAdmin": controller.arguments!['isCreator'],
                              },
                            );
                          },
                          height: 55),
                      SizedBox(height: 10.h,),
                      Row(
                        children: [
                          Expanded(
                            child: reausablebutton(
                                title: "Track",
                                icon: Icons.track_changes,
                                fontSize: 12,
                                borderradiues: 50,
                                ontap: () {
                                  Get.toNamed(Routes.LocationTracking, arguments: {
                                    "groupId": int.parse(controller
                                        .arguments!['groupId']
                                        .toString()),
                                    "groupName": controller.arguments!['groupName'],
                                  });
                                },
                                height: 55),
                          ),
                          SizedBox(width: 40.w),
                          Expanded(
                              child: reausablebutton(
                                  title: "Group Message",
                                  icon: Icons.mark_chat_unread_rounded,
                                  fontSize: 12,
                                  borderradiues: 50,
                                  ontap: () {
                                    Get.toNamed(
                                      Routes.groupChatScreen,
                                      arguments: {
                                        "groupId": int.parse(controller
                                                .arguments!['groupId']
                                                .toString())
                                            .toString(),
                                        "groupName":
                                            controller.arguments!['groupName'],
                                        "groupImage": "",
                                      },
                                    );
                                  },
                                  height: 55)),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 15.w,
                  top: 20.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      controller.arguments!['groupName'] ?? "",
                      fontsize: 21,
                      fontfamily: FontFamily.interBold,
                      color: ToggleThemeData.darkPurple,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        reausabletext(
                          "Feel Free to start a conversation ",
                          fontsize: 12,
                          fontfamily: FontFamily.interRegular,
                          color: Colors.black45,
                        ),
                        Expanded(
                          child: Container(
                            height: 3.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Color(0xff5045B9),
                                  Color(0xff5045B9),
                                ],
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.r),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
            if (controller.responseError.value.isNotEmpty)
              SliverFillRemaining(
                child: LostinternetConnection(
                  retry: () {
                    controller.getMembersData(
                      controller.arguments!['groupId'],
                    );
                  },
                  messgae: controller.responseError.value.toString(),
                ),
              )
            else if (controller.memberDataLoading.value)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: memberListUi(isLoading: true),
                ),
              )
            else if (controller.filteredMembers.isEmpty)
              SliverFillRemaining(
                child: DataEmpty(
                  imgname: Assets.images.notFount.path,
                  type: "png",
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == controller.filteredMembers.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            QrCodeBottomSheet.show(
                              context,
                              groupName: controller.arguments!["groupName"].toString(),
                              groupCode: controller.arguments!["groupCode"].toString(),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffF2F0FF),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: ToggleThemeData.darkPurple,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1,
                                  color: ToggleThemeData.darkPurple,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Add Member",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "Share QR code to invite members",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.qr_code,
                                  color: ToggleThemeData.darkPurple,
                                  size: 25.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final data = controller.filteredMembers[index];

                    bool isOnline = false;

                    if (data.lastSeen != null && data.lastSeen!.isNotEmpty) {
                      try {
                        isOnline = Tracking()
                                .getTimeAgo(
                                  DateTime.parse(data.lastSeen!),
                                )
                                .toLowerCase() ==
                            "just now";
                      } catch (_) {
                        isOnline = false;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        if (Global.storageServices
                                .get(PrefConst.userId)
                                .toString() !=
                            data.userId.toString()) {
                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: {
                              "userData": data,
                              "groupName": controller.arguments!['groupName'],
                              "isCreator": controller.arguments!['isCreator'],
                              "type": "",
                            },
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.h,
                              vertical: 10.h,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30.r,
                                      backgroundImage: NetworkImage(
                                        "${ConstRes.aImageBaseUrl}${data.profileImage ?? ""}",
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                    Positioned(
                                      right: 4.w,
                                      child: Container(
                                        height: 12.w,
                                        width: 12.w,
                                        decoration: BoxDecoration(
                                          color: isOnline
                                              ? Colors.green
                                              : Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            reausabletext(
                                              data.name ??
                                                  AppText.unnamedMember,
                                              fontsize: 15,
                                              fontfamily:
                                                  FontFamily.interSemiBold,
                                            ),
                                            SizedBox(height: 2.h),
                                            MobileNumberView(
                                              mobileNumber: data.mobileNo ??
                                                  AppText.noNumber,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          reausabletext(
                                            Utility.isNotNullEmptyOrFalse(
                                                    data.lastSeen)
                                                ? formatTime(
                                                    data.lastSeen!,
                                                  )
                                                : "",
                                            fontsize: 10,
                                            fontfamily: FontFamily.interMedium,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(

                                            children: [
                                            data.locationSharing==true?  InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                                onTap: () {
                                                  Get.toNamed(
                                                    Routes.LocationTracking,
                                                    arguments: {
                                                      "groupId": int.parse(
                                                        controller.arguments![
                                                                'groupId']
                                                            .toString(),
                                                      ),
                                                      "groupName":
                                                          controller.arguments![
                                                              'groupName'],
                                                      "targetUserId": data
                                                          .userId
                                                          .toString(),
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: ToggleThemeData
                                                        .darkPurple
                                                        .withValues(alpha: 0.08),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.near_me,
                                                    color: ToggleThemeData
                                                        .darkPurple,
                                                    size: 18.sp,
                                                  ),
                                                ),
                                              ):SizedBox(),
                                              // InkWell(
                                              //   onTap: () {
                                              //     WalkieController()
                                              //         .startServices(
                                              //             callerName: data!.name
                                              //                 .toString(),
                                              //             profileImage:
                                              //                 data.profileImage,
                                              //             remoteUserId: data!
                                              //                 .userId
                                              //                 .toString());
                                              //   },
                                              //   child: Padding(
                                              //     padding: EdgeInsets.only(
                                              //         left: 10.w),
                                              //     child: Image.asset(
                                              //       Assets.icons.walkieTalkie
                                              //           .path,
                                              //       height: 28.h,
                                              //       width: 28.w,
                                              //     ),
                                              //   ),
                                              // )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index != controller.filteredMembers.length - 1)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: controller.filteredMembers.length + 1,
                ),
              ),
          ],
        ),
        floatingActionButton: InkWell(
          onTap: () async {
            var result = await UserSheetUi().showAllUserBottomSheet(context);
            if (result != null) {
              var success = await SearchUserController().joinGroup(
                context,
                groupCode: controller.arguments!['groupCode'].toString(),
                userId: result.userId.toString(),
              );
              if (success) {
                controller.getMembersData(
                    controller.arguments!["groupId"].toString());
              }
            }
          },
          child: CircleAvatar(
            radius: 25.sp,
            backgroundColor: AppColors.primaryDarkblue,
            child: reausableIcon(
                icon: Icons.add, size: 26, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget memberListUi({
    List<MemberData>? groupData,
    bool isLoading = false,
  }) {
    return MyCustomPullToRefresh(
      onTapCallback: () {
        controller.memberDataLoading.value = true;
      },
      onTap2Callback: () {
        controller.getMembersData(controller.arguments!['groupId']);
      },
      Indicatorekey: GlobalKey<LiquidPullToRefreshState>(),
      child: Skeletonizer(
        enabled: isLoading,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: groupData?.length ?? 10,
              itemBuilder: (context, index) {
                final data = groupData?[index];
                bool isOnline = false;

                if (data?.lastSeen != null && data!.lastSeen!.isNotEmpty) {
                  try {
                    isOnline = Tracking()
                            .getTimeAgo(DateTime.parse(data.lastSeen!))
                            .toLowerCase() ==
                        "just now";
                  } catch (_) {
                    isOnline = false;
                  }
                }

                return TweenAnimationBuilder(
                  duration: Duration(
                    milliseconds: 350 + (index * 80),
                  ),
                  tween: Tween<double>(
                    begin: 0,
                    end: 1,
                  ),
                  curve: Curves.easeOut,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          30 * (1 - value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (Global.storageServices
                              .get(PrefConst.userId)
                              .toString() !=
                          data?.userId.toString()) {

                        Get.toNamed(
                          Routes.chatScreen,
                          arguments: {
                            "userData": data,
                            "groupName": controller.arguments!['groupName'],
                            "isCreator": controller.arguments!['isCreator'],
                            "type": "",
                          },
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.h, vertical: 10.h),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 30.r,
                                    backgroundImage: NetworkImage(
                                      "${ConstRes.aImageBaseUrl}${data?.profileImage ?? ""}",
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  if (true)
                                    Positioned(
                                      // bottom: 0,
                                      right: 4.w,
                                      child: Container(
                                        height: 12.w,
                                        width: 12.w,
                                        decoration: BoxDecoration(
                                          color: isOnline
                                              ? Colors.green
                                              : Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white,
                                              width: 1.5.w),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          reausabletext(
                                            data?.name ?? AppText.unnamedMember,
                                            fontsize: 15,
                                            fontfamily:
                                                FontFamily.interSemiBold,
                                          ),
                                          SizedBox(height: 2.h),
                                          MobileNumberView(
                                            mobileNumber: data?.mobileNo ??
                                                AppText.noNumber,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        reausabletext(
                                          Utility.isNotNullEmptyOrFalse(
                                                  data?.lastSeen)
                                              ? formatTime(data!.lastSeen!)
                                              : "",
                                          fontsize: 10,
                                          fontfamily: FontFamily.interMedium,
                                          color: Colors.grey.shade500,
                                        ),
                                        SizedBox(height: 8.h),
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          onTap: () {
                                            Get.toNamed(
                                              Routes.LocationTracking,
                                              arguments: {
                                                "groupId": int.parse(controller
                                                    .arguments!['groupId']
                                                    .toString()),
                                                "groupName": controller
                                                    .arguments!['groupName'],
                                                "targetUserId":
                                                    data?.userId.toString(),
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: ToggleThemeData.darkPurple
                                                  .withValues(alpha: 0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.near_me,
                                              color: ToggleThemeData.darkPurple,
                                              size: 18.sp,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // WalkieController().startServices(
                                            //     callerName:
                                            //         data!.name.toString(),
                                            //     profileImage: data.profileImage,
                                            //     remoteUserId:
                                            //         data!.userId.toString());
                                          },
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.w),
                                            child: Image.asset(
                                              Assets.icons.walkieTalkie.path,
                                              color: Colors.grey,
                                              height: 28.h,
                                              width: 28.w,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != (groupData?.length ?? 10) - 1)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}
