import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieBottomActions extends StatelessWidget {
  final GroupWalkieController? controller;
  final VoidCallback onAudioRouteTap;
  final VoidCallback onChatTap;

  const WalkieBottomActions({
    super.key,
    this.controller,
    required this.onAudioRouteTap,
    required this.onChatTap,
  });

  static const Color _cardWhite = Colors.white;
  static const Color _primaryPurple = Color(0xFF5A35FF);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textSecondary = Color(0xFF8E8EA8);

  GroupWalkieController get _effectiveController =>
      controller ?? Get.find<GroupWalkieController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: onAudioRouteTap,
              child: Obx(() {
                final route = _effectiveController.audioRoute.value;
                final label = _effectiveController.audioRouteLabel;
                final icon = _effectiveController.audioRouteIcon;
                final isSpeaker = route == WalkieAudioRoute.speaker;
                final isBluetooth = route == WalkieAudioRoute.bluetooth;

                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h.clamp(10.0, 16.0),
                    horizontal: 10.w.clamp(6.0, 14.0),
                  ),
                  decoration: BoxDecoration(
                    color: isSpeaker || isBluetooth
                        ? const Color(0xFFF3F0FF)
                        : _cardWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSpeaker || isBluetooth
                          ? _primaryPurple.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isSpeaker || isBluetooth
                            ? _primaryPurple
                            : _textSecondary,
                        size: 20.sp.clamp(18.0, 24.0),
                      ),
                      SizedBox(width: 8.w.clamp(6.0, 10.0)),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSpeaker || isBluetooth
                                ? _primaryPurple
                                : _textDark,
                            fontSize: 13.sp.clamp(11.5, 14.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: isSpeaker || isBluetooth
                            ? _primaryPurple
                            : _textSecondary,
                        size: 20.sp.clamp(18.0, 22.0),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(width: 12.w.clamp(8.0, 16.0)),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: onChatTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h.clamp(10.0, 16.0),
                  horizontal: 8.w.clamp(6.0, 12.0),
                ),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: _primaryPurple,
                      size: 20.sp.clamp(18.0, 24.0),
                    ),
                    SizedBox(width: 8.w.clamp(6.0, 10.0)),
                    Text(
                      "Chat",
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 13.sp.clamp(11.5, 14.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}