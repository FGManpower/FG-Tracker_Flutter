import 'dart:convert';
import 'package:fgtracker/app/global_widget/app_back_button.dart';

import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/Core/util/media_url.dart';
import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:fgtracker/app/modules/Messages/Controller/message_receipts.dart';
import 'package:fgtracker/app/modules/Messages/widgets/missing_media_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/DocumentService.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/util/file_helper.dart';
import '../../../Core/util/profile_navigation.dart';
import '../../../global_widget/common_widget.dart';
import '../../status/views/StatusViewScreen.dart';
import 'AudioPlayerWidget.dart';
import 'ContactBubbleWidget.dart';
import 'LocationBubbleWidget.dart';
import '../../Attendance/models/attendance_poll_model.dart';
import '../../Attendance/widgets/attendance_chat_card.dart';
import '../../../Data/Services/chat_translation_service.dart';
import 'chat_translation_widgets.dart';
import 'MessageContextMenu.dart';
import '../../../widgets/MessageInfoSheet.dart';
import '../../../Data/Services/call_service.dart';
import '../../../Data/Services/group_call_service.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';

/// Text bubbles shrink-wrap via IntrinsicWidth. The attendance card has
/// full-width bars and buttons (infinite intrinsic width), which crashes
/// IntrinsicWidth, so it fills the bubble's max width instead.
// ---- Bubble look (UI only, F-1.2.6) ----
// Received: white. Mine: light lavender with a purple outline. All corners
// rounded, no avatars, group sender names in a colour per sender.
const Color _kMyBubbleBg = Color(0xFFF8F6FF);
const Color _kMyBubbleBorder = Color(0xFF7B6CF6);

BorderRadius _bubbleRadius() => BorderRadius.circular(14.r);

Border? _bubbleBorder({required bool isSentByMe, required bool isAttendance}) =>
    (isSentByMe && !isAttendance)
        ? Border.all(color: _kMyBubbleBorder, width: 1.2)
        : null;

const List<Color> _kSenderNameColors = [
  Color(0xFFE8710A), // orange
  Color(0xFF1E9E5A), // green
  Color(0xFF5045B9), // purple
  Color(0xFFD63384), // pink
  Color(0xFF0B7FC1), // blue
  Color(0xFFB8860B), // dark gold
  Color(0xFF8E44AD), // violet
  Color(0xFF00897B), // teal
];

/// Same sender → same colour, in every group and every session.
Color senderNameColor(Object? senderId) {
  final key = senderId?.toString() ?? '';
  if (key.isEmpty) return _kSenderNameColors[2];
  var hash = 0;
  for (final c in key.codeUnits) {
    hash = (hash * 31 + c) & 0x7fffffff;
  }
  return _kSenderNameColors[hash % _kSenderNameColors.length];
}

/// WhatsApp-style single photo: shown in its own shape (portrait taller,
/// landscape wider) instead of a fixed 220×200 box. Very tall / very wide
/// photos are clamped and cropped like WhatsApp. The shape is read once per
/// URL and remembered, so scrolling back never makes the list jump.
class ChatImageAspectBox extends StatefulWidget {
  final String imageUrl;
  final double width;

  /// Builds the tile for the computed height.
  final Widget Function(double height) builder;

  const ChatImageAspectBox({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.builder,
  });

  /// height / width, per image URL.
  static final Map<String, double> _ratios = {};

  /// Tallest portrait and widest landscape shown in full.
  static const double maxRatio = 1.4;
  static const double minRatio = 0.55;

  @override
  State<ChatImageAspectBox> createState() => _ChatImageAspectBoxState();
}

class _ChatImageAspectBoxState extends State<ChatImageAspectBox> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ChatImageAspectBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _stop();
      _resolve();
    }
  }

  void _resolve() {
    final url = widget.imageUrl;
    if (url.isEmpty || ChatImageAspectBox._ratios.containsKey(url)) return;
    _listener = ImageStreamListener(
      (info, _) {
        final w = info.image.width;
        final h = info.image.height;
        if (w > 0 && h > 0) {
          ChatImageAspectBox._ratios[url] = h / w;
          if (mounted) setState(() {});
        }
        _stop();
      },
      onError: (_, __) => _stop(),
    );
    _stream = CachedNetworkImageProvider(url, maxWidth: 600)
        .resolve(ImageConfiguration.empty)
      ..addListener(_listener!);
  }

  void _stop() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Square while the size is unknown (first load), like WhatsApp.
    final ratio = (ChatImageAspectBox._ratios[widget.imageUrl] ?? 1.0)
        .clamp(ChatImageAspectBox.minRatio, ChatImageAspectBox.maxRatio);
    return widget.builder(widget.width * ratio);
  }
}

Widget _bubbleWidth({required bool isAttendance, required Widget child}) {
  if (isAttendance) {
    return SizedBox(width: double.infinity, child: child);
  }
  return IntrinsicWidth(child: child);
}

/// Placeholder for a message the app can't draw (unknown type or a row that
/// failed to parse). It keeps the list intact instead of breaking it.
Widget _unsupportedMessageContent(bool isSentByMe) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.info_outline_rounded,
          size: 16.sp, color: Colors.grey.shade600),
      SizedBox(width: 6.w),
      Flexible(
        child: Text(
          appL10n.chat_unsupportedMessage,
          style: TextStyle(
            fontSize: 12.sp,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    ],
  );
}

/// Seen tick state. `seenCount` is dynamic and may arrive as a string;
/// comparing it with `>` directly threw and broke the bubble.
bool _seenAtLeastOnce(MessageData message) =>
    (int.tryParse(message.seenCount?.toString() ?? '') ?? 0) > 0;

/// Server URL of a document message. Empty when the message has no file.
String _documentFullUrl(String path) {
  final value = path.trim();
  if (value.isEmpty || value == 'null') return '';
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  return '${ConstRes.aImageBaseUrl}$value';
}

/// Playable URL of a voice/audio message. Empty when the message has no
/// file, so the bubble shows "Media is missing" instead of a dead player.
String _audioFullUrl(dynamic content) {
  final value = content?.toString().trim() ?? '';
  if (value.isEmpty || value == 'null') return '';
  return resolveMediaUrl(value);
}

/// Extracts caption for an attachment message, falling back to non-media text
/// in content if caption is empty (covers real-time edits and history API).
String _resolveAttachmentCaption(MessageData message) {
  final cap = (message.caption?.toString() ?? '').trim();
  if (cap.isNotEmpty && cap != 'null') return cap;
  final content = (message.content?.toString() ?? '').trim();
  if (content.isNotEmpty &&
      content != 'null' &&
      !content.contains('||') &&
      !ChatScreenRules.looksLikeMediaUrl(content)) {
    return content;
  }
  return '';
}

/// Quoted message shown at the top of a reply bubble (private + group).
/// Built from the original message when it is loaded, otherwise from the
/// reply fields, so it never renders empty for any message type.
Widget _quotedReplyCard({
  required MessageData message,
  required bool isSentByMe,
  required MessageData? original,
  required Future<void> Function(int messageId) onTap,
}) {
  final replyId = int.tryParse(message.replyId?.toString() ?? '');
  if (replyId == null) return const SizedBox.shrink();

  const purple = Color(0xFF5045B9);
  final currentUserId =
      Global.storageServices.get(PrefConst.userId)?.toString();
  final preview =
      MessagePreviewBuilder.forQuotedReply(message, original: original).display;
  final sender = MessagePreviewBuilder.replySenderLabel(
    message,
    original: original,
    currentUserId: currentUserId,
  );

  return GestureDetector(
    onTap: () => onTap(replyId),
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSentByMe
            ? Colors.white.withValues(alpha: .5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: const Border(left: BorderSide(color: purple, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sender.isNotEmpty) ...[
            Text(
              sender,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: purple,
              ),
            ),
            SizedBox(height: 2.h),
          ],
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    ),
  );
}

