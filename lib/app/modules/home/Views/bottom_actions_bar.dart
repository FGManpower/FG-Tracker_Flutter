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
          bottom: 12.h,
          top: 8.h,
        ),
        color: const Color(0xFFF4F6FC),
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        DialogBox().showQRScanOptions(
          context,
          controller: joinGroupController,
          groupController: groupController,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4DFF), Color(0xFF5338EE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5338EE).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Join Group",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Join existing group",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9.5.sp,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 16.sp,
            ),
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
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF6B4DFF),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B1F70).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
              child: Icon(
                Icons.add_rounded,
                color: const Color(0xFF6B4DFF),
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create Group",
                    style: TextStyle(
                      color: const Color(0xFF6B4DFF),
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Create new group",
                    style: TextStyle(
                      color: const Color(0xFF7E84A3),
                      fontSize: 9.5.sp,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color(0xFF6B4DFF),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
