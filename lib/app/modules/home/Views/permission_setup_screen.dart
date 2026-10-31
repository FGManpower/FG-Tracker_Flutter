import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Controller/PermissionSetupController.dart';

class PermissionSetupScreen extends GetView<PermissionSetupController> {
  const PermissionSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildList()),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FF),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE4E0FF).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFECEAFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: const Color(0xFF5145F5),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'App Permissions',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF11145A),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Review the permissions required.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.3,
                    color: const Color(0xFF686B9D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      itemCount: controller.items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) =>
          _buildPermissionCard(controller.items[index], index),
    );
  }

  Widget _buildPermissionCard(PermissionItem item, int index) {
    return Obx(() {
      final bool expanded = controller.expandedItems.contains(index);
      final bool selected = controller.selectedIndex.value == index;
      final bool granted = controller.grantedItems.contains(index);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? const Color(0xFF5145F5) : const Color(0xFFECEAFF),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF5145F5).withValues(alpha: 0.12)
                  : const Color(0xFF5145F5).withValues(alpha: 0.035),
              blurRadius: selected ? 16 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () => controller.selectCard(index),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: granted
                              ? const Color(0xFFDCF5E6)
                              : const Color(0xFFECEAFF),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          granted ? Icons.check_rounded : item.icon,
                          color: granted
                              ? const Color(0xFF1BA85F)
                              : const Color(0xFF5145F5),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF11145A),
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                _buildBadge(item, granted),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                height: 1.4,
                                color: const Color(0xFF686B9D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      InkWell(
                        onTap: () => controller.toggleExpanded(index),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF5145F5),
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEBFF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: const Color(0xFF5145F5),
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Why we need this?',
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF5145F5),
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item.why,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    height: 1.5,
                                    color: const Color(0xFF686B9D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                    sizeCurve: Curves.easeInOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBadge(PermissionItem item, bool granted) {
    final String label;
    final Color bg;
    final Color fg;

    if (granted) {
      label = 'Granted';
      bg = const Color(0xFFDCF5E6);
      fg = const Color(0xFF1BA85F);
    } else if (item.required) {
      label = 'Required';
      bg = const Color(0xFFFFE5EC);
      fg = const Color(0xFFD52E58);
    } else {
      label = 'Optional';
      bg = const Color(0xFFECEAFF);
      fg = const Color(0xFF7778A5);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FF),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE4E0FF).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Obx(() {
        final idx = controller.selectedIndex.value;
        final item = controller.items[idx];
        final granted = controller.grantedItems.contains(idx);
        final isRequired = item.required;

        final locationGranted = controller.grantedItems.contains(0);

        final String primaryLabel =
            granted ? 'Continue' : 'Allow ${item.title}';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: controller.loading.value
                    ? null
                    : controller.allowCurrentPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5145F5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: controller.loading.value
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        primaryLabel,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
            if (!isRequired && !granted && locationGranted) ...[
              SizedBox(height: 4.h),
              TextButton(
                onPressed: controller.loading.value
                    ? null
                    : controller.skipAllRemaining,
                child: Text(
                  'Skip All',
                  style: TextStyle(
                    color: const Color(0xFF686B9D),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
