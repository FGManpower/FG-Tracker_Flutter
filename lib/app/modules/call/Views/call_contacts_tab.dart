import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/contact_profile_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/constant/pref_res.dart';

class CallContactsTab extends StatefulWidget {
  const CallContactsTab({super.key});

  @override
  State<CallContactsTab> createState() => _CallContactsTabState();
}

class _CallContactsTabState extends State<CallContactsTab> {
  final CallController controller = CallController.instance;

  @override
  void initState() {
    super.initState();
    controller.getRegisteredContacts();
    controller.checkContactPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Internet / Server error state
      if (controller.responseError.value.isNotEmpty && controller.allUserProfileData.isEmpty) {
        return LostinternetConnection(
          retry: () {
            controller.getRegisteredContacts();
          },
          messgae: controller.responseError.value.toString(),
        );
      }

      // 2. Loading state
      if (controller.contactLoading.value && controller.allUserProfileData.isEmpty) {
        return _buildContactsListUi(isLoading: true);
      }

      // 3. No contacts found (Empty state)
      if (controller.allUserProfileData.isEmpty || controller.filteredUsers.isEmpty) {
        final bool isDialOpen = controller.isDialPadOpen.value;
        final matchedRecent = controller.filteredRecentCalls;

        // If there are matching recent calls when contact is not in contacts list
        if (matchedRecent.isNotEmpty && controller.searchQuery.value.isNotEmpty) {
          return RefreshIndicator(
            color: const Color(0xFF4818F0),
            onRefresh: controller.refreshContacts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                isDialOpen ? 390.h : 90.h,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Calls",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: FontFamily.interBold,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEAFD),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "From Recent",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF4818F0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < matchedRecent.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: const Color(0xFFF1F3F9),
                            indent: 62.w,
                            endIndent: 14.w,
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          child: _RecentContactTile(
                            call: matchedRecent[i],
                            onTap: () {
                              final isGroup =
                                  matchedRecent[i]['isGroup'] == 'true';
                              if (isGroup) {
                                final gId = matchedRecent[i]['groupId'] ??
                                    matchedRecent[i]['callerId'];
                                if (gId != null && gId.isNotEmpty) {
                                  Get.toNamed(
                                    Routes.groupChatScreen,
                                    arguments: {
                                      "groupId": gId,
                                      "groupName":
                                          matchedRecent[i]['name'] ?? "Group",
                                      "groupProfile":
                                          matchedRecent[i]['avatar'],
                                    },
                                  );
                                }
                              } else {
                                final String phone =
                                    (matchedRecent[i]['mobileNo']?.isNotEmpty == true)
                                        ? matchedRecent[i]['mobileNo']!
                                        : (matchedRecent[i]['phone'] ?? '');

                                Get.to(
                                  () => ContactProfileScreen(
                                    contactData: MemberData(
                                      userId: int.tryParse(
                                          matchedRecent[i]['callerId'] ?? ''),
                                      name: matchedRecent[i]['name'],
                                      mobileNo: phone,
                                      profileImage: matchedRecent[i]['avatar'],
                                      isOnline:
                                          matchedRecent[i]['isOnline'] == 'true',
                                    ),
                                  ),
                                );
                              }
                            },
                            onCallTap: (type) {
                              final isGroup =
                                  matchedRecent[i]['isGroup'] == 'true';
                              final bool isVideo = type == "video";

                              if (isGroup) {
                                final gId = matchedRecent[i]['groupId'] ??
                                    matchedRecent[i]['callerId'] ??
                                    '';
                                GroupCallService.instance.startGroupCall(
                                  context,
                                  groupId: gId,
                                  groupName: matchedRecent[i]['name'] ??
                                      "Group Call",
                                  groupProfile: matchedRecent[i]['avatar'],
                                  isVideo: isVideo,
                                  memberCount: int.tryParse(matchedRecent[i]
                                              ['memberCount'] ??
                                          '0') ??
                                      0,
                                );
                              } else {
                                final callerId =
                                    matchedRecent[i]['callerId'] ?? '';
                                final currentUserId = Global.storageServices
                                    .get(PrefConst.userId)
                                    ?.toString();
                                if (currentUserId != null &&
                                    callerId.isNotEmpty &&
                                    callerId != currentUserId) {
                                  CallService().startCall(
                                    context,
                                    callerId: currentUserId,
                                    remoteUserId: callerId,
                                    is_video: isVideo,
                                    callerName:
                                        matchedRecent[i]['name'] ?? "User",
                                  );
                                } else {
                                  final String phone =
                                      matchedRecent[i]['mobileNo'] ??
                                          matchedRecent[i]['phone'] ??
                                          '';
                                  if (phone.isNotEmpty) {
                                    controller.dialNumber.value = phone;
                                    controller.makeCall(isVideo: isVideo);
                                  } else {
                                    Utils().fluttertoast("Unable to call this contact");
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF4818F0),
          onRefresh: controller.refreshContacts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: isDialOpen ? 390.h : 90.h),
            children: [
              SizedBox(height: isDialOpen ? 15.h : 60.h),
              Center(
                child: Image.asset(
                  Assets.images.notFount.path,
                  width: isDialOpen ? 140.w : 240.w,
                  height: isDialOpen ? 140.w : 240.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  controller.searchQuery.value.isNotEmpty
                      ? "No contacts match your search"
                      : "No registered contacts found",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interMedium,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // 5. Contacts successfully loaded
      return _buildContactsListUi(
        contactData: controller.filteredUsers,
        matchedRecent: controller.filteredRecentCalls,
        isLoading: false,
      );
    });
  }

  /// UI displayed when Contacts permission has not been granted yet (Exact Screenshot 2)
  Widget _buildPermissionRequiredUi() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildPermissionBanner(),
        SizedBox(height: 50.h),
        Center(
          child: Image.asset(
            Assets.images.notFount.path,
            width: 240.w,
            height: 240.w,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  /// The "Let us access your contacts" card with "Allow Access ->" button
  Widget _buildPermissionBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFF6B4DFF).withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4818F0).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.perm_contact_calendar_rounded,
                  color: const Color(0xFF4818F0),
                  size: 26.sp,
                ),
                Positioned(
                  right: 5.w,
                  bottom: 5.h,
                  child: Container(
                    padding: EdgeInsets.all(1.5.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      color: const Color(0xFF4818F0),
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let us access your contacts",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Find and call your team members easily.",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.requestContactPermission,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4818F0),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4818F0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Allow Access",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 13.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// List of Contact Cards (Exact Screenshot 1)
  Widget _buildContactsListUi({
    List<UserListData>? contactData,
    List<Map<String, String>>? matchedRecent,
    bool isLoading = false,
  }) {
    final bool loading = isLoading || contactData == null;
    final int count = loading ? 8 : contactData.length;
    final bool isDialOpen = controller.isDialPadOpen.value;
    final bool hasRecent = matchedRecent != null &&
        matchedRecent.isNotEmpty &&
        controller.searchQuery.value.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: controller.refreshContacts,
      child: Skeletonizer(
        enabled: loading,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            isDialOpen ? 390.h : 90.h,
          ),
          children: [
            if (!controller.isContactPermissionGranted.value && !loading)
              _buildPermissionBanner(),

            // "All Contacts" Section Header
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 4.h),
              child: Text(
                "All Contacts",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
            ),

            // List of individual white contact cards
            for (int index = 0; index < count; index++)
              loading
                  ? const _SkeletonContactCard()
                  : _ContactCard(
                      user: contactData[index],
                      onTapCard: () {
                        Get.to(
                          () => ContactProfileScreen(
                            contactData: MemberData(
                              userId: contactData[index].userId,
                              name: contactData[index].name,
                              mobileNo: contactData[index].mobileNo,
                              profileImage: contactData[index].profileImage,
                              isOnline: contactData[index].isOnline ?? false,
                            ),
                          ),
                        );
                      },
                      onTapAudio: () {
                        CallService().startCall(
                          context,
                          callerId: Global.storageServices
                              .get(PrefConst.userId)
                              .toString(),
                          remoteUserId:
                              contactData[index].userId.toString(),
                          is_video: false,
                          callerName:
                              contactData[index].name.toString(),
                        );
                      },
                      onTapVideo: () {
                        CallService().startCall(
                          context,
                          callerId: Global.storageServices
                              .get(PrefConst.userId)
                              .toString(),
                          remoteUserId:
                              contactData[index].userId.toString(),
                          is_video: true,
                          callerName:
                              contactData[index].name.toString(),
                        );
                      },
                    ),

            // Additional Recent Calls section if search query matches recent items
            if (hasRecent) ...[
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 16.h),
                child: Text(
                  "Recent Calls",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < matchedRecent.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: const Color(0xFFF1F3F9),
                          indent: 62.w,
                          endIndent: 14.w,
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        child: _RecentContactTile(
                          call: matchedRecent[i],
                          onTap: () {
                            final isGroup =
                                matchedRecent[i]['isGroup'] == 'true';
                            if (isGroup) {
                              final gId = matchedRecent[i]['groupId'] ??
                                  matchedRecent[i]['callerId'];
                              if (gId != null && gId.isNotEmpty) {
                                Get.toNamed(
                                  Routes.groupChatScreen,
                                  arguments: {
                                    "groupId": gId,
                                    "groupName":
                                        matchedRecent[i]['name'] ?? "Group",
                                    "groupProfile":
                                        matchedRecent[i]['avatar'],
                                  },
                                );
                              }
                            } else {
                              final String phone =
                                  (matchedRecent[i]['mobileNo']?.isNotEmpty == true)
                                      ? matchedRecent[i]['mobileNo']!
                                      : (matchedRecent[i]['phone'] ?? '');

                              Get.to(
                                () => ContactProfileScreen(
                                  contactData: MemberData(
                                    userId: int.tryParse(
                                        matchedRecent[i]['callerId'] ?? ''),
                                    name: matchedRecent[i]['name'],
                                    mobileNo: phone,
                                    profileImage: matchedRecent[i]['avatar'],
                                    isOnline:
                                        matchedRecent[i]['isOnline'] == 'true',
                                  ),
                                ),
                              );
                            }
                          },
                          onCallTap: (type) {
                            final isGroup =
                                matchedRecent[i]['isGroup'] == 'true';
                            final bool isVideo = type == "video";

                            if (isGroup) {
                              final gId = matchedRecent[i]['groupId'] ??
                                  matchedRecent[i]['callerId'] ??
                                  '';
                              GroupCallService.instance.startGroupCall(
                                context,
                                groupId: gId,
                                groupName: matchedRecent[i]['name'] ??
                                    "Group Call",
                                groupProfile: matchedRecent[i]['avatar'],
                                isVideo: isVideo,
                                memberCount: int.tryParse(matchedRecent[i]
                                            ['memberCount'] ??
                                        '0') ??
                                    0,
                              );
                            } else {
                              final callerId =
                                  matchedRecent[i]['callerId'] ?? '';
                              final currentUserId = Global.storageServices
                                  .get(PrefConst.userId)
                                  ?.toString();
                              if (currentUserId != null &&
                                  callerId.isNotEmpty &&
                                  callerId != currentUserId) {
                                CallService().startCall(
                                  context,
                                  callerId: currentUserId,
                                  remoteUserId: callerId,
                                  is_video: isVideo,
                                  callerName:
                                      matchedRecent[i]['name'] ?? "User",
                                );
                              } else {
                                final String phone =
                                    matchedRecent[i]['mobileNo'] ??
                                        matchedRecent[i]['phone'] ??
                                        '';
                                if (phone.isNotEmpty) {
                                  controller.dialNumber.value = phone;
                                  controller.makeCall(isVideo: isVideo);
                                } else {
                                  Utils().fluttertoast("Unable to call this contact");
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standalone Contact Card (Matching Screenshot 1)
class _ContactCard extends StatelessWidget {
  final UserListData user;
  final VoidCallback onTapCard;
  final VoidCallback onTapAudio;
  final VoidCallback onTapVideo;

  const _ContactCard({
    required this.user,
    required this.onTapCard,
    required this.onTapAudio,
    required this.onTapVideo,
  });

  String _formatPhoneNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String clean = raw.trim();
    String digits = clean.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return "+91 ${digits.substring(0, 5)} ${digits.substring(5)}";
    } else if (digits.length == 12 && digits.startsWith('91')) {
      final sub = digits.substring(2);
      return "+91 ${sub.substring(0, 5)} ${sub.substring(5)}";
    }
    if (!clean.startsWith('+') && digits.length >= 10) {
      return "+$clean";
    }
    return clean;
  }

  String _buildAvatarUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    raw = raw.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) raw = raw.substring(1);
    return '${ConstRes.aImageBaseUrl}$raw';
  }

  Widget _buildAvatar(String name, String? avatar, bool isOnline) {
    final String avatarUrl = _buildAvatarUrl(avatar);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Container(
            width: 46.w,
            height: 46.w,
            color: const Color(0xFFECEAFD),
            child: avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: FontFamily.interBold,
                          color: const Color(0xFF4818F0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: FontFamily.interBold,
                          color: const Color(0xFF4818F0),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF4818F0),
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF10B981)
                  : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.w),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = user.name ?? 'Unknown';
    final bool isOnline = user.isOnline ?? false;

    return GestureDetector(
      onTap: onTapCard,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFF1F3F9),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E1B4B).withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(name, user.profileImage, isOnline),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _formatPhoneNumber(user.mobileNo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interMedium,
                      color: const Color(0xFF4818F0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            CallActionChip(
              icon: Icons.call_rounded,
              size: 38.w,
              iconSize: 18.sp,
              onTap: onTapAudio,
            ),
            SizedBox(width: 8.w),
            CallActionChip(
              icon: Icons.videocam_rounded,
              size: 38.w,
              iconSize: 20.sp,
              onTap: onTapVideo,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading Skeleton Card
class _SkeletonContactCard extends StatelessWidget {
  const _SkeletonContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFF1F3F9),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23.r,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Loading contact name",
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "+91 98765 43210",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          const CallActionChip(
            icon: Icons.call_rounded,
            size: 38,
          ),
          SizedBox(width: 8.w),
          const CallActionChip(
            icon: Icons.videocam_rounded,
            size: 38,
          ),
        ],
      ),
    );
  }
}

/// Standalone Recent Contact Tile for Contacts tab
class _RecentContactTile extends StatelessWidget {
  const _RecentContactTile({
    required this.call,
    required this.onTap,
    required this.onCallTap,
  });

  final Map<String, String> call;
  final VoidCallback onTap;
  final void Function(String type) onCallTap;

  String _formatDisplayTime(String raw) {
    final String trimmed = raw.trim();
    final String cleaned = trimmed
        .replaceAll(
            RegExp(r'^(today|yesterday),?\s*', caseSensitive: false), '')
        .trim();
    return cleaned.isNotEmpty ? cleaned : trimmed;
  }

  String _buildAvatarUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    raw = raw.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) raw = raw.substring(1);
    return '${ConstRes.aImageBaseUrl}$raw';
  }

  Widget _buildAvatar(
    String name,
    String? avatar,
    bool isOnline, {
    bool isGroup = false,
  }) {
    final String avatarUrl = _buildAvatarUrl(avatar);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    Widget placeholderOrFallback() {
      if (isGroup) {
        return Center(
          child: Icon(
            Icons.groups_rounded,
            size: 20.sp,
            color: const Color(0xFF4818F0),
          ),
        );
      }
      return Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF4818F0),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Container(
            width: 42.w,
            height: 42.w,
            color: const Color(0xFFECEAFD),
            child: avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => placeholderOrFallback(),
                    errorWidget: (context, url, error) =>
                        placeholderOrFallback(),
                  )
                : placeholderOrFallback(),
          ),
        ),
        if (!isGroup)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5.w),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String type = call['type'] ?? '';
    final String callType = call['callType'] ?? '';
    final bool missed = type.toLowerCase().contains('missed');
    final bool incoming = type.toLowerCase().contains('incoming');
    final bool cancelled = type.toLowerCase().contains('cancelled') ||
        type.toLowerCase().contains('reject');

    final Color statusColor = missed
        ? const Color(0xFFEF4444)
        : incoming
            ? const Color(0xFF3B82F6)
            : cancelled
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF10B981);

    final IconData statusIcon = missed
        ? Icons.south_west_rounded
        : cancelled
            ? Icons.call_end_rounded
            : incoming
                ? Icons.south_west_rounded
                : Icons.arrow_outward_rounded;

    final String name = call['name'] ?? '';
    final String? avatar = call['avatar'];
    final bool isOnline = (call['isOnline'] ?? '').toLowerCase() == 'true';
    final bool isGroup = (call['isGroup'] ?? '').toLowerCase() == 'true';

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _buildAvatar(name, avatar, isOnline, isGroup: isGroup),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                    ),
                    if (isGroup) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEAFD),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "Group",
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF4818F0),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 13.sp,
                      color: statusColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF6B7280),
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _formatDisplayTime(call['time'] ?? ''),
            style: TextStyle(
              fontSize: 10.5.sp,
              color: const Color(0xFF6B4DFF),
              fontFamily: FontFamily.interMedium,
            ),
          ),
          SizedBox(width: 10.w),
          CallActionChip(
            icon: callType == "video"
                ? Icons.videocam_rounded
                : Icons.call_rounded,
            onTap: () {
              onCallTap(callType);
            },
          ),
        ],
      ),
    );
  }
}
