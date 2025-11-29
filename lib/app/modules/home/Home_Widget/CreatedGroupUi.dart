import 'package:fgtracker/app/Model/GroupRes.dart';
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
import '../../../Core/values/Utils.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';

import 'Home_widget.dart';

class CreatedGroupUi extends StatelessWidget {
  CreatedGroupUi(
      {super.key,
      this.groupData,
      this.isLoading = false,
      required this.groupController});
  List<GroupsResData>? groupData;
  bool isLoading = false;
  GroupController groupController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 175.h,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: groupData?.length ?? 8,
          // padding: EdgeInsets.only(bottom: 110.h),
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final data = groupData?[index];
            final bool isActive = data?.isActive ?? false;
            final bool isCreator = data?.isCreator ?? false;

            return Skeletonizer(
              enabled: isLoading,
              child: GestureDetector(
                onTap: () {
                  if (data?.isActive == true) {
                    Get.toNamed(Routes.Memberscreen, arguments: {
                      "groupId": data!.id.toString(),
                      "groupName": data!.groupName.toString(),
                      "isCreator": data.isCreator.toString(),
                      "isActive": data!.isActive.toString(),
                    })?.then(
                      (value) {
                        if (value == true) {
                          groupController.getGroupData();
                        }
                      },
                    );
                  }
                },
                child: Opacity(
                  opacity: isActive ? 1 : 0.7,
                  child: Container(
                      width: 240.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Assets.images.groupBg.path),
                          fit: BoxFit.cover,
                          opacity: 0.15,
                        ),
                        color: const Color(0xffF2F0FF),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 15.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: reausabletext(
                                    data?.groupName ?? AppText.unnamedTrip,
                                    fontsize: 14,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: ToggleThemeData.black,
                                    maxline: 2,
                                    textoverflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                isCreator
                                    ? Padding(
                                        padding: EdgeInsets.only(left: 7.w),
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: isActive,
                                            onChanged: (value) {
                                              groupController.updateGroup(
                                                groupController,
                                                groupId: data!.id.toString(),
                                                groupStatus: value.toString(),
                                              );
                                            },
                                            activeColor:
                                                const Color(0xff5045B9),
                                            trackColor: Colors.black26,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(left: 7.w),
                                        child: Icon(
                                          isActive
                                              ? Icons.check_circle_outline
                                              : Icons.cancel_sharp,
                                          color: isActive
                                              ? Colors.green
                                              : Colors.redAccent,
                                          size: 20.sp,
                                        ),
                                      )
                              ],
                            ),
                            SizedBox(
                              height: 13.h,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GroupRow(
                                  title: "Team Code",
                                  value: data?.groupCode ?? "",
                                ),
                                GroupRow(
                                  title: "Created By",
                                  value: data?.isCreator.toString() ?? "0",
                                ),
                                GroupRow(
                                  title: "No. Of Member",
                                  value: "${data?.memberCount}" ?? "0",
                                  showDivider: false,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (isActive) {
                                  Get.toNamed(Routes.QrCodeScreen, arguments: {
                                    "groupCode": data?.groupCode
                                  });
                                } else {
                                  Utils().fluttertoast(
                                      "Activate the group to view QR");
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  reausabletext("Show QR Code",
                                      fontfamily: FontFamily.interMedium,
                                      fontsize: 12,
                                      color: ToggleThemeData.darkPurple),
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
                                        icon: FontAwesomeIcons.qrcode,
                                        size: 18,
                                        color: const Color(0xff5045B9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ),
            );
          },
        ));
  }
}
