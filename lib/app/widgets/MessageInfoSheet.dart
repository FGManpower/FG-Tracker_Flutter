import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Core/constant/const_res.dart';
import '../Core/util/DateTime_Format.dart';
import '../Core/util/profile_navigation.dart';
import '../Data/Repositories/GetMessageRepo.dart';
import '../Model/GetMessage.dart';
import '../Model/MemberDataRes.dart';
import '../modules/Messages/Controller/GroupChatController.dart';
import '../modules/Messages/Controller/chat_screen_logic.dart';
import '../Core/constant/pref_res.dart';
import '../Core/values/global.dart';

class MessageInfoSheet extends StatefulWidget {
  final MessageData message;
  final GroupMessageController? groupController;
  final MemberData? memberData;

  const MessageInfoSheet({
    super.key,
    required this.message,
    this.groupController,
    this.memberData,
  });

  @override
  State<MessageInfoSheet> createState() => _MessageInfoSheetState();
}

class _MessageInfoSheetState extends State<MessageInfoSheet> {
  bool _isLoading = true;
  Map<String, dynamic>? _infoData;
  List<dynamic> _readByList = [];
  List<dynamic> _deliveredToList = [];

  bool get _isGroup => widget.groupController != null;
  String? get _currentUserId =>
      Global.storageServices.get(PrefConst.userId)?.toString();

  @override
  void initState() {
    super.initState();
    _initLocalData();
    _fetchLiveInfo();
  }

  void _initLocalData() {
    if (_isGroup) {
      final seenIds = ChatScreenRules.seenByOthers(
        widget.message,
        currentUserId: _currentUserId,
      );

      final members = widget.groupController?.groupMembers ?? [];
      final activeOthers = members
          .where((m) => m.userId?.toString() != widget.message.senderId?.toString())
          .toList();

      _readByList = activeOthers
          .where((m) => seenIds.contains(m.userId?.toString()))
          .map((m) => {
                'userId': m.userId,
                'name': m.name,
                'profileImage': m.profileImage,
                'mobileNo': m.mobileNo,
                'chatId': m.chatId,
                'readAt': widget.message.timestamp,
              })
          .toList();

      _deliveredToList = activeOthers
          .map((m) => {
                'userId': m.userId,
                'name': m.name,
                'profileImage': m.profileImage,
                'mobileNo': m.mobileNo,
                'chatId': m.chatId,
                'deliveredAt': widget.message.timestamp,
              })
          .toList();
    }
  }

