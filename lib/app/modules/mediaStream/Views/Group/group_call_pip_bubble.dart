import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../Controller/group_calling_controller.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class GroupCallPipBubble extends StatelessWidget {
  const GroupCallPipBubble({super.key});

  static const double pipW = 160;
  static const double pipH = 260;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GroupCallingController>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<GroupCallingController>();

    return Material(
      color: Colors.black,
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: pipW,
        height: pipH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => _restoreFullCall(c),
                // MUST be Obx so tiles rebuild when people join / video flips
                child: Obx(() {
                  final _ = c.activeParticipants.length;
                  final __ = c.screenSharingUsers.length;
                  final ___ = c.pinnedUserId.value;
                  final ____ = c.callDurationSeconds.value;
                  final _____ = c.isVideoOn.value;
                  return _WhatsAppPipGrid(controller: c);
                }),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${c.activeParticipants.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 6,
              bottom: 6,
              child: Row(
                children: [
                  Obx(() => Text(
                    c.formattedDuration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(blurRadius: 6, color: Colors.black),
                      ],
                    ),
                  )),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      try {
                        if (PictureInPicture.isActive) {
                          PictureInPicture.stopPiP();
                        }
                      } catch (_) {}
                      await c.endCall();
                    },
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.call_end, color: Colors.white, size: 14),
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

  void _restoreFullCall(GroupCallingController c) {
    try {
      if (PictureInPicture.isActive) PictureInPicture.stopPiP();
    } catch (_) {}

    if (Get.currentRoute != Routes.groupCallingScreen) {
      Get.toNamed(Routes.groupCallingScreen, arguments: {
        'groupId': c.groupId,
        'groupName': c.groupName,
        'groupProfile': c.groupProfile,
        'isVideo': c.isVideo,
        'callType': 'ongoing',
        'callId': c.callId,
        'memberCount': c.totalMemberCount,
      });
    }
  }
}

class _WhatsAppPipGrid extends StatelessWidget {
  const _WhatsAppPipGrid({required this.controller});

  final GroupCallingController controller;

  @override
  Widget build(BuildContext context) {
    final people = _orderedParticipants(controller);
    if (people.isEmpty) {
      return const ColoredBox(
        color: Color(0xFF0F0B29),
        child: Center(child: Icon(Icons.call, color: Colors.white54, size: 28)),
      );
    }

    switch (people.length) {
      case 1:
        return _tile(controller, people[0]);
      case 2:
        return Column(
          children: [
            Expanded(child: _tile(controller, people[0])),
            const SizedBox(height: 2),
            Expanded(child: _tile(controller, people[1])),
          ],
        );
      case 3:
        return Column(
          children: [
            Expanded(flex: 3, child: _tile(controller, people[0])),
            const SizedBox(height: 2),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _tile(controller, people[1])),
                  const SizedBox(width: 2),
                  Expanded(child: _tile(controller, people[2])),
                ],
              ),
            ),
          ],
        );
      default:
        final first4 = people.take(4).toList();
        final extra = people.length - 4;
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _tile(controller, first4[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _tile(controller, first4[1])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _tile(controller, first4[2])),
                  const SizedBox(width: 2),
                  Expanded(
                    child: _tile(
                      controller,
                      first4[3],
                      overflowBadge: extra > 0 ? extra : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  List<GroupCallParticipant> _orderedParticipants(GroupCallingController c) {
    final list = List<GroupCallParticipant>.from(c.activeParticipants);
    if (list.isEmpty) return list;

    int rank(GroupCallParticipant p) {
      final live = _resolveRenderer(c, p).hasVideo;
      if (c.isUserScreenSharing(p.userId) && live) return 0;
      if (c.isUserScreenSharing(p.userId)) return 1;
      if (c.pinnedUserId.value != null && p.userId == c.pinnedUserId.value) {
        return 2;
      }
      if (!p.isLocal && live) return 3;
      if (!p.isLocal) return 4;
      return 5;
    }

    list.sort((a, b) => rank(a).compareTo(rank(b)));
    return list;
  }
}

Widget _tile(
    GroupCallingController c,
    GroupCallParticipant p, {
      int? overflowBadge,
    }) {
  return _PipParticipantTile(
    controller: c,
    participant: p,
    overflowBadge: overflowBadge,
  );
}

class _PipParticipantTile extends StatelessWidget {
  const _PipParticipantTile({
    required this.controller,
    required this.participant,
    this.overflowBadge,
  });

  final GroupCallingController controller;
  final GroupCallParticipant participant;
  final int? overflowBadge;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveRenderer(controller, participant);
    final img = participant.profileImage;
    final sharing = controller.isUserScreenSharing(participant.userId);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (resolved.hasVideo && resolved.renderer != null)
          RTCVideoView(
            resolved.renderer!,
            key: ValueKey('pip_${participant.userId}'),
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            mirror: participant.isLocal && controller.isFrontCamera.value,
          )
        else
          ColoredBox(
            color: const Color(0xFF1C1C2E),
            child: Center(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white12,
                backgroundImage:
                (img != null && img.isNotEmpty) ? NetworkImage(img) : null,
                child: (img == null || img.isEmpty)
                    ? Text(
                  _initials(participant.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
                    : null,
              ),
            ),
          ),
        Positioned(
          left: 4,
          right: 4,
          bottom: 4,
          child: Text(
            participant.isLocal ? 'You' : (participant.name ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
        Obx(() {
          if (!participant.isMuted.value) return const SizedBox.shrink();
          return const Positioned(
            top: 4,
            right: 4,
            child: Icon(Icons.mic_off, color: Colors.white, size: 12),
          );
        }),
        if (sharing)
          const Positioned(
            top: 4,
            left: 4,
            child: Icon(Icons.screen_share,
                color: Colors.lightGreenAccent, size: 12),
          ),
        if (overflowBadge != null && overflowBadge! > 0)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '+$overflowBadge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _ResolvedVideo {
  _ResolvedVideo(this.renderer, this.hasVideo);
  final RTCVideoRenderer? renderer;
  final bool hasVideo;
}

_ResolvedVideo _resolveRenderer(
    GroupCallingController c,
    GroupCallParticipant p,
    ) {
  RTCVideoRenderer? renderer = p.renderer;
  try {
    if (p.isLocal) {
      renderer ??= c.localRenderer;
    } else {
      renderer ??= Socket_GroupCallService.instance.remoteRenderers[p.userId];
    }
  } catch (_) {}

  bool live = false;
  try {
    final stream = renderer?.srcObject;
    if (stream != null) {
      final tracks = stream.getVideoTracks();
      if (tracks.isNotEmpty) {
        final t = tracks.first;
        live = (t.enabled ?? false) && (t.muted != true);
      }
    }
  } catch (_) {}

  return _ResolvedVideo(renderer, live);
}