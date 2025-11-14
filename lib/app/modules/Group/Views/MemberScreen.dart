import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/LiquidPullToRefresh_Indicatore.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:fgtracker/app/modules/Track/Views/TrackLocationScreen.dart';
import 'package:fgtracker/app/widgets/MobileNumberView.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Messages/Views/Chat_Screen.dart';

class MemberscreenScreen extends StatefulWidget {
  final String groupId;
  final dynamic groupName;
  bool isCreator;
  bool isActive;

  MemberscreenScreen(
      {super.key,
      required this.groupId,
      required this.isCreator,
      required this.isActive,
      required this.groupName});

  @override
  State<MemberscreenScreen> createState() => _MemberscreenScreenState();
}

class _MemberscreenScreenState extends State<MemberscreenScreen> {
  final controller = Get.put(JoinGroupController());

  @override
  void initState() {
    super.initState();
    controller.getMembersData(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
          title: reausabletext(
            "Members",
            fontsize: 20,
            color: Colors.black,
            fontweight: FontWeight.bold,
          ),
          centerTitle: false,
          backgroundColor: ToggleThemeData.white,
          elevation: 4,
          actions: [
            reausableIcon(
                icon: Icons.search,
                size: 30,
                color: ToggleThemeData.darkPurple),
            SizedBox(
              width: 15.w,
            ),
          ],
        ),



        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.h,vertical: 10.h),
          child:  Row(
            children: [


              Expanded(child: reausablebutton(title: "Walkie-Talkie",icon:Icons.groups,fontSize: 12,borderradiues: 50,ontap: () {

              },height: 55)),
              SizedBox(width: 40.w),
              Expanded(child: reausablebutton(title: "Track",icon:Icons.track_changes,fontSize: 12,borderradiues: 50,ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationTrackingPage(
                      groupId: int.parse(widget.groupId.toString()),
                      groupName: widget.groupName,
                    ),
                    // builder: (_) => LocationTrackingPage(groupId: widget.groupId, userId: Global.storageServices.get(PrefConst.userId)!),
                  ),
                );
              },height: 55)),



            ],
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
                  reausabletext(widget.groupName ?? "",
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
                    controller.getMembersData(widget.groupId);
                  },
                  messgae: controller.responseError.value.toString(),
                );
              } else if (controller.memberDataLoading.value) {
                return Expanded(child: memberListUi(isLoading: true));
              } else if (controller.memberData.isEmpty) {
                return Center(child: reausabletext(AppText.noDataFound));
              } else {
                return Expanded(
                    child: memberListUi(groupData: controller.memberData));
              }
            }),
          ],
        ));
  }

  Widget memberListUi({
    List<MemberData>? groupData,
    bool isLoading = false,
    // int? _expandedIndex;
  }) {
    return MyCustomPullToRefresh(
      onTapCallback: () {
        controller.memberDataLoading.value = true;
      },
      onTap2Callback: () {
        controller.getMembersData(widget.groupId);
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

                return GestureDetector(
                  onTap: () {
                    if (Global.storageServices
                        .get(PrefConst.userId)
                        .toString() !=
                        data?.userId.toString()){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            userData: data!,
                            groupName:
                            widget.groupName,
                          ),
                        ),
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
                                        color: Colors.green,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              "12:08 PM",
                                              fontsize: 10,
                                              fontfamily: FontFamily.interMedium,
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
                                  Padding(
                                    padding: EdgeInsets.only(left: 50.w),
                                    child: Image.asset(
                                      Assets.icons.walkieTalkie.path,
                                      height: 28.h,
                                      width: 28.w,
                                    ),
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

  Widget _buildIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20.r,
            // backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: ToggleThemeData.darkPurple, size: 22.sp),
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp, fontFamily: FontFamily.interRegular)),
        ],
      ),
    );
  }
}
