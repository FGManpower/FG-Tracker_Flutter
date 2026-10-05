import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:fgtracker/app/Core/values/Curve/walkie_painter.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/NoVoiceSeatDialog.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/WalkieBottomActions.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/Walkie_Talkie.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/group_info_bottom_sheet.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import '../../../Core/constant/pref_res.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../Core/constant/notification_holder.dart';

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

  double _startY = 0.0;
  bool _isListenOnly = false;
  Timer? _trialTimer;
  int _trialRemainingSeconds = 3600;
  bool _isSubscribed = false;
  bool _canSpeak = true;

  bool _isTeamAdminWithoutSeat = false;
  int _teamPurchasedSeats = 0;
  int _teamAssignedSeats = 0;
  bool _trialDialogShown = false;
  bool _isMembersLoading = true;
  String? _userId;

  late final Worker _rippleWorker;
  late final Worker _pulseWorker;

  @override
  void initState() {
    super.initState();
    log('initState() initiated');
    WalkieLaunchTracker.fromWalkieCall = true;
    try {
      WakelockPlus.enable();
    } catch (_) {}

    if (Get.arguments is Map<String, dynamic>) {
      args = Get.arguments as Map<String, dynamic>;
      log('Arguments parsed successfully: $args');
      if (args?['isSubscribed'] != null) {
        _isSubscribed = args!['isSubscribed'] == true;
      }
    } else {
      log('Warning: No arguments map passed to view.');
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
      } else if (groupId.isNotEmpty &&
          (args?['groupName'] == null ||
              args?['groupName'] == 'Site Operations Team')) {
        final match =
            gc.groupData.firstWhereOrNull((g) => g.id?.toString() == groupId);
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
      log('Configuring active session for group ID: $groupId ($groupName)');
      controller.setCurrentGroup(groupId);
      controller
          .setConnected(GroupWalkieService.instance.socket?.connected == true);

      final myId =
          Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
      final myName =
          Global.storageServices.get(PrefConst.userName)?.toString() ?? 'You';
      final myImage =
          Global.storageServices.get(PrefConst.profileImage)?.toString() ?? '';
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
      log('Error: Invalid Group ID. Returning to previous screen.');
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
      log('Ripple worker check: isTalking=$isTalking, hasActiveSpeaker=$hasActive');

      if (isTalking || hasActive) {
        if (!_rippleController.isAnimating) {
          log('Starting ripple animation loop');
          _rippleController.repeat();
        }
      } else {
        log('Stopping ripple animation loop');
        _rippleController.stop();
        _rippleController.reset();
      }
    });

    _pulseWorker = ever(controller.isPressed, (bool pressed) {
      if (_isDisposed || !mounted) return;
      log('Pulse worker triggered. PTT Button pressed state: $pressed');
      if (pressed && !controller.isSelfLocked.value) {
        log('PTT active. Starting pulsing animation');
        _pulseController.repeat(reverse: true);
      } else if (!pressed) {
        log('PTT inactive. Stopping pulsing animation');
        _pulseController.stop();
        _pulseController.animateTo(1.0,
            duration: const Duration(milliseconds: 150));
      }
    });
  }

  @override
  void dispose() {
    log('dispose() called');
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
      log('_safeLeave() skipped (already processed)');
      return;
    }
    log('Leaving room and cleaning assets...');
    _hasLeft = true;
    if (!_isDisposed) {
      try {
        if (_rippleController.isAnimating) _rippleController.stop();
        if (_pulseController.isAnimating) _pulseController.stop();
        if (_lockHintController.isAnimating) _lockHintController.stop();
      } catch (e) {
        log('Error stopping animations in _safeLeave: $e');
      }
    }
    await GroupWalkieService.instance.leaveGroup();
    controller.reset();
  }

  Future<void> _onPTTPressed() async {
    log('PTT Touch initiated. Checking parameters...');
    if (_pttInProgress) {
      log('Block: PTT transaction already in progress.');
      return;
    }
    if (controller.isPressed.value) {
      log('Block: PTT is already pressed.');
      return;
    }
    if (controller.isSelfLocked.value) {
      log('Block: PTT is currently self-locked.');
      return;
    }
    if (controller.isChannelLocked.value) {
      log('Block: Channel is locked by admin.');
      return;
    }

    final isSocketLive = GroupWalkieService.instance.socket?.connected == true;
    if (isSocketLive && !controller.isConnected.value) {
      controller.setConnected(true);
    }

    if (!controller.isConnected.value && !isSocketLive) {
      log('Block: Socket is not connected / poor internet.');
      HapticFeedback.heavyImpact();
      controller.showNoInternetMessage();
      return;
    }

    if (_isTeamAdminWithoutSeat && !_canSpeak) {
      log('Block: User is Team Admin without an assigned voice seat.');
      HapticFeedback.heavyImpact();
      controller.showNoVoiceSeatMessage();
      NoVoiceSeatDialog.show(
        context: context,
        teamAssignedSeats: _teamAssignedSeats,
        teamPurchasedSeats: _teamPurchasedSeats,
      );
      return;
    }

    if (!_canSpeak && !_isSubscribed && _trialRemainingSeconds <= 0) {
      log('Block: Free trial ended / No active plan.');
      HapticFeedback.heavyImpact();
      controller.showTrialEndedMessage();
      _showFreeTrialEndedDialog();
      return;
    }

    if (controller.isMuted.value) {
      log('Block: User is muted.');
      HapticFeedback.heavyImpact();
      controller.showMutedMessage();
      return;
    }

    final selfId = GroupWalkieService.instance.selfUserId;
    if (controller.activeSpeakerId.value.isNotEmpty &&
        controller.activeSpeakerId.value != selfId) {
      log('Block: Channel occupied by ${controller.activeSpeakerName.value}');
      HapticFeedback.heavyImpact();
      controller.showBusyMessage(controller.activeSpeakerName.value);
      return;
    }

    log('Triggering PTT Session...');
    _pttInProgress = true;
    controller.setPressed(true);
    _lockHintController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    final ok = await GroupWalkieService.instance.startTalking();
    log('PTT activation result: $ok');
    _pttInProgress = false;

    if (!ok) {
      log('Failed to start transmission. Reverting changes...');
      controller.setPressed(false);
      _lockHintController.stop();
      _lockHintController.reset();
    }
  }

  Future<void> _onPTTReleased() async {
    log('PTT Touch released. Checking state...');
    if (!controller.isPressed.value) {
      log('Release skipped: PTT is not pressed.');
      return;
    }
    if (controller.isSelfLocked.value) {
      log('Release skipped: Channel is in locked-on state.');
      return;
    }
    HapticFeedback.lightImpact();
    await _stopTalking();
  }

  Future<void> _stopTalking() async {
    log('Stopping audio transmission and releasing lock state...');
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    controller.resetSelfLock();
    await GroupWalkieService.instance.stopTalking();
  }

  Future<void> _unlockAndStop() async {
    log('Manual unlock and stop request received.');
    controller.resetSelfLock();
    await _stopTalking();
  }

  void _onDragUpdate(double currentY) {
    if (!controller.isPressed.value) return;
    if (controller.isSelfLocked.value) return;

    // Convert screen coordinates to drag distance (dragging up reduces Y position)
    double newOffset = _startY - currentY;
    if (newOffset < 0) newOffset = 0;

    log('PTT Drag moving upwards -> offset: ${newOffset.toStringAsFixed(1)}px / $_lockThreshold px');
    controller.setDragOffset(newOffset);

    if (newOffset >= _lockThreshold) {
      _lockPTT();
    }
  }

  Future<void> _lockPTT() async {
    if (controller.isSelfLocked.value) return;
    log('🔒 PTT slide-to-lock threshold achieved! Activating channel lock...');
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
    log('⏳ Lock session duration expired. Releasing transmission channel...');
    HapticFeedback.heavyImpact();
    controller.showLockExpiredMessage();
    controller.resetSelfLock();
    controller.setPressed(false);
    _lockHintController.stop();
    _lockHintController.reset();
    await GroupWalkieService.instance.stopTalking();
  }

  @override
  Widget build(BuildContext context) {
    log('Executing build pipeline...');
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        log('OnPopInvoked triggered. didPop=$didPop');
        if (didPop) return;
        showExitDialog(
          onTap: () async {
            log('Exit confirmed. Closing channel sessions...');
            Get.back();
            await _safeLeave();
            Get.back();
          },
        );
      },
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLandscapeWide = constraints.maxWidth >= 720 &&
                  constraints.maxWidth > constraints.maxHeight;

              log('Device orientation metrics: isLandscapeWide=$isLandscapeWide, maxWidth=${constraints.maxWidth}');

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
          color: color.withValues(alpha: 0.10),
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
        WalkieBottomActions(
          controller: controller,
          onAudioRouteTap: () => _showAudioRouteBottomSheet(context),
          onChatTap: () {
            Get.toNamed(
              Routes.groupChatScreen,
              arguments: {
                "groupId": args?['groupId']?.toString() ?? "",
                "groupName": controller.currentGroupName,
                "groupImage": "",
              },
            );
          },
        ),
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
              WalkieBottomActions(
                controller: controller,
                onAudioRouteTap: () => _showAudioRouteBottomSheet(context),
                onChatTap: () {
                  Get.toNamed(
                    Routes.groupChatScreen,
                    arguments: {
                      "groupId": args?['groupId']?.toString() ?? "",
                      "groupName": controller.currentGroupName,
                      "groupImage": "",
                    },
                  );
                },
              ),
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
                color: cardWhite,
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
          headerButton(
            icon: Icons.arrow_back_rounded,
            iconColor: textDark,
            onTap: () {
              showExitDialog(
                onTap: () async {
                  log('Exit confirmed. Closing channel sessions...');
                  Get.back();
                  await _safeLeave();
                  Get.back();
                },
              );
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
                    color: textDark,
                    fontSize: 17.sp.clamp(16.0, 19.0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isWide ? controller.currentGroupName : "Group Communication",
                  style: TextStyle(
                    color: textSecondary,
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
              color: cardWhite,
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
                  color: primaryPurple, size: 20.sp.clamp(18.0, 22.0)),
              color: cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              onSelected: (value) async {
                log('Menu item clicked: $value');
                switch (value) {
                  case 'audio-output':
                    _showAudioRouteBottomSheet();
                    break;
                  case 'mute-group':
                    await GroupWalkieService.instance.toggleMute();
                    break;
                  case 'exit':
                    showExitDialog(
                      onTap: () async {
                        log('Exit confirmed. Closing channel sessions...');
                        Get.back();
                        await _safeLeave();
                        Get.back();
                      },
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                menuItem('audio-output', Icons.speaker_phone_rounded,
                    'Audio Output'),
                menuItem('exit', Icons.logout_rounded, 'Exit Walkie',
                    color: mutedRed),
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
      if (res.status == true &&
          res.memberData != null &&
          res.memberData!.isNotEmpty) {
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
      log('Error loading members from DB: $e');
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
      final localRemaining =
          prefs.getInt('walkie_trial_remaining_seconds_$_userId');
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
        final bool indivActive =
            overview.subscriptions?.individual.hasActiveSubscription == true;
        final bool teamActive =
            overview.subscriptions?.team.hasActiveSubscription == true;
        final bool isAssignedTeamMember =
            overview.access?.hasTeamAccess == true ||
                overview.access?.accessType == 'team' ||
                overview.subscriptions?.team.currentSubscription
                        ?.isAssignedMember ==
                    true ||
                (overview.subscriptions?.team.subscriptions
                        .any((s) => s.isAssignedMember) ??
                    false);
        final bool isTeamOwner =
            overview.subscriptions?.team.currentSubscription?.isOwner == true;

        if (overview.trial != null) {
          if (overview.trial!.isExpired == true ||
              overview.trial!.remainingSeconds <= 0) {
            _trialRemainingSeconds = 0;
          } else if (overview.trial!.remainingSeconds > 0) {
            _trialRemainingSeconds = overview.trial!.remainingSeconds;
          }
          await prefs.setInt('walkie_trial_remaining_seconds_$_userId',
              _trialRemainingSeconds);
        }

        final bool hasActiveTrial =
            (overview.trial?.isActive == true || _trialRemainingSeconds > 0) &&
                overview.trial?.isExpired != true;

        if (indivActive ||
            isAssignedTeamMember ||
            (canUse && overview.access?.accessType != 'trial')) {
          _isSubscribed = true;
          _canSpeak = true;
          _isListenOnly = false;
          _isTeamAdminWithoutSeat = false;
        } else if (teamActive && isTeamOwner && !isAssignedTeamMember) {
          _teamPurchasedSeats = overview
                  .subscriptions?.team.currentSubscription?.purchasedSeats ??
              1;
          _teamAssignedSeats =
              overview.subscriptions?.team.currentSubscription?.assignedSeats ??
                  0;
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
        log('Backend overview check skipped: $e');
      }

      _startTrialCountdown();
    } catch (e) {
      log('Trial init error: $e');
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
      final bool isSocketConnected =
          GroupWalkieService.instance.socket?.connected == true;
      final bool isGroupJoined =
          GroupWalkieService.instance.currentGroupId != null;
      final bool isVoiceActive =
          controller.isTalking || controller.hasActiveSpeaker;

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
              NoVoiceSeatDialog.show(
                context: context,
                teamAssignedSeats: _teamAssignedSeats,
                teamPurchasedSeats: _teamPurchasedSeats,
              );
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
        await prefs.setInt(
            'walkie_trial_remaining_seconds_$_userId', _trialRemainingSeconds);
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
        onTap: () => NoVoiceSeatDialog.show(
          context: context,
          teamAssignedSeats: _teamAssignedSeats,
          teamPurchasedSeats: _teamPurchasedSeats,
        ),
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
                color: Colors.blue.withValues(alpha: 0.04),
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
      final bool isGroupJoined =
          GroupWalkieService.instance.currentGroupId != null;
      final bool isConsuming =
          isConnected && isGroupJoined && (isTalking || hasActiveSpeaker);

      return GestureDetector(
        onTap: isEnded ? _showFreeTrialEndedDialog : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isEnded
                ? const Color(0xFFFFF0ED)
                : (isConsuming
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF5F3FF)),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isEnded
                  ? const Color(0xFFFFD6CF)
                  : (isConsuming
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFDDD6FE)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isConsuming ? Colors.red : Colors.deepPurple)
                    .withOpacity(0.04),
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
                    : (isConsuming
                        ? Icons.record_voice_over_rounded
                        : Icons.access_time_rounded),
                color: isEnded
                    ? const Color(0xFFEF4444)
                    : (isConsuming
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF6D28D9)),
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
                          : (isConsuming
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF6D28D9)),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.interBold,
                    ),
                  ),
                  Text(
                    isEnded
                        ? "Free trial ended"
                        : (isConsuming
                            ? "Consuming trial..."
                            : "1 hr trial active"),
                    style: TextStyle(
                      color: isConsuming
                          ? const Color(0xFFDC2626)
                          : Colors.grey.shade600,
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
                buildCrownGraphic(),
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
                              painter: MiniCrownPainter(color: Colors.white),
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

  Widget _buildGroupInfoCard({bool isWide = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w.clamp(12.0, 18.0),
        vertical: 10.h.clamp(8.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: cardWhite,
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
                        colors: [lightPurple, primaryPurple],
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
                        color: activeGreen,
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
                      controller.currentGroupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textDark,
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
                                color: primaryPurple,
                                fontSize: 11.5.sp.clamp(10.5, 12.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: displayCount == 1
                                  ? "Member Online"
                                  : "Members Online",
                              style: TextStyle(
                                color: textSecondary,
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
                          color: primaryPurple, size: 13.sp.clamp(12.0, 15.0)),
                      SizedBox(width: 4.w),
                      Text(
                        "Info",
                        style: TextStyle(
                          color: primaryPurple,
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
        return buildMembersSkeleton(isWide: true);
      }

      if (sortedList.isEmpty) {
        return buildEmptyMembersState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Members In Channel",
                style: TextStyle(
                  color: textDark,
                  fontSize: 13.sp.clamp(12.0, 14.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "${sortedList.length} total",
                style: TextStyle(
                  color: textSecondary,
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
                          ? primaryPurple.withOpacity(0.4)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          buildSafeAvatar(p, 16.r.clamp(14.0, 18.0)),
                          Positioned(
                            right: -1,
                            bottom: -1,
                            child: Container(
                              width: isMuted ? 13.r.clamp(12.0, 15.0) : 8.r,
                              height: isMuted ? 13.r.clamp(12.0, 15.0) : 8.r,
                              decoration: BoxDecoration(
                                color: isMuted ? mutedRed : activeGreen,
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
                                color: textDark,
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
                                    ? primaryPurple
                                    : (isMuted ? mutedRed : textSecondary),
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
                            color: primaryPurple,
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

    GroupInfoBottomSheet.show(
      context: context,
      groupName: controller.currentGroupName,
      groupDesc: controller.currentGroupDesc,
      groupCode: controller.currentGroupCode,
      adminId: args?['adminId']?.toString(),
      allGroupMembers: _allGroupMembers,
      controller: controller,
    );
  }

  Widget _buildMembersHorizontalList() {
    return Obx(() {
      final sortedList = controller.sortedParticipants;

      if (_isMembersLoading && sortedList.isEmpty) {
        return buildMembersSkeleton(isWide: false);
      }

      if (sortedList.isEmpty) {
        return buildEmptyMembersState();
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
                  buildMemberAvatar(
                    sortedList[index],
                    index: index,
                    args: args,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
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
                color: cardWhite,
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
                              ? activeGreen
                              : mutedRed,
                          shape: BoxShape.circle,
                        ),
                      )),
                  SizedBox(width: 8.w.clamp(6.0, 10.0)),
                  Obx(() => Text(
                        controller.isConnected.value
                            ? "You are Connected"
                            : "Connecting...",
                        style: TextStyle(
                          color: textDark,
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
                        color: primaryPurple.withOpacity(0.025),
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
                        color: primaryPurple.withOpacity(0.04),
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
                        color: primaryPurple.withOpacity(0.06),
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
                        color: primaryPurple.withOpacity(0.08),
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
                                  color:
                                      primaryPurple.withOpacity(opacity * 0.25),
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
                              color: primaryPurple,
                              size: 16.sp.clamp(14.0, 18.0)),
                          Icon(Icons.keyboard_arrow_up_rounded,
                              color: primaryPurple,
                              size: 18.sp.clamp(16.0, 20.0)),
                          Transform.translate(
                            offset: const Offset(0, -4),
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: lightPurple,
                                size: 18.sp.clamp(16.0, 20.0)),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -8),
                            child: Icon(Icons.keyboard_arrow_up_rounded,
                                color: lightPurple.withOpacity(0.5),
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
                        color: cardWhite,
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
                          color: primaryPurple,
                          fontSize: 10.5.sp.clamp(9.5, 12.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.isMuted.value) {
                      return buildMutedListeningView(size: buttonSize);
                    }
                    final dragOffset =
                        controller.dragOffset.value.clamp(0.0, _lockThreshold);
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (PointerDownEvent event) {
                        log('Raw pointer down at screen coordinates Dy: ${event.position.dy}');
                        _startY = event.position.dy;
                        _onPTTPressed();
                      },
                      onPointerMove: (PointerMoveEvent event) {
                        _onDragUpdate(event.position.dy);
                      },
                      onPointerUp: (PointerUpEvent event) {
                        log('Raw pointer up captured.');
                        if (!controller.isSelfLocked.value) {
                          controller.setDragOffset(0.0);
                          _onPTTReleased();
                        }
                      },
                      onPointerCancel: (PointerCancelEvent event) {
                        log('⚠️ Warning: Raw touch input canceled by iOS gesture recognizer.');
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
                          child: buildPTTButton(size: buttonSize),
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
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withValues(alpha: 0.35),
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
                        ? mutedRed
                        : isNoSeat
                            ? const Color(0xFF2563EB)
                            : primaryPurple,
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
                          ? mutedRed
                          : isNoSeat
                              ? const Color(0xFF2563EB)
                              : primaryPurple,
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

  Widget _buildMuteMeCard() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w.clamp(12.0, 20.0),
        vertical: 10.h.clamp(8.0, 12.0),
      ),
      decoration: BoxDecoration(
        color: cardWhite,
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
                colors: [lightPurple, primaryPurple],
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
                    color: textDark,
                    fontSize: 14.sp.clamp(13.0, 15.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Others won't hear you",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5.sp.clamp(10.5, 12.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => CupertinoSwitch(
                value: controller.isMuted.value,
                activeTrackColor: primaryPurple,
                onChanged: (v) async {
                  log('User changed toggle mute value: $v');
                  await GroupWalkieService.instance.toggleMute();
                },
              )),
        ],
      ),
    );
  }

  void _showAudioRouteBottomSheet([BuildContext? ctx]) {
    final effectiveContext = ctx ?? context;
    log('Opening Audio Output selection sheet...');
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
                                color: textDark,
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
                                  color: textSecondary,
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
                      buildAudioRouteItem(
                        title: phoneLabel,
                        trailingIcon: phoneIcon,
                        isSelected: currentRoute == WalkieAudioRoute.earpiece,
                        onTap: () async {
                          log('User changed audio route to: EARPIECE / RECEIVER');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.earpiece);
                        },
                      ),
                      buildAudioRouteDivider(),
                      buildAudioRouteItem(
                        title: "Speaker",
                        trailingIcon: Icons.volume_up_rounded,
                        isSelected: currentRoute == WalkieAudioRoute.speaker,
                        onTap: () async {
                          log('User changed audio route to: LOUDSPEAKER');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.speaker);
                        },
                      ),
                      buildAudioRouteDivider(),
                      buildAudioRouteItem(
                        title: hasBT ? btName : "Bluetooth",
                        subtitle: hasBT ? "Connected" : "Not connected",
                        trailingIcon: Icons.bluetooth_audio_rounded,
                        isSelected: currentRoute == WalkieAudioRoute.bluetooth,
                        isEnabled: hasBT,
                        onTap: () async {
                          if (!hasBT) {
                            log('Warning: Attempted to switch to Bluetooth but no device is active.');
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
                          log('User changed audio route to: BLUETOOTH SCO');
                          HapticFeedback.mediumImpact();
                          Navigator.of(sheetContext).pop();
                          await controller.setRoute(WalkieAudioRoute.bluetooth);
                        },
                      ),
                      if (hasHeadset) ...[
                        buildAudioRouteDivider(),
                        buildAudioRouteItem(
                          title: headsetName,
                          trailingIcon: Icons.headphones_rounded,
                          isSelected: currentRoute == WalkieAudioRoute.headset,
                          onTap: () async {
                            log('User changed audio route to: WIRED HEADSET');
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
                              color: textDark,
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

  Widget buildPTTButton({required double size}) {
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
                : primaryPurple.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: isNoSeat
                    ? const Color(0xFF3B82F6).withOpacity(0.25)
                    : primaryPurple.withOpacity(0.25),
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
                          : [lightPurple, primaryPurple],
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
}
