import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_controller.dart';
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
    controller.checkContactPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. If contacts permission is NOT granted, show the "Allow Access" Banner + illustration (Exact Screenshot 2)
      if (!controller.isContactPermissionGranted.value) {
        return _buildPermissionRequiredUi();
      }

      // 2. Internet / Server error state
      if (controller.responseError.value.isNotEmpty) {
        return LostinternetConnection(
          retry: () {
            controller.getRegisteredContacts();
          },
          messgae: controller.responseError.value.toString(),
        );
      }

      // 3. Loading state
      if (controller.contactLoading.value) {
        return _buildContactsListUi(isLoading: true);
      }

      // 4. Permission is granted, but no matched registered contacts found
      if (controller.allUserProfileData.isEmpty || controller.filteredUsers.isEmpty) {
        return RefreshIndicator(
          color: const Color(0xFF4818F0),
          onRefresh: controller.refreshContacts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 60.h),
              Center(
                child: Image.asset(
                  Assets.images.notFount.path,
                  width: 240.w,
                  height: 240.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.h),
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
  Widget _buildContactsListUi({List<UserListData>? contactData, bool isLoading = false}) {
    final bool loading = isLoading || contactData == null;
    final int count = loading ? 8 : contactData.length;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: controller.refreshContacts,
      child: Skeletonizer(
        enabled: loading,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 90.h),
          children: [
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
          ],
        ),
      ),
    );
  }
}

/// Standalone Contact Card (Matching Screenshot 1)
class _ContactCard extends StatelessWidget {
  final UserListData user;
  final VoidCallback onTapAudio;
  final VoidCallback onTapVideo;

  const _ContactCard({
    required this.user,
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
