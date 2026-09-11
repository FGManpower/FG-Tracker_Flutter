import 'dart:async';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Data/Services/walkie_awesome_notification_service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
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
  bool _pttInProgress = false;
  final bool _allowPop = false;

  final Color _bgLight = const Color(0xFFF6F8FD);
  final Color _cardWhite = Colors.white;
  final Color _primaryPurple = const Color(0xFF5A35FF);
  final Color _lightPurple = const Color(0xFF8B6CFF);
  final Color _softPurple = const Color(0xFFEDE9FE);
  final Color _activeGreen = const Color(0xFF22C55E);
  final Color _mutedRed = const Color(0xFFEF4444);
  final Color _textDark = const Color(0xFF1E1B2E);
  final Color _textSecondary = const Color(0xFF8E8EA8);
  final Color _slateGray = const Color(0xFF94A3B8);

  late final Worker _rippleWorker;
  late final Worker _pulseWorker;

  @override
  void initState() {
    super.initState();
    WalkieLaunchTracker.fromWalkieCall = true;

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
    final groupName = args?['groupName']?.toString() ?? 'FG-Manpower';
    if (groupId.isNotEmpty) {
      controller.setCurrentGroup(groupId);
      if (GroupWalkieService.instance.currentGroupId != groupId ||
          !WalkieAwesomeNotificationService.instance.isInActiveSession) {
        WalkieAwesomeNotificationService.instance.startActiveSession(
          groupId: groupId,
          groupName: groupName,
        );
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar("Error", "Invalid Group Information",
            snackPosition: SnackPosition.BOTTOM);
      });
    }

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
    super.dispose();
  }

  Future<void> _safeLeave() async {
    if (_hasLeft) return;
    _hasLeft = true;
    _rippleController.stop();
    _pulseController.stop();
    _lockHintController.stop();
    await WalkieAwesomeNotificationService.instance.exitActiveSession();
    controller.reset();
  }

  Future<void> _onPTTPressed() async {
    if (_pttInProgress) return;
    if (controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;
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

    _pttInProgress = true;
    controller.setPressed(true);
    _lockHintController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    final ok = await GroupWalkieService.instance.startTalking();
    _pttInProgress = false;

    if (!ok) {
      controller.setPressed(false);
      _lockHintController.stop();
      _lockHintController.reset();
    }
  }

  Future<void> _onPTTReleased() async {
    if (!controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;
    await _stopTalking();
  }

  Future<void> _stopTalking() async {
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    controller.resetSelfLock();
    await GroupWalkieService.instance.stopTalking();
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
    if (!controller.isSelfLocked.value) {
      controller.setDragOffset(0.0);
    }
  }

  Future<void> _lockPTT() async {
    if (controller.isSelfLocked.value) return;
    HapticFeedback.heavyImpact();
    controller.setDragOffset(0.0);
    _pulseController.stop();
    _pulseController.animateTo(1.0,
        duration: const Duration(milliseconds: 150));

    controller.activateSelfLock(() {
      _autoExpireLock();
    });
  }

  Future<void> _autoExpireLock() async {
    if (!controller.isSelfLocked.value) return;
    HapticFeedback.heavyImpact();
    controller.showLockExpiredMessage();
    controller.resetSelfLock();
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    await GroupWalkieService.instance.stopTalking();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  bool _isBadImageUrl(String url) {
    if (url.isEmpty) return true;
    if (url.contains('pngitem.com')) return true;
    if (url.contains('placeholder')) return true;
    if (url.contains('default-avatar')) return true;
    return false;
  }

  Widget _buildSafeAvatar(WalkieParticipant p, double radius) {
    final rawImage = p.image;
    if (_isBadImageUrl(rawImage)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: _softPurple,
        child: Text(
          _getInitials(p.name),
          style: TextStyle(
            color: _primaryPurple,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      );
    }
    final fullUrl = rawImage.startsWith('http')
        ? rawImage
        : ConstRes.aImageBaseUrl + rawImage;

    return CircleAvatar(
      radius: radius,
      backgroundColor: _softPurple,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _bgLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),
                      _buildGroupInfoCard(),
                      SizedBox(height: 16.h),
                      _buildPTTSection(),
                      SizedBox(height: 16.h),
                      _buildMuteMeCard(),
                      SizedBox(height: 14.h),
                      _buildBottomActions(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            iconColor: _textDark,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Walkie Talkie",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Group Communication",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: _primaryPurple, size: 22.sp),
              color: _cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'mute-group':
                    await GroupWalkieService.instance.toggleMute();
                    break;
                  case 'exit':
                    _showExitDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                _menuItem('exit', Icons.logout_rounded, 'Exit Walkie',
                    color: _mutedRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: iconColor ?? _textDark, size: 20.sp),
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
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_lightPurple, _primaryPurple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.people_alt_rounded,
                          color: Colors.white, size: 24.sp),
                    ),
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
              SizedBox(width: 12.w),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Obx(() {
                      final count = controller.totalParticipants.value > 0
                          ? controller.totalParticipants.value
                          : 8;
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$count ",
                              style: TextStyle(
                                color: _primaryPurple,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: "Members Online",
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showGroupInfoModal,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: _primaryPurple, size: 15.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "Group Info",
                        style: TextStyle(
                          color: _primaryPurple,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _buildMembersHorizontalList(),
        ],
      ),
    );
  }

  void _showGroupInfoModal() {
    final groupName = args?['groupName'] ?? 'Site Operations Team';
    final groupDesc = args?['groupDesc'] ?? '';
    final groupCode = args?['groupCode'] ?? '';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_lightPurple, _primaryPurple],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_alt_rounded,
                      color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Obx(() => Text(
                            "${controller.totalParticipants.value > 0 ? controller.totalParticipants.value : 8} Members Online",
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12.sp,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            if (groupDesc.toString().isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                "Description",
                style: TextStyle(
                  color: _textDark,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                groupDesc.toString(),
                style: TextStyle(color: _textSecondary, fontSize: 12.sp),
              ),
            ],
            if (groupCode.toString().isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                "Group Code: $groupCode",
                style: TextStyle(
                  color: _primaryPurple,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMembersHorizontalList() {
    return Obx(() {
      final sortedList = controller.sortedParticipants;
      final isFallback = sortedList.isEmpty;
      final listToDisplay = isFallback ? _fallbackMembers : sortedList;

      return Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int index = 0; index < listToDisplay.length; index++) ...[
                  if (index > 0) SizedBox(width: 12.w),
                  _buildMemberAvatar(
                    listToDisplay[index],
                    index: index,
                    isFallback: isFallback,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  List<WalkieParticipant> get _fallbackMembers => [
        WalkieParticipant(
          userId: '1',
          name: 'Arjun',
          image:
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
          isSpeaking: false,
        ),
        WalkieParticipant(
          userId: '2',
          name: 'Priya',
          image:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          isSpeaking: true,
        ),
        WalkieParticipant(
          userId: '3',
          name: 'Rohit',
          image:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          isSpeaking: false,
        ),
        WalkieParticipant(
          userId: '4',
          name: 'Imran',
          image:
              'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=150',
          isSpeaking: false,
        ),
      ];

  Widget _buildMemberAvatar(
    WalkieParticipant p, {
    required int index,
    required bool isFallback,
  }) {
    final isSpeaking = p.isSpeaking;
    final isMuted = p.isMuted;
    final isAdmin = isFallback
        ? index == 0
        : (args?['adminId'] == p.userId || index == 0);
    final isOtherGroup = isFallback && index == 2;

    return SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 58.r,
            width: 58.r,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isSpeaking)
                  Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple,
                        width: 2,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(isSpeaking ? 3.w : 2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSpeaking
                          ? _primaryPurple.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: _buildSafeAvatar(p, 23.r),
                ),
                if (isSpeaking)
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: Container(
                      width: 18.r,
                      height: 18.r,
                      decoration: BoxDecoration(
                        color: _primaryPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.graphic_eq_rounded,
                          color: Colors.white, size: 10.sp),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: isOtherGroup
                          ? _slateGray
                          : (isMuted ? _mutedRed : _activeGreen),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            p.name.length > 8 ? "${p.name.substring(0, 7)}." : p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textDark,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          if (isSpeaking)
            Text(
              "Speaking...",
              maxLines: 1,
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (isAdmin)
            Text(
              "Admin",
              maxLines: 1,
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (isOtherGroup)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_alt_rounded,
                    size: 9.sp, color: _textSecondary),
                SizedBox(width: 2.w),
                Text(
                  "In Other Group",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (isMuted)
            Text(
              "Muted",
              maxLines: 1,
              style: TextStyle(
                color: _mutedRed,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            SizedBox(height: 14.h),
        ],
      ),
    );
  }

  Widget _buildPTTSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
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
                        : "Connecting...",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 330.h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 380.r,
                height: 380.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryPurple.withOpacity(0.025),
                    width: 1.2,
                  ),
                ),
              ),
              Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryPurple.withOpacity(0.04),
                    width: 1.2,
                  ),
                ),
              ),
              Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryPurple.withOpacity(0.06),
                    width: 1.2,
                  ),
                ),
              ),
              Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryPurple.withOpacity(0.08),
                    width: 1.2,
                  ),
                ),
              ),
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
                        final size = 130.r + (progress * 220.r);
                        final opacity = (1 - progress).clamp(0.0, 1.0);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primaryPurple.withOpacity(opacity * 0.25),
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                );
              }),
              Positioned(
                top: 8.h,
                child: Container(
                  width: 38.w,
                  height: 88.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.lock_rounded,
                          color: _primaryPurple, size: 18.sp),
                      Icon(Icons.keyboard_arrow_up_rounded,
                          color: _primaryPurple, size: 20.sp),
                      Transform.translate(
                        offset: Offset(0, -6.h),
                        child: Icon(Icons.keyboard_arrow_up_rounded,
                            color: _lightPurple, size: 20.sp),
                      ),
                      Transform.translate(
                        offset: Offset(0, -12.h),
                        child: Icon(Icons.keyboard_arrow_up_rounded,
                            color: _lightPurple.withOpacity(0.5), size: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 66.h,
                left: (MediaQuery.of(context).size.width / 2) + 12.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Slide up to lock",
                    style: TextStyle(
                      color: _primaryPurple,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.isMuted.value) {
                  return _buildMutedListeningView();
                }
                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _onPTTPressed(),
                  onPointerUp: (_) => _onPTTReleased(),
                  onPointerCancel: (_) => _onPTTReleased(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.isSelfLocked.value) {
                        _unlockAndStop();
                      }
                    },
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: Obx(() {
                      final dragOffset = controller.dragOffset.value
                          .clamp(0.0, _lockThreshold);
                      return Transform.translate(
                        offset: Offset(0, -dragOffset),
                        child: _buildPTTButton(),
                      );
                    }),
                  ),
                );
              }),
              Obx(() {
                if (!controller.isSelfLocked.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 10.h,
                  child: GestureDetector(
                    onTap: _unlockAndStop,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: _primaryPurple,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPurple.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              color: Colors.white, size: 14.sp),
                          SizedBox(width: 6.w),
                          Obx(() => Text(
                                "Auto-unlock in ${controller.lockRemainingSeconds.value}s",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          final isSelfLocked = controller.isSelfLocked.value;
          final isMuted = controller.isMuted.value;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isMuted
                    ? Icons.headphones_rounded
                    : isSelfLocked
                        ? Icons.lock_rounded
                        : Icons.volume_up_rounded,
                color: isMuted ? _mutedRed : _primaryPurple,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                isMuted
                    ? "Listening Only"
                    : isSelfLocked
                        ? "Locked — Tap mic to stop"
                        : "Release to Stop",
                style: TextStyle(
                  color: isMuted ? _mutedRed : _primaryPurple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMutedListeningView() {
    return Container(
      width: 156.r,
      height: 156.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.12),
      ),
      padding: EdgeInsets.all(7.r),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(5.r),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade300, Colors.grey.shade400],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headphones_rounded, color: Colors.white, size: 38.sp),
              SizedBox(height: 4.h),
              Text(
                "Listening",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
          width: 172.r,
          height: 172.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryPurple.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withOpacity(0.25),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(10.r),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(6.r),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isBusy || isLocked
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [_lightPurple, _primaryPurple],
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
                    size: 46.sp,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lightPurple, _primaryPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_off_rounded,
                color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 14.w),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => CupertinoSwitch(
                value: controller.isMuted.value,
                activeTrackColor: _primaryPurple,
                onChanged: (v) async {
                  await GroupWalkieService.instance.toggleMute();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(22.r),
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
                  Icon(Icons.volume_up_rounded,
                      color: _primaryPurple, size: 28.sp),
                  SizedBox(height: 8.h),
                  Text(
                    "Speaker",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.toNamed(
                Routes.groupChatScreen,
                arguments: {
                  "groupId": args?['groupId']?.toString() ?? "",
                  "groupName": args?['groupName']?.toString() ?? "",
                  "groupImage": "",
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(22.r),
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
                  Icon(Icons.chat_bubble_rounded,
                      color: _primaryPurple, size: 26.sp),
                  SizedBox(height: 8.h),
                  Text(
                    "Chat",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
            child: Text("Cancel", style: TextStyle(color: _textSecondary)),
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
            child: const Text("Exit Walkie",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
