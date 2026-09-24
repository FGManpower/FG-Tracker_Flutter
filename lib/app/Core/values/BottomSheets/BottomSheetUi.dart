import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetUi {
  void showMemberBottomSheet(
    BuildContext context,
    List<LocationData> members, {
    bool isGroupChat = false,
    bool isDeleteMode = false,
    int? groupId,
    String? groupName,
  }) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    final dynamic rawArgs = Get.arguments;
    final Map? argsMap = rawArgs is Map ? rawArgs : null;

    final int? effectiveGroupId = groupId ??
        int.tryParse(argsMap?['groupId']?.toString() ?? '') ??
        (Get.isRegistered<GroupMessageController>()
            ? Get.find<GroupMessageController>().groupId
            : null);

    final String effectiveGroupName = groupName ??
        argsMap?['groupName']?.toString() ??
        (Get.isRegistered<GroupMessageController>()
            ? Get.find<GroupMessageController>().groupName
            : 'Group');

    List<LocationData> initialMembers = List<LocationData>.from(members);
    if (initialMembers.isEmpty && Get.isRegistered<GroupMessageController>()) {
      final ctrlMembers = Get.find<GroupMessageController>().groupMembers;
      if (ctrlMembers.isNotEmpty) {
        initialMembers = List<LocationData>.from(ctrlMembers);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        List<LocationData> activeMembers =
            List<LocationData>.from(initialMembers);
        bool isLoading = activeMembers.isEmpty && effectiveGroupId != null;
        bool hasFetched = false;

        void sortMembers(List<LocationData> list) {
          list.sort((a, b) {
            final aId = (a.userId ?? a.id ?? '').toString();
            final bId = (b.userId ?? b.id ?? '').toString();
            final aMe = aId == currentUserId ? 0 : 1;
            final bMe = bId == currentUserId ? 0 : 1;
            if (aMe != bMe) return aMe.compareTo(bMe);

            final aAdmin =
                (a.isCreator == true || a.isCreator == 1 || a.isCreator == '1')
                    ? 0
                    : 1;
            final bAdmin =
                (b.isCreator == true || b.isCreator == 1 || b.isCreator == '1')
                    ? 0
                    : 1;
            if (aAdmin != bAdmin) return aAdmin.compareTo(bAdmin);

            final aGhost = (a.locationSharing == false ||
                    a.locationSharing == 0 ||
                    a.locationSharing == '0')
                ? 1
                : 0;
            final bGhost = (b.locationSharing == false ||
                    b.locationSharing == 0 ||
                    b.locationSharing == '0')
                ? 1
                : 0;
            return aGhost.compareTo(bGhost);
          });
        }

        sortMembers(activeMembers);

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> fetchFreshMembers() async {
              if (effectiveGroupId == null) {
                if (bottomSheetContext.mounted) {
                  setModalState(() {
                    isLoading = false;
                  });
                }
                return;
              }

              debugPrint(
                  "🔍 [BottomSheetUi] Fetching members for groupId: $effectiveGroupId");

              try {
                final res = await MessageRepo.getGroupMembers(
                    groupId: effectiveGroupId);
                if (res.locations != null && res.locations!.isNotEmpty) {
                  debugPrint(
                      "✅ [BottomSheetUi] MessageRepo returned ${res.locations!.length} members");
                  if (bottomSheetContext.mounted) {
                    setModalState(() {
                      activeMembers = List<LocationData>.from(res.locations!);
                      sortMembers(activeMembers);
                      isLoading = false;
                    });
                  }
                  return;
                }
              } catch (e) {
                debugPrint(
                    "❌ [BottomSheetUi] Error fetching via MessageRepo: $e");
              }

              try {
                final fallbackRes =
                    await GroupRepo.getMemberData(effectiveGroupId.toString());
                if (fallbackRes.memberData != null &&
                    fallbackRes.memberData!.isNotEmpty) {
                  debugPrint(
                      "✅ [BottomSheetUi] GroupRepo returned ${fallbackRes.memberData!.length} members");
                  final mapped = fallbackRes.memberData!.map((m) {
                    return LocationData(
                      id: m.id,
                      userId: m.userId,
                      groupId: m.groupId ?? effectiveGroupId,
                      name: m.name,
                      profileImage: m.profileImage,
                      isCreator: m.isCreator,
                      isOnline: m.isOnline,
                      lastSeen: m.lastSeen,
                      locationSharing: m.locationSharing ?? true,
                      mobileNo: m.mobileNo,
                      latitude: 0.0,
                      longitude: 0.0,
                    );
                  }).toList();

                  if (bottomSheetContext.mounted) {
                    setModalState(() {
                      activeMembers = mapped;
                      sortMembers(activeMembers);
                      isLoading = false;
                    });
                  }
                  return;
                }
              } catch (e) {
                debugPrint("❌ [BottomSheetUi] Fallback fetch error: $e");
              }

              try {
                final raw = await HttpUtil()
                    .get("/getMembers?groupId=$effectiveGroupId");
                debugPrint("🔍 [BottomSheetUi] Raw response: $raw");
                final parsed = LocationDataRes.fromJson(raw);
                if (parsed.locations != null && parsed.locations!.isNotEmpty) {
                  if (bottomSheetContext.mounted) {
                    setModalState(() {
                      activeMembers =
                          List<LocationData>.from(parsed.locations!);
                      sortMembers(activeMembers);
                      isLoading = false;
                    });
                  }
                  return;
                }
              } catch (e) {
                debugPrint("❌ [BottomSheetUi] Direct raw fetch error: $e");
              }

              if (bottomSheetContext.mounted) {
                setModalState(() {
                  isLoading = false;
                });
              }
            }

            if (!hasFetched && effectiveGroupId != null) {
              hasFetched = true;
              Future.microtask(() => fetchFreshMembers());
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 12.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 45.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reausabletext(
                          "Group Members",
                          fontsize: 18,
                          fontweight: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                        if (activeMembers.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: ToggleThemeData.Appcolor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              "${activeMembers.length}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: ToggleThemeData.Appcolor,
                              ),
                            ),
                          ),
                        ],
                        if (isLoading) ...[
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Expanded(
                      child: isLoading && activeMembers.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : activeMembers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: 48.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 8.h),
                                      reausabletext(
                                        "No members found",
                                        fontsize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      if (effectiveGroupId != null) ...[
                                        SizedBox(height: 10.h),
                                        TextButton.icon(
                                          onPressed: () {
                                            setModalState(() {
                                              isLoading = true;
                                            });
                                            fetchFreshMembers();
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: const Text("Retry"),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  color: ToggleThemeData.Appcolor,
                                  onRefresh: () async {
                                    await fetchFreshMembers();
                                  },
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    itemCount: activeMembers.length,
                                    itemBuilder: (_, index) {
                                      final member = activeMembers[index];

                                      final memberUserId =
                                          (member.userId ?? member.id ?? '')
                                              .toString();
                                      final bool isMe =
                                          memberUserId.isNotEmpty &&
                                              memberUserId == currentUserId;

                                      final bool isAdmin =
                                          member.isCreator == true ||
                                              member.isCreator == 1 ||
                                              member.isCreator == '1' ||
                                              member.role
                                                      ?.toString()
                                                      .toLowerCase() ==
                                                  'admin';

                                      final bool isGhostMode =
                                          member.locationSharing == false ||
                                              member.locationSharing == 0 ||
                                              member.locationSharing == '0';

                                      final bool isOnline = !isGhostMode &&
                                          Tracking().isOnline(
                                            rawIsOnline: member.isOnline,
                                            lastSeen: member.lastSeen,
                                            thresholdMinutes: 5,
                                          );

                                      final String name =
                                          (member.name != null &&
                                                  member.name
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty &&
                                                  member.name
                                                          .toString()
                                                          .toLowerCase() !=
                                                      'null')
                                              ? member.name.toString().trim()
                                              : 'Member';

                                      final String? rawImg =
                                          member.profileImage?.toString();
                                      final String? profileUrl = (rawImg !=
                                                  null &&
                                              rawImg.trim().isNotEmpty &&
                                              rawImg.toLowerCase() != 'null')
                                          ? (rawImg.startsWith('http://') ||
                                                  rawImg.startsWith('https://')
                                              ? rawImg
                                              : "${ConstRes.aImageBaseUrl}$rawImg")
                                          : null;

                                      String getLastSeenText() {
                                        if (isGhostMode) {
                                          return "Ghost Mode Enabled";
                                        }
                                        if (isOnline) return "Online";
                                        if (member.lastSeen == null ||
                                            member.lastSeen
                                                .toString()
                                                .trim()
                                                .isEmpty ||
                                            member.lastSeen
                                                    .toString()
                                                    .toLowerCase() ==
                                                'null') {
                                          return "Offline";
                                        }

                                        final parsedDate =
                                            Tracking.parseDateTime(
                                                member.lastSeen);
                                        if (parsedDate == null) {
                                          final s =
                                              member.lastSeen.toString().trim();
                                          return s.toLowerCase() == 'offline'
                                              ? "Offline"
                                              : "Last seen: $s";
                                        }

                                        try {
                                          return "Last seen: ${Tracking().getTimeAgo(parsedDate)}";
                                        } catch (_) {
                                          return "Offline";
                                        }
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          if (!isDeleteMode) {
                                            if (isMe) return;
                                            Navigator.pop(context);
                                            if (Get.currentRoute ==
                                                Routes.LocationTracking) {
                                              final int targetGroupId =
                                                  effectiveGroupId ??
                                                      int.tryParse(member
                                                              .groupId
                                                              ?.toString() ??
                                                          '') ??
                                                      0;
                                              GroupTrackingController.instance
                                                  .searchUserAndZoom(
                                                targetGroupId.toString(),
                                                memberUserId,
                                              );
                                            } else {
                                              if (Get.isRegistered<
                                                  MessageController>()) {
                                                Get.delete<MessageController>(
                                                    force: true);
                                              }
                                              final MemberData memberData =
                                                  MemberData(
                                                id: int.tryParse(member.id
                                                        ?.toString() ??
                                                    ''),
                                                userId: int.tryParse(
                                                    memberUserId),
                                                groupId: 0,
                                                name: name,
                                                profileImage: member
                                                    .profileImage
                                                    ?.toString(),
                                                lastSeen: member.lastSeen
                                                    ?.toString(),
                                                isOnline: isOnline,
                                                locationSharing:
                                                    !isGhostMode,
                                              );

                                              Get.toNamed(
                                                Routes.chatScreen,
                                                arguments: {
                                                  "userData": memberData,
                                                  "groupName": name,
                                                  "isCreator": false,
                                                  "type": "chatScreen",
                                                  "chatType": "private",
                                                  "groupId": 0,
                                                },
                                              );
                                            }
                                            return;
                                          }

                                          if (isMe) {
                                            CommonDialog.errorMessage(
                                              "You can't remove yourself from the group.",
                                            );
                                            return;
                                          }

                                          CommonDialog.ConfirmationDialog(
                                            title: "Remove Member",
                                            content:
                                                "Are you sure you want to remove $name from the group?",
                                            confirm: "Remove",
                                            onConfirm: () {
                                               final gc = Get.isRegistered<GroupController>()
                                                   ? Get.find<GroupController>()
                                                   : Get.put(GroupController());
                                               gc.deleteGroupMember(
                                                context,
                                                groupId:
                                                    (effectiveGroupId ??
                                                            member.groupId)
                                                        .toString(),
                                                groupMemberId: memberUserId,
                                                onSuccess: (success) {
                                                  if (success) {
                                                    setModalState(() {
                                                      activeMembers.removeWhere(
                                                          (m) =>
                                                              (m.userId ??
                                                                      m.id ??
                                                                      '')
                                                                  .toString() ==
                                                              memberUserId);
                                                    });

                                                    if (Get.isRegistered<
                                                        GroupMessageController>()) {
                                                      Get.find<
                                                              GroupMessageController>()
                                                          .groupMembers
                                                          .removeWhere((m) =>
                                                              (m.userId ??
                                                                      m.id ??
                                                                      '')
                                                                  .toString() ==
                                                              memberUserId);
                                                    }

                                                    Utils().fluttertoast(
                                                        "Member removed successfully");
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6.h),
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isGhostMode
                                                  ? Colors.grey.shade300
                                                  : const Color(0xFF6B4DFF)
                                                      .withValues(alpha: 0.1),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.r),
                                            color: isGhostMode
                                                ? Colors.grey.shade100
                                                : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.02),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 22.r,
                                                backgroundColor:
                                                    const Color(0xFFE8E4FF),
                                                backgroundImage: profileUrl !=
                                                        null
                                                    ? NetworkImage(profileUrl)
                                                    : null,
                                                child: profileUrl == null
                                                    ? Text(
                                                        name.isNotEmpty
                                                            ? name[0]
                                                                .toUpperCase()
                                                            : "?",
                                                        style: TextStyle(
                                                          color: ToggleThemeData
                                                              .Appcolor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16.sp,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            name,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isMe) ...[
                                                          SizedBox(width: 6.w),
                                                          _badge(
                                                            "You",
                                                            ToggleThemeData
                                                                    .Appcolor
                                                                .withValues(
                                                              alpha: 0.12,
                                                            ),
                                                            ToggleThemeData
                                                                .Appcolor,
                                                          ),
                                                        ],
                                                        if (isAdmin) ...[
                                                          SizedBox(width: 6.w),
                                                          _badge(
                                                            "Admin",
                                                            const Color(
                                                                0xFFE7F8EC),
                                                            const Color(
                                                                0xFF2BB673),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.circle,
                                                          size: 8.r,
                                                          color: isGhostMode
                                                              ? const Color(
                                                                  0xFF7E57C2)
                                                              : (isOnline
                                                                  ? const Color(
                                                                      0xFF2BB673)
                                                                  : Colors.grey
                                                                      .shade400),
                                                        ),
                                                        SizedBox(width: 6.w),
                                                        Expanded(
                                                          child: reausabletext(
                                                            getLastSeenText(),
                                                            fontsize: 12,
                                                            color: isGhostMode
                                                                ? const Color(
                                                                    0xFF7E57C2)
                                                                : (isOnline
                                                                    ? const Color(
                                                                        0xFF2BB673)
                                                                    : Colors.grey[
                                                                        600]),
                                                            fontweight:
                                                                isGhostMode ||
                                                                        isOnline
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!isMe) ...[
                                                _actionButton(
                                                  icon: Icons
                                                      .chat_bubble_outline_rounded,
                                                  color:
                                                      ToggleThemeData.Appcolor,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    if (Get.isRegistered<
                                                        MessageController>()) {
                                                      Get.delete<
                                                              MessageController>(
                                                          force: true);
                                                    }
                                                    final MemberData
                                                        memberData = MemberData(
                                                      id: int.tryParse(member.id
                                                              ?.toString() ??
                                                          ''),
                                                      userId: int.tryParse(
                                                          memberUserId),
                                                      groupId: 0,
                                                      name: name,
                                                      profileImage: member
                                                          .profileImage
                                                          ?.toString(),
                                                      lastSeen: member.lastSeen
                                                          ?.toString(),
                                                      isOnline: isOnline,
                                                      locationSharing:
                                                          !isGhostMode,
                                                    );

                                                    Get.toNamed(
                                                      Routes.chatScreen,
                                                      arguments: {
                                                        "userData": memberData,
                                                        "groupName": name,
                                                        "isCreator": false,
                                                        "type": "chatScreen",
                                                        "chatType": "private",
                                                        "groupId": 0,
                                                      },
                                                    );
                                                  },
                                                ),
                                                SizedBox(width: 6.w),
                                                _actionButton(
                                                  icon: Icons.call_outlined,
                                                  color:
                                                      const Color(0xFF2BB673),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    if (Get.isRegistered<
                                                        CallingController>()) {
                                                      Get.delete<
                                                              CallingController>(
                                                          force: true);
                                                    }
                                                    Get.toNamed(
                                                      Routes.callScreen,
                                                      arguments: {
                                                        "callerId":
                                                            currentUserId,
                                                        "remoteUserId":
                                                            memberUserId,
                                                        "callerName": name,
                                                        "callerProfile": member
                                                                .profileImage
                                                                ?.toString() ??
                                                            "",
                                                        "offer": null,
                                                        "is_video": false,
                                                        "callType": "outGoing",
                                                      },
                                                    );
                                                  },
                                                ),
                                                SizedBox(width: 6.w),
                                                _actionButton(
                                                  icon: Icons.videocam_outlined,
                                                  color: Colors.redAccent,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    if (Get.isRegistered<
                                                        CallingController>()) {
                                                      Get.delete<
                                                              CallingController>(
                                                          force: true);
                                                    }
                                                    Get.toNamed(
                                                      Routes.callScreen,
                                                      arguments: {
                                                        "callerId":
                                                            currentUserId,
                                                        "remoteUserId":
                                                            memberUserId,
                                                        "callerName": name,
                                                        "callerProfile": member
                                                                .profileImage
                                                                ?.toString() ??
                                                            "",
                                                        "offer": null,
                                                        "is_video": true,
                                                        "callType": "outGoing",
                                                      },
                                                    );
                                                  },
                                                ),
                                                if (!isGhostMode) ...[
                                                  SizedBox(width: 6.w),
                                                  _actionButton(
                                                    icon: Icons
                                                        .navigation_rounded,
                                                    color:
                                                        const Color(0xFF3B82F6),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      final int targetGroupId =
                                                          effectiveGroupId ??
                                                              int.tryParse(member
                                                                      .groupId
                                                                      ?.toString() ??
                                                                  '') ??
                                                              0;
                                                      if (Get.currentRoute ==
                                                          Routes
                                                              .LocationTracking) {
                                                        GroupTrackingController
                                                            .instance
                                                            .searchUserAndZoom(
                                                          targetGroupId
                                                              .toString(),
                                                          memberUserId,
                                                        );
                                                      } else {
                                                        Get.toNamed(
                                                          Routes
                                                              .LocationTracking,
                                                          arguments: {
                                                            "groupId":
                                                                targetGroupId,
                                                            "groupName":
                                                                effectiveGroupName,
                                                            "targetUserId":
                                                                memberUserId,
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                                if (isDeleteMode) ...[
                                                  SizedBox(width: 6.w),
                                                  _actionButton(
                                                    icon: Icons
                                                        .person_remove_outlined,
                                                    color: Colors.red,
                                                    onTap: () {
                                                      CommonDialog
                                                          .ConfirmationDialog(
                                                        title: "Remove Member",
                                                        content:
                                                            "Are you sure you want to remove $name from the group?",
                                                        confirm: "Remove",
                                                        onConfirm: () {
                                                           final gc = Get.isRegistered<GroupController>()
                                                               ? Get.find<GroupController>()
                                                               : Get.put(GroupController());
                                                           gc.deleteGroupMember(
                                                            context,
                                                            groupId:
                                                                (effectiveGroupId ??
                                                                        member
                                                                            .groupId)
                                                                    .toString(),
                                                            groupMemberId:
                                                                memberUserId,
                                                            onSuccess:
                                                                (success) {
                                                              if (success) {
                                                                setModalState(
                                                                    () {
                                                                  activeMembers.removeWhere((m) =>
                                                                      (m.userId ??
                                                                              m.id ??
                                                                              '')
                                                                          .toString() ==
                                                                      memberUserId);
                                                                });

                                                                if (Get.isRegistered<
                                                                    GroupMessageController>()) {
                                                                  Get.find<
                                                                          GroupMessageController>()
                                                                      .groupMembers
                                                                      .removeWhere((m) =>
                                                                          (m.userId ?? m.id ?? '')
                                                                              .toString() ==
                                                                          memberUserId);
                                                                }

                                                                Utils().fluttertoast(
                                                                    "Member removed successfully");
                                                              }
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _badge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 18.sp,
        ),
      ),
    );
  }
}
