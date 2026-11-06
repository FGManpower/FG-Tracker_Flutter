

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/util/profile_navigation.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Controller/walkieController.dart';
import '../Controller/walkie_channel_controller.dart';

class GroupInfoBottomSheet extends StatelessWidget {
  final String? groupId;
  final String groupName;
  final String? groupDesc;
  final String? groupCode;
  final String? adminId;
  final List<dynamic> allGroupMembers;
  final GroupWalkieController? controller;

  const GroupInfoBottomSheet({
    super.key,
    this.groupId,
    required this.groupName,
    this.groupDesc,
    this.groupCode,
    this.adminId,
    this.allGroupMembers = const [],
    this.controller,
  });

  // UI Theme Colors
  static const Color _cardWhite = Colors.white;
  static const Color _primaryPurple = Color(0xFF5A35FF);
  static const Color _lightPurple = Color(0xFF8B6CFF);
  static const Color _softPurple = Color(0xFFEDE9FE);
  static const Color _activeGreen = Color(0xFF22C55E);
  static const Color _mutedRed = Color(0xFFEF4444);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textSecondary = Color(0xFF8E8EA8);

  static void show({
    required BuildContext context,
    String? groupId,
    required String groupName,
    String? groupDesc,
    String? groupCode,
    String? adminId,
    List<dynamic> allGroupMembers = const [],
    GroupWalkieController? controller,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GroupInfoBottomSheet(
        groupId: groupId,
        groupName: groupName,
        groupDesc: groupDesc,
        groupCode: groupCode,
        adminId: adminId,
        allGroupMembers: allGroupMembers,
        controller: controller,
      ),
    );
  }

  GroupWalkieController get _effectiveController =>
      controller ?? Get.find<GroupWalkieController>();

  bool get _isCurrentViewerAdmin {
    final selfId = _effectiveController.safeSelfUserId;
    if (selfId.isEmpty) return false;

    if (adminId != null && adminId!.trim().isNotEmpty) {
      if (selfId == adminId!.trim() ||
          (int.tryParse(selfId) != null &&
              int.tryParse(selfId) == int.tryParse(adminId!.trim()))) {
        return true;
      }
    }

    for (final m in allGroupMembers) {
      final mId = m.userId?.toString();
      if (mId == selfId ||
          (int.tryParse(mId ?? '') != null &&
              int.tryParse(mId ?? '') == int.tryParse(selfId))) {
        if (m.isCreator == true || m.isCreator == 1 || m.isCreator == '1') {
          return true;
        }
      }
    }

    return false;
  }

  bool _isMemberNotificationOff(dynamic member, String memberId) {
    final cleanId = memberId.trim();
    if (cleanId.isEmpty) return false;

    // 1. Controller reactive override (if set by socket or local update)
    if (_effectiveController.memberNotificationStatus.containsKey(cleanId)) {
      return _effectiveController.memberNotificationStatus[cleanId] == false;
    }

    // 2. If it's the current viewer, check WalkieChannelController preference
    final selfId = _effectiveController.safeSelfUserId;
    if (cleanId == selfId && Get.isRegistered<WalkieChannelController>()) {
      try {
        final chCtrl = Get.find<WalkieChannelController>();
        final effGId = groupId ?? _effectiveController.currentGroupId;
        final ch = chCtrl.channels.firstWhereOrNull(
          (c) => c.groupId?.toString() == effGId?.toString(),
        );
        if (ch != null) {
          return ch.notificationsEnabled == false;
        }
      } catch (_) {}
    }

    // 3. Member object notification property (MemberData or Map)
    if (member is MemberData && member.notificationsEnabled != null) {
      return member.notificationsEnabled == false;
    }

    try {
      if (member is Map) {
        final raw = member['notificationsEnabled'] ??
            member['notifications_enabled'] ??
            member['notification_enabled'] ??
            member['channelNotification'] ??
            member['walkie_notifications_enabled'] ??
            member['isNotification'];
        if (raw != null) {
          final s = raw.toString().toLowerCase().trim();
          if (s == 'false' || s == '0' || raw == false || raw == 0) return true;
          if (s == 'true' || s == '1' || raw == true || raw == 1) return false;
        }
      }
    } catch (_) {}

    try {
      final notif = (member as dynamic).notificationsEnabled;
      if (notif != null) {
        return notif == false ||
            notif == 0 ||
            notif.toString() == 'false' ||
            notif.toString() == '0';
      }
    } catch (_) {}

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Modal Drag Handle (Fixed)
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Fixed Group Header
          _buildGroupHeader(),

          // Fixed Group Description
          if (groupDesc != null && groupDesc!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Description",
              style: TextStyle(
                color: _textDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              groupDesc!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _textSecondary, fontSize: 12.sp),
            ),
          ],