  Future<void> _fetchLiveInfo() async {
    final msgId = widget.message.id;
    if (msgId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await MessageRepo.getMessageInfo(
        messageId: msgId,
        chatType: _isGroup ? "group" : "private",
      );

      if (mounted && res != null && res['status'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        setState(() {
          _infoData = data;
          if (data['readBy'] is List) {
            _readByList = List<dynamic>.from(data['readBy']);
          }
          if (data['deliveredTo'] is List) {
            _deliveredToList = List<dynamic>.from(data['deliveredTo']);
          }
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return "---";
    final s = ts.toString().trim();
    if (s.isEmpty) return "---";
    try {
      final dt = DateTime.parse(s).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(dt.year, dt.month, dt.day);
      final timeStr = appDateFormat('hh:mm a').format(dt);
      if (itemDate == today) {
        return "${appL10n.common_today}, $timeStr";
      } else if (itemDate == today.subtract(const Duration(days: 1))) {
        return "${appL10n.common_yesterday}, $timeStr";
      } else {
        return "${appDateFormat('dd MMM yyyy').format(dt)}, $timeStr";
      }
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalRecipients = _isGroup
        ? (_infoData?['totalMembers'] ??
            widget.groupController!.groupMembers
                .where((m) =>
                    m.userId?.toString() != widget.message.senderId?.toString())
                .length)
        : 1;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 14.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 24.sp,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      appL10n.chat_menuMessageInfo,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            Divider(height: 1, color: Colors.grey.shade300),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message preview
                    _buildMessagePreview(),

                    Divider(height: 1, color: Colors.grey.shade300),

                    // 1. Read / Seen Section
                    _buildSectionTitle(
                      icon: Icons.done_all,
                      iconColor: Colors.blue,
                      title: appL10n.widget_seen,
                      count: _readByList.length,
                      total: _isGroup ? totalRecipients : null,
                    ),

                    if (_isGroup)
                      ...(_readByList.isEmpty
                          ? [_buildEmptyTile(appL10n.widget_notSeenYet)]
                          : _readByList.map((m) => _buildMemberTile(m, isSeen: true)))
                    else
                      _buildPrivateReadTile(),

                    SizedBox(height: 8.h),
                    Divider(height: 1, color: Colors.grey.shade200),

                    // 2. Delivered Section
                    _buildSectionTitle(
                      icon: Icons.done_all,
                      iconColor: Colors.grey.shade600,
                      title: "Delivered",
                      count: _deliveredToList.length,
                      total: _isGroup ? totalRecipients : null,
                    ),

                    if (_isGroup)
                      ...(_deliveredToList.isEmpty
                          ? [_buildEmptyTile("Not delivered yet")]
                          : _deliveredToList.map((m) => _buildMemberTile(m, isSeen: false)))
                    else
                      _buildPrivateDeliveredTile(),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePreview() {
    String preview;

    switch (widget.message.messageType?.toString()) {
      case "image":
      case "image_text":
        preview = appL10n.util_previewPhoto;
        break;

      case "video":
        preview = appL10n.util_previewVideo;
        break;

      case "audio":
        preview = appL10n.util_previewVoice;
        break;

      case "document":
        preview = appL10n.util_previewDocument;
        break;

      case "location":
        preview = appL10n.util_previewLocation;
        break;

      case "contact":
        preview = appL10n.util_previewContact;
        break;

      default:
        preview = widget.message.content?.toString() ?? "";
    }

    final sentTime = _formatTimestamp(
      _infoData?['sentAt'] ?? widget.message.timestamp,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMessageIcon(),
                color: Colors.grey.shade600,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 30.w),
            child: Text(
              "Sent: $sentTime",
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMessageIcon() {
    switch (widget.message.messageType?.toString()) {
      case "image":
      case "image_text":
        return Icons.image_outlined;

      case "video":
        return Icons.videocam_outlined;

      case "audio":
        return Icons.mic_none;

      case "document":
        return Icons.insert_drive_file_outlined;

      case "location":
        return Icons.location_on_outlined;

      case "contact":
        return Icons.person_outline;

      default:
        return Icons.message_outlined;
    }
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    int? total,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: AutoFitText(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count > 0 || (total ?? 0) > 0) ...[
            SizedBox(width: 5.w),
            Text(
              total != null && total > 0
                  ? appL10n.widget_seenCountOfTotal(count, total)
                  : "($count)",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyTile(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMemberTile(dynamic member, {required bool isSeen}) {
    final name = (member is Map ? member['name'] : member.name)?.toString().trim();
    final displayName = (name != null && name.isNotEmpty) ? name : appL10n.chat_unknown;
    final image = (member is Map ? member['profileImage'] : member.profileImage)?.toString() ?? "";
    final timestamp = member is Map
        ? (isSeen ? member['readAt'] ?? member['seenAt'] : member['deliveredAt'])
        : widget.message.timestamp;

    final formattedTime = _formatTimestamp(timestamp);

    return ListTile(
      onTap: () {
        final uid = member is Map ? member['userId'] : member.userId;
        final phone = member is Map ? member['mobileNo'] : member.mobileNo;
        final cId = member is Map ? member['chatId'] : member.chatId;
        showUserQuickProfile(
          userId: int.tryParse(uid?.toString() ?? ''),
          name: displayName,
          profileImage: image,
          mobileNo: phone?.toString(),
          chatId: int.tryParse(cId?.toString() ?? ''),
        );
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: image.isNotEmpty
            ? NetworkImage("${ConstRes.aImageBaseUrl}$image")
            : null,
        child: image.isEmpty
            ? Icon(Icons.person, size: 20.sp)
            : null,
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        formattedTime,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.done_all,
        color: isSeen ? Colors.blue : Colors.grey.shade600,
        size: 18.sp,
      ),
    );
  }

  Widget _buildPrivateReadTile() {
    final isSeen = _infoData?['isSeen'] == true ||
        ChatScreenRules.seenCount(
          widget.message,
          currentUserId: _currentUserId,
          isGroup: false,
        ) > 0;

    final seenTime = _formatTimestamp(
      _infoData?['seenAt'] ?? widget.message.timestamp,
    );

    if (!isSeen) {
      return _buildEmptyTile(appL10n.widget_notSeenYet);
    }

    final name = widget.memberData?.name?.toString().trim().isNotEmpty == true
        ? widget.memberData!.name.toString()
        : appL10n.chat_unknown;
    final image = widget.memberData?.profileImage?.toString() ?? "";

    return ListTile(
      onTap: () => showUserQuickProfile(
        userId: widget.memberData?.userId,
        name: name,
        profileImage: image,
        mobileNo: widget.memberData?.mobileNo,
        chatId: widget.memberData?.chatId,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: image.isNotEmpty
            ? NetworkImage("${ConstRes.aImageBaseUrl}$image")
            : null,
        child: image.isEmpty ? Icon(Icons.person, size: 20.sp) : null,
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        seenTime,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.done_all,
        color: Colors.blue,
        size: 18.sp,
      ),
    );
  }

  Widget _buildPrivateDeliveredTile() {
    final isDelivered = _infoData?['isDelivered'] == true ||
        widget.message.isDelivered == true ||
        widget.message.timestamp != null;

    final deliveredTime = _formatTimestamp(
      _infoData?['deliveredAt'] ?? widget.message.timestamp,
    );

    if (!isDelivered) {
      return _buildEmptyTile("Not delivered yet");
    }

    final name = widget.memberData?.name?.toString().trim().isNotEmpty == true
        ? widget.memberData!.name.toString()
        : appL10n.chat_unknown;
    final image = widget.memberData?.profileImage?.toString() ?? "";

    return ListTile(
      onTap: () => showUserQuickProfile(
        userId: widget.memberData?.userId,
        name: name,
        profileImage: image,
        mobileNo: widget.memberData?.mobileNo,
        chatId: widget.memberData?.chatId,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: image.isNotEmpty
            ? NetworkImage("${ConstRes.aImageBaseUrl}$image")
            : null,
        child: image.isEmpty ? Icon(Icons.person, size: 20.sp) : null,
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        deliveredTime,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.done_all,
        color: Colors.grey.shade600,
        size: 18.sp,
      ),
    );
  }
}
