import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../../../gen/assets.gen.dart';
import '../../../routes/app_pages.dart';

class WalkieInviteDialog {
  static bool _isShowing = false;

  static void show({
    required String groupId,
    required String groupName,
    required String speakerName,
    required String speakerImage,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    try {
      FlutterRingtonePlayer().play(
        fromAsset: Assets.music.ringing,
        looping: true,
        volume: 1.0,
        asAlarm: false,
      );
    } catch (_) {}

    Get.generalDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: true,
      barrierLabel: 'WalkieInvite',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
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
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
          )),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
      try {
        FlutterRingtonePlayer().stop();
      } catch (_) {}
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (_isShowing && Get.isDialogOpen == true) {
        Get.back();
      }
    });
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
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAnimatedIcon(),
          SizedBox(width: 14.w),
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
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Group: ${widget.groupName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        color: _lightPurple, size: 14.sp),
                    SizedBox(width: 6.w),
                    Text(
                      "Active Channel",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.close_rounded,
                label: "Reject",
                iconColor: Colors.white,
                bgColor: _btnRejectBg,
                labelColor: Colors.white70,
                onTap: () => Get.back(),
              ),
              SizedBox(width: 16.w),
              _buildActionButton(
                icon: Icons.mic_rounded,
                label: "Accept",
                iconColor: Colors.white,
                isGradient: true,
                labelColor: _lightPurple,
                onTap: () async {
                  Get.back();
                  if (GroupWalkieService.instance.currentGroupId != null) {
                    await GroupWalkieService.instance.leaveGroup();
                  }
                  Get.toNamed(Routes.groupWalkieScreen, arguments: {
                    "groupId": widget.groupId,
                    "groupName": widget.groupName,
                    "speakerName": widget.speakerName,
                    "autoOpened": true,
                  });
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
      width: 64.r,
      height: 64.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final progress = ((_rippleController.value + i * 0.33) % 1.0);
                  final size = 40.r + (progress * 24.r);
                  final opacity = (1 - progress).clamp(0.0, 1.0);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _lightPurple.withOpacity(opacity * 0.6),
                        width: 1.w,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _btnRejectBg,
              border: Border.all(color: _primaryPurple.withOpacity(0.3), width: 1),
            ),
            child: Icon(
              Icons.speaker_phone_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          Positioned(
            right: 4.w,
            bottom: 4.h,
            child: Container(
              width: 14.r,
              height: 14.r,
              decoration: BoxDecoration(
                color: _lightPurple,
                shape: BoxShape.circle,
                border: Border.all(color: _bgDark, width: 2.5),
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
            width: 46.r,
            height: 46.r,
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}