String formatSystemMessageText(MessageData message, String currentUserId) {
  final meta = message.systemMeta;
  final defaultContent = message.content?.toString() ?? '';
  if (meta == null || meta.isEmpty) {
    return defaultContent;
  }

  final action = meta['action']?.toString() ?? '';
  final actorId = meta['actorId']?.toString();
  final targetUserId = (meta['targetUserId'] ??
          meta['userId'] ??
          meta['promotedUserId'] ??
          meta['demotedUserId'] ??
          meta['removedUserId'])
      ?.toString();
  final l = appL10n;
  // 'Admin' / 'Member' are the old English fallbacks (logic ids); only the
  // displayed text is translated. Names from the server are shown as sent.
  final rawTarget = meta['targetName']?.toString();
  final hasTargetName =
      rawTarget != null && rawTarget.isNotEmpty && rawTarget != 'Member';
  final actorName = meta['actorName']?.toString() ?? l.groupInfo_admin;
  final targetName = hasTargetName ? rawTarget : l.groupInfo_member;
  final groupName = meta['groupName']?.toString();
  final newName = meta['newName']?.toString();

  final isMeActor = actorId == currentUserId;
  final addedUserIdsRaw = meta['addedUserIds'];
  final List<String> addedUserIds = addedUserIdsRaw is List
      ? addedUserIdsRaw.map((e) => e.toString()).toList()
      : [];
  final isMeTarget =
      targetUserId == currentUserId || addedUserIds.contains(currentUserId);

  switch (action) {
    case 'member_added':
      if (isMeTarget && !isMeActor) {
        return groupName != null
            ? l.chatSys_youWereAddedTo(actorName, groupName)
            : l.chatSys_actorAddedYou(actorName);
      }
      if (isMeActor) {
        if (hasTargetName) {
          return groupName != null
              ? l.chatSys_youAddedTo(groupName, targetName)
              : l.chatSys_youAdded(targetName);
        }
        // The server text ("<actor> added A, B") can only be rewritten to
        // "You added A, B" in English; other languages use the short form.
        if (defaultContent.isNotEmpty && l.localeName.startsWith('en')) {
          return defaultContent.replaceFirst(
              RegExp('^' + RegExp.escape(actorName) + '\s+'), 'You ');
        }
        return l.chatSys_youAddedMembers;
      }
      return defaultContent.isNotEmpty
          ? defaultContent
          : (groupName != null
              ? l.chatSys_actorAddedTo(actorName, groupName, targetName)
              : l.chatSys_actorAdded(actorName, targetName));

    case 'member_joined':
      if (isMeActor || isMeTarget) {
        return l.chatSys_youJoinedViaLink;
      }
      return defaultContent.isNotEmpty
          ? defaultContent
          : l.chatSys_joinedViaLink(targetName);

    case 'member_left':
      if (isMeTarget || isMeActor) return l.chatSys_youLeft;
      return l.chatSys_left(targetName);

    case 'member_removed':
      if (isMeTarget) {
        return groupName != null
            ? l.chatSys_youWereRemovedFrom(groupName)
            : l.chatSys_youWereRemoved;
      }
      if (isMeActor) {
        return groupName != null
            ? l.chatSys_youRemovedFrom(groupName, targetName)
            : l.chatSys_youRemoved(targetName);
      }
      return groupName != null
          ? l.chatSys_actorRemovedFrom(actorName, groupName, targetName)
          : l.chatSys_actorRemoved(actorName, targetName);

    case 'admin_promoted':
      if (isMeTarget) {
        return groupName != null
            ? l.chatSys_youAreAdminIn(groupName)
            : l.chatSys_youAreAdmin;
      }
      if (isMeActor) {
        return groupName != null
            ? l.chatSys_youMadeAdminIn(groupName, targetName)
            : l.chatSys_youMadeAdmin(targetName);
      }
      return groupName != null
          ? l.chatSys_actorMadeAdminIn(actorName, groupName, targetName)
          : l.chatSys_actorMadeAdmin(actorName, targetName);

    case 'admin_demoted':
      if (isMeTarget) {
        return groupName != null
            ? l.chatSys_youNoLongerAdminIn(groupName)
            : l.chatSys_youNoLongerAdmin;
      }
      if (isMeActor) {
        return groupName != null
            ? l.chatSys_youDismissedAdminIn(groupName, targetName)
            : l.chatSys_youDismissedAdmin(targetName);
      }
      return groupName != null
          ? l.chatSys_actorDismissedAdminIn(actorName, groupName, targetName)
          : l.chatSys_actorDismissedAdmin(actorName, targetName);

    case 'group_name_changed':
      if (isMeActor) {
        return newName != null && newName.isNotEmpty
            ? l.chatSys_youRenamedTo(newName)
            : l.chatSys_youRenamed;
      }
      return newName != null && newName.isNotEmpty
          ? l.chatSys_actorRenamedTo(actorName, newName)
          : l.chatSys_actorRenamed(actorName);

    case 'group_icon_changed':
      if (isMeActor) return l.chatSys_youChangedIcon;
      return l.chatSys_actorChangedIcon(actorName);

    case 'group_description_changed':
      if (isMeActor) return l.chatSys_youChangedDesc;
      return l.chatSys_actorChangedDesc(actorName);

    case 'group_settings_changed':
      final onlyAdmins = meta['onlyAdminsCanSend'] == true ||
          meta['onlyAdminsCanSend'] == 1 ||
          meta['onlyAdminsCanSend'] == 'true';
      if (isMeActor) {
        return onlyAdmins
            ? l.chatSys_youSetAdminsOnly
            : l.chatSys_youSetAllCanSend;
      }
      return defaultContent.isNotEmpty
          ? defaultContent
          : (onlyAdmins
              ? l.chatSys_actorSetAdminsOnly(actorName)
              : l.chatSys_actorSetAllCanSend(actorName));

    default:
      return defaultContent;
  }
}

/// People named in a system message ("sarita added prashant"), shown bold.
List<String> _systemMessageNames(MessageData message) {
  final meta = message.systemMeta;
  if (meta == null) return const [];
  final names = <String>{};
  for (final key in const ['actorName', 'targetName']) {
    final v = meta[key]?.toString().trim() ?? '';
    if (v.isNotEmpty) names.add(v);
  }
  final added = meta['addedNames'] ?? meta['addedUserNames'];
  if (added is List) {
    for (final n in added) {
      final v = n?.toString().trim() ?? '';
      if (v.isNotEmpty) names.add(v);
    }
  }
  // Longest first, so "Asha Rani" wins over "Asha".
  return names.toList()..sort((a, b) => b.length.compareTo(a.length));
}

