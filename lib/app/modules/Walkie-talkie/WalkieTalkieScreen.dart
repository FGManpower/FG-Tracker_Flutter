import 'dart:async';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Core/constant/const_res.dart';
import '../../Core/constant/notification_holder.dart';
import '../../config/themes_data.dart';
import '../../global_widget/common_widget.dart';


class GroupWalkieScreen extends StatefulWidget {
  const GroupWalkieScreen({super.key});

  @override
  State<GroupWalkieScreen> createState() => _GroupWalkieScreenState();
}

class _GroupWalkieScreenState extends State<GroupWalkieScreen>
    with SingleTickerProviderStateMixin {
  // ✅ Correctly retrieve the Group Controller instance
  final controller = Get.put(GroupWalkieController());
  final args = Get.arguments as Map<String, dynamic>;

  late final AnimationController _pulse;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    WalkieLaunchTracker.fromWalkieCall = true;

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    final groupId = args['groupId'].toString();
    controller.setCurrentGroup(groupId);

    // ✅ Join Active Screen room on mount
    GroupWalkieService.instance.joinGroup(groupId);

    // ✅ Initialize and keep microphone warm (instant PTT activation)
    _initializeWarmHardware();

    // ✅ Display incoming talk notification if auto-opened by another user
    if (args['autoOpened'] == true) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          "🎤 Live Transmission",
          "${args['speakerName'] ?? 'Someone'} is speaking...",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.greenAccent,
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  Future<void> _initializeWarmHardware() async {
    await GroupWalkieService.instance.initRecorder();
  }

  @override
  void dispose() {
    _pulse.dispose();

    // ✅ Leave Active Room but do NOT dispose service socket (keeps BG listener alive)
    GroupWalkieService.instance.leaveGroup();
    GroupWalkieService.instance.stopRecorder(); // Clean up mic warm capture pipeline

    controller.reset();
    WalkieLaunchTracker.fromWalkieCall = false;
    super.dispose();
  }

  // ============================================================
  // PUSH TO TALK STATE HANDLING
  // ============================================================
  Future<void> _onPTTPressed() async {
    if (controller.isChannelLocked.value || _isPressed) return;

    // Check if channel is occupied by another active speaker
    if (controller.activeSpeakerId.value.isNotEmpty &&
        controller.activeSpeakerId.value != GroupWalkieService.instance.socket?.id) {
      HapticFeedback.heavyImpact();
      return;
    }

    _isPressed = true;
    HapticFeedback.mediumImpact();
    controller.startTalking();
    _pulse.repeat(reverse: true);

    await GroupWalkieService.instance.startTalking();
  }

  Future<void> _onPTTReleased() async {
    if (!_isPressed) return;
    _isPressed = false;

    _pulse.stop();
    _pulse.animateTo(1.0, duration: const Duration(milliseconds: 150));
    controller.stopTalking();

    await GroupWalkieService.instance.stopTalking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Active Speaker Section
            Obx(() => _buildActiveSpeaker()),

            // Status Message (Busy/Mute/Lock alerts)
            Obx(() => _buildStatusMessage()),

            // Participants List
            Expanded(
              child: Obx(() => _buildParticipantsList()),
            ),

            // Warm PTT Button Controls
            _buildPTTSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args['groupName'] ?? 'Group Walkie',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(() => Text(
                  "${controller.totalParticipants.value} active",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12.sp,
                  ),
                )),
              ],
            ),
          ),

          if (args['isAdmin'] == true)
            Obx(() => IconButton(
              icon: Icon(
                controller.isChannelLocked.value
                    ? Icons.lock
                    : Icons.lock_open,
                color: controller.isChannelLocked.value
                    ? Colors.orange
                    : Colors.white,
              ),
              onPressed: () {
                final newState = !controller.isChannelLocked.value;
                GroupWalkieService.instance.toggleLockChannel(newState);
              },
            )),
        ],
      ),
    );
  }

  Widget _buildActiveSpeaker() {
    final speaker = controller.activeSpeakerName.value;
    final image = controller.activeSpeakerImage.value;
    final hasSpeaker = speaker.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: hasSpeaker
            ? Colors.greenAccent.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasSpeaker ? Colors.greenAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: image.isNotEmpty
                    ? NetworkImage(ConstRes.aImageBaseUrl + image)
                    : null,
                child: image.isEmpty
                    ? Icon(Icons.person, color: Colors.white54, size: 30.sp)
                    : null,
              ),
              if (hasSpeaker)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic, size: 12.sp, color: Colors.black),
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
                  hasSpeaker ? speaker : "No one is talking",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasSpeaker ? "Speaking..." : "Channel Open",
                  style: TextStyle(
                    color: hasSpeaker ? Colors.greenAccent : Colors.white54,
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

  Widget _buildStatusMessage() {
    if (!controller.showStatus.value) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        controller.statusMessage.value,
        style: TextStyle(color: Colors.orange, fontSize: 13.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildParticipantsList() {
    if (controller.participants.isEmpty) {
      return Center(
        child: Text(
          "Waiting for participants to connect...",
          style: TextStyle(color: Colors.white54, fontSize: 14.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.participants.length,
      itemBuilder: (context, index) {
        final p = controller.participants[index];
        return _buildParticipantTile(p);
      },
    );
  }

  Widget _buildParticipantTile(WalkieParticipant p) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (p.isSpeaking) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.mic;
      statusText = "Speaking";
    } else if (p.isMuted) {
      statusColor = Colors.red;
      statusIcon = Icons.volume_off;
      statusText = "Muted";
    } else {
      statusColor = Colors.blueAccent;
      statusIcon = Icons.hearing;
      statusText = "Listening";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: p.isSpeaking
            ? Colors.greenAccent.withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: p.isSpeaking
              ? Colors.greenAccent.withOpacity(0.5)
              : Colors.transparent,
        ),
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
                    ? Icon(Icons.person, color: Colors.white54, size: 24.sp)
                    : null,
              ),
              if (p.isSpeaking)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0A0E27), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              p.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(statusIcon, color: statusColor, size: 18.sp),
          SizedBox(width: 6.w),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPTTSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (_) => _onPTTPressed(),
            onTapUp: (_) => _onPTTReleased(),
            onTapCancel: () => _onPTTReleased(),
            child: Obx(() {
              final isBusy = controller.activeSpeakerId.value.isNotEmpty &&
                  !controller.isTalking;
              final isLocked = controller.isChannelLocked.value;

              return ScaleTransition(
                scale: _pulse,
                child: Container(
                  height: 140.r,
                  width: 140.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isTalking
                        ? Colors.greenAccent
                        : isBusy || isLocked
                        ? Colors.grey.shade700
                        : Colors.blueAccent,
                    boxShadow: controller.isTalking
                        ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    isLocked
                        ? Icons.lock
                        : isBusy
                        ? Icons.mic_off
                        : Icons.mic,
                    size: 56.sp,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),
          Obx(() => Text(
            controller.isTalking
                ? "Release to transmit"
                : controller.isChannelLocked.value
                ? "Channel Locked"
                : controller.activeSpeakerId.value.isNotEmpty
                ? "Wait for your turn"
                : "Push to Talk",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          )),
        ],
      ),
    );
  }
}