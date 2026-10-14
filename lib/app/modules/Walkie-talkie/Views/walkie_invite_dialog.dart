import 'dart:async';
import 'dart:math' as math;
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import '../Controller/walkieController.dart';
import '../../../routes/app_pages.dart';

class WalkieInviteDialog {
  static void show({
    required String groupId,
    required String groupName,
    required String speakerName,
    required String speakerImage,
    String? title,
    String? subtitle,
    String? location,
    String? alertTime,
    int? joinedCount,
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
              title: title,
              subtitle: subtitle,
              location: location,
              alertTime: alertTime,
              joinedCount: joinedCount,
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black26, // Subtle soft backdrop
      useSafeArea: false,
    );
  }
}

class _BannerInviteWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String speakerName;
  final String speakerImage;
  final String? title;
  final String? subtitle;
  final String? location;
  final String? alertTime;
  final int? joinedCount;

  const _BannerInviteWidget({
    required this.groupId,
    required this.groupName,
    required this.speakerName,
    required this.speakerImage,
    this.title,
    this.subtitle,
    this.location,
    this.alertTime,
    this.joinedCount,
  });

  @override
  State<_BannerInviteWidget> createState() => _BannerInviteWidgetState();
}

class _BannerInviteWidgetState extends State<_BannerInviteWidget>
    with SingleTickerProviderStateMixin {
  Timer? _autoDismissTimer;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto dismiss after 15 seconds if unanswered
    _autoDismissTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && (Get.isDialogOpen ?? false)) {
        Get.back();
      }
    });

    // Play notification tone
    try {
      FlutterRingtonePlayer().playNotification();
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _pulseController.dispose();
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _navigateToWalkie() async {
    // Dismiss banner
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}

    // Leave previous group if connected to a different group
    if (GroupWalkieService.instance.currentGroupId != null &&
        GroupWalkieService.instance.currentGroupId != widget.groupId) {
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
  }

  void _declineInvite() {
    try {
      final myId = GroupWalkieService.instance.selfUserId ??
          Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
      final myName = Global.storageServices.get(PrefConst.userName)?.toString() ?? 'A member';

      // Emit decline events to server so members on WalkieTalkieScreen receive notification
      GroupWalkieService.instance.socket?.emit('decline_walkie_invite', {
        'groupId': widget.groupId,
        'userId': myId,
        'userName': myName,
        'name': myName,
      });
      GroupWalkieService.instance.socket?.emit('walkie_invite_declined', {
        'groupId': widget.groupId,
        'userId': myId,
        'userName': myName,
        'name': myName,
      });
    } catch (_) {}

    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String _getJoinedMemberCountText() {
    if (widget.joinedCount != null && widget.joinedCount! > 0) {
      return "${widget.joinedCount} Joined";
    }
    if (Get.isRegistered<GroupWalkieController>()) {
      final wc = Get.find<GroupWalkieController>();
      if (wc.participants.isNotEmpty) {
        return "${wc.participants.length} Joined";
      }
    }
    return "1 Joined";
  }

  @override
  Widget build(BuildContext context) {
    final displayGroupName = widget.groupName.trim().isNotEmpty
        ? widget.groupName
        : "Field Team";

    final displaySpeakerText = (widget.subtitle != null &&
            widget.subtitle!.trim().isNotEmpty)
        ? widget.subtitle!
        : (widget.speakerName.trim().isNotEmpty
            ? "${widget.speakerName.trim()} is speaking..."
            : "Someone is speaking...");

    final memberCountText = _getJoinedMemberCountText();

    return Dismissible(
      key: const Key('walkie_active_pill_banner'),
      direction: DismissDirection.up,
      onDismissed: (_) {
        _declineInvite();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        padding: EdgeInsets.fromLTRB(10.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF3F5FE),
              Color(0xFFE9ECFE),
            ],
          ),
          borderRadius: BorderRadius.circular(34.r),
          border: Border.all(
            color: const Color(0xFF4C4FE8),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C4FE8).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: 3D Walkie-Talkie Device with Radiating Sound Waves
            _buildWalkieWithWaves(),
            SizedBox(width: 8.w),

            // Middle & Right Content
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: LIVE Tag and Members Badge
                  Row(
                    children: [
                      // Red LIVE Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF334B),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF334B)
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.5.r,
                              height: 5.5.r,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Member Count Indicator
                      if (memberCountText.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: const Color(0xFF656985),
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              memberCountText,
                              style: TextStyle(
                                color: const Color(0xFF656985),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Main Title: Group Name
                  Text(
                    displayGroupName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF141738),
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Subtitle: Who Is Speaking
                  Text(
                    displaySpeakerText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF4C4FE8),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Bottom Action Buttons: Cancel & Accept
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCancelButton(),
                      SizedBox(width: 10.w),
                      _buildAcceptButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkieWithWaves() {
    return SizedBox(
      width: 76.r,
      height: 76.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle soft radial backdrop
          Container(
            width: 66.r,
            height: 66.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFDDE3FF).withValues(alpha: 0.6),
                  const Color(0xFFEBF0FE).withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          // Radiating Sound Waves (Concentric Arcs on Left & Right)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(76.r, 76.r),
                painter: _SoundWavesPainter(
                  animationValue: _pulseAnimation.value,
                ),
              );
            },
          ),

          // 3D Walkie-Talkie Device Graphic
          Transform.rotate(
            angle: -0.06,
            child: Assets.walkieTalkie.walkieDevice.image(
              width: 38.r,
              height: 52.r,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          _declineInvite();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFE2E4F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                size: 15.sp,
                color: const Color(0xFF141738),
              ),
              SizedBox(width: 5.w),
              Text(
                "Cancel",
                style: TextStyle(
                  color: const Color(0xFF141738),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: _navigateToWalkie,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF635BFF), Color(0xFF4C3BF4)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C3BF4).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 17.sp,
                color: Colors.white,
              ),
              SizedBox(width: 5.w),
              Text(
                "Accept",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the radiating curved blue sound wave arcs on left and right sides
class _SoundWavesPainter extends CustomPainter {
  final double animationValue;

  _SoundWavesPainter({this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paintInner = Paint()
      ..color =
          const Color(0xFF4C4FE8).withValues(alpha: 0.85 * animationValue)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintOuter = Paint()
      ..color =
          const Color(0xFF4C4FE8).withValues(alpha: 0.50 * animationValue)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rInner = 24.r;
    final rOuter = 33.r;

    // Right Waves: Concentric arcs curving outward to the right
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: rInner),
      -0.65,
      1.30,
      false,
      paintInner,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: rOuter),
      -0.60,
      1.20,
      false,
      paintOuter,
    );

    // Left Waves: Concentric arcs curving outward to the left
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: rInner),
      math.pi - 0.65,
      1.30,
      false,
      paintInner,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: rOuter),
      math.pi - 0.60,
      1.20,
      false,
      paintOuter,
    );
  }

  @override
  bool shouldRepaint(covariant _SoundWavesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}