Widget _buildSystemMessageTile(String content,
    {List<String> boldNames = const []}) {
  final normal = TextStyle(
    fontSize: 11.5.sp,
    color: Colors.grey.shade700,
    fontWeight: FontWeight.w500,
  );
  final bold = normal.copyWith(
    color: const Color(0xFF1B1B1B),
    fontWeight: FontWeight.w700,
  );

  // Split the text around the names (UI only; the text itself is unchanged).
  final spans = <TextSpan>[];
  var rest = content;
  while (rest.isNotEmpty && boldNames.isNotEmpty) {
    var at = -1;
    var name = '';
    for (final n in boldNames) {
      final i = rest.indexOf(n);
      if (i != -1 && (at == -1 || i < at)) {
        at = i;
        name = n;
      }
    }
    if (at == -1) break;
    if (at > 0) spans.add(TextSpan(text: rest.substring(0, at)));
    spans.add(TextSpan(text: name, style: bold));
    rest = rest.substring(at + name.length);
  }
  if (rest.isNotEmpty) spans.add(TextSpan(text: rest));

  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text.rich(
        TextSpan(style: normal, children: spans),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget _buildCallLogTile({
  required BuildContext context,
  required MessageData message,
  required bool isSentByMe,
  required VoidCallback onCallBack,
}) {
  final content = message.content?.toString() ?? 'Voice call';
  final isMissed = content.toLowerCase().contains('missed') ||
      content.toLowerCase().contains('declined') ||
      message.callLogMeta?['callStatus'] == 'missed' ||
      message.callLogMeta?['callStatus'] == 'rejected' ||
      message.callLogMeta?['callStatus'] == 'busy';

  final isVideo = content.toLowerCase().contains('video') ||
      message.callLogMeta?['isVideo'] == true ||
      message.callLogMeta?['callType'] == 'video';

  final iconData = isVideo
      ? (isMissed ? Icons.missed_video_call_rounded : Icons.videocam_rounded)
      : (isMissed ? Icons.phone_missed_rounded : Icons.phone_callback_rounded);

  final iconColor =
      isMissed ? const Color(0xFFE53935) : const Color(0xFF43A047);

  String timeStr = '';
  if (message.timestamp != null) {
    try {
      final dt = DateTime.parse(message.timestamp.toString()).toLocal();
      timeStr =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {}
  }

  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F4),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: iconColor, size: 16.sp),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color:
                    isMissed ? const Color(0xFFE53935) : Colors.grey.shade800,
              ),
            ),
          ),
          if (timeStr.isNotEmpty) ...[
            SizedBox(width: 6.w),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          SizedBox(width: 8.w),
          InkWell(
            onTap: onCallBack,
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                    size: 12.sp,
                    color: const Color(0xFF5045B9),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    context.l10n.chatSys_callBack,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5045B9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final MessageController controller;
  final bool showAvatar;
  final bool isDense;

  const ChatBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.context,
    this.showAvatar = true,
    this.isDense = false,
  });

  static const Color _purple = Color(0xFF5045B9);
  static const Color _myBubbleBg = _kMyBubbleBg;
  static const Color _otherBubbleBg = Colors.white;

  bool get _isDeletedMessage =>
      message.isDeleted == true ||
      message.isDeleted.toString() == 'true' ||
      message.isDeleted.toString() == '1' ||
      message.isDeletedForEveryone == true ||
      message.content?.toString() == "This message was deleted" ||
      message.content?.toString() == "You deleted this message";

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    if (message.isSystemMessage) {
      return _buildSystemMessageTile(
        formatSystemMessageText(message, currentUserId),
        boldNames: _systemMessageNames(message),
      );
    }

    if (message.isCallLogMessage) {
      return _buildCallLogTile(
        context: context,
        message: message,
        isSentByMe: isSentByMe,
        onCallBack: () {
          try {
            final isVideo =
                message.content?.toString().toLowerCase().contains('video') ==
                        true ||
                    message.callLogMeta?['isVideo'] == true ||
                    message.callLogMeta?['callType'] == 'video';
            final myId =
                Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
            final remoteId = isSentByMe
                ? (message.receiverId?.toString() ?? '')
                : (message.senderId?.toString() ?? '');
            final finalRemoteId = remoteId.isNotEmpty && remoteId != '0'
                ? remoteId
                : (controller.memberData.userId?.toString() ?? '');
            final targetName = controller.memberData.name?.toString() ?? 'User';
            final targetPic = controller.memberData.profileImage;
            CallService().startOutGoingCall(
              context,
              callerId: myId,
              remoteUserId: finalRemoteId,
              is_video: isVideo,
              callerName: targetName,
              callerProfile: targetPic,
            );
          } catch (_) {}
        },
      );
    }

    // No avatar next to received bubbles (UI, F-1.2.6): the app bar
    // already shows and opens the contact's profile.
    return Container(
      margin: EdgeInsets.symmetric(vertical: isDense ? 2.h : 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Obx(() {
              // Read the observable unconditionally: an Obx that reads none
              // (e.g. for attendance cards) throws "improper use of GetX".
              final isHighlighted =
                  controller.highlightedMessageId.value == message.id;

              return Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (bubbleContext) {
                      return GestureDetector(
                        onLongPress: () => _showMessageMenu(
                          bubbleContext,
                          isSentByMe,
                          messageWidget: _buildBubbleContainer(
                            context,
                            isSentByMe,
                            isHighlighted: isHighlighted,
                          ),
                        ),
                        child: _buildBubbleContainer(
                          context,
                          isSentByMe,
                          isHighlighted: isHighlighted,
                        ),
                      );
                    },
                  ),
                  if (!_isDeletedMessage &&
                      message.reactions != null &&
                      message.reactions!.isNotEmpty)
                    _buildReactionPill(message, isSentByMe),
                  if (!isSentByMe &&
                      !_isDeletedMessage &&
                      _getTranslatableText(message).isNotEmpty)
                    ChatMessageActionRow(
                      messageId: _getMessageTranslationId(message),
                      originalText: _getTranslatableText(message),
                      isSentByMe: isSentByMe,
                      // Plain text has the speaker inside the bubble.
                      showListen: !_isPlainTextMessage(message),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContainer(
    BuildContext context,
    bool isSentByMe, {
    bool isHighlighted = false,
  }) {
    final bgColor = isSentByMe ? _myBubbleBg : _otherBubbleBg;
    final textColor = Colors.black87;
    final borderRadius = _bubbleRadius();
    final isAttendance =
        !_isDeletedMessage && message.messageType == "attendance";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxWidth: isAttendance
            ? MediaQuery.of(context).size.width * 0.88
            : MediaQuery.of(context).size.width * 0.75,
      ),
      padding: isAttendance
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
      decoration: BoxDecoration(
        color: isAttendance
            ? Colors.transparent
            : (isHighlighted
                ? Colors.yellow.withValues(alpha: .35)
                : bgColor),
        borderRadius: isAttendance
            ? BorderRadius.circular(20.r)
            : borderRadius,
        border: _bubbleBorder(
          isSentByMe: isSentByMe,
          isAttendance: isAttendance,
        ),
        boxShadow: isAttendance
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: _bubbleWidth(
        isAttendance: isAttendance,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isDeletedMessage)
              _buildReplyPreview(
                message,
                isSentByMe,
              ),
            if (!_isDeletedMessage && message.isForwarded == true)
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forward_rounded,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      context.l10n.chat_forwarded,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isDeletedMessage) ...[
              _buildDeletedContent(isSentByMe),
            ] else if (_isPlainTextMessage(message)) ...[
              _buildTextWithTime(
                message: message,
                textColor: textColor,
                isSentByMe: isSentByMe,
              ),
              if (!isSentByMe) _buildTranslatedCard(message),
            ] else ...[
              _buildMessageContent(
                message,
                textColor,
                isSentByMe,
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: _buildTimeRow(
                  isSentByMe,
                ),
              ),
              if (!isSentByMe) _buildTranslatedCard(message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedContent(bool isSentByMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.block_rounded,
          size: 14.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            isSentByMe
                ? appL10n.chat_previewOwnDeleted
                : appL10n.chat_messageDeleted,
            style: TextStyle(
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  String _getTranslatableText(MessageData message) {
    if (_isDeletedMessage) return '';

    if (_isPlainTextMessage(message)) {
      return (message.content?.toString() ?? '').trim();
    }

    final caption = _resolveAttachmentCaption(message);
    if (caption.isNotEmpty) {
      return caption;
    }

    if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName).trim();
      return documentName;
    }

    if (message.messageType == "contact") {
      final content = (message.content?.toString() ?? '').trim();
      if (content.isNotEmpty && !content.startsWith('{')) return content;
    }

    return '';
  }

  String _getMessageTranslationId(MessageData message) {
    if (message.id != null &&
        message.id.toString().isNotEmpty &&
        message.id.toString() != "0") {
      return message.id.toString();
    }
    final text = _getTranslatableText(message);
    final raw = text.isNotEmpty ? text : (message.content?.toString() ?? '');
    return "msg_${raw.hashCode}";
  }

  Widget _buildTranslatedCard(MessageData message) {
    final translatableText = _getTranslatableText(message);
    if (translatableText.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final mId = _getMessageTranslationId(message);
      final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(translatableText);
      final targetLang = isHindi ? 'en' : 'hi';
      final cacheKey = '${mId}_$targetLang';
      final translationService = ChatTranslationService.instance;
      final translated = translationService.translations[cacheKey];
      final isShown = translationService.showTranslated[cacheKey] == true;

      if (translated != null && translated.isNotEmpty && isShown) {
        return ChatTranslatedCard(
          messageId: mId,
          translatedText: translated,
          targetLang: targetLang,
          onToggleOriginal: () {
            translationService.toggleTranslationVisibility(
              mId,
              targetLang: targetLang,
            );
          },
        );
      }
      return const SizedBox.shrink();
    });
  }

  bool _isPlainTextMessage(MessageData message) {
    final type =
        (message.messageType?.toString() ?? "text").toLowerCase().trim();
    if (type == "text" || type == "text_message" || type.isEmpty) {
      return true;
    }
    if ((type == "forward" ||
            type == "forwarded" ||
            type == "forward_message") &&
        (message.images?.isEmpty ?? true) &&
        (message.videos?.isEmpty ?? true)) {
      return true;
    }
    return false;
  }

  Widget _buildTimeRow(bool isSentByMe) {
    final wasEdited = !_isDeletedMessage &&
        (message.isEdited == true ||
            message.isEdited?.toString() == 'true' ||
            message.isEdited?.toString() == '1' ||
            message.edited == true ||
            message.edited?.toString() == 'true' ||
            message.edited?.toString() == '1');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (wasEdited) ...[
          Text(
            appL10n.chat_edited,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          appTime(DateTime.parse(message.timestamp ?? "").toLocal()),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isSentByMe && !_isDeletedMessage) ...[
          SizedBox(width: 3.w),
          Icon(
            (_seenAtLeastOnce(message) || message.isDelivered)
                ? Icons.done_all
                : Icons.done,
            size: 14.sp,
            color: _seenAtLeastOnce(message) ? _purple : Colors.grey.shade500,
          ),
        ],
      ],
    );
  }

  Widget _buildTextWithTime({
    required MessageData message,
    required Color textColor,
    required bool isSentByMe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextContent(
            message,
            textColor,
            isSentByMe,
          ),
        ),
        // Speaker inside received text bubbles, before the time (UI, F-1.2.6).
        if (!isSentByMe) ...[
          SizedBox(width: 6.w),
          ChatInlineListenButton(
            messageId: _getMessageTranslationId(message),
            originalText: _getTranslatableText(message),
          ),
          SizedBox(width: 6.w),
        ] else
          SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  Widget _buildTextContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final query = controller.searchQuery.value;
    String content = message.content?.toString() ?? "";
    if (content.trim().isEmpty &&
        (message.caption?.toString() ?? "").trim().isNotEmpty) {
      content = message.caption!.toString();
    }

    if (query.isNotEmpty &&
        content.toLowerCase().contains(query.toLowerCase())) {
      return _buildHighlightedText(
        content,
        query,
        normalStyle: TextStyle(
          color: textColor,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
        highlightStyle: TextStyle(
          backgroundColor: const Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
      );
    }

    return Linkify(
      text: content,
      style: TextStyle(
        color: textColor,
        fontSize: 13.sp,
        fontFamily: FontFamily.interMedium,
        height: 1.35,
      ),
      linkStyle: TextStyle(
        color: _purple,
        decoration: TextDecoration.underline,
        fontSize: 13.sp,
      ),
      onOpen: (link) async {
        Uri uri = Uri.parse(link.url);

        if (!uri.hasScheme) {
          uri = Uri.parse("https://${link.url}");
        }

        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final msgType =
        (message.messageType?.toString() ?? '').toLowerCase().trim();
    final hasImages = (message.images?.isNotEmpty ?? false);
    final hasVideos = (message.videos?.isNotEmpty ?? false);

    if (msgType == "media" ||
        msgType == "image" ||
        msgType == "image_text" ||
        (msgType == "video" && hasVideos) ||
        ((msgType == "forward" ||
                msgType == "forwarded" ||
                msgType == "forward_message") &&
            (hasImages || hasVideos))) {
      final imageList = (message.images ?? [])
          .where((image) => image.trim().isNotEmpty)
          .toList();

      if (imageList.isEmpty &&
          (message.messageType == "image" ||
              message.messageType == "image_text")) {
        final imagePart = message.content?.toString() ?? "";
        if (imagePart.trim().isNotEmpty) {
          imageList.add(imagePart);
        }
      }

      final videos = (message.videos != null && message.videos!.isNotEmpty)
          ? message.videos!
          : ((message.messageType == "media" || message.messageType == "video")
              ? (message.videos ?? [])
              : <MessageVideo>[]);

      String getMediaUrl(String path) {
        final value = path.trim();
        if (value.isEmpty) return "";
        if (value.startsWith("http://") || value.startsWith("https://")) {
          return value;
        }
        return "${ConstRes.aImageBaseUrl}$value";
      }

      void openGallery(int index) {
        Get.to(
          () => GroupImageGallery(
            images: imageList,
            videos: videos,
            initialIndex: index,
          ),
        );
      }

      Widget buildImageTile(
        int index,
        double width,
        double height,
      ) {
        return GestureDetector(
          onTap: () => openGallery(index),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: getMediaUrl(imageList[index]),
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _purple,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      ChatImageErrorTile(url: url),
                ),
                if (index == 3 && imageList.length > 4)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      "+${imageList.length - 4}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      Widget buildVideoTile(MessageVideo video, int videoIndex) {
        final videoUrl = getMediaUrl(video.videoUrl ?? "");
        final thumbnailUrl = getMediaUrl(video.thumbnail ?? "");
        final duration = (video.duration ?? "").trim().isNotEmpty
            ? video.duration!
            : "--:--";

        return VideoThumbnailWidget(
          videoUrl: videoUrl,
          thumbnail: thumbnailUrl,
          duration: duration,
          onTap: () => openGallery(imageList.length + videoIndex),
        );
      }

      final mediaCount = imageList.length + videos.length;
      final caption = _resolveAttachmentCaption(message);

      if (mediaCount == 0) {
        return MissingMediaCard(
          type: MissingMediaType.media,
          isSentByMe: isSentByMe,
        );
      }

      return SizedBox(
        width: 220.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mediaCount == 1)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                // One photo: its own shape, like WhatsApp (F-1.2.6).
                child: imageList.isNotEmpty
                    ? ChatImageAspectBox(
                        imageUrl: getMediaUrl(imageList.first),
                        width: 220.w,
                        builder: (h) => buildImageTile(0, 220.w, h),
                      )
                    : SizedBox(
                        width: 220.w,
                        height: 200.h,
                        child: buildVideoTile(videos.first, 0),
                      ),
              )
            else
              Builder(
                builder: (context) {
                  final totalMedia = imageList.length + videos.length;
                  final visibleCount = totalMedia > 4 ? 4 : totalMedia;

                  return Wrap(
                    spacing: 4.w,
                    runSpacing: 4.w,
                    children: List.generate(visibleCount, (index) {
                      final isVideo = index >= imageList.length;
                      final remainingCount = totalMedia - 4;

                      return SizedBox(
                        width: 108.w,
                        height: 108.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isVideo)
                                buildVideoTile(
                                  videos[index - imageList.length],
                                  index - imageList.length,
                                )
                              else
                                buildImageTile(index, 108.w, 108.w),
                              if (index == 3 && remainingCount > 0)
                                Container(
                                  color: Colors.black54,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "+$remainingCount",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            if (caption.isNotEmpty) ...[
              SizedBox(height: 8.h),
              reausabletext(
                caption,
                color: textColor,
                fontsize: 12.sp,
              ),
            ],
          ],
        ),
      );
    } else if (message.messageType == "audio") {
      // Server audio location first (socket payloads), else content.
      final audioSrc = _audioFullUrl(message.audioUrl ?? message.content);
      final audioBubble = AudioBubble(
        // Temp → server message, or a later event with the URL: a new key
        // gives a fresh bubble, so the player loads the new source.
        key: ValueKey(
            'audio_${message.id ?? message.clientMessageId}_$audioSrc'),
        audioUrl: audioSrc,
        isMe: false,
      );
      final audioCaption = _resolveAttachmentCaption(message);
      if (audioCaption.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            audioBubble,
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: reausabletext(
                audioCaption,
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
          ],
        );
      }
      return audioBubble;
    } else if (message.messageType == "video") {
      final parts = message.content?.split("||") ?? [];
      final videoPath = parts.isNotEmpty ? parts[0].trim() : "";
      final rawThumbnailPath = parts.length > 1 ? parts[1].trim() : "";
      final duration = parts.length > 2 && parts[2].trim().isNotEmpty
          ? parts[2].trim()
          : "--:--";
      final videoUrl = _buildMediaUrl(videoPath);
      final thumbnailUrl = _buildMediaUrl(rawThumbnailPath);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoThumbnailWidget(
            videoUrl: videoUrl,
            thumbnail: thumbnailUrl,
            duration: duration,
            onTap: () {
              Get.toNamed(
                Routes.videoPlayerScreen,
                arguments: {
                  "videoUrl": videoUrl,
                },
              );
            },
          ),
          if (_resolveAttachmentCaption(message).isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                _resolveAttachmentCaption(message),
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName);
      final extension = documentName.split('.').last.toLowerCase();
      final fileSize = parts.length > 2 ? parts[2] : "";

      IconData icon;

      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf_rounded;
          break;
        case "doc":
        case "docx":
          icon = Icons.description_rounded;
          break;
        case "xls":
        case "xlsx":
          icon = Icons.table_chart_rounded;
          break;
        case "ppt":
        case "pptx":
          icon = Icons.slideshow_rounded;
          break;
        default:
          icon = Icons.insert_drive_file_rounded;
      }

      final documentFullUrl = _documentFullUrl(documentUrl);

      return MediaAvailabilityGuard(
        url: documentFullUrl,
        type: MissingMediaType.document,
        isSentByMe: isSentByMe,
        fileName: documentName,
        width: 240.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await DocumentService().openDocument(documentFullUrl);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 240.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? Colors.white.withValues(alpha: 0.6)
                      : const Color(0xFFF3F1FB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        color: _purple,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            documentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            fileSize.isNotEmpty
                                ? "$fileSize • ${extension.toUpperCase()}"
                                : extension.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    if (!isSentByMe) ...[
                      SizedBox(width: 6.w),
                      Obx(() {
                        final url = documentFullUrl;

                        if (DocumentService.isDownloading(url)) {
                          return SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _purple,
                            ),
                          );
                        }

                        return Icon(
                          DocumentService.isDownloaded(url)
                              ? Icons.download_done_rounded
                              : Icons.download_rounded,
                          color: _purple,
                          size: 20.sp,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            if (_resolveAttachmentCaption(message).isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: reausabletext(
                  _resolveAttachmentCaption(message),
                  color: textColor,
                  fontsize: 12.sp,
                  fontfamily: FontFamily.interMedium,
                ),
              ),
          ],
        ),
      );
    } else if (message.messageType == "location" ||
        message.messageType == "live_location") {
      return LocationBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
        senderName: isSentByMe ? "You" : controller.memberData.name,
        senderImage: isSentByMe ? null : controller.memberData.profileImage,
        onStopLiveLocation: () => controller.stopLiveLocation(message),
      );
    } else if (message.messageType == "contact") {
      return ContactBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else if (message.messageType == "attendance") {
      final isCreator = controller is GroupMessageController
          ? (controller as GroupMessageController).isCreator
          : null;

      final groupController = controller is GroupMessageController
          ? controller as GroupMessageController
          : null;

      final embedded = AttendancePoll.fromJson(message.attendance);
      final pollId = embedded?.id ??
          int.tryParse(message.attendancePollId?.toString() ?? "");
      if (pollId == null || pollId <= 0) {
        return _buildTextContent(message, textColor, isSentByMe);
      }

      return AttendanceChatCard(
        key: ValueKey("attendance_$pollId"),
        pollId: pollId,
        initialPoll: embedded,
        isAdmin: isCreator,
        groupMembers: groupController?.groupMembers,
        senderName: message.senderName?.toString() ?? "",
        groupName: groupController?.groupName.value ?? "",
        messageTime: message.timestamp?.toString(),
        onDeleted: groupController?.markAttendanceDeleted,
      );
    } else if (ChatScreenRules.isUnsupported(message)) {
      return _unsupportedMessageContent(isSentByMe);
    } else {
      return _buildTextContent(
        message,
        textColor,
        isSentByMe,
      );
    }
  }

  String _buildMediaUrl(String path) {
    if (path.trim().isEmpty) {
      return "";
    }

    final value = path.trim();

    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }

    return "${ConstRes.aImageBaseUrl}$value";
  }

  Widget _buildReplyPreview(
    MessageData message,
    bool isSentByMe,
  ) {
    if (message.isStatusReply) {
      return _buildStatusReplyPreview(message, isSentByMe);
    }

    return _quotedReplyCard(
      message: message,
      isSentByMe: isSentByMe,
      original: controller.findMessageById(message.replyId),
      onTap: controller.scrollToMessage,
    );
  }

  Widget _buildStatusReplyPreview(MessageData message, bool isSentByMe) {
    final status = message.replyStatus;
    final meta = message.statusMeta;

    final ownerName = status?.creator?.name ??
        meta?.ownerName ??
        message.replySenderName?.toString() ??
        appL10n.chat_statusLabel;

    final statusType =
        (status?.type ?? meta?.type ?? message.statusType?.toString() ?? 'text')
            .toString()
            .toLowerCase();

    final isVideo = statusType == 'video' || (status?.isVideo ?? false);
    final isImage = statusType == 'image' ||
        statusType == 'photo' ||
        (status?.isImage ?? false);

    final mediaUrl = status?.mediaUrl ?? meta?.mediaUrl;
    final thumbnailUrl = status?.thumbnailUrl ?? meta?.thumbnail ?? mediaUrl;
    final rawText = status?.content ??
        message.replyMessageContent?.toString() ??
        message.replyMessage?.toString() ??
        appL10n.chat_statusLabel;

    final cleanText = rawText.replaceAll(RegExp(r'^\[Status:\s*|\]$'), '');

    String typeLabel = appL10n.chat_statusLabel;
    if (isImage) {
      typeLabel = appL10n.chat_previewPhoto;
    } else if (isVideo) {
      typeLabel = appL10n.chat_previewVideo;
    } else {
      typeLabel = cleanText.isNotEmpty ? cleanText : appL10n.chat_statusLabel;
    }

    return GestureDetector(
      onTap: () => _openStatusFromReply(message),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.white.withValues(alpha: .55)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: const Border(
            left: BorderSide(
              color: _purple,
              width: 3.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5.sp,
                        color: _purple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : isImage
                                  ? Icons.photo_rounded
                                  : Icons.text_fields_rounded,
                          size: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(9.r),
                bottomRight: Radius.circular(9.r),
              ),
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: _buildStatusThumbnail(
                  status: status,
                  isImage: isImage,
                  isVideo: isVideo,
                  mediaUrl: thumbnailUrl,
                  textContent: cleanText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusThumbnail({
    StatusItemModel? status,
    required bool isImage,
    required bool isVideo,
    String? mediaUrl,
    required String textContent,
  }) {
    if ((isImage || isVideo) && mediaUrl != null && mediaUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
            memCacheWidth: 600,
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
          ),
          if (isVideo)
            Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      );
    }

    final bgColor = status?.parsedBgColor ?? const Color(0xFF10B981);

    return Container(
      color: bgColor,
      padding: EdgeInsets.all(4.w),
      alignment: Alignment.center,
      child: Text(
        textContent,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }

  void _openStatusFromReply(MessageData message) {
    final status = message.replyStatus;

    if (status == null || status.isExpired) {
      Utils().fluttertoast(appL10n.chat_statusUnavailable);
      return;
    }

    Get.to(() => StatusViewScreen(
          isOwnStatus: false,
          userName: status.creator?.name ??
              message.replySenderName?.toString() ??
              appL10n.chat_statusLabel,
          userAvatar: status.creator?.profilePic,
          statuses: [status],
          currentIndex: 0,
        ));
  }

  void _showMessageMenu(
    BuildContext bubbleContext,
    bool isSentByMe, {
    Widget? messageWidget,
  }) {
    final isPinned = controller.pinnedMessage.value?.id == message.id;
    final isText = message.messageType == "text" ||
        message.messageType == "text_message" ||
        (message.messageType ?? "").isEmpty;
    // Attendance messages have no delete option (see ChatScreenRules).
    final options = ChatScreenRules.menuOptions(
      messageType: message.messageType,
      isSentByMe: isSentByMe,
      isDeleted: _isDeletedMessage,
    );

    final actions = <MessageContextMenuAction>[
      if (options.contains(MessageMenuOption.reply))
        MessageContextMenuAction(
          icon: Icons.reply_rounded,
          title: appL10n.chat_menuReply,
          iconColor: _purple,
          onTap: () {
            controller.setReply(message);
          },
        ),
      if (isText && options.contains(MessageMenuOption.copy))
        MessageContextMenuAction(
          icon: Icons.copy_rounded,
          title: appL10n.common_copy,
          iconColor: _purple,
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(text: message.content ?? ""),
            );
            Utils().fluttertoast(appL10n.chat_messageCopied);
          },
        ),
      // Hidden for attendance cards (ChatScreenRules.menuOptions).
      if (options.contains(MessageMenuOption.forward))
        MessageContextMenuAction(
          icon: Icons.forward_rounded,
          title: appL10n.chat_menuForward,
          iconColor: _purple,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.toNamed(
                Routes.forwardMessageScreen,
                arguments: {
                  "message": message,
                  "sourceType": "private",
                },
              );
            });
          },
        ),
      if (options.contains(MessageMenuOption.edit) &&
          !_isDeletedMessage &&
          isSentByMe &&
          (isText || ChatScreenRules.isEditable(message.messageType)))
        MessageContextMenuAction(
          icon: Icons.edit_rounded,
          title: appL10n.common_edit,
          iconColor: _purple,
          onTap: () {
            controller.startEditingMessage(message);
          },
        ),
      if (options.contains(MessageMenuOption.pin))
        MessageContextMenuAction(
          icon: Icons.push_pin_rounded,
          title: isPinned ? appL10n.chat_menuUnpin : appL10n.chat_menuPin,
          iconColor: isPinned ? Colors.redAccent : _purple,
          onTap: () {
            if (isPinned) {
              controller.unpinMessage();
            } else {
              controller.pinMessage(message);
            }
          },
        ),
      if (options.contains(MessageMenuOption.info))
        MessageContextMenuAction(
          icon: Icons.info_outline_rounded,
          title: appL10n.chat_menuMessageInfo,
          iconColor: _purple,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              MessageInfoSheet.show(
                context: context,
                message: message,
                memberData: controller.memberData,
              );
            });
          },
        ),
      if (options.contains(MessageMenuOption.deleteForEveryone))
        MessageContextMenuAction(
          icon: Icons.delete_outline_rounded,
          title: appL10n.chat_deleteForEveryone,
          isDestructive: true,
          onTap: () {
            CommonDialog.ConfirmationDialog(
              title: appL10n.chat_deleteForEveryone,
              content: appL10n.chat_deleteForEveryoneConfirm,
              cancel: appL10n.common_no,
              confirm: appL10n.common_yes,
              icon: Icons.delete_outline_rounded,
              onConfirm: () {
                Get.back();
                controller.deleteMessage(
                  messageId: message.id!,
                  deleteType: "for_everyone",
                );
              },
            );
          },
        ),
      if (options.contains(MessageMenuOption.deleteForMe))
        MessageContextMenuAction(
          icon: Icons.delete_rounded,
          title: appL10n.chat_deleteForMe,
          isDestructive: true,
          onTap: () {
            CommonDialog.ConfirmationDialog(
              title: appL10n.chat_deleteForMe,
              content: appL10n.chat_deleteForMeConfirm,
              cancel: appL10n.common_no,
              confirm: appL10n.common_yes,
              icon: Icons.delete_rounded,
              onConfirm: () {
                Get.back();
                controller.deleteMessage(
                  messageId: message.id!,
                  deleteType: "for_me",
                );
              },
            );
          },
        ),
    ];

    MessageContextMenu.show(
      context: context,
      bubbleContext: bubbleContext,
      isSentByMe: isSentByMe,
      actions: actions,
      messageWidget: messageWidget,
      currentReaction: _isDeletedMessage ? null : message.userReaction,
      onReactionSelected: _isDeletedMessage
          ? null
          : (emoji) {
              try {
                controller.toggleReaction(message, emoji);
              } catch (_) {}
            },
    );
  }

  // ==========================================
  // WHATSAPP PARITY: MESSAGE REACTION PILL
  // ==========================================
  Widget _buildReactionPill(MessageData message, bool isSentByMe) {
    final reactions = message.reactions ?? [];
    if (reactions.isEmpty) return const SizedBox.shrink();

    final totalCount = reactions.fold<int>(0, (sum, r) => sum + (r.count ?? 0));
    final displayEmojis = reactions.take(3).map((r) => r.emoji ?? '').join('');

    return GestureDetector(
      onTap: () {
        if (message.userReaction != null) {
          controller.toggleReaction(message, message.userReaction!);
        } else if (reactions.isNotEmpty && reactions.first.emoji != null) {
          controller.toggleReaction(message, reactions.first.emoji!);
        }
      },
      child: Transform.translate(
        offset: Offset(isSentByMe ? -6.w : 6.w, -6.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayEmojis,
                style: TextStyle(fontSize: 12.sp),
              ),
              if (totalCount > 1) ...[
                SizedBox(width: 3.w),
                Text(
                  totalCount.toString(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final List<InlineSpan> spans = [];

    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);

      if (index == -1) {
        if (start < text.length) {
          spans.add(
            TextSpan(
              text: text.substring(start),
              style: normalStyle,
            ),
          );
        }
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: normalStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(
            index,
            index + query.length,
          ),
          style: highlightStyle,
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }
}

class GroupChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final bool isGroup;
  final int? groupId;
  final String? groupName;
  final GroupMessageController controller;
  final bool showSenderName;
  final bool showAvatar;
  final bool isDense;

  const GroupChatBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.context,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.showSenderName = true,
    this.showAvatar = true,
    this.isDense = false,
  });

  static const Color _purple = Color(0xFF5045B9);
  static const Color _myBubbleBg = _kMyBubbleBg;
  static const Color _otherBubbleBg = Colors.white;

  bool get _isDeletedMessage =>
      message.isDeleted == true ||
      message.isDeleted.toString() == 'true' ||
      message.isDeleted.toString() == '1' ||
      message.isDeletedForEveryone == true ||
      message.content?.toString() == "This message was deleted" ||
      message.content?.toString() == "You deleted this message";

  /// Name above a received group message: the message's own name, or the
  /// member list's when a real-time message arrived without one.
  String _senderDisplayName() {
    final own = message.senderName?.toString().trim() ?? '';
    if (own.isNotEmpty && own != 'null') return own;
    return controller.memberNameFor(message.senderId) ?? '';
  }

  /// Sender avatar / name tap → sender's full profile (WhatsApp style).
  void _openSenderInfo({bool asPopup = false}) {
    final String senderId = message.senderId?.toString() ?? '';
    dynamic member;
    if (Get.isRegistered<GroupMessageController>()) {
      member = Get.find<GroupMessageController>()
          .groupMembers
          .firstWhereOrNull((m) => m.userId?.toString() == senderId);
    }
    final String? name =
        message.senderName?.toString() ?? member?.name?.toString();
    final String? image =
        message.senderImage?.toString() ?? member?.profileImage?.toString();
    final String? mobileNo = member?.mobileNo?.toString();
    final int? chatId = int.tryParse(member?.chatId?.toString() ?? '');

    if (asPopup) {
      // Avatar tap → photo popup with Message / Call / Video / Info
      showUserQuickProfile(
        userId: senderId,
        name: name,
        profileImage: image,
        mobileNo: mobileNo,
        chatId: chatId,
      );
      return;
    }
    openUserProfile(
      userId: senderId,
      name: name,
      profileImage: image,
      mobileNo: mobileNo,
      chatId: chatId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    if (message.isSystemMessage) {
      return _buildSystemMessageTile(
        formatSystemMessageText(message, currentUserId),
        boldNames: _systemMessageNames(message),
      );
    }

    if (message.isCallLogMessage) {
      return _buildCallLogTile(
        context: context,
        message: message,
        isSentByMe: isSentByMe,
        onCallBack: () {
          try {
            final isVideo =
                message.content?.toString().toLowerCase().contains('video') ==
                        true ||
                    message.callLogMeta?['isVideo'] == true ||
                    message.callLogMeta?['callType'] == 'video';
            GroupCallService.instance.startGroupCall(
              context,
              groupId: groupId?.toString() ?? '',
              groupName: groupName ?? 'Group',
              isVideo: isVideo,
            );
          } catch (_) {}
        },
      );
    }

    // No avatar next to received bubbles (UI, F-1.2.6). The sender's name
    // in the bubble still opens their info.
    return Container(
      margin: EdgeInsets.symmetric(vertical: isDense ? 2.h : 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Obx(() {
              // Read the observable unconditionally: an Obx that reads none
              // (e.g. for attendance cards) throws "improper use of GetX".
              final isHighlighted =
                  controller.highlightedMessageId.value == message.id;

              return Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (bubbleContext) {
                      return GestureDetector(
                        onLongPress: () => _showMessageMenu(
                          bubbleContext,
                          isSentByMe,
                          messageWidget: _buildBubbleContainer(
                            context,
                            isSentByMe,
                            isHighlighted: isHighlighted,
                          ),
                        ),
                        child: _buildBubbleContainer(
                          context,
                          isSentByMe,
                          isHighlighted: isHighlighted,
                        ),
                      );
                    },
                  ),
                  if (!_isDeletedMessage &&
                      message.reactions != null &&
                      message.reactions!.isNotEmpty)
                    _buildReactionPill(message, isSentByMe),
                  if (!isSentByMe &&
                      !_isDeletedMessage &&
                      _getTranslatableText(message).isNotEmpty)
                    ChatMessageActionRow(
                      messageId: _getMessageTranslationId(message),
                      originalText: _getTranslatableText(message),
                      isSentByMe: isSentByMe,
                      // Plain text has the speaker inside the bubble.
                      showListen: !_isPlainTextMessage(message),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContainer(
    BuildContext context,
    bool isSentByMe, {
    bool isHighlighted = false,
  }) {
    final bgColor = isSentByMe ? _myBubbleBg : _otherBubbleBg;
    final textColor = Colors.black87;
    final borderRadius = _bubbleRadius();
    final isAttendance =
        !_isDeletedMessage && message.messageType == "attendance";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width *
            (isAttendance ? 0.88 : 0.75),
      ),
      padding: isAttendance
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
      decoration: BoxDecoration(
        color: isAttendance
            ? Colors.transparent
            : (isHighlighted
                ? Colors.yellow.withValues(
                    alpha: .35,
                  )
                : bgColor),
        borderRadius: isAttendance
            ? BorderRadius.circular(20.r)
            : borderRadius,
        border: _bubbleBorder(
          isSentByMe: isSentByMe,
          isAttendance: isAttendance,
        ),
        boxShadow: isAttendance
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: _bubbleWidth(
        isAttendance: isAttendance,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGroup && !isSentByMe && showSenderName)
              Padding(
                padding: EdgeInsets.only(
                  bottom: 4.h,
                ),
                child: GestureDetector(
                  onTap: _openSenderInfo,
                  child: Text(
                    // Real-time messages may arrive
                    // without a name: use the member list.
                    _senderDisplayName(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          senderNameColor(message.senderId),
                    ),
                  ),
                ),
              ),
            if (!_isDeletedMessage)
              _buildReplyPreview(
                message,
                isSentByMe,
              ),
            if (!_isDeletedMessage &&
                message.isForwarded == true)
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forward_rounded,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      context.l10n.chat_forwarded,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isDeletedMessage) ...[
              _buildDeletedContent(isSentByMe),
            ] else if (_isPlainTextMessage(message)) ...[
              _buildTextWithTime(
                message: message,
                textColor: textColor,
                isSentByMe: isSentByMe,
              ),
              if (!isSentByMe)
                _buildTranslatedCard(message),
            ] else ...[
              _buildMessageContent(
                message,
                textColor,
                isSentByMe,
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: _buildTimeRow(
                  isSentByMe,
                ),
              ),
              if (!isSentByMe)
                _buildTranslatedCard(message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedContent(bool isSentByMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.block_rounded,
          size: 14.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            isSentByMe
                ? appL10n.chat_previewOwnDeleted
                : appL10n.chat_messageDeleted,
            style: TextStyle(
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  String _getTranslatableText(MessageData message) {
    if (_isDeletedMessage) return '';

    if (_isPlainTextMessage(message)) {
      return (message.content?.toString() ?? '').trim();
    }

    final caption = _resolveAttachmentCaption(message);
    if (caption.isNotEmpty) {
      return caption;
    }

    if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName).trim();
      return documentName;
    }

    if (message.messageType == "contact") {
      final content = (message.content?.toString() ?? '').trim();
      if (content.isNotEmpty && !content.startsWith('{')) return content;
    }

    return '';
  }

  String _getMessageTranslationId(MessageData message) {
    if (message.id != null &&
        message.id.toString().isNotEmpty &&
        message.id.toString() != "0") {
      return message.id.toString();
    }
    final text = _getTranslatableText(message);
    final raw = text.isNotEmpty ? text : (message.content?.toString() ?? '');
    return "msg_${raw.hashCode}";
  }

  Widget _buildTranslatedCard(MessageData message) {
    final translatableText = _getTranslatableText(message);
    if (translatableText.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final mId = _getMessageTranslationId(message);
      final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(translatableText);
      final targetLang = isHindi ? 'en' : 'hi';
      final cacheKey = '${mId}_$targetLang';
      final translationService = ChatTranslationService.instance;
      final translated = translationService.translations[cacheKey];
      final isShown = translationService.showTranslated[cacheKey] == true;

      if (translated != null && translated.isNotEmpty && isShown) {
        return ChatTranslatedCard(
          messageId: mId,
          translatedText: translated,
          targetLang: targetLang,
          onToggleOriginal: () {
            translationService.toggleTranslationVisibility(
              mId,
              targetLang: targetLang,
            );
          },
        );
      }
      return const SizedBox.shrink();
    });
  }

  bool _isPlainTextMessage(MessageData message) {
    final type =
        (message.messageType?.toString() ?? "text").toLowerCase().trim();
    if (type == "text" || type == "text_message" || type.isEmpty) {
      return true;
    }
    if ((type == "forward" ||
            type == "forwarded" ||
            type == "forward_message") &&
        (message.images?.isEmpty ?? true) &&
        (message.videos?.isEmpty ?? true)) {
      return true;
    }
    return false;
  }

  Widget _buildTimeRow(bool isSentByMe) {
    final wasEdited = !_isDeletedMessage &&
        (message.isEdited == true ||
            message.isEdited?.toString() == 'true' ||
            message.isEdited?.toString() == '1' ||
            message.edited == true ||
            message.edited?.toString() == 'true' ||
            message.edited?.toString() == '1');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (wasEdited) ...[
          Text(
            appL10n.chat_edited,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          appTime(DateTime.parse(message.timestamp ?? "").toLocal()),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isSentByMe && !_isDeletedMessage) ...[
          SizedBox(width: 3.w),
          // Same aggregation as Message Info (MessageReceipts.groupTick).
          Builder(builder: (_) {
            final tick = MessageReceipts.groupTick(
              message,
              memberIds: controller.groupMembers.map((m) => m.userId),
            );
            return Icon(
              tick == GroupTick.sent ? Icons.done : Icons.done_all,
              size: 14.sp,
              color: tick == GroupTick.read ? _purple : Colors.grey.shade500,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTextWithTime({
    required MessageData message,
    required Color textColor,
    required bool isSentByMe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextContent(message, textColor, isSentByMe),
        ),
        // Speaker inside received text bubbles, before the time (UI, F-1.2.6).
        if (!isSentByMe) ...[
          SizedBox(width: 6.w),
          ChatInlineListenButton(
            messageId: _getMessageTranslationId(message),
            originalText: _getTranslatableText(message),
          ),
          SizedBox(width: 6.w),
        ] else
          SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  Widget _buildTextContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final query = controller.searchQuery.value;
    String content = message.content?.toString() ?? "";
    if (content.trim().isEmpty &&
        (message.caption?.toString() ?? "").trim().isNotEmpty) {
      content = message.caption!.toString();
    }

    if (query.isNotEmpty &&
        content.toLowerCase().contains(query.toLowerCase())) {
      return _buildHighlightedText(
        content,
        query,
        normalStyle: TextStyle(
          color: textColor,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
        highlightStyle: TextStyle(
          backgroundColor: const Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
      );
    }

    return Linkify(
      text: content,
      style: TextStyle(
        color: textColor,
        fontSize: 13.sp,
        fontFamily: FontFamily.interMedium,
        height: 1.35,
      ),
      linkStyle: TextStyle(
        color: _purple,
        decoration: TextDecoration.underline,
        fontSize: 13.sp,
      ),
      onOpen: (link) async {
        Uri uri = Uri.parse(link.url);
        if (!uri.hasScheme) {
          uri = Uri.parse("https://${link.url}");
        }
        AppLog.d("OPEN URL => $uri");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<InlineSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }

      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: normalStyle));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildReplyPreview(MessageData message, bool isSentByMe) {
    if (message.isStatusReply) {
      return _buildStatusReplyPreview(message, isSentByMe);
    }

    return _quotedReplyCard(
      message: message,
      isSentByMe: isSentByMe,
      original: controller.findMessageById(message.replyId),
      onTap: controller.scrollToMessage,
    );
  }

  Widget _buildStatusReplyPreview(MessageData message, bool isSentByMe) {
    final status = message.replyStatus;
    final meta = message.statusMeta;

    final ownerName = status?.creator?.name ??
        meta?.ownerName ??
        message.replySenderName?.toString() ??
        appL10n.chat_statusLabel;

    final statusType =
        (status?.type ?? meta?.type ?? message.statusType?.toString() ?? 'text')
            .toString()
            .toLowerCase();

    final isVideo = statusType == 'video' || (status?.isVideo ?? false);
    final isImage = statusType == 'image' ||
        statusType == 'photo' ||
        (status?.isImage ?? false);

    final mediaUrl = status?.mediaUrl ?? meta?.mediaUrl;
    final thumbnailUrl = status?.thumbnailUrl ?? meta?.thumbnail ?? mediaUrl;
    final rawText = status?.content ??
        message.replyMessageContent?.toString() ??
        message.replyMessage?.toString() ??
        appL10n.chat_statusLabel;

    final cleanText = rawText.replaceAll(RegExp(r'^\[Status:\s*|\]$'), '');

    String typeLabel = appL10n.chat_statusLabel;
    if (isImage) {
      typeLabel = appL10n.chat_previewPhoto;
    } else if (isVideo) {
      typeLabel = appL10n.chat_previewVideo;
    } else {
      typeLabel = cleanText.isNotEmpty ? cleanText : appL10n.chat_statusLabel;
    }

    return GestureDetector(
      onTap: () => _openStatusFromReply(message),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.white.withValues(alpha: .55)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: const Border(
            left: BorderSide(
              color: _purple,
              width: 3.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5.sp,
                        color: _purple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : isImage
                                  ? Icons.photo_rounded
                                  : Icons.text_fields_rounded,
                          size: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(9.r),
                bottomRight: Radius.circular(9.r),
              ),
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: _buildStatusThumbnail(
                  status: status,
                  isImage: isImage,
                  isVideo: isVideo,
                  mediaUrl: thumbnailUrl,
                  textContent: cleanText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusThumbnail({
    StatusItemModel? status,
    required bool isImage,
    required bool isVideo,
    String? mediaUrl,
    required String textContent,
  }) {
    if ((isImage || isVideo) && mediaUrl != null && mediaUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
            memCacheWidth: 600,
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
          ),
          if (isVideo)
            Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      );
    }

    final bgColor = status?.parsedBgColor ?? const Color(0xFF10B981);

    return Container(
      color: bgColor,
      padding: EdgeInsets.all(4.w),
      alignment: Alignment.center,
      child: Text(
        textContent,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }

  void _openStatusFromReply(MessageData message) {
    final status = message.replyStatus;

    if (status == null || status.isExpired) {
      Utils().fluttertoast(appL10n.chat_statusUnavailable);
      return;
    }

    Get.to(() => StatusViewScreen(
          isOwnStatus: false,
          userName: status.creator?.name ??
              message.replySenderName?.toString() ??
              appL10n.chat_statusLabel,
          userAvatar: status.creator?.profilePic,
          statuses: [status],
          currentIndex: 0,
        ));
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final messageType =
        (message.messageType?.toString() ?? '').toLowerCase().trim();

    final videos = message.videos ?? [];

    final hasMultipleVideos = videos.length > 1;

    final hasImages = (message.images?.isNotEmpty ?? false);
    final hasVideos = (message.videos?.isNotEmpty ?? false);

    if (messageType == "media" ||
        messageType == "image" ||
        messageType == "image_text" ||
        (messageType == "video" && hasMultipleVideos) ||
        ((messageType == "forward" ||
                messageType == "forwarded" ||
                messageType == "forward_message") &&
            (hasImages || hasVideos))) {
      final imageList = (message.images ?? [])
          .where((image) => image.trim().isNotEmpty)
          .toList();

      if (imageList.isEmpty &&
          (message.messageType == "image" ||
              message.messageType == "image_text")) {
        final imagePart = message.content?.toString() ?? "";
        if (imagePart.trim().isNotEmpty) {
          imageList.add(imagePart);
        }
      }

      final videos = (message.videos != null && message.videos!.isNotEmpty)
          ? message.videos!
          : ((messageType == "media" || messageType == "video")
              ? (message.videos ?? [])
              : <MessageVideo>[]);

      final caption = _resolveAttachmentCaption(message);

      String getMediaUrl(String path) {
        final value = path.trim();
        if (value.isEmpty) return "";
        if (value.startsWith("http://") || value.startsWith("https://")) {
          return value;
        }
        return "${ConstRes.aImageBaseUrl}$value";
      }

      void openGallery(int index) {
        Get.to(
          () => GroupImageGallery(
            images: imageList,
            videos: videos,
            initialIndex: index,
          ),
        );
      }

      Widget buildImageTile(
        int index,
        double width,
        double height,
      ) {
        return GestureDetector(
          onTap: () => openGallery(index),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: getMediaUrl(imageList[index]),
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _purple,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      ChatImageErrorTile(url: url),
                ),
                if (index == 3 && imageList.length > 4)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      "+${imageList.length - 4}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      Widget buildVideoTile(MessageVideo video, int videoIndex) {
        final videoUrl = getMediaUrl(video.videoUrl ?? "");
        final thumbnailUrl = getMediaUrl(video.thumbnail ?? "");
        final duration = (video.duration ?? "").trim().isNotEmpty
            ? video.duration!
            : "--:--";

        return VideoThumbnailWidget(
          videoUrl: videoUrl,
          thumbnail: thumbnailUrl,
          duration: duration,
          onTap: () => openGallery(imageList.length + videoIndex),
        );
      }

      if (imageList.isEmpty && videos.isEmpty) {
        return MissingMediaCard(
          type: MissingMediaType.media,
          isSentByMe: isSentByMe,
        );
      }

      final hasMixedMedia = videos.isNotEmpty;
      final totalImages = imageList.length;
      final visibleImages = totalImages > 4 ? 4 : totalImages;

      return SizedBox(
        width: 220.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasMixedMedia && totalImages == 1)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                // One photo: its own shape, like WhatsApp (F-1.2.6).
                child: ChatImageAspectBox(
                  imageUrl: getMediaUrl(imageList.first),
                  width: 220.w,
                  builder: (h) => buildImageTile(0, 220.w, h),
                ),
              )
            else if (!hasMixedMedia && totalImages > 1)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 220.w,
                  child: Wrap(
                    spacing: 3.w,
                    runSpacing: 3.w,
                    children: List.generate(
                      visibleImages,
                      (index) {
                        final tileSize = totalImages == 2
                            ? 108.w
                            : totalImages == 3 && index == 0
                                ? 220.w
                                : 108.w;

                        final tileHeight =
                            totalImages == 3 && index == 0 ? 130.h : 108.h;

                        return buildImageTile(
                          index,
                          tileSize,
                          tileHeight,
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 220.w,
                  child: Wrap(
                    spacing: 3.w,
                    runSpacing: 3.w,
                    children: List.generate(
                      (imageList.length + videos.length).clamp(0, 4),
                      (index) {
                        final isVideo = index >= imageList.length;
                        final totalMedia = imageList.length + videos.length;

                        return SizedBox(
                          width: 108.w,
                          height: 108.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (isVideo)
                                  buildVideoTile(
                                    videos[index - imageList.length],
                                    index - imageList.length,
                                  )
                                else
                                  buildImageTile(
                                    index,
                                    108.w,
                                    108.w,
                                  ),
                                if (index == 3 && totalMedia > 4)
                                  Container(
                                    color: Colors.black54,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "+${totalMedia - 4}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (caption.isNotEmpty) ...[
              SizedBox(height: 8.h),
              reausabletext(
                caption,
                color: textColor,
                fontsize: 12.sp,
              ),
            ],
          ],
        ),
      );
    } else if (message.messageType == "audio") {
      // Server audio location first (socket payloads), else content.
      final audioSrc = _audioFullUrl(message.audioUrl ?? message.content);
      final audioBubble = AudioBubble(
        // Temp → server message, or a later event with the URL: a new key
        // gives a fresh bubble, so the player loads the new source.
        key: ValueKey(
            'audio_${message.id ?? message.clientMessageId}_$audioSrc'),
        audioUrl: audioSrc,
        isMe: false,
      );
      final audioCaption = _resolveAttachmentCaption(message);
      if (audioCaption.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            audioBubble,
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: reausabletext(
                audioCaption,
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
          ],
        );
      }
      return audioBubble;
    } else if (messageType == "video") {
      final parts = message.content?.split("||") ?? [];
      final videoPath = parts.isNotEmpty ? parts[0].trim() : "";
      final thumbnailPath = parts.length > 1 ? parts[1].trim() : "";
      final duration = parts.length > 2 && parts[2].trim().isNotEmpty
          ? parts[2].trim()
          : "--:--";
      final videoUrl = videoPath.isEmpty
          ? ""
          : videoPath.startsWith("http://") || videoPath.startsWith("https://")
              ? videoPath
              : "${ConstRes.aImageBaseUrl}$videoPath";
      final thumbnailUrl = thumbnailPath.startsWith("http://") ||
              thumbnailPath.startsWith("https://")
          ? thumbnailPath
          : "${ConstRes.aImageBaseUrl}$thumbnailPath";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoThumbnailWidget(
            videoUrl: videoUrl,
            thumbnail: thumbnailUrl,
            duration: duration,
            onTap: () {
              Get.toNamed(
                Routes.videoPlayerScreen,
                arguments: {
                  "videoUrl": videoUrl,
                },
              );
            },
          ),
          if (_resolveAttachmentCaption(message).isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                _resolveAttachmentCaption(message),
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName);
      final extension = documentName.split('.').last.toLowerCase();
      final fileSize = parts.length > 2 ? parts[2] : "";

      IconData icon;
      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf_rounded;
          break;
        case "doc":
        case "docx":
          icon = Icons.description_rounded;
          break;
        case "xls":
        case "xlsx":
          icon = Icons.table_chart_rounded;
          break;
        case "ppt":
        case "pptx":
          icon = Icons.slideshow_rounded;
          break;
        default:
          icon = Icons.insert_drive_file_rounded;
      }

      final documentFullUrl = _documentFullUrl(documentUrl);

      return MediaAvailabilityGuard(
        url: documentFullUrl,
        type: MissingMediaType.document,
        isSentByMe: isSentByMe,
        fileName: documentName,
        width: 240.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await DocumentService().openDocument(documentFullUrl);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 240.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? Colors.white.withValues(alpha: 0.6)
                      : const Color(0xFFF3F1FB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        color: _purple,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            documentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            fileSize.isNotEmpty
                                ? "$fileSize • ${extension.toUpperCase()}"
                                : extension.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    if (!isSentByMe) ...[
                      SizedBox(width: 6.w),
                      Obx(() {
                        final url = documentFullUrl;

                        if (DocumentService.isDownloading(url)) {
                          return SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _purple,
                            ),
                          );
                        }

                        return Icon(
                          DocumentService.isDownloaded(url)
                              ? Icons.download_done_rounded
                              : Icons.download_rounded,
                          color: _purple,
                          size: 20.sp,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            if (_resolveAttachmentCaption(message).isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: reausabletext(
                  _resolveAttachmentCaption(message),
                  color: textColor,
                  fontsize: 12.sp,
                  fontfamily: FontFamily.interMedium,
                ),
              ),
          ],
        ),
      );
    } else if (message.messageType == "location" ||
        message.messageType == "live_location") {
      final senderMember = controller.groupMembers.firstWhereOrNull(
          (m) => m.userId?.toString() == message.senderId?.toString());
      return LocationBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
        senderName: isSentByMe ? "You" : _senderDisplayName(),
        senderImage: isSentByMe
            ? null
            : (message.senderImage?.toString() ??
                senderMember?.profileImage?.toString()),
        onStopLiveLocation: () => controller.stopLiveLocation(message),
      );
    } else if (message.messageType == "contact") {
      return ContactBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else if (message.messageType == "attendance") {
      final embedded = AttendancePoll.fromJson(message.attendance);
      final pollId = embedded?.id ??
          int.tryParse(message.attendancePollId?.toString() ?? "") ??
          _pollIdFromContent(message.content);
      if (pollId == null || pollId <= 0) {
        return _buildTextContent(message, textColor, isSentByMe);
      }

      return AttendanceChatCard(
        key: ValueKey("attendance_$pollId"),
        pollId: pollId,
        initialPoll: embedded,
        isAdmin: controller.isCreator,
        groupMembers: controller.groupMembers,
        // The group bubble already shows the sender's name above the card.
        senderName: "",
        groupName: controller.groupName.value,
        messageTime: message.timestamp?.toString(),
        onDeleted: controller.markAttendanceDeleted,
      );
    } else if (ChatScreenRules.isUnsupported(message)) {
      return _unsupportedMessageContent(isSentByMe);
    } else {
      return _buildTextContent(
        message,
        textColor,
        isSentByMe,
      );
    }
  }

  /// Message content is {"attendancePollId":3,...}; used when the message
  /// arrives without the embedded `attendance` summary.
  int? _pollIdFromContent(dynamic content) {
    try {
      final decoded = jsonDecode(content?.toString() ?? "");
      if (decoded is Map) {
        return int.tryParse(
          (decoded["attendancePollId"] ?? decoded["pollId"])?.toString() ?? "",
        );
      }
    } catch (_) {}
    return null;
  }

  // Group "all read" lives in MessageReceipts.groupTick (shared with Message
  // Info). The old _areAllMembersSeen compared map entries with toString()
  // and never matched (BUG-CS-13).

  void _showMessageMenu(
    BuildContext bubbleContext,
    bool isSentByMe, {
    Widget? messageWidget,
  }) {
    final isPinned = controller.pinnedMessage.value?.id == message.id;
    final isText = message.messageType == "text" ||
        message.messageType == "text_message" ||
        (message.messageType ?? "").isEmpty;
    // Attendance messages have no delete option (see ChatScreenRules).
    final options = ChatScreenRules.menuOptions(
      messageType: message.messageType,
      isSentByMe: isSentByMe,
      isDeleted: _isDeletedMessage,
    );

    final actions = <MessageContextMenuAction>[
      if (options.contains(MessageMenuOption.reply))
        MessageContextMenuAction(
          icon: Icons.reply_rounded,
          title: appL10n.chat_menuReply,
          iconColor: _purple,
          onTap: () {
            controller.setReply(message);
          },
        ),
      if (isText && options.contains(MessageMenuOption.copy))
        MessageContextMenuAction(
          icon: Icons.copy_rounded,
          title: appL10n.common_copy,
          iconColor: _purple,
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(text: message.content ?? ""),
            );
            Utils().fluttertoast(appL10n.chat_messageCopied);
          },
        ),
      // Hidden for attendance cards (ChatScreenRules.menuOptions).
      if (options.contains(MessageMenuOption.forward))
        MessageContextMenuAction(
          icon: Icons.forward_rounded,
          title: appL10n.chat_menuForward,
          iconColor: _purple,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.toNamed(
                Routes.forwardMessageScreen,
                arguments: {
                  "message": message,
                  "sourceType": "group",
                },
              );
            });
          },
        ),
      if (options.contains(MessageMenuOption.edit) &&
          !_isDeletedMessage &&
          isSentByMe &&
          (isText || ChatScreenRules.isEditable(message.messageType)))
        MessageContextMenuAction(
          icon: Icons.edit_rounded,
          title: appL10n.common_edit,
          iconColor: _purple,
          onTap: () {
            controller.startEditingMessage(message);
          },
        ),
      if (options.contains(MessageMenuOption.pin))
        MessageContextMenuAction(
          icon: Icons.push_pin_rounded,
          title: isPinned ? appL10n.chat_menuUnpin : appL10n.chat_menuPin,
          iconColor: isPinned ? Colors.redAccent : _purple,
          onTap: () {
            if (isPinned) {
              controller.unpinMessage();
            } else {
              controller.pinMessage(message);
            }
          },
        ),
      if (options.contains(MessageMenuOption.info))
        MessageContextMenuAction(
          icon: Icons.info_outline_rounded,
          title: appL10n.chat_menuMessageInfo,
          iconColor: _purple,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              MessageInfoSheet.show(
                context: context,
                message: message,
                groupController: controller,
              );
            });
          },
        ),
      if (options.contains(MessageMenuOption.deleteForEveryone))
        MessageContextMenuAction(
          icon: Icons.delete_outline_rounded,
          title: appL10n.chat_deleteForEveryone,
          isDestructive: true,
          onTap: () {
            CommonDialog.ConfirmationDialog(
              title: appL10n.chat_deleteForEveryone,
              content: appL10n.chat_deleteForEveryoneConfirm,
              cancel: appL10n.common_no,
              confirm: appL10n.common_yes,
              icon: Icons.delete_outline_rounded,
              onConfirm: () {
                Get.back();
                controller.deleteMessage(
                  messageId: message.id!,
                  deleteType: "for_everyone",
                );
              },
            );
          },
        ),
      if (options.contains(MessageMenuOption.deleteForMe))
        MessageContextMenuAction(
          icon: Icons.delete_rounded,
          title: appL10n.chat_deleteForMe,
          isDestructive: true,
          onTap: () {
            CommonDialog.ConfirmationDialog(
              title: appL10n.chat_deleteForMe,
              content: appL10n.chat_deleteForMeConfirm,
              cancel: appL10n.common_no,
              confirm: appL10n.common_yes,
              icon: Icons.delete_rounded,
              onConfirm: () {
                Get.back();
                controller.deleteMessage(
                  messageId: message.id!,
                  deleteType: "for_me",
                );
              },
            );
          },
        ),
    ];

    MessageContextMenu.show(
      context: context,
      bubbleContext: bubbleContext,
      isSentByMe: isSentByMe,
      actions: actions,
      messageWidget: messageWidget,
      currentReaction: _isDeletedMessage ? null : message.userReaction,
      onReactionSelected: _isDeletedMessage
          ? null
          : (emoji) {
              try {
                controller.toggleReaction(message, emoji);
              } catch (_) {}
            },
    );
  }

  // ==========================================
  // WHATSAPP PARITY: MESSAGE REACTION PILL
  // ==========================================
  Widget _buildReactionPill(MessageData message, bool isSentByMe) {
    final reactions = message.reactions ?? [];
    if (reactions.isEmpty) return const SizedBox.shrink();

    final totalCount = reactions.fold<int>(0, (sum, r) => sum + (r.count ?? 0));
    final displayEmojis = reactions.take(3).map((r) => r.emoji ?? '').join('');

    return GestureDetector(
      onTap: () {
        if (message.userReaction != null) {
          controller.toggleReaction(message, message.userReaction!);
        } else if (reactions.isNotEmpty && reactions.first.emoji != null) {
          controller.toggleReaction(message, reactions.first.emoji!);
        }
      },
      child: Transform.translate(
        offset: Offset(isSentByMe ? -6.w : 6.w, -6.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayEmojis,
                style: TextStyle(fontSize: 12.sp),
              ),
              if (totalCount > 1) ...[
                SizedBox(width: 3.w),
                Text(
                  totalCount.toString(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GroupGalleryMedia {
  final String url;
  final bool isVideo;
  final String? thumbnail;
  final String? duration;

  const GroupGalleryMedia({
    required this.url,
    this.isVideo = false,
    this.thumbnail,
    this.duration,
  });
}

class GroupImageGallery extends StatefulWidget {
  final List<String> images;
  final List<MessageVideo> videos;
  final int initialIndex;

  const GroupImageGallery({
    super.key,
    this.images = const [],
    this.videos = const [],
    this.initialIndex = 0,
  });

  @override
  State<GroupImageGallery> createState() => _GroupImageGalleryState();
}

class _GroupImageGalleryState extends State<GroupImageGallery> {
  late final PageController _pageController;
  late final ScrollController _thumbnailScrollController;
  late int _currentIndex;
  late final List<GroupGalleryMedia> _media;
  bool _isOverlayVisible = true;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();

    _media = [
      ...widget.images.where((image) => image.trim().isNotEmpty).map(
            (image) => GroupGalleryMedia(
              url: _buildMediaUrl(image),
            ),
          ),
      ...widget.videos
          .where((video) => (video.videoUrl ?? '').trim().isNotEmpty)
          .map(
            (video) => GroupGalleryMedia(
              url: _buildMediaUrl(video.videoUrl!),
              isVideo: true,
              thumbnail: video.thumbnail == null
                  ? null
                  : _buildMediaUrl(video.thumbnail!),
              duration: video.duration,
            ),
          ),
    ];

    _currentIndex =
        widget.initialIndex.clamp(0, _media.isEmpty ? 0 : _media.length - 1);

    _pageController = PageController(
      initialPage: _currentIndex,
    );

    _thumbnailScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  void _scrollToThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;
    const itemWidth = 56.0;
    final targetOffset = (index * itemWidth) - 100.0;
    _thumbnailScrollController.animateTo(
      targetOffset.clamp(
          0.0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  String _buildMediaUrl(String path) {
    final value = path.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '${ConstRes.aImageBaseUrl}$value';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _openVideo(GroupGalleryMedia media) {
    Get.toNamed(
      Routes.videoPlayerScreen,
      arguments: {
        'videoUrl': media.url,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_media.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            context.l10n.chat_noMediaAvailable,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main Page View
          GestureDetector(
            onTap: () {
              setState(() {
                _isOverlayVisible = !_isOverlayVisible;
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _media.length,
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _isZoomed = false;
                });
                _scrollToThumbnail(index);
              },
              itemBuilder: (context, index) {
                final media = _media[index];

                if (media.isVideo) {
                  return Center(
                    child: GestureDetector(
                      onTap: () => _openVideo(media),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (media.thumbnail != null &&
                              media.thumbnail!.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: media.thumbnail!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.videocam_rounded,
                                color: Colors.white,
                                size: 64,
                              ),
                            )
                          else
                            const Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          if ((media.duration ?? '').isNotEmpty)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  media.duration!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    onInteractionUpdate: (details) {
                      final zoomed = details.scale > 1.05;
                      if (zoomed != _isZoomed) {
                        setState(() => _isZoomed = zoomed);
                      }
                    },
                    onInteractionEnd: (_) {
                      // Allow time for reset
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (mounted && _isZoomed) {
                          setState(() => _isZoomed = false);
                        }
                      });
                    },
                    child: CachedNetworkImage(
                      imageUrl: media.url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // WhatsApp Style Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isOverlayVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4.h,
                  bottom: 8.h,
                  left: 8.w,
                  right: 16.w,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    AppBackButton(onTap: () => Navigator.of(context).pop()),
                    SizedBox(width: 8.w),
                    Text(
                      context.l10n.chat_galleryCounter(
                          _currentIndex + 1, _media.length),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // WhatsApp Style Bottom Thumbnail Strip
          if (_media.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _isOverlayVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10.h,
                    bottom: MediaQuery.of(context).padding.bottom + 10.h,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: ListView.separated(
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _media.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, i) {
                        final isSelected = i == _currentIndex;
                        final m = _media[i];
                        final thumbUrl =
                            m.isVideo ? (m.thumbnail ?? m.url) : m.url;

                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: thumbUrl,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 150,
                                    placeholder: (_, __) => Container(
                                      color: Colors.grey.shade900,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey.shade900,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white24,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  if (m.isVideo)
                                    Center(
                                      child: Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
