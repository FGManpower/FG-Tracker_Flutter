import 'package:fgtracker/app/Core/constant/BottomSheet/bottom_actions_bar.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/JoinGroup_Controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomActionsBar extends StatelessWidget {
  const BottomActionsBar({
    super.key,
    required this.groupController,
    required this.joinGroupController,
  });

  final GroupController groupController;
  final JoinGroupController joinGroupController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 15.h,
          top: 10.h,
        ),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: _JoinGroupButton(
                joinGroupController: joinGroupController,
                groupController: groupController,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _CreateGroupButton(groupController: groupController),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinGroupButton extends StatelessWidget {
  const _JoinGroupButton({
    required this.joinGroupController,
    required this.groupController,
  });

  final JoinGroupController joinGroupController;
  final GroupController groupController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DialogBox().showQRScanOptions(
          context,
          controller: joinGroupController,
          groupController: groupController,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 7.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B78FF), Color(0xFF5A3FFF)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.group_add, color: Colors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  reausabletext(
                    "Join Group",
                    color: Colors.white,
                    fontsize: 13.sp,
                    fontfamily: FontFamily.interBold,
                  ),
                  reausabletext(
                    "Join existing group",
                    color: Colors.white70,
                    fontsize: 9.sp,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

class _CreateGroupButton extends StatelessWidget {
  const _CreateGroupButton({required this.groupController});

  final GroupController groupController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        try {
          groupController.groupName.clear();
          groupController.groupDesc.clear();
        } catch (e) {
          debugPrint("Clear error: $e");
        }
        showCreateGroupSheet();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 7.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF6B4DFF), width: 1.5.w),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B4DFF),
                  width: 1.5.w,
                ),
              ),
              child:
                  Icon(Icons.add, color: const Color(0xFF6B4DFF), size: 16.sp),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  reausabletext(
                    "Create Group",
                    color: const Color(0xFF6B4DFF),
                    fontsize: 13.sp,
                    fontfamily: FontFamily.interBold,
                  ),
                  reausabletext(
                    "Create new group",
                    color: Colors.grey,
                    fontsize: 9.sp,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF6B4DFF),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
