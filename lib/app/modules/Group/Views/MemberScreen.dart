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
      required this.isActive,required this.groupName});

  @override
  State<MemberscreenScreen> createState() => _MemberscreenScreenState();
}

class _MemberscreenScreenState extends State<MemberscreenScreen> {
  final controller = Get.put(JoinGroupController());
  int? _expandedIndex;
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
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: reausableIcon(
                icon: Icons.arrow_back_outlined, color: Colors.white)),
        title: reausabletext(
         widget.groupName,
          fontsize: 20,
          color: Colors.white,
          fontweight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: ToggleThemeData.Appcolor,
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                CommonDialog.ConfirmationDialog(
                  title: AppText.areYouSure,
                  content: AppText.doYouWantToDeleteGroup,
                  onConfirm: () {
                    controller.deleteGroup(context,
                        groupId: widget.groupId.toString());
                  },
                );
              } else if (value == 'exit') {
                CommonDialog.ConfirmationDialog(
                  title: AppText.areYouSure,
                  content: AppText.doYouWantToExitGroup,
                  onConfirm: () {
                    controller.exitGroup(context, groupId: widget.groupId);
                  },
                );
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 25,
            ),
            offset: Offset(0, 40), // Move popup slightly downward
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white, // Light background for contrast
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                height: 20.h, // Reduce height
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                value: widget.isCreator ? 'delete' : 'exit',
                child: Row(
                  children: [
                    Icon(
                      widget.isCreator ? Icons.delete_outline : Icons.logout,
                      size: 18,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 8),
                    reausabletext(
                        widget.isCreator ? 'Delete Group' : 'Exit Group',
                        fontsize: 14.sp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.isActive == true
          ? FloatingActionButton.extended(
              backgroundColor: ToggleThemeData.Appcolor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationTrackingPage(groupId: int.parse(widget.groupId.toString()),groupName: widget.groupName,),
                    // builder: (_) => LocationTrackingPage(groupId: widget.groupId, userId: Global.storageServices.get(PrefConst.userId)!),
                  ),
                );
              },
              icon: reausableIcon(
                  icon: Icons.track_changes,
                  color: ToggleThemeData.white,
                  size: 17),
              label: reausabletext(AppText.track,
                  color: ToggleThemeData.white, fontsize: 17),
            )
          : SizedBox(),
      body: SafeArea(
        child: Obx(() {
          if (controller.responseError.value.isNotEmpty) {
            return LostinternetConnection(
              retry: () {
                controller.getMembersData(widget.groupId);
              },
              messgae: controller.responseError.value.toString(),
            );
          } else if (controller.memberDataLoading.value) {
            return memberListUi(isLoading: true);
          } else if (controller.memberData.isEmpty) {
            return Center(child: reausabletext(AppText.noDataFound));
          } else {
            return memberListUi(groupData: controller.memberData);
          }
        }),
      ),
    );
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
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: groupData?.length ?? 10,
            itemBuilder: (context, index) {
              final data = groupData?[index];
                    return Card(
                      elevation: 10,
                      shadowColor: Colors.white,
                      color: Colors.grey.shade50,
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [

                            Row(
                              children: [

                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 28.r,
                                    backgroundImage: NetworkImage(
                                      "${ConstRes.aImageBaseUrl}${data?.profileImage ?? ""}",
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                                SizedBox(width: 16.w),

                                /// Info Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: reausabletext(
                                              data?.name ?? AppText.unnamedMember,
                                              fontsize: 16,
                                              fontweight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          MobileNumberView(
                                            mobileNumber:
                                                data?.mobileNo ?? AppText.noNumber,
                                          ),
                                          Global.storageServices.get(PrefConst.userId).toString()!=data?.userId.toString()? Padding(
                                            padding: EdgeInsets.only(left:50.w),
                                            child: _buildIcon(
                                              Icons.chat,
                                              "",
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ChatPage(userData: data!, groupName: widget.groupName,),
                                                  ),
                                                );
                                              },
                                            ),
                                          ):SizedBox(),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),

                                if (data?.isCreator == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 6.h),
                                    child: Row(
                                      children: [
                                        Container(

                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.cyanAccent,
                                                Colors.blue,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.r),
                                          ),

                                          child: reausabletext(
                                            AppText.creator,
                                            fontsize: 11,
                                            fontweight: FontWeight.w600,
                                            color: Colors.white,
                                          ),

                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),


                          ],
                        ),
                      ),
                    );
                  }

          ),
        ),
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
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue, size: 20.sp),
          ),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 10.sp)),
        ],
      ),
    );
  }
}
