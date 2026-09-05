import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Data/Services/group_call_service.dart';
import '../../../routes/app_pages.dart';

class CallGroupsTab extends StatelessWidget {
   CallGroupsTab({super.key});

  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F7FD),
      child: Obx(() {
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
        return
          ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:  EdgeInsets.only(bottom: 10.h),
              child: _GroupTile(group: groups[index]),
            );
          },

        );
      }),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final GroupsResData group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE2E0FA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.groups_rounded,
            size: 22.sp,
            color: const Color(0xFF6B4DFF),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            // TODO: Remove after backend group incoming call is integrated
            onLongPress: () {
              Get.toNamed(
                Routes.groupIncomingCallScreen,
                arguments: {
                  "groupId": group.id.toString(),
                  "groupName": group.groupName ?? "Unknown Group",
                  "groupProfile": group.groupProfile,
                  "callerName": "Samad",
                  "activeMemberCount": 10,
                  "totalMemberCount": group.memberCount ?? 25,
                  "isVideo": false,
                  "callId": "test-group-call",
                },
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  group.groupName ?? "No Name Group",
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 3.h),
                reausabletext(
                  "${group.memberCount ?? 0} Members",
                  fontsize: 11.sp,
                  color: const Color(0xFF6B4DFF).withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),

        CallActionChip(
          icon: Icons.videocam_rounded,
          onTap: () {
            GroupCallService.instance.startGroupCall(
              context,
              groupId: group.id.toString(),
              groupName: group.groupName ?? "",
              groupProfile: group.groupProfile,
              memberCount: group.memberCount,
              isVideo: true,
            );
          },
        ),

        SizedBox(width: 7.w),

        CallActionChip(
          icon: Icons.call,
          onTap: () {
            GroupCallService.instance.startGroupCall(
              context,
              groupId: group.id.toString(),
              groupName: group.groupName ?? "",
              groupProfile: group.groupProfile,
              memberCount: group.memberCount,
              isVideo: false,
            );
          },
        ),
      ],
    );
  }
}

class _GroupListSkeleton extends StatelessWidget {
  const _GroupListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
      children: [
        Skeletonizer(
          enabled: true,
          child: Column(
            children: [
              reausabletext(
                "All Groups",
                fontsize: 14.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
              ),
              SizedBox(height: 8.h),
              for (int i = 0; i < 5; i++) ...[
                _GroupSkeletonTile(),
                SizedBox(height: 14.h),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupSkeletonTile extends StatelessWidget {
  const _GroupSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
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
        Icon(Icons.call_rounded, size: 20.sp),
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
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: reausabletext(
          message,
          fontsize: 14.sp,
          color: Colors.grey,
        ),
      ),
    );
  }
}
