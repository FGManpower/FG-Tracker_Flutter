import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/theme/AppText.dart';
import '../../../Core/values/Utils.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import '../../../routes/app_pages.dart';

class NewlyGroupUi extends StatelessWidget {
  NewlyGroupUi({
    super.key,
    this.groupData,
    this.isLoading = false,
    required this.groupController,
  });

  List<GroupsResData>? groupData;
  bool isLoading;
  GroupController groupController;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardGap = 12.w;
    final double horizontalPadding = 24.w;
    final double blockWidth = screenWidth - horizontalPadding;
    final double cardWidth = (blockWidth - cardGap) / 2;

    final items = groupData ?? List<GroupsResData?>.filled(8, null);

    final List<List<GroupsResData?>> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(items.sublist(i, (i + 2).clamp(0, items.length)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(row.length, (colIndex) {
              final data = row[colIndex];
              final bool isActive = data?.isActive ?? false;
              final bool isCreator = data?.isCreator ?? false;

              return Padding(
                padding: EdgeInsets.only(left: colIndex == 0 ? 0 : cardGap),
                child: Skeletonizer(
                  enabled: isLoading,
                  child: GestureDetector(
                    onTap: () {
                      if (data?.isActive == true) {
                        Get.toNamed(Routes.Memberscreen, arguments: {
                          "groupId": data!.id.toString(),
                          "groupName": data.groupName.toString(),
                          "groupCode": data.groupCode.toString(),
                          "isCreator": data.isCreator.toString(),
                          "isActive": data.isActive.toString(),
                        })?.then((value) {
                          if (value == true) {
                            groupController.getGroupData();
                          }
                        });
                      }
                    },
                    child: Opacity(
                      opacity: isActive ? 1 : 0.7,
                      child: Container(
                        width: cardWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xffF2F0FF),
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 49.h,
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
                                fontsize: 16,
                                fontfamily: FontFamily.interSemiBold,
                                color: ToggleThemeData.black,
                                maxline: 1,
                                textoverflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
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
                                        fontsize: 11,
                                        color: Colors.black54,
                                      ),
                                      isCreator
                                          ? Transform.scale(
                                              scale: 0.8,
                                              child: CupertinoSwitch(
                                                value: isActive,
                                                onChanged: (value) {
                                                  groupController.updateGroup(
                                                    groupController,
                                                    groupId:
                                                        data!.id.toString(),
                                                    groupStatus:
                                                        value.toString(),
                                                  );
                                                },
                                                activeColor:
                                                    const Color(0xff5045B9),
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
                                              size: 18.sp,
                                            ),
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: reausabletext(
                                          data?.groupCode ?? "",
                                          fontfamily: FontFamily.interSemiBold,
                                          fontsize: 11,
                                          color: const Color(0xff5045B9),
                                          maxline: 1,
                                          textoverflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      reausableIcon(
                                        icon: Icons.copy,
                                        size: 14,
                                        color: Colors.black45,
                                        ontap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: data?.groupCode ?? ""));
                                          Utils().fluttertoast(
                                              "Group code copied!");
                                        },
                                      ),
                                    ],
                                  ),
                                  if (isActive) ...[
                                    SizedBox(height: 5.h),
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(Routes.QrCodeScreen,
                                            arguments: {
                                              "groupCode": data?.groupCode
                                            });
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                width: 1.5.w,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(5.r),
                                              child: FaIcon(
                                                FontAwesomeIcons.qrcode,
                                                size: 16,
                                                color: const Color(0xff5045B9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (!isActive && !isCreator) ...[
                                    SizedBox(height: 6.h),
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
                                                if(success){
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
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            reausabletext(
                                              "Exit Group",
                                              fontfamily:
                                                  FontFamily.interSemiBold,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
