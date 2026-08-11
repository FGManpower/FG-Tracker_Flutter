import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Model/MemberDataRes.dart';
import '../../../modules/Group/controller/Group_Controller.dart';
import '../../../routes/app_pages.dart';
import '../../constant/pref_res.dart';
import '../Dialog/Common_dialog.dart';
import '../global.dart';

class BottomSheetUi {
  void showMemberBottomSheet(
    BuildContext context,
    List<LocationData> members, {
    bool isGroupChat = false,
    bool isDeleteMode = false,
    int? groupId,
    String? groupName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 12.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 5.h,
            ),
            child: Column(
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                reausabletext(
                  "Group Members",
                  fontsize: 18,
                  fontweight: FontWeight.w600,
                  align: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (_, index) {
                      final member = members[index];
                      final currentUserId = Global.storageServices
                          .get(PrefConst.userId)
                          .toString();

                      final isMe = member.userId.toString() == currentUserId;
                      bool isOnline = false;
                      final isGhostMode = member.locationSharing == false;
                      if (member.lastSeen != null &&
                          member.lastSeen!.isNotEmpty) {
                        try {
                          isOnline = Tracking()
                                  .getTimeAgo(DateTime.parse(member.lastSeen!))
                                  .toLowerCase() ==
                              "just now";
                        } catch (_) {
                          isOnline = false;
                        }
                      }

                      final profileUrl = (member.profileImage?.isNotEmpty ??
                              false)
                          ? "${ConstRes.aImageBaseUrl}${member.profileImage}"
                          : null;
                      return GestureDetector(
                              onTap: () {
                                if (!isDeleteMode) return;

                                if (isMe) {
                                  CommonDialog.errorMessage(
                                    "You can't remove yourself from the group.",
                                  );
                                  return;
                                }

                                Navigator.pop(context);

                                CommonDialog.ConfirmationDialog(
                                  title: "Remove Member",
                                  content:
                                      "Are you sure you want to remove ${member.name} from the group?",
                                  confirm: "Remove",
                                  onConfirm: () {
                                    Get.find<GroupController>()
                                        .deleteGroupMember(
                                      context,
                                      groupId: groupId.toString(),
                                      groupMemberId: member.userId.toString(),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8.h),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: isGhostMode
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade50,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24.r,
                                      backgroundImage: profileUrl != null
                                          ? NetworkImage(profileUrl)
                                          : const AssetImage(
                                                  'assets/default_avatar.png')
                                              as ImageProvider,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            member.name ??
                                                                'Unknown',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isMe)
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 2.h,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: ToggleThemeData
                                                                      .Appcolor
                                                                  .withOpacity(
                                                                      .1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.r),
                                                            ),
                                                            child: Text(
                                                              "You",
                                                              style: TextStyle(
                                                                color:
                                                                    ToggleThemeData
                                                                        .Appcolor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 11.sp,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.circle,
                                                          size: 10.r,
                                                          color: isOnline
                                                              ? Colors.green
                                                              : Colors.grey,
                                                        ),
                                                        SizedBox(width: 6.w),
                                                        Expanded(
                                                          child: reausabletext(
                                                            isGhostMode
                                                                ? "Ghost Mode Enabled"
                                                                : isOnline
                                                                ? "Online"
                                                                : "Last seen: ${Tracking().getTimeAgo(DateTime.parse(member.lastSeen ?? DateTime.now().toString()))}",
                                                            fontsize: 13,
                                                            color: isGhostMode
                                                                ? const Color(0xFF7E57C2)
                                                                : (isOnline ? Colors.green : Colors.grey[600]),
                                                            fontweight: isGhostMode ? FontWeight.w600 : FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!isMe) ...[
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);

                                                    final MemberData
                                                        memberData = MemberData(
                                                      id: member.id,
                                                      userId: member.userId,
                                                      groupId:
                                                          member.groupId ?? 0,
                                                      name: member.name,
                                                      profileImage:
                                                          member.profileImage,
                                                      lastSeen: member.lastSeen,
                                                      isOnline: member.isOnline,
                                                    );

                                                    Get.toNamed(
                                                      Routes.chatScreen,
                                                      arguments: {
                                                        "userData": memberData,
                                                        "groupName":
                                                            "Members Chat",
                                                        "isCreator": false,
                                                        "type": "",
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(9.w),
                                                    decoration: BoxDecoration(
                                                      color: ToggleThemeData
                                                              .Appcolor
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.chat_bubble_outline,
                                                      color: ToggleThemeData
                                                          .Appcolor,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);

                                                    Get.toNamed(
                                                      Routes.callScreen,
                                                      arguments: {
                                                        "callerId": Global
                                                            .storageServices
                                                            .get(PrefConst
                                                                .userId)
                                                            .toString(),
                                                        "remoteUserId": member
                                                            .userId
                                                            .toString(),
                                                        "callerName":
                                                            member.name ?? "",
                                                        "offer": null,
                                                        "is_video": false,
                                                        "callType": "outGoing",
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(9.w),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.call,
                                                      color: Colors.green,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);

                                                    Get.toNamed(
                                                      Routes.callScreen,
                                                      arguments: {
                                                        "callerId": Global
                                                            .storageServices
                                                            .get(PrefConst
                                                                .userId)
                                                            .toString(),
                                                        "remoteUserId": member
                                                            .userId
                                                            .toString(),
                                                        "callerName":
                                                            member.name ?? "",
                                                        "offer": null,
                                                        "is_video": true,
                                                        "callType": "outGoing",
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(9.w),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.videocam,
                                                      color: Colors.red,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (!isMe && !isGhostMode) ...[
                                            SizedBox(height: 10.h),
                                            member.locationSharing == false
                                                ? SizedBox()
                                                : Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        Navigator.pop(context);

                                                        if (isGroupChat) {
                                                          Get.toNamed(
                                                            Routes
                                                                .LocationTracking,
                                                            arguments: {
                                                              "groupId":
                                                                  groupId,
                                                              "groupName":
                                                                  groupName,
                                                              "targetUserId":
                                                                  member.userId
                                                                      .toString(),
                                                            },
                                                          );
                                                        } else {
                                                          final Uri mapsUri =
                                                              Uri.parse(
                                                            "https://www.google.com/maps/dir/?api=1&destination=${member.latitude},${member.longitude}&travelmode=walking",
                                                          );

                                                          launchUrl(mapsUri);
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.navigation),
                                                      label: Text(
                                                        isGroupChat
                                                            ? "Track"
                                                            : "Navigate",
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            ToggleThemeData
                                                                .Appcolor,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.r),
                                                        ),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 8.h,
                                                        ),
                                                        textStyle: TextStyle(
                                                            fontSize: 13.sp),
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
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
