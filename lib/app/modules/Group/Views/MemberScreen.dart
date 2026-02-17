import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/LiquidPullToRefresh_Indicatore.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/Controller/MemberController.dart';
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
import '../../Walkie-talkie/Controller/walkieController.dart';

class MemberscreenScreen extends GetView<MemberController> {
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
              if (!controller.isSearching.value &&
                  bool.parse(controller.arguments?['isCreator']))
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
                            controller.deleteGroup(context,
                                groupId: controller.arguments!['groupId']
                                    .toString());
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
                    child:reausablebutton(
                        title: "Track",
                        icon: Icons.track_changes,
                        fontSize: 12,
                        borderradiues: 50,
                        ontap: () {
                          Get.toNamed(Routes.LocationTracking,
                              arguments: {
                                "groupId": int.parse(controller
                                    .arguments!['groupId']
                                    .toString()),
                                "groupName":
                                controller.arguments!['groupName'],
                              });
                        },
                        height: 55)
                    // Row(
                    //   children: [
                    //     // Expanded(
                    //     //     child: reausablebutton(
                    //     //         title: "Walkie-Talkie",
                    //     //         icon: Icons.groups,
                    //     //         fontSize: 12,
                    //     //         borderradiues: 50,
                    //     //         ontap: () {},
                    //     //         height: 55)),
                    //     // SizedBox(width: 40.w),
                    //     Expanded(
                    //         child: reausablebutton(
                    //             title: "Track",
                    //             icon: Icons.track_changes,
                    //             fontSize: 12,
                    //             borderradiues: 50,
                    //             ontap: () {
                    //               Get.toNamed(Routes.LocationTracking,
                    //                   arguments: {
                    //                     "groupId": int.parse(controller
                    //                         .arguments!['groupId']
                    //                         .toString()),
                    //                     "groupName":
                    //                         controller.arguments!['groupName'],
                    //                   });
                    //             },
                    //             height: 55)),
                    //   ],
                    // ),
                  ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 15.w,
                  top: 20.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(controller.arguments!['groupName'] ?? "",
                        fontsize: 21,
                        fontfamily: FontFamily.interBold,
                        color: ToggleThemeData.darkPurple),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        reausabletext("Feel Free to start a conversation ",
                            fontsize: 12,
                            fontfamily: FontFamily.interRegular,
                            color: Colors.black45),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.r)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Obx(() {
                if (controller.responseError.value.isNotEmpty) {
                  return LostinternetConnection(
                    retry: () {
                      controller
                          .getMembersData(controller.arguments!['groupId']);
                    },
                    messgae: controller.responseError.value.toString(),
                  );
                } else if (controller.memberDataLoading.value) {
                  return Expanded(child: memberListUi(isLoading: true));
                } else if (controller.filteredMembers.isEmpty) {
                  return Expanded(
                      child: DataEmpty(
                    imgname: Assets.images.notFount.path,
                    type: "png",
                  ));
                } else {
                  return Expanded(
                      child:
                          memberListUi(groupData: controller.filteredMembers));
                }
              }),
            ],
          )),
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
                bool isOnline = (data?.isOnline == true) ||
                    (data?.lastSeen != null &&
                        Tracking()
                                .getTimeAgo(DateTime.parse(data!.lastSeen!))
                                .toLowerCase() ==
                            "just now");

                return GestureDetector(
                  onTap: () {
                    if (Global.storageServices
                            .get(PrefConst.userId)
                            .toString() !=
                        data?.userId.toString()) {
                      Get.toNamed(Routes.chatScreen, arguments: {
                        "userData": data,
                        "groupName": controller.arguments!['groupName'],
                        "type": "",
                      });
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
                                            color: Colors.white, width: 1.5.w),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: reausabletext(
                                                data?.name ??
                                                    AppText.unnamedMember,
                                                fontsize: 15,
                                                fontfamily:
                                                    FontFamily.interSemiBold,
                                              ),
                                            ),
                                            reausabletext(
                                              Utility.isNotNullEmptyOrFalse(
                                                      data?.lastSeen)
                                                  ? formatTime(data!.lastSeen!)
                                                  : "",
                                              fontsize: 10,
                                              fontfamily:
                                                  FontFamily.interMedium,
                                              color: Colors.grey.shade500,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        MobileNumberView(
                                          mobileNumber: data?.mobileNo ??
                                              AppText.noNumber,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // InkWell(
                                  //   onTap: () {
                                  //     WalkieController().startServices(
                                  //         callerName: data!.name.toString(),
                                  //         profileImage: data.profileImage,
                                  //         remoteUserId:
                                  //             data!.userId.toString());
                                  //   },
                                  //   child: Padding(
                                  //     padding: EdgeInsets.only(left: 50.w),
                                  //     child: Image.asset(
                                  //       Assets.icons.walkieTalkie.path,
                                  //       height: 28.h,
                                  //       width: 28.w,
                                  //     ),
                                  //   ),
                                  // )
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
                          color: Colors.grey.withOpacity(0.2),
                        ),
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }
}