          // Fixed Group Code
          if (groupCode != null && groupCode!.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              "Group Code: $groupCode",
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          // Fixed Members Header & Scrollable Members List
          if (allGroupMembers.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildMembersHeader(),
            SizedBox(height: 10.h),
            Flexible(
              child: _buildMembersList(),
            ),
          ] else ...[
            SizedBox(height: 24.h),
            Center(
              child: Text(
                "No members found",
                style: TextStyle(color: _textSecondary, fontSize: 13.sp),
              ),
            ),
          ],
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Row(
      children: [
        Container(
          width: 46.r,
          height: 46.r,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_lightPurple, _primaryPurple],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.people_alt_rounded, color: Colors.white, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textDark,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Obx(() {
                final activeCount = _effectiveController.totalParticipants.value > 0
                    ? _effectiveController.totalParticipants.value
                    : _effectiveController.participants.length;
                return Text(
                  "$activeCount Active in Walkie",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.sp,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersHeader() {
    return Row(
      children: [
        Text(
          "Group Members",
          style: TextStyle(
            color: _textDark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          "${allGroupMembers.length} total",
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _openMemberProfile(dynamic member, String memberName) {
    dynamic chatId;
    dynamic mobileNo;
    try {
      chatId = member.chatId;
    } catch (_) {}
    try {
      mobileNo = member.mobileNo;
    } catch (_) {}
    showUserQuickProfile(
      userId: member.userId,
      name: memberName,
      profileImage: member.profileImage?.toString(),
      mobileNo: mobileNo?.toString(),
      chatId: int.tryParse(chatId?.toString() ?? ''),
    );
  }

  Widget _buildMembersList() {
    final bool isViewerAdmin = _isCurrentViewerAdmin;

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: allGroupMembers.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final member = allGroupMembers[index];
        final memberId = member.userId?.toString() ?? '';
        final memberName = (member.name != null && member.name!.trim().isNotEmpty)
            ? member.name!.trim()
            : "Member";
        final bool isThisMemberAdmin = (adminId != null &&
                adminId!.trim().isNotEmpty &&
                (adminId!.trim() == memberId.trim() ||
                    (int.tryParse(adminId!.trim()) != null &&
                        int.tryParse(adminId!.trim()) == int.tryParse(memberId.trim())))) ||
            member.isCreator == true ||
            member.isCreator == 1 ||
            member.isCreator == '1';

        return Obx(() {
          final participant = _effectiveController.participants.firstWhereOrNull(
            (p) =>
                p.userId.trim() == memberId.trim() ||
                (int.tryParse(p.userId) != null &&
                    int.tryParse(p.userId) == int.tryParse(memberId)),
          );

          final bool inWalkie = participant != null;
          final bool isMuted = participant?.isMuted == true;
          final bool isSpeaking = participant?.isSpeaking == true;
          final bool isAppOnline = member.isOnline == true;
          final String? rawLastSeen = member.lastSeen?.toString();

          final bool isNotifOff = _isMemberNotificationOff(member, memberId);

          final String statusText;
          final Color statusColor;

          if (inWalkie) {
            if (isSpeaking) {
              statusText = "Speaking...";
              statusColor = _primaryPurple;
            } else if (isMuted) {
              statusText = "Muted • In Walkie";
              statusColor = _mutedRed;
            } else {
              statusText = "In Walkie Channel";
              statusColor = _activeGreen;
            }
          } else if (isAppOnline) {
            statusText = "Active";
            statusColor = _activeGreen;
          } else if (rawLastSeen != null &&
              rawLastSeen.trim().isNotEmpty &&
              rawLastSeen.toLowerCase() != 'offline' &&
              rawLastSeen.toLowerCase() != 'null') {
            final dt = DateTime.tryParse(rawLastSeen);
            if (dt != null) {
              statusText = "Last seen ${Tracking().getTimeAgo(dt)}";
            } else {
              statusText = "Last seen: $rawLastSeen";
            }
            statusColor = _textSecondary;
          } else {
            statusText = "Offline";
            statusColor = _textSecondary;
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openMemberProfile(member, memberName),
                  child: _buildMemberAvatar(
                    member,
                    memberName,
                    inWalkie: inWalkie,
                    isSpeaking: isSpeaking,
                    isMuted: isMuted,
                    isAppOnline: isAppOnline,
                    isNotificationOff: isNotifOff,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _openMemberProfile(member, memberName),
                        child: Text(
                          memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isThisMemberAdmin) ...[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _softPurple,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Admin",
                          style: TextStyle(
                            color: _primaryPurple,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isNotifOff) SizedBox(width: 6.w),
                    ],
                    if (isNotifOff)
                      _buildNotificationButton(
                        memberId: memberId,
                        memberName: memberName,
                        isViewerAdmin: isViewerAdmin,
                      ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildNotificationButton({
    required String memberId,
    required String memberName,
    required bool isViewerAdmin,
  }) {
    return Obx(() {
      final countdown = _effectiveController.adminAlertCountdown[memberId] ?? 0;
      final bool isCountingDown = countdown > 0;

      if (isCountingDown) {
        // Requirement 5: 10-Second Timer displayed to Admin
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _softPurple,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _primaryPurple.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12.r,
                height: 12.r,
                child: CircularProgressIndicator(
                  value: (countdown / 10.0).clamp(0.0, 1.0),
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(_primaryPurple),
                  backgroundColor: _softPurple,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "${countdown}s",
                style: TextStyle(
                  color: _primaryPurple,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }

      // Bell Icon Button
      if (isViewerAdmin) {
        // Requirement 3 & 4: Clickable by Admin -> Triggers notification to member
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final effGId = groupId ?? _effectiveController.currentGroupId ?? '';
              _effectiveController.triggerAdminAlertForMember(
                groupId: effGId,
                memberId: memberId,
                memberName: memberName,
                groupName: groupName,
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: _softPurple,
                shape: BoxShape.circle,
                border: Border.all(color: _primaryPurple.withOpacity(0.35)),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: _primaryPurple,
                size: 16.sp,
              ),
            ),
          ),
        );
      } else {
        // Requirement 3: Other members show button but cannot click
        return Tooltip(
          message: "Only Group Admin can send alert",
          child: GestureDetector(
            onTap: () {
              Get.snackbar(
                "Admin Only Action",
                "Only group admin can send notification alerts to members.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF1E1B2E),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: EdgeInsets.all(16.w),
                borderRadius: 12.r,
                icon: const Icon(Icons.info_outline_rounded,
                    color: Colors.orangeAccent),
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.grey.shade400,
                size: 16.sp,
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildMemberAvatar(
    dynamic member,
    String memberName, {
    required bool inWalkie,
    required bool isSpeaking,
    required bool isMuted,
    required bool isAppOnline,
    required bool isNotificationOff,
  }) {
    final String? profileImage = member.profileImage;
    final bool hasValidImage = profileImage != null &&
        profileImage.isNotEmpty &&
        !_isBadImageUrl(profileImage);

    final String fullUrl = hasValidImage
        ? (profileImage.startsWith('http')
            ? profileImage
            : ConstRes.aImageBaseUrl + profileImage)
        : '';

    final Color badgeColor;
    if (isMuted) {
      badgeColor = _mutedRed;
    } else if (isSpeaking) {
      badgeColor = _primaryPurple;
    } else if (inWalkie || isAppOnline) {
      badgeColor = _activeGreen;
    } else {
      badgeColor = Colors.grey.shade400;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: _softPurple,
          backgroundImage: hasValidImage ? NetworkImage(fullUrl) : null,
          child: !hasValidImage
              ? Text(
                  _getInitials(memberName),
                  style: TextStyle(
                    color: _primaryPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                )
              : null,
        ),
        // Bottom-right: Walkie / Online status indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: isMuted ? 13.r : 8.r,
            height: isMuted ? 13.r : 8.r,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: isMuted
                ? Center(
                    child: Icon(
                      Icons.mic_off_rounded,
                      color: Colors.white,
                      size: 7.5.sp,
                    ),
                  )
                : null,
          ),
        ),
        // Top-left: Small Notification Off icon badge
        if (isNotificationOff)
          Positioned(
            left: -2.r,
            top: -2.r,
            child: Container(
              padding: EdgeInsets.all(2.5.r),
              decoration: BoxDecoration(
                color: _mutedRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                color: Colors.white,
                size: 8.5.sp,
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  bool _isBadImageUrl(String? url) {
    if (url == null || url.isEmpty) return true;
    if (url.contains('pngitem.com')) return true;
    if (url.contains('placeholder')) return true;
    if (url.contains('default-avatar')) return true;
    return false;
  }
}