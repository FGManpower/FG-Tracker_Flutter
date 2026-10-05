import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_trial_details.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import '../../Core/constant/pref_res.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  bool _isDisposed = false;
  bool _pttInProgress = false;
  final bool _allowPop = false;

  // Manual touch-tracking state to bypass iOS gesture cancellation
  double _startY = 0.0;

  Timer? _trialTimer;
  int _trialRemainingSeconds = 3600; // 1 hour trial allocated (3600 seconds)
  bool _isSubscribed = false;
  bool _canSpeak = true;
  bool _isListenOnly = false;
  bool _isTeamAdminWithoutSeat = false;
  int _teamPurchasedSeats = 0;
  int _teamAssignedSeats = 0;
  bool _trialDialogShown = false;
  bool _isMembersLoading = true;
  String? _userId;

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

  void _log(String msg) {
    dev.log('📱 [WALKIE_UI] $msg');
  }

  @override
  void initState() {
    super.initState();
    _log('initState() initiated');
    WalkieLaunchTracker.fromWalkieCall = true;
    try {
      WakelockPlus.enable();
    } catch (_) {}

    if (Get.arguments is Map<String, dynamic>) {
      args = Get.arguments as Map<String, dynamic>;
      _log('Arguments parsed successfully: $args');
      if (args?['isSubscribed'] != null) {
        _isSubscribed = args!['isSubscribed'] == true;
      }
    } else {
      _log('Warning: No arguments map passed to view.');
    }

    _initTrialAndSubscription();

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

    String groupId = args?['groupId']?.toString() ?? '';
    if (Get.isRegistered<GroupController>()) {
      final gc = Get.find<GroupController>();
      if (groupId.isEmpty && gc.groupData.isNotEmpty) {
        final g = gc.groupData.first;
        groupId = g.id?.toString() ?? '';
        args = {
          'groupId': groupId,
          'groupName': g.groupName ?? 'Walkie Group',
          'groupDesc': g.groupDesc ?? '',
          'groupCode': g.groupCode ?? '',
          'isSubscribed': args?['isSubscribed'] ?? _isSubscribed,
        };
      } else if (groupId.isNotEmpty && (args?['groupName'] == null || args?['groupName'] == 'Site Operations Team')) {
        final match = gc.groupData.firstWhereOrNull((g) => g.id?.toString() == groupId);
        if (match != null) {
          args ??= {};
          args!['groupName'] = match.groupName ?? 'Walkie Group';
          args!['groupDesc'] = match.groupDesc ?? '';
          args!['groupCode'] = match.groupCode ?? '';
        }
      }
    }

    if (groupId.isNotEmpty) {
      final groupName = args?['groupName']?.toString() ?? 'Walkie Group';
      _log('Configuring active session for group ID: $groupId ($groupName)');
      controller.setCurrentGroup(groupId);
      controller.setConnected(GroupWalkieService.instance.socket?.connected == true);

      final myId = Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
      final myName = Global.storageServices.get(PrefConst.userName)?.toString() ?? 'You';
      final myImage = Global.storageServices.get(PrefConst.profileImage)?.toString() ?? '';
      if (myId.isNotEmpty) {
        controller.addOrUpdateParticipant(
          WalkieParticipant(
            userId: myId,
            name: myName,
            image: myImage,
            isSpeaking: false,
            isListening: true,
          ),
        );
      }

      GroupWalkieService.instance.joinGroup(groupId, groupName: groupName);
      _loadGroupMembersFromDb(groupId);
    } else {
      _log('Error: Invalid Group ID. Returning to previous screen.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar("Error", "Please select a group first",
            snackPosition: SnackPosition.BOTTOM);
      });
    }

    _rippleWorker =
        everAll([controller.activeSpeakerId, controller.audioState], (_) {
      if (_isDisposed || !mounted) return;
      final isTalking = controller.isTalking;
      final hasActive = controller.hasActiveSpeaker;
      _log(
          'Ripple worker check: isTalking=$isTalking, hasActiveSpeaker=$hasActive');

      if (isTalking || hasActive) {
        if (!_rippleController.isAnimating) {
          _log('Starting ripple animation loop');
          _rippleController.repeat();
        }
      } else {
        _log('Stopping ripple animation loop');
        _rippleController.stop();
        _rippleController.reset();
      }
    });

    _pulseWorker = ever(controller.isPressed, (bool pressed) {
      if (_isDisposed || !mounted) return;
      _log('Pulse worker triggered. PTT Button pressed state: $pressed');
      if (pressed && !controller.isSelfLocked.value) {
        _log('PTT active. Starting pulsing animation');
        _pulseController.repeat(reverse: true);
      } else if (!pressed) {
        _log('PTT inactive. Stopping pulsing animation');
        _pulseController.stop();
        _pulseController.animateTo(1.0,
            duration: const Duration(milliseconds: 150));
      }
    });
  }

  @override
  void dispose() {
    _log('dispose() called');
    _isDisposed = true;
    _rippleWorker.dispose();
    _pulseWorker.dispose();
    _trialTimer?.cancel();
    _saveTrialRemainingSeconds();
    WalkieLaunchTracker.fromWalkieCall = false;
    try {
      WakelockPlus.disable();
    } catch (_) {}
    _safeLeave();
    _rippleController.dispose();
    _pulseController.dispose();
    _lockHintController.dispose();
    super.dispose();
  }

  Future<void> _safeLeave() async {
    if (_hasLeft) {
      _log('_safeLeave() skipped (already processed)');
      return;
    }
    _log('Leaving room and cleaning assets...');
    _hasLeft = true;
    if (!_isDisposed) {
      try {
        if (_rippleController.isAnimating) _rippleController.stop();
        if (_pulseController.isAnimating) _pulseController.stop();
        if (_lockHintController.isAnimating) _lockHintController.stop();
      } catch (e) {
        _log('Error stopping animations in _safeLeave: $e');
      }
    }
    await GroupWalkieService.instance.leaveGroup();
    controller.reset();
  }

  Future<void> _onPTTPressed() async {
    _log('PTT Touch initiated. Checking parameters...');
    if (_pttInProgress) {
      _log('Block: PTT transaction already in progress.');
      return;
    }
    if (controller.isPressed.value) {
      _log('Block: PTT is already pressed.');
      return;
    }
    if (controller.isSelfLocked.value) {
      _log('Block: PTT is currently self-locked.');
      return;
    }
    if (controller.isChannelLocked.value) {
      _log('Block: Channel is locked by admin.');
      return;
    }

    final isSocketLive = GroupWalkieService.instance.socket?.connected == true;
    if (isSocketLive && !controller.isConnected.value) {
      controller.setConnected(true);
    }

    if (!controller.isConnected.value && !isSocketLive) {
      _log('Block: Socket is not connected / poor internet.');
      HapticFeedback.heavyImpact();
      controller.showNoInternetMessage();
      return;
    }

    if (_isTeamAdminWithoutSeat && !_canSpeak) {
      _log('Block: User is Team Admin without an assigned voice seat.');
      HapticFeedback.heavyImpact();
      controller.showNoVoiceSeatMessage();
      _showNoVoiceSeatDialog();
      return;
    }

    if (!_canSpeak && !_isSubscribed && _trialRemainingSeconds <= 0) {
      _log('Block: Free trial ended / No active plan.');
      HapticFeedback.heavyImpact();
      controller.showTrialEndedMessage();
      _showFreeTrialEndedDialog();
      return;
    }

    if (controller.isMuted.value) {
      _log('Block: User is muted.');
      HapticFeedback.heavyImpact();
      controller.showMutedMessage();
      return;
    }

    final selfId = GroupWalkieService.instance.selfUserId;
    if (controller.activeSpeakerId.value.isNotEmpty &&
        controller.activeSpeakerId.value != selfId) {
      _log('Block: Channel occupied by ${controller.activeSpeakerName.value}');
      HapticFeedback.heavyImpact();
      controller.showBusyMessage(controller.activeSpeakerName.value);
      return;
    }

    _log('Triggering PTT Session...');
    _pttInProgress = true;
    controller.setPressed(true);
    _lockHintController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    final ok = await GroupWalkieService.instance.startTalking();
    _log('PTT activation result: $ok');
    _pttInProgress = false;

    if (!ok) {
      _log('Failed to start transmission. Reverting changes...');
      controller.setPressed(false);
      _lockHintController.stop();
      _lockHintController.reset();
    }
  }

  Future<void> _onPTTReleased() async {
    _log('PTT Touch released. Checking state...');
    if (!controller.isPressed.value) {
      _log('Release skipped: PTT is not pressed.');
      return;
    }
    if (controller.isSelfLocked.value) {
      _log('Release skipped: Channel is in locked-on state.');
      return;
    }
    HapticFeedback.lightImpact();
    await _stopTalking();
  }

  Future<void> _stopTalking() async {
    _log('Stopping audio transmission and releasing lock state...');
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    controller.resetSelfLock();
    await GroupWalkieService.instance.stopTalking();
  }

  Future<void> _unlockAndStop() async {
    _log('Manual unlock and stop request received.');
    controller.resetSelfLock();
    await _stopTalking();
  }

  void _onDragUpdate(double currentY) {
    if (!controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;

    // Convert screen coordinates to drag distance (dragging up reduces Y position)
    double newOffset = _startY - currentY;
    if (newOffset < 0) newOffset = 0;

    _log(
        'PTT Drag moving upwards -> offset: ${newOffset.toStringAsFixed(1)}px / $_lockThreshold px');
    controller.setDragOffset(newOffset);

    if (newOffset >= _lockThreshold) {
      _lockPTT();
    }
  }

  Future<void> _lockPTT() async {
    if (controller.isSelfLocked.value) return;
    _log('🔒 PTT slide-to-lock threshold achieved! Activating channel lock...');
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
    _log('⏳ Lock session duration expired. Releasing transmission channel...');
    HapticFeedback.heavyImpact();
    controller.showLockExpiredMessage();
    controller.resetSelfLock();
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    await GroupWalkieService.instance.stopTalking();
  }

  String get _currentGroupName {
    final nameFromArgs = args?['groupName']?.toString();
    if (nameFromArgs != null &&
        nameFromArgs.trim().isNotEmpty &&
        nameFromArgs != 'Site Operations Team') {
      return nameFromArgs.trim();
    }
    final groupId = args?['groupId']?.toString() ?? '';
    if (Get.isRegistered<GroupController>()) {
      final gc = Get.find<GroupController>();
      final match = gc.groupData.firstWhereOrNull((g) => g.id?.toString() == groupId);
      if (match != null && (match.groupName?.trim().isNotEmpty ?? false)) {
        return match.groupName!.trim();
      }
      if (gc.groupData.isNotEmpty && (gc.groupData.first.groupName?.trim().isNotEmpty ?? false)) {
        return gc.groupData.first.groupName!.trim();
      }
    }
    return 'Walkie Group';
  }

  String get _currentGroupDesc {
    final descFromArgs = args?['groupDesc']?.toString();
    if (descFromArgs != null && descFromArgs.trim().isNotEmpty) {
      return descFromArgs.trim();
    }
    final groupId = args?['groupId']?.toString() ?? '';
    if (Get.isRegistered<GroupController>()) {
      final gc = Get.find<GroupController>();
      final match = gc.groupData.firstWhereOrNull((g) => g.id?.toString() == groupId);
      if (match != null && (match.groupDesc?.trim().isNotEmpty ?? false)) {
        return match.groupDesc!.trim();
      }
    }
    return '';
  }

  String get _currentGroupCode {
    final codeFromArgs = args?['groupCode']?.toString();
    if (codeFromArgs != null && codeFromArgs.trim().isNotEmpty) {
      return codeFromArgs.trim();
    }
    final groupId = args?['groupId']?.toString() ?? '';
    if (Get.isRegistered<GroupController>()) {
      final gc = Get.find<GroupController>();
      final match = gc.groupData.firstWhereOrNull((g) => g.id?.toString() == groupId);
      if (match != null && (match.groupCode?.trim().isNotEmpty ?? false)) {
        return match.groupCode!.trim();
      }
    }
    return '';
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
      onBackgroundImageError: (_, __) {
        _log('Failed to load profile photo for: ${p.name}');
      },
      child: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Executing build pipeline...');
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        _log('OnPopInvoked triggered. didPop=$didPop');
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: _bgLight,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLandscapeWide = constraints.maxWidth >= 720 &&
                  constraints.maxWidth > constraints.maxHeight;

              _log(
                  'Device orientation metrics: isLandscapeWide=$isLandscapeWide, maxWidth=${constraints.maxWidth}');

              return Column(
                children: [
                  _buildHeader(isWide: isLandscapeWide),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscapeWide
                            ? 20.w.clamp(16.0, 32.0)
                            : 16.w.clamp(12.0, 20.0),
                      ),
                      child: isLandscapeWide
                          ? _buildWideLayout(constraints)
                          : Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 520),
                                child: _buildPortraitLayout(constraints),
                              ),
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

  Widget _buildStatusBar() {
    return Obx(() {
      final bool showCustomStatus = controller.showStatus.value;
      final bool isDisconnected = !controller.isConnected.value;

      if (!showCustomStatus && !isDisconnected) {
        return const SizedBox.shrink();
      }

      final String message = showCustomStatus
          ? controller.statusMessage.value
          : "Poor network connection — Reconnecting...";
      final Color color = showCustomStatus
          ? controller.statusColor.value
          : Colors.orange.shade800;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDisconnected && !showCustomStatus
                  ? Icons.wifi_off_rounded
                  : Icons.info_outline_rounded,
              color: color,
              size: 15.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return Column(
      children: [
        _buildStatusBar(),
        SizedBox(height: 4.h.clamp(2.0, 6.0)),
        _buildGroupInfoCard(),
        SizedBox(height: 8.h.clamp(4.0, 12.0)),
        Expanded(
          child: _buildPTTSection(),
        ),
        SizedBox(height: 8.h.clamp(4.0, 12.0)),
        _buildMuteMeCard(),
        SizedBox(height: 10.h.clamp(8.0, 14.0)),
        _buildBottomActions(),
        SizedBox(height: 12.h.clamp(8.0, 16.0)),
      ],
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 380.w.clamp(320.0, 420.0),
          child: Column(
            children: [
              _buildStatusBar(),
              Expanded(
                child: _buildGroupInfoCard(isWide: true),
              ),
              SizedBox(height: 10.h.clamp(8.0, 14.0)),
              _buildMuteMeCard(),
              SizedBox(height: 10.h.clamp(8.0, 14.0)),
              _buildBottomActions(),
              SizedBox(height: 12.h.clamp(8.0, 16.0)),
            ],
          ),
        ),
        SizedBox(width: 16.w.clamp(12.0, 24.0)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h.clamp(8.0, 16.0)),
            child: Container(
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildPTTSection(isWide: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({bool isWide = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w.clamp(12.0, 20.0),
        8.h.clamp(6.0, 12.0),
        16.w.clamp(12.0, 20.0),
        6.h.clamp(4.0, 8.0),
      ),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            iconColor: _textDark,
            onTap: () {
              _showExitDialog();
            },
          ),
          SizedBox(width: 14.w.clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Walkie Talkie",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 17.sp.clamp(16.0, 19.0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isWide
                      ? _currentGroupName
                      : "Group Communication",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11.5.sp.clamp(10.5, 12.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _buildTrialTimerPill(),
          SizedBox(width: 8.w),
          Container(
            width: 42.r.clamp(38.0, 46.0),
            height: 42.r.clamp(38.0, 46.0),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(14.r),
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
                  color: _primaryPurple, size: 20.sp.clamp(18.0, 22.0)),
              color: _cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              onSelected: (value) async {
                _log('Menu item clicked: $value');
                switch (value) {
                  case 'audio-output':
                    _showAudioRouteBottomSheet();
                    break;
                  case 'mute-group':
                    await GroupWalkieService.instance.toggleMute();
                    break;
                  case 'exit':
                    _showExitDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                _menuItem('audio-output', Icons.speaker_phone_rounded,
                    'Audio Output'),
                _menuItem('exit', Icons.logout_rounded, 'Exit Walkie',
                    color: _mutedRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MemberData> _allGroupMembers = [];
  Map<String, MemberData> _dbMembersMap = {};

  Future<void> _loadGroupMembersFromDb(String groupId) async {
    if (groupId.isEmpty) return;
    try {
      if (mounted) setState(() => _isMembersLoading = true);
      final res = await GroupRepo.getMemberData(groupId);
      if (res.status == true && res.memberData != null && res.memberData!.isNotEmpty) {
        _allGroupMembers = res.memberData!;
        _dbMembersMap = {
          for (var m in res.memberData!)
            if (m.userId != null) m.userId.toString(): m
        };

        // Enrich only the active real-time socket participants with their profile image/name if missing
        bool updated = false;
        for (int i = 0; i < controller.participants.length; i++) {
          final p = controller.participants[i];
          if (_dbMembersMap.containsKey(p.userId)) {
            final dbMember = _dbMembersMap[p.userId];
            final dbImg = dbMember?.profileImage;
            final dbName = dbMember?.name;
            if ((p.image.isEmpty && dbImg != null && dbImg.isNotEmpty) ||
                (p.name == 'User' && dbName != null && dbName.isNotEmpty)) {
              controller.participants[i] = WalkieParticipant(
                userId: p.userId,
                name: (p.name.isEmpty || p.name == 'User')
                    ? (dbName ?? p.name)
                    : p.name,
                image: (p.image.isNotEmpty) ? p.image : (dbImg ?? ''),
                isMuted: p.isMuted,
                isListening: p.isListening,
                isSpeaking: p.isSpeaking,
              );
              updated = true;
            }
          }
        }
        if (updated) {
          controller.participants.refresh();
        }
      }
    } catch (e) {
      _log('Error loading members from DB: $e');
    } finally {
      if (mounted) {
        setState(() => _isMembersLoading = false);
      }
    }
  }

  Future<void> _initTrialAndSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(PrefConst.userId) ?? '';

      // Load locally persisted trial seconds (default: 3600s = 1 hour)
      final localRemaining = prefs.getInt('walkie_trial_remaining_seconds_$_userId');
      if (localRemaining != null) {
        _trialRemainingSeconds = localRemaining;
      } else {
        _trialRemainingSeconds = 3600;
        await prefs.setInt('walkie_trial_remaining_seconds_$_userId', 3600);
      }
      if (mounted) setState(() {});

      // Sync with overview backend API if reachable
      try {
        final overview = await WalkieTalkieTrialService().getOverview();
        final bool canUse = overview.access?.canUseWalkie == true;
        final bool indivActive = overview.subscriptions?.individual.hasActiveSubscription == true;
        final bool teamActive = overview.subscriptions?.team.hasActiveSubscription == true;
        final bool isAssignedTeamMember = overview.access?.hasTeamAccess == true ||
            overview.access?.accessType == 'team' ||
            overview.subscriptions?.team.currentSubscription?.isAssignedMember == true ||
            (overview.subscriptions?.team.subscriptions.any((s) => s.isAssignedMember) ?? false);
        final bool isTeamOwner = overview.subscriptions?.team.currentSubscription?.isOwner == true;

        if (overview.trial != null) {
          if (overview.trial!.isExpired == true || overview.trial!.remainingSeconds <= 0) {
            _trialRemainingSeconds = 0;
          } else if (overview.trial!.remainingSeconds > 0) {
            _trialRemainingSeconds = overview.trial!.remainingSeconds;
          }
          await prefs.setInt('walkie_trial_remaining_seconds_$_userId', _trialRemainingSeconds);
        }

        final bool hasActiveTrial = (overview.trial?.isActive == true || _trialRemainingSeconds > 0) &&
            overview.trial?.isExpired != true;

        if (indivActive || isAssignedTeamMember || (canUse && overview.access?.accessType != 'trial')) {
          _isSubscribed = true;
          _canSpeak = true;
          _isListenOnly = false;
          _isTeamAdminWithoutSeat = false;
        } else if (teamActive && isTeamOwner && !isAssignedTeamMember) {
          _teamPurchasedSeats = overview.subscriptions?.team.currentSubscription?.purchasedSeats ?? 1;
          _teamAssignedSeats = overview.subscriptions?.team.currentSubscription?.assignedSeats ?? 0;
          _isTeamAdminWithoutSeat = true;
          _isSubscribed = false;
          _canSpeak = hasActiveTrial && canUse;
          _isListenOnly = !_canSpeak;
        } else if (hasActiveTrial && canUse) {
          _isSubscribed = false;
          _canSpeak = true;
          _isListenOnly = false;
          _isTeamAdminWithoutSeat = false;
        } else {
          _isSubscribed = false;
          _canSpeak = false;
          _isListenOnly = false;
          _isTeamAdminWithoutSeat = false;
          _trialRemainingSeconds = 0;
        }

        if (mounted) setState(() {});
      } catch (e) {
        _log('Backend overview check skipped: $e');
      }

      _startTrialCountdown();
    } catch (e) {
      _log('Trial init error: $e');
      _startTrialCountdown();
    }
  }

  void _startTrialCountdown() {
    _trialTimer?.cancel();
    _trialDialogShown = false;

    _trialTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // If user is subscribed, trial is NOT consumed
      if (_isSubscribed) {
        return;
      }

      // Trail SHOULD ONLY CONSUME WHEN:
      // 1. User is joined in that socket (connected && groupId matches)
      // 2. Active voice transmission occurs (walkie_speaker_active or local user is talking)
      final bool isSocketConnected = GroupWalkieService.instance.socket?.connected == true;
      final bool isGroupJoined = GroupWalkieService.instance.currentGroupId != null;
      final bool isVoiceActive = controller.isTalking || controller.hasActiveSpeaker;

      if (isSocketConnected && isGroupJoined && isVoiceActive) {
        if (_trialRemainingSeconds > 0) {
          setState(() {
            _trialRemainingSeconds--;
          });

          if (_trialRemainingSeconds % 5 == 0 || _trialRemainingSeconds == 0) {
            _saveTrialRemainingSeconds();
          }
        }

        if (_trialRemainingSeconds <= 0) {
          _trialRemainingSeconds = 0;
          _saveTrialRemainingSeconds();
          if (controller.isTalking || controller.isPressed.value) {
            _stopTalking();
          }
          if (!_trialDialogShown && mounted) {
            _trialDialogShown = true;
            if (_isTeamAdminWithoutSeat) {
              _showNoVoiceSeatDialog();
            } else {
              _showFreeTrialEndedDialog();
            }
          }
        }
      }
    });
  }

  Future<void> _saveTrialRemainingSeconds() async {
    if (_userId != null && _userId!.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('walkie_trial_remaining_seconds_$_userId', _trialRemainingSeconds);
      } catch (_) {}
    }
  }

  String get _trialFormattedTime {
    if (_trialRemainingSeconds <= 0) return "00:00";
    final int hours = _trialRemainingSeconds ~/ 3600;
    final int minutes = (_trialRemainingSeconds % 3600) ~/ 60;
    final int seconds = _trialRemainingSeconds % 60;
    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildTrialTimerPill() {
    if (_isSubscribed) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFBBF7D0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_rounded,
              color: const Color(0xFF16A34A),
              size: 16.sp,
            ),
            SizedBox(width: 5.w),
            Text(
              "Subscribed",
              style: TextStyle(
                color: const Color(0xFF16A34A),
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.interBold,
              ),
            ),
          ],
        ),
      );
    }

    if (_isTeamAdminWithoutSeat) {
      return GestureDetector(
        onTap: _showNoVoiceSeatDialog,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.headphones_rounded,
                color: const Color(0xFF2563EB),
                size: 15.sp,
              ),
              SizedBox(width: 5.w),
              Text(
                "Listen Only",
                style: TextStyle(
                  color: const Color(0xFF2563EB),
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF3B82F6),
                size: 13.sp,
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final isConnected = controller.isConnected.value;
      final isTalking = controller.isTalking;
      final hasActiveSpeaker = controller.hasActiveSpeaker;
      final bool isEnded = _trialRemainingSeconds <= 0;
      final bool isGroupJoined = GroupWalkieService.instance.currentGroupId != null;
      final bool isConsuming = isConnected && isGroupJoined && (isTalking || hasActiveSpeaker);

      return GestureDetector(
        onTap: isEnded ? _showFreeTrialEndedDialog : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isEnded
                ? const Color(0xFFFFF0ED)
                : (isConsuming ? const Color(0xFFFEF2F2) : const Color(0xFFF5F3FF)),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isEnded
                  ? const Color(0xFFFFD6CF)
                  : (isConsuming ? const Color(0xFFFCA5A5) : const Color(0xFFDDD6FE)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isConsuming ? Colors.red : Colors.deepPurple).withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isEnded
                    ? Icons.access_time_filled_rounded
                    : (isConsuming ? Icons.record_voice_over_rounded : Icons.access_time_rounded),
                color: isEnded
                    ? const Color(0xFFEF4444)
                    : (isConsuming ? const Color(0xFFDC2626) : const Color(0xFF6D28D9)),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _trialFormattedTime,
                    style: TextStyle(
                      color: isEnded
                          ? const Color(0xFFEF4444)
                          : (isConsuming ? const Color(0xFFDC2626) : const Color(0xFF6D28D9)),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.interBold,
                    ),
                  ),
                  Text(
                    isEnded
                        ? "Free trial ended"
                        : (isConsuming ? "Consuming trial..." : "1 hr trial active"),
                    style: TextStyle(
                      color: isConsuming ? const Color(0xFFDC2626) : Colors.grey.shade600,
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showFreeTrialEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                _buildCrownGraphic(),
                SizedBox(height: 8.h),
                Text(
                  "Free Trial Ended",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Your 1 hour free trial for Walkie Talkie has ended.\nUpgrade now to continue using group communication\nwith your team.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF475569),
                    fontFamily: FontFamily.interRegular,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDialogFeatureCol(
                          icon: Icons.groups_rounded,
                          title: "Unlimited",
                          subtitle: "Team Communication",
                        ),
                      ),
                      Container(
                        height: 36.h,
                        width: 1.w,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildDialogFeatureCol(
                          icon: Icons.verified_user_rounded,
                          title: "Safe & Reliable",
                          subtitle: "Real-time Connectivity",
                        ),
                      ),
                      Container(
                        height: 36.h,
                        width: 1.w,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildDialogFeatureCol(
                          icon: Icons.devices_rounded,
                          title: "Use on All Devices",
                          subtitle: "Stay Connected Always",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6356F6), Color(0xFF4F46E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () {
                        Navigator.pop(ctx);
                        Get.to(() => const WalkieTalkiePlanDetails());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            CustomPaint(
                              size: Size(20.w, 17.h),
                              painter: _MiniCrownPainter(color: Colors.white),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Upgrade Now",
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontFamily: FontFamily.interBold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      "Maybe Later",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF475569),
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoVoiceSeatDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.headset_mic_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "No Voice Seat Assigned",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "You have an active Team Plan, but all active voice seats are currently assigned to other team members.\n\nYou can listen to group conversations in real-time, but to speak, you must assign a seat to yourself or upgrade your plan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF475569),
                    fontFamily: FontFamily.interRegular,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Team Plan Status",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              "Active",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Assigned Seats",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$_teamAssignedSeats / $_teamPurchasedSeats Seats Used",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Voice Access",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Listen Only",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  height: 46.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6356F6), Color(0xFF4F46E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: () {
                        Navigator.pop(ctx);
                        Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 1));
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                color: Colors.white, size: 17.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "Upgrade & Add Seats",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5.sp,
                                fontFamily: FontFamily.interBold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "Continue in Listen-Only Mode",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrownGraphic() {
    return SizedBox(
      width: 110.w,
      height: 72.h,
      child: CustomPaint(
        painter: _PremiumCrownIllustrationPainter(),
      ),
    );
  }

  Widget _buildDialogFeatureCol({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: const Color(0xFF5B4DFF),
          size: 20.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 7.5.sp,
            color: const Color(0xFF64748B),
            fontFamily: FontFamily.interRegular,
          ),
        ),
      ],
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

  Widget _buildGroupInfoCard({bool isWide = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w.clamp(12.0, 18.0),
        vertical: 10.h.clamp(8.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20.r),
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
        mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42.r.clamp(36.0, 46.0),
                    height: 42.r.clamp(36.0, 46.0),
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
                          color: Colors.white, size: 20.sp.clamp(18.0, 23.0)),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10.r.clamp(8.0, 12.0),
                      height: 10.r.clamp(8.0, 12.0),
                      decoration: BoxDecoration(
                        color: _activeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w.clamp(8.0, 14.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentGroupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 15.sp.clamp(13.5, 16.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(() {
                      final count = controller.totalParticipants.value;
                      final isConn = controller.isConnected.value;
                      final displayCount = count > 0 ? count : (isConn ? 1 : 0);
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$displayCount ",
                              style: TextStyle(
                                color: _primaryPurple,
                                fontSize: 11.5.sp.clamp(10.5, 12.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: displayCount == 1
                                  ? "Member Online"
                                  : "Members Online",
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 11.5.sp.clamp(10.5, 12.5),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w.clamp(6.0, 12.0),
                      vertical: 5.h.clamp(3.0, 6.0)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: _primaryPurple, size: 13.sp.clamp(12.0, 15.0)),
                      SizedBox(width: 4.w),
                      Text(
                        "Info",
                        style: TextStyle(
                          color: _primaryPurple,
                          fontSize: 11.sp.clamp(10.0, 12.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h.clamp(6.0, 14.0)),
          if (isWide)
            Expanded(child: _buildMembersListWide())
          else
            _buildMembersHorizontalList(),
        ],
      ),
    );
  }

  Widget _buildMembersListWide() {
    return Obx(() {
      final sortedList = controller.sortedParticipants;

      if (_isMembersLoading && sortedList.isEmpty) {
        return _buildMembersSkeleton(isWide: true);
      }

      if (sortedList.isEmpty) {
        return _buildEmptyMembersState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Members In Channel",
                style: TextStyle(
                  color: _textDark,
                  fontSize: 13.sp.clamp(12.0, 14.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "${sortedList.length} total",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11.sp.clamp(10.0, 12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: sortedList.length,
              separatorBuilder: (_, __) => SizedBox(height: 6.h),
              itemBuilder: (context, index) {
                final p = sortedList[index];
                final isSpeaking = p.isSpeaking;
                final isMuted = p.isMuted;
                final isAdmin = args?['adminId'] == p.userId || index == 0;

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSpeaking
                        ? const Color(0xFFF3F0FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSpeaking
                          ? _primaryPurple.withOpacity(0.4)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildSafeAvatar(p, 16.r.clamp(14.0, 18.0)),
                          Positioned(
                            right: -1,
                            bottom: -1,
                            child: Container(
                              width: isMuted ? 13.r.clamp(12.0, 15.0) : 8.r,
                              height: isMuted ? 13.r.clamp(12.0, 15.0) : 8.r,
                              decoration: BoxDecoration(
                                color: isMuted ? _mutedRed : _activeGreen,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: isMuted
                                  ? Center(
                                      child: Icon(
                                        Icons.mic_off_rounded,
                                        color: Colors.white,
                                        size: 7.5.sp,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 13.sp.clamp(12.0, 14.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isSpeaking
                                  ? "Speaking..."
                                  : (isMuted
                                      ? (isAdmin ? "Admin • Muted" : "Muted")
                                      : (isAdmin ? "Admin" : "Online")),
                              style: TextStyle(
                                color: isSpeaking
                                    ? _primaryPurple
                                    : (isMuted ? _mutedRed : _textSecondary),
                                fontSize: 10.5.sp.clamp(9.5, 12.0),
                                fontWeight: isSpeaking
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSpeaking)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _primaryPurple,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq_rounded,
                                  color: Colors.white, size: 11.sp),
                              SizedBox(width: 3.w),
                              Text("LIVE",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  void _showGroupInfoModal() {
    final groupName = _currentGroupName;
    final groupDesc = _currentGroupDesc;
    final groupCode = _currentGroupCode;

    _log('Displaying group information modal for: $groupName');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
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
                              "${controller.totalParticipants.value > 0 ? controller.totalParticipants.value : controller.sortedParticipants.length} Active in Walkie",
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
              if (_allGroupMembers.isNotEmpty) ...[
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Text(
                      "Group Members",
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${_allGroupMembers.length} total",
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allGroupMembers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final member = _allGroupMembers[index];
                    final memberId = member.userId?.toString() ?? '';
                    final memberName = (member.name != null &&
                            member.name!.trim().isNotEmpty)
                        ? member.name!.trim()
                        : "Member";
                    final isAdmin = args?['adminId'] == memberId || index == 0;

                    return Obx(() {
                      final participant = controller.participants
                          .firstWhereOrNull((p) =>
                              p.userId.trim() == memberId.trim() ||
                              (int.tryParse(p.userId) != null &&
                                  int.tryParse(p.userId) == int.tryParse(memberId)));
                      final isOnline = participant != null;
                      final isMuted = participant?.isMuted == true;
                      final isSpeaking = participant?.isSpeaking == true;

                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: _softPurple,
                                  backgroundImage: (member.profileImage != null &&
                                          member.profileImage!.isNotEmpty &&
                                          !_isBadImageUrl(member.profileImage!))
                                      ? NetworkImage(
                                          member.profileImage!.startsWith('http')
                                              ? member.profileImage!
                                              : ConstRes.aImageBaseUrl +
                                                  member.profileImage!)
                                      : null,
                                  child: (member.profileImage == null ||
                                          member.profileImage!.isEmpty ||
                                          _isBadImageUrl(member.profileImage!))
                                      ? Text(
                                          _getInitials(memberName),
                                          style: TextStyle(
                                            color: _primaryPurple,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.sp,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: isMuted ? 13.r : 8.r,
                                    height: isMuted ? 13.r : 8.r,
                                    decoration: BoxDecoration(
                                      color: isMuted
                                          ? _mutedRed
                                          : (isOnline
                                              ? _activeGreen
                                              : Colors.grey.shade400),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: isMuted
                                        ? Center(
                                            child: Icon(
                                              Icons.mic_off_rounded,
                                              color: Colors.white,
                                              size: 7.5.sp,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memberName,
                                    style: TextStyle(
                                      color: _textDark,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isSpeaking
                                        ? "Speaking..."
                                        : (isMuted
                                            ? "Muted"
                                            : (isOnline
                                                ? "In Walkie Channel"
                                                : "Offline")),
                                    style: TextStyle(
                                      color: isSpeaking
                                          ? _primaryPurple
                                          : (isMuted
                                              ? _mutedRed
                                              : (isOnline
                                                  ? _activeGreen
                                                  : _textSecondary)),
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: _softPurple,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "Admin",
                                  style: TextStyle(
                                    color: _primaryPurple,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersHorizontalList() {
    return Obx(() {
      final sortedList = controller.sortedParticipants;

      if (_isMembersLoading && sortedList.isEmpty) {
        return _buildMembersSkeleton(isWide: false);
      }

      if (sortedList.isEmpty) {
        return _buildEmptyMembersState();
      }

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
                for (int index = 0; index < sortedList.length; index++) ...[
                  if (index > 0) SizedBox(width: 12.w),
                  _buildMemberAvatar(
                    sortedList[index],
                    index: index,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMembersSkeleton({bool isWide = false}) {
    if (isWide) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 6.h),
        itemBuilder: (_, __) => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 45.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < 3 ? 12.w : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.r.clamp(42.0, 52.0),
                  height: 48.r.clamp(42.0, 52.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  width: 36.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMembersState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: _softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_tethering_rounded,
                size: 15.sp, color: _primaryPurple),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "Connected to channel • Waiting for others to join",
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(
    WalkieParticipant p, {
    required int index,
  }) {
    final isSpeaking = p.isSpeaking;
    final isMuted = p.isMuted;
    final isAdmin = args?['adminId'] == p.userId || index == 0;

    return SizedBox(
      width: 66.w.clamp(58.0, 74.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 48.r.clamp(42.0, 52.0),
            width: 48.r.clamp(42.0, 52.0),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isSpeaking)
                  Container(
                    width: 48.r.clamp(42.0, 52.0),
                    height: 48.r.clamp(42.0, 52.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple,
                        width: 2,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(isSpeaking ? 2.5 : 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSpeaking
                          ? _primaryPurple.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: _buildSafeAvatar(p, 19.r.clamp(16.0, 21.0)),
                ),
                if (isSpeaking)
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: Container(
                      width: 16.r.clamp(14.0, 18.0),
                      height: 16.r.clamp(14.0, 18.0),
                      decoration: BoxDecoration(
                        color: _primaryPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(Icons.graphic_eq_rounded,
                          color: Colors.white, size: 9.sp.clamp(8.0, 11.0)),
                    ),
                  ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: isMuted ? 14.r.clamp(12.0, 16.0) : 10.r.clamp(8.0, 12.0),
                    height: isMuted ? 14.r.clamp(12.0, 16.0) : 10.r.clamp(8.0, 12.0),
                    decoration: BoxDecoration(
                      color: isMuted ? _mutedRed : _activeGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isMuted
                        ? Center(
                            child: Icon(Icons.mic_off_rounded,
                                color: Colors.white, size: 8.sp.clamp(7.0, 9.5)),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h.clamp(2.0, 5.0)),
          Text(
            p.name.length > 8 ? "${p.name.substring(0, 7)}." : p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textDark,
              fontSize: 11.sp.clamp(10.0, 12.5),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          if (isSpeaking)
            Text(
              "Speaking...",
              maxLines: 1,
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 9.5.sp.clamp(8.5, 11.0),
                fontWeight: FontWeight.w600,
              ),
            )
          else if (isMuted)
            Text(
              "Muted",
              maxLines: 1,
              style: TextStyle(
                color: _mutedRed,
                fontSize: 9.5.sp.clamp(8.5, 11.0),
                fontWeight: FontWeight.w600,
              ),
            )
          else if (isAdmin)
            Text(
              "Admin",
              maxLines: 1,
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 9.5.sp.clamp(8.5, 11.0),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            SizedBox(height: 12.h.clamp(10.0, 14.0)),
        ],
      ),
    );
  }

  Widget _buildPTTSection({bool isWide = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalH = constraints.maxHeight;
        final double totalW = constraints.maxWidth;

        final double availableStackH = (totalH - 76.0).clamp(180.0, 480.0);
        final double buttonSize =
            (availableStackH * (isWide ? 0.46 : 0.50)).clamp(120.0, 175.0);
        final double maxRingRadius = math.min(availableStackH, totalW);
        final double lockTargetTop =
            math.max(6.0, ((availableStackH - buttonSize) / 2) - 76.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w.clamp(12.0, 18.0),
                vertical: 6.h.clamp(5.0, 8.0),
              ),
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
                        width: 8.r.clamp(7.0, 9.0),
                        height: 8.r.clamp(7.0, 9.0),
                        decoration: BoxDecoration(
                          color: controller.isConnected.value
                              ? _activeGreen
                              : _mutedRed,
                          shape: BoxShape.circle,
                        ),
                      )),
                  SizedBox(width: 8.w.clamp(6.0, 10.0)),
                  Obx(() => Text(
                        controller.isConnected.value
                            ? "You are Connected"
                            : "Connecting...",
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 12.sp.clamp(11.0, 13.5),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 8.h.clamp(4.0, 12.0)),
            SizedBox(
              height: availableStackH,
              width: totalW,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: (buttonSize * 2.2).clamp(190.0, maxRingRadius),
                    height: (buttonSize * 2.2).clamp(190.0, maxRingRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple.withOpacity(0.025),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: (buttonSize * 1.75).clamp(160.0, maxRingRadius),
                    height: (buttonSize * 1.75).clamp(160.0, maxRingRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple.withOpacity(0.04),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: (buttonSize * 1.35).clamp(130.0, maxRingRadius),
                    height: (buttonSize * 1.35).clamp(130.0, maxRingRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple.withOpacity(0.06),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: (buttonSize * 1.05).clamp(100.0, maxRingRadius),
                    height: (buttonSize * 1.05).clamp(100.0, maxRingRadius),
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
                            final rippleSize = buttonSize * 0.85 +
                                (progress * (buttonSize * 1.25));
                            final opacity = (1 - progress).clamp(0.0, 1.0);
                            return Container(
                              width: rippleSize,
                              height: rippleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _primaryPurple
                                      .withOpacity(opacity * 0.25),
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
                    top: lockTargetTop,
                    child: Container(
                      width: 36.w.clamp(32.0, 40.0),
                      height: 74.h.clamp(66.0, 80.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
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
                              color: _primaryPurple,
                              size: 16.sp.clamp(14.0, 18.0)),
                          Icon(Icons.keyboard_arrow_up_rounded,
                              color: _primaryPurple,
                              size: 18.sp.clamp(16.0, 20.0)),
                          Transform.translate(
                            offset: const Offset(0, -4),
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: _lightPurple,
                                size: 18.sp.clamp(16.0, 20.0)),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -8),
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: _lightPurple.withOpacity(0.5),
                                size: 18.sp.clamp(16.0, 20.0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: lockTargetTop + 14.0,
                    left: (totalW / 2) + 24.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w.clamp(8.0, 14.0),
                        vertical: 5.h.clamp(4.0, 6.0),
                      ),
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
                          fontSize: 10.5.sp.clamp(9.5, 12.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // FIXED iOS gesture handling setup (Manual tracking on PointerEvents)
                  Obx(() {
                    if (controller.isMuted.value) {
                      return _buildMutedListeningView(size: buttonSize);
                    }
                    final dragOffset = controller.dragOffset.value.clamp(0.0, _lockThreshold);
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (PointerDownEvent event) {
                        _log(
                            'Raw pointer down at screen coordinates Dy: ${event.position.dy}');
                        _startY = event.position.dy;
                        _onPTTPressed();
                      },
                      onPointerMove: (PointerMoveEvent event) {
                        _onDragUpdate(event.position.dy);
                      },
                      onPointerUp: (PointerUpEvent event) {
                        _log('Raw pointer up captured.');
                        if (!controller.isSelfLocked.value) {
                          controller.setDragOffset(0.0);
                          _onPTTReleased();
                        }
                      },
                      onPointerCancel: (PointerCancelEvent event) {
                        _log(
                            '⚠️ Warning: Raw touch input canceled by iOS gesture recognizer.');
                        if (!controller.isSelfLocked.value) {
                          controller.setDragOffset(0.0);
                          _onPTTReleased();
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (controller.isSelfLocked.value) {
                            _unlockAndStop();
                          }
                        },
                        child: Transform.translate(
                          offset: Offset(0, -dragOffset),
                          child: _buildPTTButton(size: buttonSize),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    top: lockTargetTop + 10.0,
                    child: Obx(() {
                      if (!controller.isSelfLocked.value) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: _unlockAndStop,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w.clamp(10.0, 16.0),
                            vertical: 7.h.clamp(5.0, 9.0),
                          ),
                          decoration: BoxDecoration(
                            color: _primaryPurple,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryPurple.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  color: Colors.white,
                                  size: 13.sp.clamp(11.0, 15.0)),
                              SizedBox(width: 6.w.clamp(4.0, 8.0)),
                              Text(
                                "Auto-unlock in ${controller.lockRemainingSeconds.value}s",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5.sp.clamp(10.5, 13.0),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h.clamp(4.0, 12.0)),
            Obx(() {
              final isSelfLocked = controller.isSelfLocked.value;
              final isMuted = controller.isMuted.value;
              final bool isNoSeat = _isTeamAdminWithoutSeat && !_canSpeak;
              final bool isPressed = controller.isPressed.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMuted
                        ? Icons.headphones_rounded
                        : isNoSeat
                            ? Icons.headphones_rounded
                            : isSelfLocked
                                ? Icons.lock_rounded
                                : isPressed
                                    ? Icons.volume_up_rounded
                                    : Icons.touch_app_rounded,
                    color: isMuted
                        ? _mutedRed
                        : isNoSeat
                            ? const Color(0xFF2563EB)
                            : _primaryPurple,
                    size: 15.sp.clamp(13.0, 17.0),
                  ),
                  SizedBox(width: 6.w.clamp(4.0, 8.0)),
                  Text(
                    isMuted
                        ? "Listening Only"
                        : isNoSeat
                            ? "Listen Only — Tap to View Plan"
                            : isSelfLocked
                                ? "Locked — Tap mic to stop"
                                : isPressed
                                    ? "Release to Stop"
                                    : "Hold to Talk, Slide Up to Lock",
                    style: TextStyle(
                      color: isMuted
                          ? _mutedRed
                          : isNoSeat
                              ? const Color(0xFF2563EB)
                              : _primaryPurple,
                      fontSize: 12.sp.clamp(11.0, 13.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildMutedListeningView({required double size}) {
    final double s = size * 0.92;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.12),
      ),
      padding: EdgeInsets.all((s * 0.05).clamp(5.0, 8.0)),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all((s * 0.035).clamp(3.0, 6.0)),
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
              Icon(Icons.headphones_rounded,
                  color: Colors.white, size: (s * 0.26).clamp(32.0, 44.0)),
              SizedBox(height: 3.h),
              Text(
                "Listening",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (s * 0.075).clamp(11.0, 13.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPTTButton({required double size}) {
    return Obx(() {
      final isTalking = controller.isTalking;
      final isBusy = controller.hasActiveSpeaker && !controller.isTalking;
      final isLocked = controller.isChannelLocked.value;
      final isSelfLocked = controller.isSelfLocked.value;
      final bool isNoSeat = _isTeamAdminWithoutSeat && !_canSpeak;

      return ScaleTransition(
        scale: _pulseController,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNoSeat
                ? const Color(0xFF3B82F6).withOpacity(0.08)
                : _primaryPurple.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: isNoSeat
                    ? const Color(0xFF3B82F6).withOpacity(0.25)
                    : _primaryPurple.withOpacity(0.25),
                blurRadius: 32,
                spreadRadius: 3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all((size * 0.06).clamp(6.0, 12.0)),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: EdgeInsets.all((size * 0.035).clamp(4.0, 8.0)),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isBusy || isLocked
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : isNoSeat
                          ? [const Color(0xFF60A5FA), const Color(0xFF2563EB)]
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
                                : isNoSeat
                                    ? Icons.headphones_rounded
                                    : Icons.mic_rounded,
                    color: Colors.white,
                    size: (size * 0.28).clamp(36.0, 52.0),
                  ),
                  SizedBox(height: (size * 0.02).clamp(2.0, 5.0)),
                  Text(
                    isSelfLocked
                        ? "Tap to Unlock"
                        : isTalking
                            ? "Talking..."
                            : isNoSeat
                                ? "Listen Only"
                                : "Hold to Talk",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (size * 0.075).clamp(11.0, 14.0),
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
      padding: EdgeInsets.symmetric(
        horizontal: 16.w.clamp(12.0, 20.0),
        vertical: 10.h.clamp(8.0, 12.0),
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
        children: [
          Container(
            width: 38.r.clamp(34.0, 42.0),
            height: 38.r.clamp(34.0, 42.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lightPurple, _primaryPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_off_rounded,
                color: Colors.white, size: 20.sp.clamp(18.0, 22.0)),
          ),
          SizedBox(width: 12.w.clamp(8.0, 14.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mute Me",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 14.sp.clamp(13.0, 15.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Others won't hear you",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11.5.sp.clamp(10.5, 12.5),
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
                  _log('User changed toggle mute value: $v');
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: () => _showAudioRouteBottomSheet(context),
              child: Obx(() {
                final route = controller.audioRoute.value;
                final label = controller.audioRouteLabel;
                final icon = controller.audioRouteIcon;
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
              onTap: () {
                _log('Navigating to chat view...');
                Get.toNamed(
                  Routes.groupChatScreen,
                  arguments: {
                    "groupId": args?['groupId']?.toString() ?? "",
                    "groupName": _currentGroupName,
                    "groupImage": "",
                  },
                );
              },
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

  void _showAudioRouteBottomSheet([BuildContext? ctx]) {
    final effectiveContext = ctx ?? context;
    _log('Opening Audio Output selection sheet...');
    HapticFeedback.lightImpact();
    final isIOS = Platform.isIOS;
    final phoneLabel = isIOS ? "iPhone" : "Phone";
    final phoneIcon =
        isIOS ? Icons.phone_iphone_rounded : Icons.phone_android_rounded;

    showModalBottomSheet(
      context: effectiveContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (sheetContext) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 14.w.clamp(10.0, 20.0),
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Obx(() {
                  final currentRoute = controller.audioRoute.value;
                  final hasBT = controller.hasBluetooth.value;
                  final btName = controller.bluetoothName.value;
                  final hasHeadset = controller.hasHeadset.value;
                  final headsetName = controller.headsetName.value;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                          width: 38.w.clamp(32.0, 44.0),
                          height: 4.h.clamp(3.0, 5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Audio Output",
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 16.sp.clamp(15.0, 18.0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.of(sheetContext).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.sp,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1,
                        thickness: 1,
                      ),
                      _buildAudioRouteItem(
                        title: phoneLabel,
                        trailingIcon: phoneIcon,
                        isSelected: currentRoute == WalkieAudioRoute.earpiece,
                        onTap: () async {
                          _log(
                              'User changed audio route to: EARPIECE / RECEIVER');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.earpiece);
                        },
                      ),
                      _buildAudioRouteDivider(),
                      _buildAudioRouteItem(
                        title: "Speaker",
                        trailingIcon: Icons.volume_up_rounded,
                        isSelected: currentRoute == WalkieAudioRoute.speaker,
                        onTap: () async {
                          _log('User changed audio route to: LOUDSPEAKER');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.speaker);
                        },
                      ),
                      _buildAudioRouteDivider(),
                      _buildAudioRouteItem(
                        title: hasBT ? btName : "Bluetooth",
                        subtitle: hasBT ? "Connected" : "Not connected",
                        trailingIcon: Icons.bluetooth_audio_rounded,
                        isSelected: currentRoute == WalkieAudioRoute.bluetooth,
                        isEnabled: hasBT,
                        onTap: () async {
                          if (!hasBT) {
                            _log(
                                'Warning: Attempted to switch to Bluetooth but no device is active.');
                            Get.snackbar(
                              "Bluetooth",
                              "No Bluetooth audio device connected. Please pair your Bluetooth headset in settings.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                            return;
                          }
                          _log('User changed audio route to: BLUETOOTH SCO');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.bluetooth);
                        },
                      ),
                      if (hasHeadset) ...[
                        _buildAudioRouteDivider(),
                        _buildAudioRouteItem(
                          title: headsetName,
                          trailingIcon: Icons.headphones_rounded,
                          isSelected: currentRoute == WalkieAudioRoute.headset,
                          onTap: () async {
                            _log('User changed audio route to: WIRED HEADSET');
                            HapticFeedback.mediumImpact();
                            Navigator.of(sheetContext).pop();
                            await controller.setRoute(WalkieAudioRoute.headset);
                          },
                        ),
                      ],
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 14.5.sp.clamp(13.0, 16.0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioRouteItem({
    required String title,
    String? subtitle,
    required IconData trailingIcon,
    required bool isSelected,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? const Color(0xFFF6F3FF) : Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: 18.w.clamp(14.0, 22.0),
            vertical: 13.h.clamp(10.0, 16.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24.w.clamp(20.0, 28.0),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: _primaryPurple,
                        size: 20.sp.clamp(18.0, 23.0),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(width: 10.w.clamp(8.0, 14.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: !isEnabled
                            ? _slateGray
                            : (isSelected ? _primaryPurple : _textDark),
                        fontSize: 15.sp.clamp(14.0, 16.5),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected
                              ? _primaryPurple.withOpacity(0.8)
                              : _textSecondary,
                          fontSize: 11.5.sp.clamp(10.5, 12.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                trailingIcon,
                color: !isEnabled
                    ? _slateGray.withOpacity(0.5)
                    : (isSelected ? _primaryPurple : _textSecondary),
                size: 22.sp.clamp(19.0, 25.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioRouteDivider() {
    return Divider(
      color: const Color(0xFFF1F5F9),
      height: 1,
      thickness: 1,
      indent: 52.w.clamp(44.0, 60.0),
      endIndent: 16.w,
    );
  }

  void _showExitDialog() {
    _log('Displaying exit dialog prompt...');
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
            onPressed: () {
              _log('User cancelled exit prompt.');
              Get.back();
            },
            child: Text("Cancel", style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              _log('Exit confirmed. Closing channel sessions...');
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

class _PremiumCrownIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Soft radial halo glow behind crown
    final glowRadius = size.height * 0.48;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEDE9FE).withOpacity(0.9),
          const Color(0xFFEDE9FE).withOpacity(0.4),
          const Color(0xFFEDE9FE).withOpacity(0.0),
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: glowRadius));
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);

    // 2. Radiating burst lines (4 rays)
    final rayPaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
        Offset(cx - 28, cy - 10), Offset(cx - 36, cy - 12), rayPaint);
    // Bottom-left
    canvas.drawLine(
        Offset(cx - 26, cy + 6), Offset(cx - 32, cy + 14), rayPaint);
    // Top-right
    canvas.drawLine(
        Offset(cx + 28, cy - 10), Offset(cx + 36, cy - 12), rayPaint);
    // Bottom-right
    canvas.drawLine(
        Offset(cx + 26, cy + 6), Offset(cx + 32, cy + 14), rayPaint);

    // 3. 3D Crown body
    final crownPath = Path();
    crownPath.moveTo(cx - 23, cy + 12);
    crownPath.quadraticBezierTo(cx, cy + 15, cx + 23, cy + 12);
    crownPath.cubicTo(cx + 24, cy + 4, cx + 23, cy - 4, cx + 21, cy - 7);
    crownPath.quadraticBezierTo(cx + 12, cy + 2, cx + 7, cy + 2);
    crownPath.quadraticBezierTo(cx + 3, cy - 11, cx, cy - 16);
    crownPath.quadraticBezierTo(cx - 3, cy - 11, cx - 7, cy + 2);
    crownPath.quadraticBezierTo(cx - 12, cy + 2, cx - 21, cy - 7);
    crownPath.cubicTo(cx - 23, cy - 4, cx - 24, cy + 4, cx - 23, cy + 12);
    crownPath.close();

    // Shadow
    canvas.drawShadow(
        crownPath, const Color(0xFF4F46E5).withOpacity(0.35), 6, true);

    // Crown body fill gradient
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA78BFA),
          Color(0xFF7C3AED),
          Color(0xFF4F46E5),
        ],
      ).createShader(Rect.fromLTWH(cx - 25, cy - 18, 50, 35));
    canvas.drawPath(crownPath, bodyPaint);

    // Crown lower rim band with highlight
    final bandPath = Path()
      ..moveTo(cx - 23, cy + 12)
      ..quadraticBezierTo(cx, cy + 15, cx + 23, cy + 12)
      ..quadraticBezierTo(cx, cy + 8, cx - 23, cy + 8)
      ..close();
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFFC4B5FD),
          Color(0xFF6D28D9),
        ],
      ).createShader(Rect.fromLTWH(cx - 23, cy + 8, 46, 7));
    canvas.drawPath(bandPath, bandPaint);

    // Jewels / Pearls on the 3 peak tips
    void drawJewel(Offset center, double radius) {
      final jewelPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [
            Colors.white,
            Color(0xFFDDD6FE),
            Color(0xFF7C3AED),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, jewelPaint);

      // Specular bright spot
      final specPaint = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(
        Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
        radius * 0.35,
        specPaint,
      );
    }

    drawJewel(Offset(cx - 21, cy - 7), 3.8);
    drawJewel(Offset(cx, cy - 16), 4.8);
    drawJewel(Offset(cx + 21, cy - 7), 3.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniCrownPainter extends CustomPainter {
  final Color color;
  const _MiniCrownPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.82);
    path.quadraticBezierTo(w * 0.5, h * 0.95, w, h * 0.82);
    path.lineTo(w * 0.92, h * 0.28);
    path.lineTo(w * 0.65, h * 0.55);
    path.lineTo(w * 0.5, h * 0.1);
    path.lineTo(w * 0.35, h * 0.55);
    path.lineTo(w * 0.08, h * 0.28);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Base band line
    final bandPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final bandPath = Path();
    bandPath.moveTo(w * 0.05, h * 0.72);
    bandPath.quadraticBezierTo(w * 0.5, h * 0.82, w * 0.95, h * 0.72);
    canvas.drawPath(bandPath, bandPaint);

    // 3 small tip dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(w * 0.08, h * 0.24), 1.6, dotPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.08), 2.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.92, h * 0.24), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniCrownPainter oldDelegate) =>
      oldDelegate.color != color;
}
