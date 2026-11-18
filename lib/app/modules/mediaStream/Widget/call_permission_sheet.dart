import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide navigator;
import 'package:fgtracker/l10n/l10n.dart';

import '../../../../gen/fonts.gen.dart';

/// The app's [CallPermissionUi]: one bottom sheet per [CallPermSheet].
class GetCallPermissionUi implements CallPermissionUi {
  const GetCallPermissionUi();

  @override
  Future<CallPermChoice> show(CallPermSheet sheet) async {
    final BuildContext? ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return CallPermChoice.cancel;
    final CallPermChoice? c = await showModalBottomSheet<CallPermChoice>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => CallPermissionSheet(sheet: sheet),
    );
    return c ?? CallPermChoice.cancel;
  }
}

class _SheetText {
  const _SheetText(this.icon, this.title, this.body, this.actions);
  final IconData icon;
  final String title;
  final String body;

  /// First = primary (filled) button.
  final List<MapEntry<CallPermChoice, String>> actions;
}

_SheetText _textFor(CallPermSheet sheet) {
  final l = appL10n;
  switch (sheet) {
    case CallPermSheet.micExplain:
      return _SheetText(Icons.mic_rounded, l.call_permMicTitle,
          l.call_permMicBody, [
        MapEntry(CallPermChoice.allow, l.common_allow),
        MapEntry(CallPermChoice.cancel, l.common_notNow),
      ]);
    case CallPermSheet.micBlocked:
      return _SheetText(Icons.mic_off_rounded, l.call_permMicTitle,
          l.call_permMicBlockedBody, [
        MapEntry(CallPermChoice.openSettings, l.permission_openSettings),
        MapEntry(CallPermChoice.cancel, l.common_cancel),
      ]);
    case CallPermSheet.cameraBlocked:
      return _SheetText(Icons.videocam_off_rounded, l.call_permCameraTitle,
          l.call_permCameraBlockedBody, [
        MapEntry(CallPermChoice.voiceInstead, l.call_permVoiceInstead),
        MapEntry(CallPermChoice.openSettings, l.permission_openSettings),
        MapEntry(CallPermChoice.cancel, l.common_cancel),
      ]);
    case CallPermSheet.cameraMidCall:
      return _SheetText(Icons.videocam_off_rounded, l.call_permCameraTitle,
          l.call_permCameraMidCallBody, [
        MapEntry(CallPermChoice.openSettings, l.permission_openSettings),
        MapEntry(CallPermChoice.cancel, l.common_notNow),
      ]);
    case CallPermSheet.answerReady:
      return _SheetText(Icons.ring_volume_rounded, l.call_permAnswerReadyTitle,
          l.call_permAnswerReadyBody, [
        MapEntry(CallPermChoice.allow, l.common_allow),
        MapEntry(CallPermChoice.cancel, l.common_notNow),
      ]);
  }
}

/// Explains why a call needs a permission and offers the next step.
/// All strings come from the ARB files (doc 02, Phase 2).
class CallPermissionSheet extends StatelessWidget {
  const CallPermissionSheet({super.key, required this.sheet});

  final CallPermSheet sheet;

  static const Color _primary = AppColors.primaryPurple;

  @override
  Widget build(BuildContext context) {
    final _SheetText t = _textFor(sheet);
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 18.h),
            CircleAvatar(
              radius: 28.r,
              backgroundColor: _primary.withValues(alpha: 0.12),
              child: Icon(t.icon, color: _primary, size: 28.r),
            ),
            SizedBox(height: 14.h),
            Text(
              t.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.interSemiBold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              t.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            for (int i = 0; i < t.actions.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 6.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: i == 0
                      ? ElevatedButton(
                          key: ValueKey<String>('call_perm_${t.actions[i].key.name}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(context).pop(t.actions[i].key),
                          child: Text(t.actions[i].value),
                        )
                      : TextButton(
                          key: ValueKey<String>('call_perm_${t.actions[i].key.name}'),
                          onPressed: () =>
                              Navigator.of(context).pop(t.actions[i].key),
                          child: Text(
                            t.actions[i].value,
                            style: const TextStyle(color: _primary),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
