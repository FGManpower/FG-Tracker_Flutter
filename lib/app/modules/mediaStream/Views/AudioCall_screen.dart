import 'dart:math' as math;

import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Centre of the 1:1 audio call screen: avatar, name, status / timer.
///
/// * Calling / ringing (light background): pulsing rings + voice wave.
/// * Connected (purple background): still avatar, white text, timer.
class AudiocallScreen extends StatelessWidget {
  const AudiocallScreen({super.key, required this.controller});

  final CallingController controller;

  @override
  Widget build(BuildContext context) {
    final CallingController c = controller;
    return Obx(() {
      final bool connected = isCallConnected(c);
      final String status = c.callStatus.value;
      final bool reconnecting =
          status.toLowerCase().startsWith('reconnecting');
      final String name = (c.args["callerName"] ?? "").toString();

      final Color nameColor = connected ? Colors.white : CallColors.name;
      final Color statusColor = reconnecting
          ? const Color(0xFFFFB020)
          : (connected
              ? Colors.white.withOpacity(0.80)
              : CallColors.primary);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 300.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CallPulseAvatar(
                    name: name,
                    image: c.args['profileImage'],
                    animate: !connected,
                    onDark: connected,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: nameColor,
                      fontSize: 28.sp,
                      fontFamily: FontFamily.interSemiBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    connected && !reconnecting
                        ? formatCallDuration(c.callDurationRx.value)
                        : '${callStatusLabel(context.l10n, status)}…',
                    key: const ValueKey<String>('call_status_text'),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interMedium,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    height: 48.h,
                    child: connected
                        ? null
                        : const _VoiceWave(color: CallColors.primaryLight),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// True once the call is connected (the timer runs).
bool isCallConnected(CallingController c) =>
    c.callTimer != null || c.callDurationRx.value > 0;

/// Avatar with soft halo rings. The rings pulse while [animate] (calling /
/// ringing) and stand still once connected.
class CallPulseAvatar extends StatefulWidget {
  const CallPulseAvatar({
    super.key,
    required this.name,
    required this.image,
    this.animate = true,
    this.onDark = false,
    this.avatarSize = 124,
    this.accent,
  });

  final String name;
  final Object? image;
  final bool animate;

  /// Rings in white (purple / video background) instead of purple.
  final bool onDark;
  final double avatarSize;

  /// Colour of the rings and the avatar outline (green on incoming audio).
  final Color? accent;

  @override
  State<CallPulseAvatar> createState() => _CallPulseAvatarState();
}

class _CallPulseAvatarState extends State<CallPulseAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _anim.repeat();
  }

  @override
  void didUpdateWidget(CallPulseAvatar old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_anim.isAnimating) {
      _anim.repeat();
    } else if (!widget.animate && _anim.isAnimating) {
      _anim.stop();
      _anim.value = 0.5;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double avatar = widget.avatarSize.r;
    final double box = avatar * 2.0;
    final Color ring =
        widget.accent ?? (widget.onDark ? Colors.white : CallColors.primaryLight);

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      _ring(avatar, box, ring, (_anim.value + i / 3) % 1.0),
                  ],
                );
              },
            ),
          ),
          CallAvatar(
            name: widget.name,
            image: widget.image,
            size: avatar,
            ringColor: widget.accent ?? Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _ring(double avatar, double box, Color color, double t) {
    // Each ring grows from the avatar to the box edge and fades out.
    final double size = avatar + (box - avatar) * t;
    final double opacity = (1 - t) * (widget.onDark ? 0.22 : 0.20);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity * 0.6),
        border: Border.all(color: color.withOpacity(opacity), width: 1.2),
      ),
    );
  }
}

/// Decorative voice wave shown while the call is ringing.
class _VoiceWave extends StatefulWidget {
  const _VoiceWave({required this.color});

  final Color color;

  @override
  State<_VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<_VoiceWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  static const List<double> _base = [10, 18, 28, 38, 46, 38, 28, 18, 10];

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_base.length, (i) {
              final double wave =
                  (math.sin(_anim.value * math.pi * 2 + i * 0.6) + 1) / 2;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: 4.w,
                height: (_base[i] * (0.55 + wave * 0.45)).h,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.45 + wave * 0.45),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
