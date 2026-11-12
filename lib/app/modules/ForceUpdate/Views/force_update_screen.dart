import 'dart:io';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Controller/force_update_controller.dart';
import 'package:fgtracker/gen/assets.gen.dart';

class ForceUpdateScreen extends GetView<ForceUpdateController> {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIos = Platform.isIOS;
    final storeName = isIos ? 'Apple App Store' : 'Google Play Store';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Ambient Background Glows
            Positioned(
              top: -100.h,
              right: -80.w,
              child: Container(
                width: 280.w,
                height: 280.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: -60.h,
              left: -60.w,
              child: Container(
                width: 240.w,
                height: 240.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // App Icon with Glowing Update Badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 110.w,
                          height: 110.w,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.r),
                            child: Image.asset(
                              Assets.icons.appIcon.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4.w,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0F172A), width: 3),
                            ),
                            child: Icon(
                              Icons.system_update_rounded,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Title
                    Text(
                      controller.versionData.title.isNotEmpty
                          ? controller.versionData.title
                          : context.l10n.forceUpdate_defaultTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'InterBold',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Explanation Message
                    Text(
                      controller.versionData.message.isNotEmpty
                          ? controller.versionData.message
                          : context.l10n.forceUpdate_fallbackMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'InterRegular',
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Version Comparison Card
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                context.l10n.forceUpdate_currentInstalled,
                                style: TextStyle(
                                  fontFamily: 'InterMedium',
                                  fontSize: 10.sp,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Obx(
                                () => Text(
                                  'v${controller.installedVersion.value}',
                                  style: TextStyle(
                                    fontFamily: 'InterBold',
                                    fontSize: 15.sp,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30.h,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          Column(
                            children: [
                              Text(
                                context.l10n.forceUpdate_requiredVersion,
                                style: TextStyle(
                                  fontFamily: 'InterMedium',
                                  fontSize: 10.sp,
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'v${controller.targetStoreVersion}',
                                style: TextStyle(
                                  fontFamily: 'InterBold',
                                  fontSize: 15.sp,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLaunchingStore.value
                              ? null
                              : () => controller.openStore(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.5),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: controller.isLaunchingStore.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isIos ? Icons.apple : Icons.shop_two_rounded,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          context.l10n.forceUpdate_updateOnStore(storeName),
                                          style: TextStyle(
                                            fontFamily: 'InterBold',
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Helper footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          context.l10n.forceUpdate_footer,
                          style: TextStyle(
                            fontFamily: 'InterRegular',
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
