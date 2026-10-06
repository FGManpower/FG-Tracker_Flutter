import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/Views/Chat_Screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../call/Controller/call_controller.dart';

class ContactProfileScreen extends StatelessWidget {
  final MemberData contactData;

  const ContactProfileScreen({
    super.key,
    required this.contactData,
  });

  MemberData get selectedUser => contactData;

  @override
  Widget build(BuildContext context) {
    final user = selectedUser;

    final String name = user.name?.trim().isNotEmpty == true
        ? user.name!.trim()
        : 'Unknown Contact';

    final String phone = user.mobileNo?.trim().isNotEmpty == true
        ? user.mobileNo!.trim()
        : '+91 00000 00000';

    final String? avatar = user.profileImage;

    final bool isOnline = _getIsOnline(user);

    final String statusText = _getStatusText(
      user,
      isOnline,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.8),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFE2DDFD).withOpacity(0.9),
                    const Color(0xFFF4F5FA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  _buildProfileHeader(
                    name,
                    phone,
                    avatar,
                    isOnline,
                    statusText,
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButtons(
                    context,
                    user,
                  ),
                  SizedBox(height: 20.h),
                  _buildContactInfo(
                    context,
                    phone,
                    user,
                  ),
                  SizedBox(height: 20.h),
                  _buildRecentCalls(
                    context,
                    user,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomActionsCard(
      //   context,
      //   name,
      //   phone,
      //   avatar,
      // ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 65.w,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.only(
            left: 16.w,
            top: 8.h,
            bottom: 8.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: const Color(0xFF4818F0),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    String name,
    String phone,
    String? avatar,
    bool isOnline,
    String statusText,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 45.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _getImageProvider(avatar),
                child: _hasImage(avatar)
                    ? null
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 32.sp,
                          color: const Color(0xFF4818F0),
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
              ),
            ),
            if (isOnline)
              Container(
                width: 22.w,
                height: 22.w,
                margin: EdgeInsets.only(
                  bottom: 4.h,
                  right: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3.w,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          phone,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interSemiBold,
            color: const Color(0xFF4818F0),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isOnline)
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
            if (isOnline) SizedBox(width: 6.w),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    isOnline ? const Color(0xFF22C55E) : Colors.grey.shade600,
                fontFamily: FontFamily.interMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MemberData user,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 19.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionCard(
            Icons.call_rounded,
            "Audio Call",
            onTap: () => _startCall(
              context,
              user,
              isVideo: false,
            ),
          ),
          _actionCard(
            Icons.videocam_rounded,
            "Video Call",
            onTap: () => _startCall(
              context,
              user,
              isVideo: true,
            ),
          ),
          _actionCard(
            Icons.chat_bubble_rounded,
            "Message",
            onTap: () => _openPrivateChat(user),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4818F0).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4818F0),
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall(
    BuildContext context,
    MemberData user, {
    required bool isVideo,
  }) {
    final remoteUserId = user.userId?.toString();

    if (remoteUserId == null ||
        remoteUserId.isEmpty ||
        remoteUserId == 'null') {
      Get.snackbar(
        "Call Failed",
        "User information is not available.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    if (currentUserId.isEmpty || currentUserId == 'null') {
      Get.snackbar(
        "Call Failed",
        "Your user information is not available.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    CallService().startCall(
      context,
      callerId: currentUserId,
      remoteUserId: remoteUserId,
      is_video: isVideo,
      callerName: user.name ?? "User",
    );
  }

  void _openPrivateChat(MemberData user) {
    final userId = user.userId;

    if (userId == null) {
      Get.snackbar(
        "Chat Failed",
        "User information is not available.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      Routes.chatScreen,
      arguments: {
        "userData": user,
        "type": "chatScreen",
        "chatType": "private",
        "groupId": user.groupId ?? 0,
      },
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    String phone,
    MemberData user,
  ) {
    final String location = user.location?.trim().isNotEmpty == true
        ? user.location!.trim()
        : "Location not available";

    return _cardWrapper(
      child: Column(
        children: [
          _infoTile(
            Icons.person_rounded,
            "Contact Information",
            isHeader: true,
          ),
          const Divider(
            color: Color(0xFFF1F1F5),
            height: 1,
          ),
          _infoTile(
            Icons.call_rounded,
            phone,
            subtitle: "Mobile",
            onTap: () {},
          ),
          const Divider(
            color: Color(0xFFF1F1F5),
            height: 1,
          ),
          // _infoTile(
          //   Icons.location_on_rounded,
          //   location,
          //   subtitle: "Location",
          //   trailingIcon: Icons.near_me_rounded,
          // ),
        ],
      ),
    );
  }

  Widget _buildRecentCalls(
    BuildContext context,
    MemberData user,
  ) {
    final calls = _getUserRecentCalls(user);

    return _cardWrapper(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                _iconWrapper(
                  Icons.access_time_rounded,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "Recent Calls",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (calls.isNotEmpty)
                  Text(
                    "${calls.length}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF4818F0),
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFF1F1F5),
            height: 1,
          ),
          if (calls.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 22.h,
                horizontal: 16.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_disabled_rounded,
                    size: 18.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "No recent calls",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              calls.length > 5 ? 5 : calls.length,
              (index) {
                final call = calls[index];

                return Column(
                  children: [
                    if (index > 0)
                      const Divider(
                        color: Color(0xFFF1F1F5),
                        height: 1,
                      ),
                    _buildDynamicCallTile(
                      context,
                      call,
                      user,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getUserRecentCalls(
    MemberData user,
  ) {
    try {
      if (!Get.isRegistered<CallController>()) {
        return [];
      }

      final CallController controller = Get.find<CallController>();
      final List<Map<String, String>> result = [];
      final userId = user.userId?.toString();
      final userMobile = (user.mobileNo ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      final userNorm = userMobile.length > 10 ? userMobile.substring(userMobile.length - 10) : userMobile;

      for (final group in controller.groupedRecentCalls.values) {
        for (final call in group) {
          final callerId = call['callerId']?.trim();
          final callPhone = (call['mobileNo'] ?? call['phone'] ?? '').replaceAll(RegExp(r'[^0-9]'), '');
          final callNorm = callPhone.length > 10 ? callPhone.substring(callPhone.length - 10) : callPhone;

          final bool idMatch = userId != null && userId.isNotEmpty && callerId == userId;
          final bool phoneMatch = userNorm.isNotEmpty && callNorm.isNotEmpty && userNorm == callNorm;

          if (idMatch || phoneMatch) {
            result.add(
              Map<String, String>.from(call),
            );
          }
        }
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  Widget _buildDynamicCallTile(
    BuildContext context,
    Map<String, String> call,
    MemberData user,
  ) {
    final String type =
        call['type']?.trim().isNotEmpty == true ? call['type']!.trim() : "Call";

    final String callType = call['callType']?.trim().isNotEmpty == true
        ? call['callType']!.trim().toLowerCase()
        : "audio";

    final String time =
        call['time']?.trim().isNotEmpty == true ? call['time']!.trim() : "-";

    final String duration = call['duration']?.trim().isNotEmpty == true
        ? call['duration']!.trim()
        : "-";

    final String normalizedType = type.toLowerCase();

    final bool missed = normalizedType.contains("missed");

    final bool incoming = normalizedType.contains("incoming");

    final bool cancelled = normalizedType.contains("cancelled") ||
        normalizedType.contains("reject");

    final Color color;

    if (missed) {
      color = const Color(0xFFEF4444);
    } else if (incoming) {
      color = const Color(0xFF3B82F6);
    } else if (cancelled) {
      color = const Color(0xFF9CA3AF);
    } else {
      color = const Color(0xFF10B981);
    }

    final IconData icon;

    if (missed) {
      icon = Icons.call_missed_rounded;
    } else if (cancelled) {
      icon = Icons.call_end_rounded;
    } else if (incoming) {
      icon = Icons.call_received_rounded;
    } else {
      icon = Icons.call_made_rounded;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: missed ? color : Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      callType == "video"
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                      size: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        _formatDisplayTime(time),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
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
          InkWell(
            onTap: () {
              _startCall(
                context,
                user,
                isVideo: callType == "video",
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F0FE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                callType == "video"
                    ? Icons.videocam_rounded
                    : Icons.call_rounded,
                size: 17.sp,
                color: const Color(0xFF4818F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplayTime(String raw) {
    final trimmed = raw.trim();

    if (trimmed.isEmpty) {
      return "-";
    }

    final cleaned = trimmed
        .replaceFirst(
          RegExp(
            r'^(today|yesterday),?\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    return cleaned.isNotEmpty ? cleaned : trimmed;
  }

  Widget _buildBottomActionsCard(
    BuildContext context,
    String name,
    String phone,
    String? avatar,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(
        vertical: 14.h,
        horizontal: 8.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomAction(
              Icons.star_rounded,
              "Add to Favorites",
              const Color(0xFF4818F0),
            ),
          ),
          Container(
            width: 1,
            height: 36.h,
            color: const Color(0xFFE8E8EE),
          ),
          Expanded(
            child: _bottomAction(
              Icons.person_add_alt_1_rounded,
              "Share Contact",
              const Color(0xFF4818F0),
            ),
          ),
          Container(
            width: 1,
            height: 36.h,
            color: const Color(0xFFE8E8EE),
          ),
          Expanded(
            child: _bottomAction(
              Icons.edit_rounded,
              "Edit Contact",
              const Color(0xFF4818F0),
              onTap: () {
                _showEditBottomSheet(
                  context,
                  name,
                  phone,
                  avatar,
                );
              },
            ),
          ),
          Container(
            width: 1,
            height: 36.h,
            color: const Color(0xFFE8E8EE),
          ),
          Expanded(
            child: _bottomAction(
              Icons.block_rounded,
              "Block Contact",
              const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 22.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: FontFamily.interMedium,
                color:
                    color == const Color(0xFFEF4444) ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    String name,
    String phone,
    String? avatar,
  ) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          10.h,
          20.w,
          20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Contact",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    minimumSize: Size(
                      80.w,
                      36.h,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getImageProvider(avatar),
                  child: _hasImage(avatar)
                      ? null
                      : Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: const Color(0xFF4818F0),
                            fontFamily: FontFamily.interBold,
                          ),
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16.sp,
                    color: const Color(0xFF6B4DFF),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _bottomSheetTextField(
              "Full Name",
              name,
              Icons.person_rounded,
            ),
            SizedBox(height: 16.h),
            _bottomSheetTextField(
              "Mobile Number",
              phone,
              Icons.call_rounded,
            ),
            SizedBox(height: 16.h),
            // _bottomSheetTextField(
            //   "Location",
            //   selectedUser.location?.trim().isNotEmpty == true
            //       ? selectedUser.location!
            //       : "Location not available",
            //   Icons.location_on_rounded,
            //   isDropdown: true,
            // ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Delete Contact",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetTextField(
    String label,
    String value,
    IconData icon, {
    bool isDropdown = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.h,
          ),
          child: _iconWrapper(icon),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  fontFamily: FontFamily.interMedium,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (isDropdown)
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardWrapper({
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile(
    IconData leadingIcon,
    String title, {
    String? subtitle,
    IconData? trailingIcon,
    bool isHeader = false,
    VoidCallback? onTap,
  }) {
    final tile = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      child: Row(
        children: [
          _iconWrapper(leadingIcon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF0F172A),
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isHeader ? 14.sp : 13.sp,
                    fontFamily: isHeader
                        ? FontFamily.interSemiBold
                        : FontFamily.interMedium,
                    color: isHeader
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F5FA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                trailingIcon,
                size: 18.sp,
                color: const Color(0xFF4818F0),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return InkWell(
      onTap: onTap,
      child: tile,
    );
  }

  Widget _iconWrapper(
    IconData icon,
  ) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: const Color(0xFF4818F0).withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: const Color(0xFF4818F0),
        size: 18.sp,
      ),
    );
  }

  bool _getIsOnline(MemberData user) {
    if (user.isOnline == true) {
      return true;
    }

    if (user.lastSeen == null || user.lastSeen!.trim().isEmpty) {
      return false;
    }

    try {
      final timeAgo = Tracking().getTimeAgo(
        DateTime.parse(
          user.lastSeen!.trim(),
        ),
      );

      return timeAgo.toLowerCase() == "just now";
    } catch (_) {
      return false;
    }
  }

  String _getStatusText(
    MemberData user,
    bool isOnline,
  ) {
    if (isOnline) {
      return "Online";
    }

    if (user.lastSeen != null && user.lastSeen!.trim().isNotEmpty) {
      try {
        return Tracking().getTimeAgo(
          DateTime.parse(
            user.lastSeen!.trim(),
          ),
        );
      } catch (_) {
        return user.lastSeen!.trim();
      }
    }

    return "Offline";
  }

  bool _hasImage(String? avatar) {
    return avatar != null &&
        avatar.trim().isNotEmpty &&
        avatar.trim().toLowerCase() != "null";
  }

  ImageProvider? _getImageProvider(
    String? avatar,
  ) {
    if (!_hasImage(avatar)) {
      return null;
    }

    final image = avatar!.trim();

    if (image.startsWith("http://") || image.startsWith("https://")) {
      return NetworkImage(image);
    }

    return NetworkImage(
      "${ConstRes.aImageBaseUrl}$image",
    );
  }
}
