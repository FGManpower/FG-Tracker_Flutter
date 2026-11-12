import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Data/Services/PermissionGate/permission_flow.dart';
import '../../Data/Services/PermissionGate/permission_gate_models.dart';
import 'permission_gate_controller.dart';

class PermissionGateScreen extends GetView<PermissionGateController> {
  const PermissionGateScreen({super.key});

  static const Color _bg = Color(0xFFF5F4FF);
  static const Color _brand = Color(0xFF5145F5);
  static const Color _navy = Color(0xFF11145A);
  static const Color _grey = Color(0xFF686B9D);
  static const Color _green = Color(0xFF1BA85F);

  @override
  Widget build(BuildContext context) {
    // Back button / gesture can never leave this screen.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Obx(() {
            final r = controller.gate.result.value;
            if (r == null) {
              return const Center(
                child: CircularProgressIndicator(color: _brand),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 16.h),
                    children: [
                      _header(),
                      SizedBox(height: 24.h),
                      if (r.hasError) _errorCard() else ...[
                        _locationCard(r),
                        SizedBox(height: 12.h),
                        _notificationCard(r),
                      ],
                    ],
                  ),
                ),
                _bottom(r),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: _brand.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.verified_user_rounded, color: _brand, size: 34.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          appL10n.permission_gateTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          appL10n.permission_gateSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, height: 1.45, color: _grey),
        ),
      ],
    );
  }

  Widget _locationCard(PermissionGateResult r) {
    final step = r.locationStep;
    return _card(
      key: const Key('gate-location-card'),
      icon: Icons.location_on_rounded,
      title: appL10n.permission_location,
      reason: PermissionReasons.location,
      required: controller.locationRequired,
      ok: step == LocationStep.done,
      status: PermissionFlow.locationStatusText(step),
      actionLabel: PermissionFlow.locationActionLabel(step),
      onAction: controller.fixLocation,
    );
  }

  Widget _notificationCard(PermissionGateResult r) {
    final step = r.notificationStep;
    return _card(
      key: const Key('gate-notification-card'),
      icon: Icons.notifications_rounded,
      title: appL10n.permission_pushNotifications,
      reason: PermissionReasons.notification,
      required: controller.notificationRequired,
      ok: step == NotificationStep.done,
      status: PermissionFlow.notificationStatusText(step),
      actionLabel: PermissionFlow.notificationActionLabel(step),
      onAction: controller.fixNotification,
    );
  }

  Widget _card({
    required Key key,
    required IconData icon,
    required String title,
    required String reason,
    required bool required,
    required bool ok,
    required String status,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    return Container(
      key: key,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: ok ? const Color(0xFFBFE9D0) : const Color(0xFFECEAFF),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: ok ? const Color(0xFFDCF5E6) : const Color(0xFFECEAFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  ok ? Icons.check_rounded : icon,
                  color: ok ? _green : _brand,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ),
              _badge(ok: ok, required: required),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            reason,
            style: TextStyle(fontSize: 12.sp, height: 1.4, color: _grey),
          ),
          SizedBox(height: 6.h),
          Text(
            status,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: ok ? _green : const Color(0xFFD52E58),
            ),
          ),
          if (!ok) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: controller.busy.value ? null : onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: AutoFitText(
                  actionLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge({required bool ok, required bool required}) {
    final String label;
    final Color bg;
    final Color fg;
    if (ok) {
      label = appL10n.permission_badgeGranted;
      bg = const Color(0xFFDCF5E6);
      fg = _green;
    } else if (required) {
      label = appL10n.permission_badgeRequired;
      bg = const Color(0xFFFFE5EC);
      fg = const Color(0xFFD52E58);
    } else {
      label = appL10n.permission_badgeRecommended;
      bg = const Color(0xFFFFF3DC);
      fg = const Color(0xFFB7791F);
    }
    return Container(
      constraints: BoxConstraints(maxWidth: 110.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AutoFitText(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              color: const Color(0xFFD52E58), size: 32.sp),
          SizedBox(height: 10.h),
          Text(
            appL10n.permission_gateCheckFailed,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, height: 1.4, color: _grey),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: controller.busy.value ? null : controller.retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: AutoFitText(appL10n.common_retry,
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottom(PermissionGateResult r) {
    final blockedInSettings =
        r.status == PermissionGateStatus.permanentlyDenied;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (blockedInSettings)
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: controller.busy.value ? null : controller.openSettings,
                icon: const Icon(Icons.settings_rounded),
                label: Text(appL10n.permission_openSettings),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brand,
                  side: BorderSide(color: _brand.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          if (r.allowsAccess) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: controller.continueToApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                ),
                child: Text(appL10n.common_continue),
              ),
            ),
          ],
          TextButton.icon(
            onPressed: controller.busy.value ? null : controller.logout,
            icon: Icon(Icons.logout_rounded, size: 18.sp, color: _grey),
            label: Text(
              appL10n.permission_logout,
              style: TextStyle(
                color: _grey,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
