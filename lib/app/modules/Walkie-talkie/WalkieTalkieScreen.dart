import 'dart:async';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
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
  final args = Get.arguments as Map<String, dynamic>;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  bool _isPressed = false;

  final Color _bgDark = const Color(0xFF0F1223);
  final Color _cardDark = const Color(0xFF161A30);
  final Color _primaryPurple = const Color(0xFF6B4EFF);
  final Color _lightPurple = const Color(0xFF8C73FF);
  final Color _activeGreen = const Color(0xFF1DE9B6);
  final Color _mutedRed = const Color(0xFFFF5252);
  final Color _textSecondary = const Color(0xFF8B95A5);

  @override
  void initState() {
    super.initState();
    WalkieLaunchTracker.fromWalkieCall = true;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    final groupId = args['groupId'].toString();
    controller.setCurrentGroup(groupId);
    GroupWalkieService.instance.joinGroup(groupId);
  }



  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    GroupWalkieService.instance.leaveGroup();
    controller.reset();
    super.dispose();
  }

  Future<void> _onPTTPressed() async {
    if (controller.isChannelLocked.value || _isPressed) return;

    if (controller.activeSpeakerId.value.isNotEmpty &&
        controller.activeSpeakerId.value !=
            GroupWalkieService.instance.socket?.id) {
      HapticFeedback.heavyImpact();
      controller.showBusyMessage(controller.activeSpeakerName.value);
      return;
    }

    _isPressed = true;
    HapticFeedback.mediumImpact();
    controller.startTalking();
    _pulseController.repeat(reverse: true);
    await GroupWalkieService.instance.startTalking();
  }

  Future<void> _onPTTReleased() async {
    if (!_isPressed) return;
    _isPressed = false;

    _pulseController.stop();
    _pulseController.animateTo(1.0,
        duration: const Duration(milliseconds: 150));
    controller.stopTalking();
    await GroupWalkieService.instance.stopTalking();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildBannerCard(),
                    SizedBox(height: 24.h),
                    _buildStatsRow(),
                    SizedBox(height: 24.h),
                    _buildWhosSpeakingSection(),
                    SizedBox(height: 24.h),
                    _buildChannelMembersSection(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            _buildBottomConsole(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 24.sp),
            onPressed: () => Get.back(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args['groupName'] ?? 'Walkie Channel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(() => Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "${controller.totalParticipants.value} active",
                          style: TextStyle(
                            color: _activeGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          _buildIconBtn(Icons.people_alt_outlined),
          SizedBox(width: 12.w),
          _buildIconBtn(Icons.graphic_eq_rounded),
          SizedBox(width: 12.w),
          if (args['isAdmin'] == true)
            Obx(() => _buildIconBtn(
                  controller.isChannelLocked.value
                      ? Icons.lock
                      : Icons.lock_open,
                  onTap: () {
                    final next = !controller.isChannelLocked.value;
                    GroupWalkieService.instance.toggleLockChannel(next);
                  },
                  color: controller.isChannelLocked.value
                      ? Colors.orange
                      : Colors.white,
                ))
          else
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              color: const Color(0xFF1C1B2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'members':
                  // Navigate to members list
                    break;
                  case 'mute-group':
                    controller.toggleMute();
                    await GroupWalkieService.instance.toggleMute();
                    break;
                  case 'exit':
                    _showExitGroupDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'members',
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Group Members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'mute-group',
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_mute,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Mute Group',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'exit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.redAccent,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Exit Group',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon,
      {VoidCallback? onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: _cardDark,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryPurple,
            const Color(0xFF4A34BE),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.settings_voice_rounded,
                color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Walkie Talkie",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Push to talk. Release to listen.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final total = controller.totalParticipants.value;
      int speaking = 0;
      int muted = 0;
      int listening = 0;

      for (var p in controller.participants) {
        if (p.isSpeaking) {
          speaking++;
        } else if (p.isMuted) {
          muted++;
        } else {
          listening++;
        }
      }

      // Include self in speaking if active
      if (controller.isTalking) speaking = 1;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(total.toString(), "Members", Colors.white),
          _buildStatItem(speaking.toString(), "Speaking", _primaryPurple,
              isHighlighted: true),
          _buildStatItem(listening.toString(), "Listening", _textSecondary),
          _buildStatItem(muted.toString(), "Muted", _mutedRed,
              icon: Icons.mic_off, iconColor: _mutedRed),
        ],
      );
    });
  }

  Widget _buildStatItem(String value, String label, Color color,
      {bool isHighlighted = false, IconData? icon, Color? iconColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 10.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: isHighlighted ? _primaryPurple : _textSecondary,
                fontSize: 11.sp,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhosSpeakingSection() {
    return Obx(() {
      final hasSpeaker =
          controller.activeSpeakerId.value.isNotEmpty || controller.isTalking;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Who's Speaking",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasSpeaker)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "1 speaking",
                        style:
                            TextStyle(color: _textSecondary, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: hasSpeaker
                    ? _primaryPurple.withOpacity(0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: hasSpeaker
                ? _buildActiveSpeakerContent()
                : _buildIdleSpeakerContent(),
          ),
        ],
      );
    });
  }

  Widget _buildActiveSpeakerContent() {
    final isMeTalking = controller.isTalking;
    final speakerName =
        isMeTalking ? "You" : controller.activeSpeakerName.value;
    final image = isMeTalking ? "" : controller.activeSpeakerImage.value;

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: _primaryPurple.withOpacity(0.2),
              backgroundImage: image.isNotEmpty
                  ? NetworkImage(ConstRes.aImageBaseUrl + image)
                  : null,
              child: image.isEmpty
                  ? Text(_getInitials(speakerName),
                      style: TextStyle(
                          color: _primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp))
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardDark, width: 2),
                ),
                child: Icon(Icons.graphic_eq_rounded,
                    color: Colors.white, size: 10.sp),
              ),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                speakerName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Speaking...",
                style: TextStyle(
                  color: _lightPurple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildAudioWaves(color: _lightPurple),
      ],
    );
  }

  Widget _buildIdleSpeakerContent() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: Colors.white.withOpacity(0.05),
          child:
              Icon(Icons.mic_none_rounded, color: _textSecondary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "No one is talking",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                "Channel is idle",
                style: TextStyle(color: _textSecondary, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioWaves({required Color color}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (i) {
            final phase = (_waveController.value + (i * 0.15)) % 1.0;
            final h = 6.0 + (phase < 0.5 ? phase : 1 - phase) * 24.0;
            return Container(
              width: 3.w,
              height: h.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildChannelMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Channel Members",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700),
            ),
            Obx(() => Text(
                  "${controller.totalParticipants.value} members",
                  style: TextStyle(color: _textSecondary, fontSize: 12.sp),
                )),
          ],
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.participants.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text("No one else is here",
                    style: TextStyle(color: _textSecondary)),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.participants.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildListTile(controller.participants[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildListTile(WalkieParticipant p) {
    Color statusColor;
    String statusText;
    IconData? actionIcon;

    if (p.isSpeaking) {
      statusColor = _lightPurple;
      statusText = "Speaking";
      actionIcon = Icons.graphic_eq;
    } else if (p.isMuted) {
      statusColor = _mutedRed;
      statusText = "Muted";
      actionIcon = Icons.mic_off_rounded;
    } else {
      statusColor = _textSecondary;
      statusText = "Listening";
      actionIcon = Icons.hearing_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: p.image.isNotEmpty
                    ? NetworkImage(ConstRes.aImageBaseUrl + p.image)
                    : null,
                child: p.image.isEmpty
                    ? Text(_getInitials(p.name),
                        style: TextStyle(color: Colors.white, fontSize: 14.sp))
                    : null,
              ),
              if (!p.isMuted && !p.isSpeaking)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: _activeGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cardDark, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (actionIcon != null)
            Icon(actionIcon, color: statusColor, size: 18.sp),
          SizedBox(width: 12.w),
          Icon(Icons.more_horiz_rounded, color: _textSecondary, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildBottomConsole() {
    return Container(
      decoration: BoxDecoration(
        color: _bgDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Inside _buildBottomConsole():

          // Speaker Toggle
          Obx(() => _buildBottomActionButton(
                icon: controller.audioRouteIcon,
                label: controller.audioRouteLabel,
                isActive: controller.isSpeakerOn.value ||
                    controller.audioRoute.value == WalkieAudioRoute.bluetooth ||
                    controller.audioRoute.value == WalkieAudioRoute.headset,
                onTap: () async {
                  // Prevent switching to Speaker if Bluetooth is connected
                  if (controller.audioRoute.value ==
                          WalkieAudioRoute.bluetooth ||
                      controller.audioRoute.value == WalkieAudioRoute.headset) {
                    Get.snackbar(
                      "Audio Route",
                      "Currently routing audio to ${controller.audioRouteLabel}",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: Colors.black,
                    );
                    return;
                  }

                  final next = !controller.isSpeakerOn.value;
                  await GroupWalkieService.instance.toggleSpeaker(next);
                },
              )),
          GestureDetector(
            onTapDown: (_) => _onPTTPressed(),
            onTapUp: (_) => _onPTTReleased(),
            onTapCancel: () => _onPTTReleased(),
            child: Obx(() {
              final isTalking = controller.isTalking;
              final isBusy =
                  controller.hasActiveSpeaker && !controller.isTalking;
              final isLocked = controller.isChannelLocked.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isTalking
                              ? [_primaryPurple, _lightPurple]
                              : (isBusy || isLocked)
                                  ? [Colors.grey.shade800, Colors.grey.shade900]
                                  : [
                                      _primaryPurple.withOpacity(0.8),
                                      _primaryPurple
                                    ],
                        ),
                        boxShadow: [
                          if (isTalking || (!isBusy && !isLocked))
                            BoxShadow(
                              color: _primaryPurple.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                        ],
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.lock_rounded
                            : isBusy
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    isTalking ? "Release to Listen" : "Hold to Talk",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isTalking
                        ? "Transmitting..."
                        : (isBusy ? "Channel Busy" : "Ready"),
                    style: TextStyle(color: _textSecondary, fontSize: 11.sp),
                  ),
                ],
              );
            }),
          ),
          Obx(() => _buildBottomActionButton(
                icon: controller.isMuted.value
                    ? Icons.mic_off_rounded
                    : Icons.mic_none_rounded,
                label: "Mute",
                isActive: controller.isMuted.value,
                activeColor: _mutedRed,
                onTap: () {
                  controller.toggleMute();
                  GroupWalkieService.instance.toggleMute();
                },
              )),
        ],
      ),
    );
  }

  void _showExitGroupDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Exit Group?",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        content: Text(
          "You will be removed from ${args['groupName'] ?? 'this group'} and will no longer receive walkie invites.",
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await GroupWalkieService.instance
                  .exitGroupMembership(args['groupId'].toString());
              Get.back(); // exit walkie screen

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text("Exit Group"),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    Color activeColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Icon(icon,
                color: isActive ? activeColor : _textSecondary, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
                color: isActive ? activeColor : _textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
