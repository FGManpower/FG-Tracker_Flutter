import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/l10n/l10n.dart';

/// Calls tab: "Incoming calls may not ring · Allow" when notifications (or,
/// on Android 14, the full-screen call screen) are not allowed (P-09).
/// Non-blocking: calling works either way. Re-checked when the app comes
/// back (e.g. from Settings).
///
/// Also asks for the microphone once, the first time Calls is opened, if it
/// was never asked (P-10), so a call answered from the lock screen does not
/// wait for a dialog.
class CallRingReadinessBanner extends StatefulWidget {
  const CallRingReadinessBanner({super.key, this.primeMic = true});

  /// Show the one-time microphone sheet (P-10).
  final bool primeMic;

  @override
  State<CallRingReadinessBanner> createState() =>
      _CallRingReadinessBannerState();
}

class _CallRingReadinessBannerState extends State<CallRingReadinessBanner> {
  bool _canRing = true;
  bool _busy = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
    if (widget.primeMic) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await CallPermissionFlow().primeMicOnce();
      });
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final bool ok = await CallPermissionFlow().incomingCallsCanRing();
    if (mounted && ok != _canRing) setState(() => _canRing = ok);
  }

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    final bool ok = await CallPermissionFlow().fixIncomingRinging();
    if (mounted) {
      setState(() {
        _busy = false;
        _canRing = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_canRing) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
      child: Container(
        key: const ValueKey<String>('call_ring_banner'),
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 4.w, 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFFD8A8)),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_rounded,
                color: const Color(0xFFB45309), size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                appL10n.call_permRingBanner,
                style: TextStyle(
                  color: const Color(0xFF7C2D12),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey<String>('call_ring_banner_allow'),
              onPressed: _busy ? null : _allow,
              child: Text(appL10n.common_allow),
            ),
          ],
        ),
      ),
    );
  }
}
