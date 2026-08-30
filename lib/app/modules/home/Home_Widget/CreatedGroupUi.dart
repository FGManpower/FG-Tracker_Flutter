import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/modules/Group/Views/QrScreen.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/theme/AppText.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';

class CreatedGroupUi extends StatelessWidget {
  const CreatedGroupUi({
    super.key,
    this.groupData,
    this.isLoading = false,
    required this.groupController,
  });

  final List<GroupsResData>? groupData;
  final bool isLoading;
  final GroupController groupController;

  @override
  Widget build(BuildContext context) {
    final List<GroupsResData> safeGroupData = groupData ?? [];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 150.h,
      ),
      itemCount: isLoading ? 6 : safeGroupData.length,
      itemBuilder: (context, index) {
        final GroupsResData? data = isLoading ? null : safeGroupData[index];

        final bool isActive = data?.isActive ?? false;
        final bool isCreator = data?.isCreator ?? false;

        return Skeletonizer(
          enabled: isLoading,
          child: GestureDetector(
            onTap: () {
              if (data == null) return;

              if (isActive) {
                Get.toNamed(
                  Routes.Memberscreen,
                  arguments: {
                    "groupId": data.id?.toString() ?? "",
                    "groupName": data.groupName ?? "",
                    "groupCode": data.groupCode ?? "",
                    "isCreator": data.isCreator?.toString() ?? "false",
                    "isActive": data.isActive?.toString() ?? "false",
                  },
                )?.then((value) {
                  if (value == true) {
                    groupController.getGroupData();
                  }
                });
              }
            },
            child: Opacity(
              opacity: isActive ? 1 : 0.75,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      Assets.images.groupBg.path,
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  ),
                  color: const Color(0xffF2F0FF),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10.w,
                    right: 5.w,
                    top: 12.h,
                    bottom: 3.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: reausabletext(
                              data?.groupName ?? AppText.unnamedTrip,
                              fontsize: 13,
                              fontfamily: FontFamily.interSemiBold,
                              color: ToggleThemeData.black,
                              maxline: 2,
                              textoverflow: TextOverflow.ellipsis,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          isCreator
                              ? Transform.translate(
                            offset: Offset(8.w, 0),
                            child: Transform.scale(
                              scale: 0.50,
                              child: CupertinoSwitch(
                                value: isActive,
                                onChanged: (value) {
                                  if (data == null) return;

                                  groupController.updateGroup(
                                    groupController,
                                    groupId: data.id?.toString() ?? "",
                                    groupStatus: value.toString(),
                                  );
                                },
                                activeColor: const Color(0xff5045B9),
                                trackColor: Colors.black26,
                              ),
                            ),
                          )
                              :  SizedBox(
                            width: 40.w,
                            height: 38.h,
                            child: Center(
                              child: Icon(
                                isActive
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_sharp,
                                color: isActive
                                    ? Colors.green
                                    : Colors.redAccent,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                reausabletext(
                                  "Team Code",
                                  fontsize: 8,
                                  fontfamily: FontFamily.interMedium,
                                  color: Colors.black54,
                                ),
                                SizedBox(height: 4.h),
                                reausabletext(
                                  data?.groupCode ?? "--",
                                  fontsize: 10,
                                  fontfamily: FontFamily.interSemiBold,
                                  color: ToggleThemeData.darkPurple,
                                  maxline: 1,
                                  textoverflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Container(
                              height: 30.h,
                              width: 1.2.w,
                              color: const Color(0xff5045B9),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                reausabletext(
                                  "Created",
                                  fontsize: 8,
                                  fontfamily: FontFamily.interMedium,
                                  color: Colors.black54,
                                ),
                                SizedBox(height: 4.h),
                                reausabletext(
                                  isCreator ? "You" : "Other",
                                  fontsize: 10,
                                  fontfamily: FontFamily.interSemiBold,
                                  color: ToggleThemeData.darkPurple,
                                  maxline: 1,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Container(
                              height: 30.h,
                              width: 1.2.w,
                              color: const Color(0xff5045B9),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                reausabletext(
                                  "Members",
                                  fontsize: 8,
                                  fontfamily: FontFamily.interMedium,
                                  color: Colors.black54,
                                  maxline: 1,
                                ),
                                SizedBox(height: 4.h),
                                reausabletext(
                                  data?.memberCount?.toString() ?? "0",
                                  fontsize: 10,
                                  fontfamily: FontFamily.interSemiBold,
                                  color: ToggleThemeData.darkPurple,
                                  maxline: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (isActive)
                        GestureDetector(
                          onTap: () {
                            if (data == null) return;
                            QrCodeBottomSheet.show(
                              context,
                              groupName: data.groupName ?? "Group",
                              groupCode: data.groupCode ?? "",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              reausabletext(
                                "Show QR Code",
                                fontfamily: FontFamily.interMedium,
                                fontsize: 11,
                                color: ToggleThemeData.darkPurple,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xff5045B9),
                                    width: 1.4.w,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6.r),
                                  child: FaIcon(
                                    FontAwesomeIcons.qrcode,
                                    size: 15,
                                    color: const Color(0xff5045B9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!isCreator)
                        GestureDetector(
                          onTap: () {
                            if (data == null) return;
                            CommonDialog.ConfirmationDialog(
                              title: AppText.areYouSure,
                              content: AppText.doYouWantToExitGroup,
                              onConfirm: () {
                                Get.back();
                                MemberController().exitGroup(
                                  context,
                                  groupId: data.id.toString(),
                                  userId: Global.storageServices
                                      .get(PrefConst.userId)
                                      .toString(),
                                  onSuccess: (success) {
                                    if (success) {
                                      groupController.getGroupData();
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffB3261E),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                reausabletext(
                                  "Exit Group",
                                  fontfamily: FontFamily.interSemiBold,
                                  fontsize: 11,
                                  color: Colors.white,
                                ),
                                Icon(
                                  Icons.exit_to_app_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}