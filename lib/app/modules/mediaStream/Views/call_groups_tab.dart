import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../routes/app_pages.dart';

class CallGroupsTab extends StatelessWidget {
  CallGroupsTab({super.key});

  final CallController controller = CallController.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.groupsError.isNotEmpty) {
        return LostinternetConnection(
          retry: controller.loadGroups,
          messgae: controller.groupsError,
        );
      }
      if (controller.isGroupsLoading) {
        return const _GroupListSkeleton();
      }
      final List<GroupsResData> groups = controller.filteredGroups;
      if (groups.isEmpty) {
        return _EmptyState(
          message:
              controller.groups.isEmpty ? "No groups yet" : "No groups found",
        );
      }
      return RefreshIndicator(
        color: const Color(0xFF4818F0),
        onRefresh: () async => controller.loadGroups(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
          children: [
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
                  for (int index = 0; index < groups.length; index++) ...[
                    if (index > 0)
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
                      child: _GroupTile(group: groups[index]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

Future<void> _initiateGroupCall({
  required dynamic group,
  required bool isVideo,
}) async {
  try {
    Get.toNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": group.id.toString(),
        "groupName": group.groupName ?? "Unknown Group",
        "groupProfile": group.groupProfile,
        "isVideo": isVideo,
        "memberCount": group.memberCount ?? 0,
        "callType": "outgoing",
      },
    );
  } catch (e) {
    debugPrint("Error initiating group call: $e");
    Get.snackbar(
      "Error",
      "Could not start group call. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final GroupsResData group;

  @override
  Widget build(BuildContext context) {
    final String groupName = group.groupName ?? "No Name Group";
    final int memberCount = group.memberCount ?? 0;

    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F0FE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.groups_rounded,
            size: 20.sp,
            color: const Color(0xFF4818F0),
          ),
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
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "$memberCount Members",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B4DFF),
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CallActionChip(
          icon: Icons.videocam_rounded,
          onTap: () => _initiateGroupCall(
            group: group,
            isVideo: true,
          ),
        ),
        SizedBox(width: 8.w),
        CallActionChip(
          icon: Icons.call_rounded,
          onTap: () => _initiateGroupCall(
            group: group,
            isVideo: false,
          ),
        ),
      ],
    );
  }
}

class _GroupListSkeleton extends StatelessWidget {
  const _GroupListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  const _GroupSkeletonTile(),
                  if (i < 4) SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSkeletonTile extends StatelessWidget {
  const _GroupSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 21.r, backgroundColor: Colors.grey.shade200),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Group name placeholder",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interSemiBold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Members placeholder",
                style: TextStyle(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        const CallActionChip(icon: Icons.videocam_rounded),
        SizedBox(width: 8.w),
        const CallActionChip(icon: Icons.call_rounded),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
            fontFamily: FontFamily.interRegular,
          ),
        ),
      ),
    );
  }
}
