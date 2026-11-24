import 'dart:io';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
export '../Controller/force_update_controller.dart' show UpdateType;
import '../Controller/force_update_controller.dart';

class ForceUpdateScreen extends StatelessWidget {
  final UpdateType? updateType;
  const ForceUpdateScreen({super.key, this.updateType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForceUpdateController>();
    if (updateType != null) {
      controller.setUpdateType(updateType!);
    }

    final isIos = Platform.isIOS;
    final storeName = isIos ? 'Apple App Store' : 'Google Play Store';

    return Obx(() {
      final isShorebird = controller.isShorebird;

      return PopScope(
        canPop: isShorebird,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
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

              // Back button for Shorebird / In-App Update mode
              if (isShorebird)
                Positioned(
                  top: 10.h,
                  left: 14.w,
                  child: SafeArea(
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(50.r),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
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
                                color: _getBadgeColor(controller, isShorebird),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0F172A), width: 3),
                              ),
                              child: Icon(
                                _getBadgeIcon(controller, isShorebird),
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
                        _getTitle(context, controller, isShorebird),
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
                        _getMessage(context, controller, isShorebird),
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
                                  isShorebird
                                      ? 'INSTALLED VERSION'
                                      : context.l10n.forceUpdate_currentInstalled,
                                  style: TextStyle(
                                    fontFamily: 'InterMedium',
                                    fontSize: 10.sp,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'v${controller.installedVersion.value}',
                                  style: TextStyle(
                                    fontFamily: 'InterBold',
                                    fontSize: 15.sp,
                                    color: const Color(0xFFE2E8F0),
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
                                  isShorebird
                                      ? 'PATCH STATUS'
                                      : context.l10n.forceUpdate_requiredVersion,
                                  style: TextStyle(
                                    fontFamily: 'InterMedium',
                                    fontSize: 10.sp,
                                    color: _getRightCardColor(controller, isShorebird),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _getRightCardValue(controller, isShorebird),
                                  style: TextStyle(
                                    fontFamily: 'InterBold',
                                    fontSize: 15.sp,
                                    color: _getRightCardColor(controller, isShorebird),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Linear progress bar for Shorebird downloading
                      if (isShorebird && controller.isDownloadingShorebird.value) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: controller.shorebirdProgress.value / 100,
                            backgroundColor: const Color(0xFF1E293B),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                            minHeight: 6.h,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // Update Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: _getButtonAction(controller, isShorebird),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 8,
                            shadowColor: _getGradientColors(controller, isShorebird).first.withValues(alpha: 0.5),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getGradientColors(controller, isShorebird),
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _getButtonContent(context, controller, isShorebird, isIos, storeName),
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
                            isShorebird ? Icons.bolt_rounded : Icons.lock_outline_rounded,
                            size: 13.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isShorebird
                                ? "Instant Over-The-Air update powered by Shorebird"
                                : context.l10n.forceUpdate_footer,
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
    });
  }

  Color _getBadgeColor(ForceUpdateController controller, bool isShorebird) {
    if (!isShorebird) return const Color(0xFF10B981);
    if (controller.isRestartRequired.value) return const Color(0xFFF59E0B);
    if (controller.isDownloadingShorebird.value) return const Color(0xFF06B6D4);
    if (controller.isUpToDate.value) return const Color(0xFF10B981);
    return const Color(0xFF4F46E5);
  }

  IconData _getBadgeIcon(ForceUpdateController controller, bool isShorebird) {
    if (!isShorebird) return Icons.system_update_rounded;
    if (controller.isRestartRequired.value) return Icons.restart_alt_rounded;
    if (controller.isDownloadingShorebird.value) return Icons.downloading_rounded;
    if (controller.isUpToDate.value) return Icons.check_rounded;
    return Icons.bolt_rounded;
  }

  String _getTitle(BuildContext context, ForceUpdateController controller, bool isShorebird) {
    if (isShorebird) {
      if (controller.isRestartRequired.value) return "Update Ready to Apply";
      if (controller.isDownloadingShorebird.value) return "Downloading Update";
      if (controller.isCheckingShorebird.value) return "Checking for Updates";
      if (controller.isUpToDate.value) return "App is Up to Date";
      return context.l10n.appUpdate_updateApp;
    }
    return controller.versionData.title.isNotEmpty
        ? controller.versionData.title
        : context.l10n.forceUpdate_defaultTitle;
  }

  String _getMessage(BuildContext context, ForceUpdateController controller, bool isShorebird) {
    if (isShorebird) {
      if (controller.isRestartRequired.value) {
        return "A new update has been downloaded and installed. Please restart the app to apply the latest changes.";
      }
      if (controller.isDownloadingShorebird.value) {
        return "Downloading the latest over-the-air patch from Shorebird... please wait.";
      }
      if (controller.isCheckingShorebird.value) {
        return "Connecting to Shorebird servers to check for new patches...";
      }
      if (controller.isUpToDate.value) {
        return "You are currently running the latest version with all recent patches applied.";
      }
      return context.l10n.appUpdate_updateAvailableMessage;
    }
    return controller.versionData.message.isNotEmpty
        ? controller.versionData.message
        : context.l10n.forceUpdate_fallbackMessage;
  }

  Color _getRightCardColor(ForceUpdateController controller, bool isShorebird) {
    if (!isShorebird) return const Color(0xFF10B981);
    if (controller.isRestartRequired.value) return const Color(0xFFF59E0B);
    if (controller.isDownloadingShorebird.value) return const Color(0xFF06B6D4);
    return const Color(0xFF10B981);
  }

  String _getRightCardValue(ForceUpdateController controller, bool isShorebird) {
    if (!isShorebird) return 'v${controller.targetStoreVersion}';
    if (controller.isRestartRequired.value) return 'Pending Restart';
    if (controller.isDownloadingShorebird.value) return '${controller.shorebirdProgress.value.toInt()}%';
    if (controller.currentPatch.value != null) return 'Patch #${controller.currentPatch.value}';
    return controller.isUpToDate.value ? 'Up to Date' : 'Base Release';
  }

  List<Color> _getGradientColors(ForceUpdateController controller, bool isShorebird) {
    if (isShorebird && controller.isRestartRequired.value) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    }
    return [const Color(0xFF4F46E5), const Color(0xFF06B6D4)];
  }

  VoidCallback? _getButtonAction(ForceUpdateController controller, bool isShorebird) {
    if (isShorebird) {
      if (controller.isDownloadingShorebird.value || controller.isCheckingShorebird.value) {
        return null;
      }
      if (controller.isRestartRequired.value) {
        return () => controller.restartApp();
      }
      return () => controller.checkShorebirdUpdate(showToast: true);
    }
    if (controller.isLaunchingStore.value) return null;
    return () => controller.openStore();
  }

  Widget _getButtonContent(
    BuildContext context,
    ForceUpdateController controller,
    bool isShorebird,
    bool isIos,
    String storeName,
  ) {
    if (isShorebird) {
      if (controller.isDownloadingShorebird.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
            SizedBox(width: 10.w),
            Text(
              context.l10n.appUpdate_updatingProgress(controller.shorebirdProgress.value.toInt()),
              style: TextStyle(
                fontFamily: 'InterBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      if (controller.isRestartRequired.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restart_alt_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              context.l10n.appUpdate_restartApp,
              style: TextStyle(
                fontFamily: 'InterBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      if (controller.isCheckingShorebird.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
            SizedBox(width: 10.w),
            Text(
              "Checking for updates...",
              style: TextStyle(
                fontFamily: 'InterBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      if (controller.isUpToDate.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              "Check for Updates",
              style: TextStyle(
                fontFamily: 'InterBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.system_update_rounded, color: Colors.white, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            context.l10n.appUpdate_updateApp,
            style: TextStyle(
              fontFamily: 'InterBold',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    // Force Update Mode
    if (controller.isLaunchingStore.value) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return Row(
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
    );
  }
}
