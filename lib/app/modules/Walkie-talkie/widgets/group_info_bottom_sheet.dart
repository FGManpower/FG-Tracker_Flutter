

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Controller/walkieController.dart';

class GroupInfoBottomSheet extends StatelessWidget {
  final String groupName;
  final String? groupDesc;
  final String? groupCode;
  final String? adminId;
  final List<dynamic> allGroupMembers;
  final GroupWalkieController? controller;

  const GroupInfoBottomSheet({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Modal Drag Handle
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


            _buildGroupHeader(),


            if (groupDesc != null && groupDesc!.trim().isNotEmpty) ...[
              SizedBox(height: 14.h),
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
                style: TextStyle(color: _textSecondary, fontSize: 12.sp),
              ),
            ],


            if (groupCode != null && groupCode!.trim().isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                "Group Code: $groupCode",
                style: TextStyle(
                  color: _primaryPurple,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],


            if (allGroupMembers.isNotEmpty) ...[
              SizedBox(height: 18.h),
              _buildMembersHeader(),
              SizedBox(height: 10.h),
              _buildMembersList(),
            ],
            SizedBox(height: 20.h),
          ],
        ),
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
                    : _effectiveController.sortedParticipants.length;
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

  Widget _buildMembersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allGroupMembers.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final member = allGroupMembers[index];
        final memberId = member.userId?.toString() ?? '';
        final memberName = (member.name != null && member.name!.trim().isNotEmpty)
            ? member.name!.trim()
            : "Member";
        final bool isGroupAdmin = adminId == memberId || index == 0;

        return Obx(() {
          final participant = _effectiveController.participants.firstWhereOrNull(
                (p) =>
            p.userId.trim() == memberId.trim() ||
                (int.tryParse(p.userId) != null &&
                    int.tryParse(p.userId) == int.tryParse(memberId)),
          );

          final bool isOnline = participant != null;
          final bool isMuted = participant?.isMuted == true;
          final bool isSpeaking = participant?.isSpeaking == true;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildMemberAvatar(member, memberName, isOnline, isMuted),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isSpeaking
                            ? "Speaking..."
                            : (isMuted
                            ? "Muted"
                            : (isOnline ? "In Walkie Channel" : "Offline")),
                        style: TextStyle(
                          color: isSpeaking
                              ? _primaryPurple
                              : (isMuted
                              ? _mutedRed
                              : (isOnline ? _activeGreen : _textSecondary)),
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isGroupAdmin)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildMemberAvatar(
      dynamic member,
      String memberName,
      bool isOnline,
      bool isMuted,
      ) {
    final String? profileImage = member.profileImage;
    final bool hasValidImage = profileImage != null &&
        profileImage.isNotEmpty &&
        !_isBadImageUrl(profileImage);

    final String fullUrl = hasValidImage
        ? (profileImage.startsWith('http')
        ? profileImage
        : ConstRes.aImageBaseUrl + profileImage)
        : '';

    return Stack(
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
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: isMuted ? 13.r : 8.r,
            height: isMuted ? 13.r : 8.r,
            decoration: BoxDecoration(
              color: isMuted
                  ? _mutedRed
                  : (isOnline ? _activeGreen : Colors.grey.shade400),
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