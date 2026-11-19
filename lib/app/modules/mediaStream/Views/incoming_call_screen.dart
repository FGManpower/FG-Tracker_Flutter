import 'dart:ui';

import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Controller/incoming_call_controller.dart';

/// In-app incoming 1:1 call (mock "Audio · 3 Incoming" / "Video · 3
/// Incoming"): app + call type label, pulsing avatar, name, and two round
/// buttons, Decline (red) and Accept (green).
class IncomingCallScreen extends GetView<IncomingCallController> {
  const IncomingCallScreen({super.key});

  static const Color _green = CallColors.accept;
  static const Color _videoBgTop = Color(0xFF26222F);
  static const Color _videoBgBottom = CallColors.videoBg;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IncomingCallController>(
      builder: (_) {
        final bool isVideo = controller.call.isVideo;
        final String name = controller.call.callerName;
        final Object? image = controller.call.callerProfileImage;
        const Color fg = Colors.white;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  _videoBg(image)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: CallColors.audioIncoming,
                      ),
                    ),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 36.h),
                      Text(
                        isVideo
                            ? context.l10n.call_videoCallBrand
                            : context.l10n.call_audioCallBrand,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontSize: 12.sp,
                          letterSpacing: 1.4,
                          fontFamily: FontFamily.interSemiBold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
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
                                    image: image,
                                    onDark: true,
                                    accent: isVideo ? null : _green,
                                    avatarSize: 120,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: fg,
                                      fontSize: 28.sp,
                                      fontFamily: FontFamily.interSemiBold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    isVideo
                                        ? context.l10n.call_isVideoCallingYou
                                        : context.l10n.call_isCallingYou,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: fg.withOpacity(0.65),
                                      fontSize: 14.sp,
                                      fontFamily: FontFamily.interMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _AnswerButtons(
                        isVideo: isVideo,
                        textColor: fg,
                        onDecline: controller.rejectCall,
                        onAccept: controller.acceptCall,
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dark background; the caller's photo blurred behind it when there is one.
  Widget _videoBg(Object? image) {
    final String? url = CallAvatar.resolveUrl(image);
    const Widget plain = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_videoBgTop, _videoBgBottom],
        ),
      ),
    );
    if (url == null) return plain;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => plain,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.black.withOpacity(0.55)),
        ),
      ],
    );
  }
}

/// Decline / Accept. Only the first tap counts, so a double tap can't
/// both accept and decline, or accept twice.
class _AnswerButtons extends StatefulWidget {
  const _AnswerButtons({
    required this.isVideo,
    required this.textColor,
    required this.onDecline,
    required this.onAccept,
  });

  final bool isVideo;
  final Color textColor;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  State<_AnswerButtons> createState() => _AnswerButtonsState();
}

class _AnswerButtonsState extends State<_AnswerButtons> {
  bool _done = false;

  void _once(VoidCallback action) {
    if (_done) return;
    setState(() => _done = true);
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _button(
            key: const ValueKey<String>('incoming_decline'),
            icon: Icons.call_end_rounded,
            color: CallColors.end,
            label: context.l10n.call_decline,
            onTap: () => _once(widget.onDecline),
          ),
          _button(
            key: const ValueKey<String>('incoming_accept'),
            icon: widget.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
            color: IncomingCallScreen._green,
            label: context.l10n.call_accept,
            onTap: () => _once(widget.onAccept),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required Key key,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: key,
                onTap: _done ? null : onTap,
                splashColor: Colors.white24,
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 32.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 90.w),
            child: AutoFitText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
