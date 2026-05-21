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
  CreatedGroupUi({
    super.key,
    this.groupData,
    this.isLoading = false,
    required this.groupController,
  });

  List<GroupsResData>? groupData;
  bool isLoading;
  GroupController groupController;

  List<List<GroupsResData?>> _buildChunks() {
    final items = groupData ?? List<GroupsResData?>.filled(8, null);
    final List<List<GroupsResData?>> chunks = [];
    for (int i = 0; i < items.length; i += 4) {
      chunks.add(items.sublist(i, (i + 4).clamp(0, items.length)));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final double blockWidth = 1.sw - 24.w;
    final double cardGap = 10.w;
    final double cardWidth = (blockWidth - cardGap) / 2;
    final double rowGap = 8.h;
    final double blockHeight = 310.h;
    final double cardHeight = (blockHeight - rowGap) / 2;

    final chunks = _buildChunks();

    return SizedBox(
      height: blockHeight,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: chunks.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, chunkIndex) {
          final chunk = chunks[chunkIndex];
          final List<List<GroupsResData?>> rows = [
            chunk.sublist(0, chunk.length >= 2 ? 2 : chunk.length),
            chunk.length > 2
                ? chunk.sublist(2, chunk.length)
                : [],
          ];

          return SizedBox(
            width: blockWidth,
            child: Column(
              children: List.generate(rows.length, (rowIndex) {
                if (rows[rowIndex].isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(
                      top: rowIndex == 0 ? 0 : rowGap),
                  child: Row(
                    children: List.generate(rows[rowIndex].length, (colIndex) {
                      final data = rows[rowIndex][colIndex];
                      final bool isActive = data?.isActive ?? false;
                      final bool isCreator = data?.isCreator ?? false;

                      return Padding(
                        padding: EdgeInsets.only(
                            left: colIndex == 0 ? 0 : cardGap),
                        child: Skeletonizer(
                          enabled: isLoading,
                          child: GestureDetector(
                            onTap: () {
                              if (data?.isActive == true) {
                                Get.toNamed(
                                  Routes.Memberscreen,
                                  arguments: {
                                    "groupId": data!.id.toString(),
                                    "groupName": data.groupName.toString(),
                                    "isCreator": data.isCreator.toString(),
                                    "isActive": data.isActive.toString(),
                                  },
                                )?.then((value) {
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
                                height: cardHeight,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        Assets.images.groupBg.path),
                                    fit: BoxFit.cover,
                                    opacity: 0.15,
                                  ),
                                  color: const Color(0xffF2F0FF),
                                  borderRadius:
                                  BorderRadius.circular(15.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Flexible(
                                            child: reausabletext(
                                              data?.groupName ??
                                                  AppText.unnamedTrip,
                                              fontsize: 12,
                                              fontfamily: FontFamily
                                                  .interSemiBold,
                                              color:
                                              ToggleThemeData.black,
                                              maxline: 2,
                                              textoverflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                          isCreator
                                              ? Transform.scale(
                                            scale: 0.7,
                                            child: CupertinoSwitch(
                                              value: isActive,
                                              onChanged: (value) {
                                                groupController
                                                    .updateGroup(
                                                  groupController,
                                                  groupId: data!.id
                                                      .toString(),
                                                  groupStatus: value
                                                      .toString(),
                                                );
                                              },
                                              activeColor:
                                              const Color(
                                                  0xff5045B9),
                                              trackColor:
                                              Colors.black26,
                                            ),
                                          )
                                              : Icon(
                                            isActive
                                                ? Icons
                                                .check_circle_outline
                                                : Icons.cancel_sharp,
                                            color: isActive
                                                ? Colors.green
                                                : Colors.redAccent,
                                            size: 16.sp,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          miniLabel("Code",
                                              data?.groupCode ?? "-"),
                                          SizedBox(height: 3.h),
                                          miniLabel(
                                              "By",
                                              data?.isCreator == true
                                                  ? "You"
                                                  : "Other"),
                                          SizedBox(height: 3.h),
                                          miniLabel("Members",
                                              "${data?.memberCount ?? 0}"),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (isActive) {
                                            Get.toNamed(
                                              Routes.QrCodeScreen,
                                              arguments: {
                                                "groupCode":
                                                data?.groupCode
                                              },
                                            );
                                          } else {
                                            Utils().fluttertoast(
                                                "Activate the group to view QR");
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            reausabletext(
                                              "Show QR",
                                              fontfamily:
                                              FontFamily.interMedium,
                                              fontsize: 11,
                                              color: ToggleThemeData
                                                  .darkPurple,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                      0xff5045B9),
                                                  width: 1.5.w,
                                                ),
                                              ),
                                              padding:
                                              EdgeInsets.all(5.r),
                                              child: reausableIcon(
                                                icon: FontAwesomeIcons
                                                    .qrcode,
                                                size: 14,
                                                color: const Color(
                                                    0xff5045B9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget miniLabel(String title, String value) {
    return Row(
      children: [
        reausabletext(
          "$title: ",
          fontsize: 10,
          fontfamily: FontFamily.interMedium,
          color: Colors.grey[600],
        ),
        Flexible(
          child: reausabletext(
            value,
            fontsize: 10,
            fontfamily: FontFamily.interSemiBold,
            color: ToggleThemeData.black,
            maxline: 1,
            textoverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}