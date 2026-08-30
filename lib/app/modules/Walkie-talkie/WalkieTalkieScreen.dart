import 'dart:async';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Core/constant/const_res.dart';
import '../../Core/constant/notification_holder.dart';

class GroupWalkieScreen extends StatefulWidget {
  const GroupWalkieScreen({super.key});

  @override
  State<GroupWalkieScreen> createState() => _GroupWalkieScreenState();
}

class _GroupWalkieScreenState extends State<GroupWalkieScreen>
    with TickerProviderStateMixin {
  final controller = Get.put(GroupWalkieController());
  Map<String, dynamic>? args;

  late final AnimationController _rippleController;
  late final AnimationController _pulseController;
  late final AnimationController _lockHintController;

  static const double _lockThreshold = 80.0;
  bool _hasLeft = false;

  final Color _bgLight = const Color(0xFFF5F5F8);
  final Color _cardWhite = Colors.white;
  final Color _primaryPurple = const Color(0xFF6B4EFF);
  final Color _lightPurple = const Color(0xFF8C73FF);
  final Color _softPurple = const Color(0xFFEDE9FE);
  final Color _activeGreen = const Color(0xFF22C55E);
  final Color _mutedRed = const Color(0xFFEF4444);
  final Color _textDark = const Color(0xFF1A1A2E);
  final Color _textSecondary = const Color(0xFF6B7280);

  // Reactive listeners to stop CPU battery drain
  late final Worker _rippleWorker;
  late final Worker _pulseWorker;

  @override
  void initState() {
    super.initState();
    WalkieLaunchTracker.fromWalkieCall = true;

    // Safe extraction of Get.arguments to prevent casting crash (Bug C4)
    if (Get.arguments is Map<String, dynamic>) {
      args = Get.arguments as Map<String, dynamic>;
    }

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    _lockHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final groupId = args?['groupId']?.toString() ?? '';
    if (groupId.isNotEmpty) {
      controller.setCurrentGroup(groupId);
      GroupWalkieService.instance.joinGroup(groupId);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar("Error", "Invalid Group Information",
            snackPosition: SnackPosition.BOTTOM);
      });
    }

    // Dynamic animation control to save battery (Bug M4)
    _rippleWorker =
        everAll([controller.activeSpeakerId, controller.audioState], (_) {
      if (controller.isTalking || controller.hasActiveSpeaker) {
        if (!_rippleController.isAnimating) {
          _rippleController.repeat();
        }
      } else {
        _rippleController.stop();
        _rippleController.reset();
      }
    });

    _pulseWorker = ever(controller.isPressed, (bool pressed) {
      if (pressed && !controller.isSelfLocked.value) {
        _pulseController.repeat(reverse: true);
      } else if (!pressed) {
        _pulseController.stop();
        _pulseController.animateTo(1.0,
            duration: const Duration(milliseconds: 150));
      }
    });
  }

  @override
  void dispose() {
    _rippleWorker.dispose();
    _pulseWorker.dispose();
    _rippleController.dispose();
    _pulseController.dispose();
    _lockHintController.dispose();
    WalkieLaunchTracker.fromWalkieCall = false;
    _safeLeave();
    super.dispose();
  }

  // Prevents Double emit on fast navigation teardown (Bug C2)
  Future<void> _safeLeave() async {
    if (_hasLeft) return;
    _hasLeft = true;
    _rippleController.stop();
    _pulseController.stop();
    _lockHintController.stop();
    await GroupWalkieService.instance.leaveGroup();
    controller.reset();
  }

  Future<void> _startTalking() async {
    if (controller.isChannelLocked.value) return;

    if (controller.isMuted.value) {
      HapticFeedback.heavyImpact();
      controller.showMutedMessage();
      return;
    }

    final selfId = GroupWalkieService.instance.selfUserId;
    if (controller.activeSpeakerId.value.isNotEmpty &&
        controller.activeSpeakerId.value != selfId) {
      HapticFeedback.heavyImpact();
      controller.showBusyMessage(controller.activeSpeakerName.value);
      return;
    }

    controller.setPressed(true);
    _lockHintController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    final ok = await GroupWalkieService.instance.startTalking();
    if (!ok) {
      _stopTalking();
    }
  }
  Future<void> _stopTalking() async {
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    controller.resetSelfLock();

    // Service automatically coordinates UI and resets mic state safely (Bug M2)
    await GroupWalkieService.instance.stopTalking();
  }

  Future<void> _onPTTPressed() async {
    if (controller.isPressed.value) return;
    await _startTalking();
  }

  Future<void> _onPTTReleased() async {
    if (!controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;
    await _stopTalking();
  }

  Future<void> _unlockAndStop() async {
    controller.resetSelfLock();
    await _stopTalking();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;

    double newOffset = controller.dragOffset.value + -details.delta.dy;
    if (newOffset < 0) newOffset = 0;
    controller.setDragOffset(newOffset);

    if (newOffset >= _lockThreshold) {
      _lockPTT();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    controller.setDragOffset(0.0);
  }

  Future<void> _lockPTT() async {
    if (controller.isSelfLocked.value) return;
    HapticFeedback.heavyImpact();
    controller.toggleSelfLock(true);
    controller.setDragOffset(0.0);
    _pulseController.stop();
    _pulseController.animateTo(1.0,
        duration: const Duration(milliseconds: 150));
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Hardware/System Pop handling (Bug m5)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _safeLeave();
        if (mounted) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: _bgLight,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          _buildGroupInfoCard(),
                          SizedBox(height: 24.h),
                          _buildPTTSection(),
                          SizedBox(height: 20.h),
                          _buildMuteMeCard(),
                          SizedBox(height: 12.h),
                          _buildBottomActions(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            onTap: () async {
              await _safeLeave();
              Get.back();
            },
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Walkie Talkie",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Group Communication",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: PopupMenuButton<String>(
              icon:
                  Icon(Icons.more_vert_rounded, color: _textDark, size: 22.sp),
              color: _cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'mute-group':
                    // Single entry toggle prevents double call desync (Bug M1)
                    await GroupWalkieService.instance.toggleMute();
                    break;
                  case 'exit':
                    _showExitDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                _menuItem('mute-group', Icons.volume_mute, 'Mute Group'),
                _menuItem('exit', Icons.logout_rounded, 'Exit Walkie',
                    color: _mutedRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: _textDark, size: 22.sp),
        onPressed: onTap,
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color ?? _textDark, size: 18.sp),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              color: color ?? _textDark,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: _primaryPurple,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: Colors.white, size: 26.sp),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: _activeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args?['groupName'] ?? 'Site Operations Team',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          "${controller.totalParticipants.value} Members Online",
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 12.sp,
                          ),
                        )),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.info_outline_rounded,
                    color: _primaryPurple, size: 16.sp),
                label: Text(
                  "Info",
                  style: TextStyle(
                    color: _primaryPurple,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  side: BorderSide(color: _softPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: _bgLight, height: 1),
          SizedBox(height: 16.h),
          _buildMembersHorizontalList(),
        ],
      ),
    );
  }

  Widget _buildMembersHorizontalList() {
    return Obx(() {
      final sortedList = controller.sortedParticipants;

      if (sortedList.isEmpty) {
        return SizedBox(
          height: 90.h,
          child: Center(
            child: Text(
              "No members yet",
              style: TextStyle(color: _textSecondary, fontSize: 13.sp),
            ),
          ),
        );
      }
      return SizedBox(
        height: 90.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: sortedList.length,
          separatorBuilder: (_, __) => SizedBox(width: 14.w),
          itemBuilder: (context, index) {
            return _buildMemberAvatar(sortedList[index]);
          },
        ),
      );
    });
  }

  Widget _buildMemberAvatar(WalkieParticipant p) {
    return SizedBox(
      width: 70.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60.r,
            width: 60.r,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (p.isSpeaking)
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (_, __) {
                      final progress = _rippleController.value;
                      final scale = 1.0 + (progress * 0.5);
                      final opacity = (1 - progress).clamp(0.0, 1.0);
                      return Container(
                        width: 56.r * scale,
                        height: 56.r * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryPurple.withOpacity(opacity * 0.25),
                        ),
                      );
                    },
                  ),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p.isSpeaking ? _primaryPurple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: _softPurple,
                    backgroundImage: p.image.isNotEmpty
                        ? NetworkImage(ConstRes.aImageBaseUrl + p.image)
                        : null,
                    child: p.image.isEmpty
                        ? Text(
                            _getInitials(p.name),
                            style: TextStyle(
                              color: _primaryPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16.r,
                    height: 16.r,
                    decoration: BoxDecoration(
                      color: p.isMuted
                          ? _mutedRed
                          : (p.isSpeaking ? _primaryPurple : _activeGreen),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: p.isSpeaking
                        ? Icon(Icons.mic_rounded,
                            color: Colors.white, size: 8.sp)
                        : p.isMuted
                            ? Icon(Icons.mic_off_rounded,
                                color: Colors.white, size: 8.sp)
                            : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            p.name.length > 8 ? "${p.name.substring(0, 7)}." : p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textDark,
              fontSize: 12.sp,
              fontWeight: p.isSpeaking ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (p.isSpeaking)
            Text(
              "Speaking",
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (p.isMuted)
            Text(
              "Muted",
              style: TextStyle(
                color: _mutedRed,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPTTSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: controller.isConnected.value
                          ? _activeGreen
                          : _mutedRed,
                      shape: BoxShape.circle,
                    ),
                  )),
              SizedBox(width: 8.w),
              Obx(() => Text(
                    controller.isConnected.value
                        ? "You are Connected"
                        : "Reconnecting...",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 320.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Obx(() {
                if (!controller.hasActiveSpeaker && !controller.isTalking) {
                  return const SizedBox.shrink();
                }
                return AnimatedBuilder(
                  animation: _rippleController,
                  builder: (_, __) {
                    return Stack(
                      alignment: Alignment.center,
                      children: List.generate(4, (i) {
                        final progress =
                            ((_rippleController.value + i * 0.25) % 1.0);
                        final size = 120.r + (progress * 220.r);
                        final opacity = (1 - progress).clamp(0.0, 1.0);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primaryPurple.withOpacity(opacity * 0.3),
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                );
              }),
              Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _primaryPurple.withOpacity(0.06), width: 1),
                ),
              ),
              Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _primaryPurple.withOpacity(0.1), width: 1),
                ),
              ),
              Obx(() {
                if (!controller.isPressed.value ||
                    controller.isSelfLocked.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: 240.h,
                  child: AnimatedBuilder(
                    animation: _lockHintController,
                    builder: (_, __) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: _primaryPurple,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.lock_rounded,
                                color: Colors.white, size: 18.sp),
                          ),
                          SizedBox(height: 4.h),
                          Opacity(
                            opacity: 0.4 + _lockHintController.value * 0.6,
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: _primaryPurple, size: 20.sp),
                          ),
                          Opacity(
                            opacity: _lockHintController.value * 0.6,
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: _primaryPurple, size: 20.sp),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
              Obx(() {
                if (!controller.isPressed.value ||
                    controller.isSelfLocked.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  right: 20.w,
                  bottom: 220.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _cardWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      "Slide up to lock",
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _onPTTPressed(),
                onTapUp: (_) => _onPTTReleased(),
                onTapCancel: () => _onPTTReleased(),
                onVerticalDragStart: (_) {
                  if (!controller.isPressed.value) _onPTTPressed();
                },
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: Obx(() {
                  final dragOffset =
                      controller.dragOffset.value.clamp(0.0, _lockThreshold);
                  return Transform.translate(
                    offset: Offset(0, -dragOffset),
                    child: _buildPTTButton(),
                  );
                }),
              ),
              Obx(() {
                if (!controller.isSelfLocked.value) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _unlockAndStop,
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final isTalking = controller.isTalking;
          final isSelfLocked = controller.isSelfLocked.value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelfLocked ? Icons.lock_rounded : Icons.volume_up_rounded,
                  color: _primaryPurple, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                isSelfLocked
                    ? "Locked - Tap mic to stop"
                    : isTalking
                        ? "Release to Stop"
                        : "Push and hold to talk",
                style: TextStyle(
                  color: _primaryPurple,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPTTButton() {
    return Obx(() {
      final isTalking = controller.isTalking;
      final isBusy = controller.hasActiveSpeaker && !controller.isTalking;
      final isLocked = controller.isChannelLocked.value;
      final isSelfLocked = controller.isSelfLocked.value;

      return ScaleTransition(
        scale: _pulseController,
        child: Container(
          width: 150.r,
          height: 150.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.all(10.r),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isBusy || isLocked
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : [_primaryPurple, _lightPurple],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocked
                      ? Icons.lock_rounded
                      : isSelfLocked
                          ? Icons.lock_open_rounded
                          : isBusy
                              ? Icons.mic_off_rounded
                              : Icons.mic_rounded,
                  color: Colors.white,
                  size: 38.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  isSelfLocked
                      ? "Tap to Unlock"
                      : isTalking
                          ? "Talking..."
                          : "Hold to Talk",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMuteMeCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: _primaryPurple,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child:
                Icon(Icons.mic_off_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mute Me",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Others won't hear you",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Switch(
                value: controller.isMuted.value,
                onChanged: (v) async {
                  // Direct service execution handles controller status sync perfectly
                  await GroupWalkieService.instance.toggleMute();
                },
                activeColor: _primaryPurple,
              )),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _actionButton(
                icon: controller.audioRouteIcon,
                label: controller.audioRouteLabel,
                onTap: () async {
                  if (controller.audioRoute.value ==
                          WalkieAudioRoute.bluetooth ||
                      controller.audioRoute.value == WalkieAudioRoute.headset) {
                    Get.snackbar(
                      "Audio Route",
                      "Routing to ${controller.audioRouteLabel}",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  final next = !controller.isSpeakerOn.value;
                  await GroupWalkieService.instance.toggleSpeaker(next);
                },
              )),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _actionButton(
            icon: Icons.history_rounded,
            label: "History",
            onTap: () {},
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _actionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: "Chat",
            onTap: () {
              // Fixed C5: Secure navigation parameters (Clean string casting, No unsafe parsing)
              Get.toNamed(
                Routes.groupChatScreen,
                arguments: {
                  "groupId": args?['groupId']?.toString() ?? "",
                  "groupName": args?['groupName']?.toString() ?? "",
                  "groupImage": "",
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: _primaryPurple, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: _textDark,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: _cardWhite,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Exit Walkie?",
          style: TextStyle(
            color: _textDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "You will disconnect from this walkie channel. You will still remain a member of the group.",
          style: TextStyle(color: _textSecondary, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _safeLeave();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              "Exit Walkie",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
