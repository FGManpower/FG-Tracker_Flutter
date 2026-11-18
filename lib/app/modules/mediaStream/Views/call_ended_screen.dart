import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

/// WhatsApp-like end screen after an unanswered / declined / busy / failed
/// call: name, reason, Call again / Cancel (BUG-CALL-17, doc 02 §7).
class CallEndedScreen extends StatelessWidget {
  const CallEndedScreen({super.key, required this.info});

  final CallEndInfo info;

  static String reasonText(AppLocalizations l, CallEndOutcome o) {
    switch (o) {
      case CallEndOutcome.noAnswer:
        return l.call_endNoAnswer;
      case CallEndOutcome.declined:
        return l.call_endDeclined;
      case CallEndOutcome.busy:
        return l.call_onAnotherCall;
      case CallEndOutcome.unavailable:
        return l.call_endUnavailable;
      case CallEndOutcome.connectionLost:
        return l.call_endConnectionLost;
    }
  }

  void _close() {
    final NavigatorState? nav = Get.key.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  Future<void> _callAgain(BuildContext context) async {
    _close();
    final String me = Global.storageServices.get(PrefConst.userId).toString();
    await CallService().startOutGoingCall(
      context,
      callerId: me,
      remoteUserId: info.remoteUserId,
      is_video: info.isVideo,
      callerName: info.name,
      callerProfile: info.avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String avatar = info.avatar ?? '';
    final bool hasAvatar = avatar.startsWith('http');
    return Scaffold(
      backgroundColor: const Color(0xFF12131F),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            CircleAvatar(
              radius: 48.r,
              backgroundColor: Colors.white12,
              backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
              child: hasAvatar
                  ? null
                  : Icon(Icons.person_rounded, color: Colors.white70, size: 48.r),
            ),
            SizedBox(height: 16.h),
            Text(
              info.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              reasonText(appL10n, info.outcome),
              key: const ValueKey<String>('call_end_reason'),
              style: TextStyle(color: Colors.white70, fontSize: 15.sp),
            ),
            const Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _action(
                  key: const ValueKey<String>('call_end_cancel'),
                  icon: Icons.close_rounded,
                  color: Colors.white24,
                  label: appL10n.common_cancel,
                  onTap: _close,
                ),
                _action(
                  key: const ValueKey<String>('call_end_again'),
                  icon: info.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                  color: const Color(0xFF2BB673),
                  label: appL10n.call_callAgain,
                  onTap: () => _callAgain(context),
                ),
              ],
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required Key key,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            key: key,
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 64.r,
              height: 64.r,
              child: Icon(icon, color: Colors.white, size: 28.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
      ],
    );
  }
}
