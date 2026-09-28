import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import '../../../routes/app_pages.dart';

class WalkieInviteDialog {
  static void show({
    required String groupId,
    required String groupName,
    required String speakerName,
    required String speakerImage,
  }) {
    if (WalkieLaunchTracker.fromWalkieCall) return;

    // Dismiss any existing open dialog to prevent stacking
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: _BannerInviteWidget(
              groupId: groupId,
              groupName: groupName,
              speakerName: speakerName,
              speakerImage: speakerImage,
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black26, // Gentle dark overlay behind top banner
      useSafeArea: false,
    );
  }
}

class _BannerInviteWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String speakerName;
  final String speakerImage;

  const _BannerInviteWidget({
    required this.groupId,
    required this.groupName,
    required this.speakerName,
    required this.speakerImage,
  });

  @override
  State<_BannerInviteWidget> createState() => _BannerInviteWidgetState();
}

class _BannerInviteWidgetState extends State<_BannerInviteWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleController;

  final Color _bgDark = const Color(0xFF131524);
  final Color _primaryPurple = const Color(0xFF6B4EFF);
  final Color _lightPurple = const Color(0xFF8C73FF);
  final Color _btnRejectBg = const Color(0xFF26293C);

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Play notification sound on incoming walkie talkie invite
    try {
      FlutterRingtonePlayer().playNotification();
    } catch (_) {}
  }

  @override
  void dispose() {
    _rippleController.dispose();
    // Stop sound when banner is closed or accepted
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAnimatedIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WALKIE-TALKIE",
                  style: TextStyle(
                    color: _lightPurple,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${widget.speakerName} is talking",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Group: ${widget.groupName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: _lightPurple,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Active Channel",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.close_rounded,
                label: "Reject",
                iconColor: Colors.white,
                bgColor: _btnRejectBg,
                labelColor: Colors.white70,
                onTap: () {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                },
              ),
              SizedBox(width: 12.w),
              _buildActionButton(
                icon: Icons.mic_rounded,
                label: "Accept",
                iconColor: Colors.white,
                isGradient: true,
                labelColor: _lightPurple,
                onTap: () async {
                  // Dismiss banner
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }

                  // Leave previous group if connected
                  if (GroupWalkieService.instance.currentGroupId != null) {
                    await GroupWalkieService.instance.leaveGroup();
                  }

                  // Navigate to Group Walkie Screen
                  Get.toNamed(
                    Routes.groupWalkieScreen,
                    arguments: {
                      "groupId": widget.groupId,
                      "groupName": widget.groupName,
                      "speakerName": widget.speakerName,
                      "speakerImage": widget.speakerImage,
                      "autoOpened": true,
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return SizedBox(
      width: 56.r,
      height: 56.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final progress =
                  ((_rippleController.value + i * 0.33) % 1.0);
                  final size = 36.r + (progress * 20.r);
                  final opacity = (1 - progress).clamp(0.0, 1.0);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _lightPurple.withValues(alpha: opacity * 0.6),
                        width: 1.w,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Container(
            width: 40.r,
            height: 40.r,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _btnRejectBg,
              border: Border.all(
                color: _primaryPurple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Assets.walkieTalkie.walkieDevice.image(
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 2.w,
            bottom: 2.h,
            child: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: _lightPurple,
                shape: BoxShape.circle,
                border: Border.all(color: _bgDark, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color labelColor,
    Color? bgColor,
    bool isGradient = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGradient ? null : bgColor,
              gradient: isGradient
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              )
                  : null,
              boxShadow: isGradient
                  ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}