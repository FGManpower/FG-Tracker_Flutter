import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Core/constant/const_res.dart';
import '../Core/util/DateTime_Format.dart';
import '../Core/util/profile_navigation.dart';
import '../Data/Repositories/GetMessageRepo.dart';
import '../Data/Services/Socket/Socket_Message_Services.dart';
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

  /// Single entrypoint that guarantees only 1 Message Info dialog / sheet
  /// is ever open at a time (preventing overlapping dialogs).
  static bool _isOpen = false;

  static Future<void> show({
    required BuildContext context,
    required MessageData message,
    GroupMessageController? groupController,
    MemberData? memberData,
  }) async {
    if (_isOpen) return;
    _isOpen = true;
    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => MessageInfoSheet(
          message: message,
          groupController: groupController,
          memberData: memberData,
        ),
      );
    } finally {
      _isOpen = false;
    }
  }

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
    _setupRealtimeListeners();
    _fetchLiveInfo();
  }

  @override
  void dispose() {
    _removeRealtimeListeners();
    super.dispose();
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
                'readAt': null, // Populated by server live fetch or real-time event
              })
          .toList();

      // In WhatsApp parity, Delivered section only contains members who have NOT yet seen the message
      _deliveredToList = activeOthers
          .where((m) =>
              !seenIds.contains(m.userId?.toString()) &&
              widget.message.isDelivered)
          .map((m) => {
                'userId': m.userId,
                'name': m.name,
                'profileImage': m.profileImage,
                'mobileNo': m.mobileNo,
                'chatId': m.chatId,
                'deliveredAt': null, // Populated by server live fetch or real-time event
              })
          .toList();
    } else {
      // 1-to-1 Private Chat Local Initialization
      final isSeenLocally = ChatScreenRules.seenCount(
            widget.message,
            currentUserId: _currentUserId,
            isGroup: false,
          ) >
          0;
      final isDeliveredLocally = widget.message.isDelivered || isSeenLocally;

      if (widget.memberData != null) {
        final m = widget.memberData!;
        final userDetail = {
          'userId': m.userId,
          'name': m.name,
          'profileImage': m.profileImage,
          'mobileNo': m.mobileNo,
          'chatId': m.chatId,
        };

        if (isSeenLocally) {
          _readByList = [
            {...userDetail, 'readAt': null}
          ];
        }
        if (isDeliveredLocally) {
          _deliveredToList = [
            {...userDetail, 'deliveredAt': null}
          ];
        }
      }
    }
  }

  void _setupRealtimeListeners() {
    try {
      final sm = SocketMessageService.instance;
      if (_isGroup) {
        sm.socket.on("messages_seen_update", _handleGroupSeenUpdate);
        sm.socket.on("group_message_seen", _handleGroupSeenUpdate);
        sm.socket.on("group_messages_delivered", _handleGroupDeliveredUpdate);
        sm.socket.on("messages_delivered", _handleGroupDeliveredUpdate);
      } else {
        sm.privateChatSocket.on("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket.on("messages_delivered", _handlePrivateDeliveredUpdate);
      }
    } catch (_) {}
  }

  void _removeRealtimeListeners() {
    try {
      final sm = SocketMessageService.instance;
      if (_isGroup) {
        sm.socket.off("messages_seen_update", _handleGroupSeenUpdate);
        sm.socket.off("group_message_seen", _handleGroupSeenUpdate);
        sm.socket.off("group_messages_delivered", _handleGroupDeliveredUpdate);
        sm.socket.off("messages_delivered", _handleGroupDeliveredUpdate);
      } else {
        sm.privateChatSocket.off("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket.off("messages_delivered", _handlePrivateDeliveredUpdate);
      }
    } catch (_) {}
  }

  void _handlePrivateSeenUpdate(dynamic data) {
    if (!mounted || data == null) return;
    try {
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId != null && ids.contains(currentMsgId)) {
        final seenAt = map['seenAt']?.toString() ?? DateTime.now().toIso8601String();
        setState(() {
          _infoData ??= {};
          _infoData!['isSeen'] = true;
          _infoData!['seenAt'] = seenAt;
          widget.message.seenCount = 1;
          if (_readByList.isEmpty && widget.memberData != null) {
            _readByList = [
              {
                'userId': widget.memberData!.userId,
                'name': widget.memberData!.name,
                'profileImage': widget.memberData!.profileImage,
                'mobileNo': widget.memberData!.mobileNo,
                'chatId': widget.memberData!.chatId,
                'readAt': seenAt,
              }
            ];
          } else if (_readByList.isNotEmpty && _readByList.first is Map) {
            (_readByList.first as Map)['readAt'] = seenAt;
          }
        });
      }
    } catch (_) {}
  }

  void _handlePrivateDeliveredUpdate(dynamic data) {
    if (!mounted || data == null) return;
    try {
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId != null && ids.contains(currentMsgId)) {
        final delAt = map['deliveredAt']?.toString() ?? DateTime.now().toIso8601String();
        setState(() {
          _infoData ??= {};
          _infoData!['isDelivered'] = true;
          _infoData!['deliveredAt'] = delAt;
          widget.message.isDelivered = true;
          if (_deliveredToList.isEmpty && widget.memberData != null) {
            _deliveredToList = [
              {
                'userId': widget.memberData!.userId,
                'name': widget.memberData!.name,
                'profileImage': widget.memberData!.profileImage,
                'mobileNo': widget.memberData!.mobileNo,
                'chatId': widget.memberData!.chatId,
                'deliveredAt': delAt,
              }
            ];
          } else if (_deliveredToList.isNotEmpty && _deliveredToList.first is Map) {
            (_deliveredToList.first as Map)['deliveredAt'] = delAt;
          }
        });
      }
    } catch (_) {}
  }

  void _handleGroupSeenUpdate(dynamic data) {
    if (!mounted || data == null) return;
    try {
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId == null || !ids.contains(currentMsgId)) return;

      final readerId = (map['userId'] ?? map['readerId'] ?? map['reader_id'])?.toString();
      if (readerId == null || readerId == _currentUserId) return;

      final seenAt = map['seenAt']?.toString() ?? DateTime.now().toIso8601String();
      final members = widget.groupController?.groupMembers ?? [];
      final member = members.firstWhereOrNull((m) => m.userId?.toString() == readerId);

      final displayName = map['readerName'] ?? member?.name ?? "Member";
      final displayImage = map['readerImage'] ?? member?.profileImage ?? "";
      final phone = member?.mobileNo ?? "";
      final cId = member?.chatId;

      setState(() {
        // WhatsApp Mutual Exclusivity: Remove from deliveredTo when seen
        _deliveredToList.removeWhere(
            (m) => (m is Map ? m['userId'] : m?.userId)?.toString() == readerId);

        // Add or update in readBy
        final existingIdx = _readByList.indexWhere(
            (m) => (m is Map ? m['userId'] : m?.userId)?.toString() == readerId);
        final entry = {
          'userId': readerId,
          'name': displayName,
          'profileImage': displayImage,
          'mobileNo': phone,
          'chatId': cId,
          'readAt': seenAt,
        };
        if (existingIdx >= 0) {
          _readByList[existingIdx] = entry;
        } else {
          _readByList.insert(0, entry);
        }

        _infoData ??= {};
        _infoData!['readCount'] = _readByList.length;
        _infoData!['deliveredCount'] = _deliveredToList.length;
      });
    } catch (_) {}
  }

  void _handleGroupDeliveredUpdate(dynamic data) {
    if (!mounted || data == null) return;
    try {
      final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId == null || !ids.contains(currentMsgId)) return;

      final recipientId =
          (map['userId'] ?? map['recipientId'] ?? map['recipient_id'])?.toString();
      if (recipientId == null || recipientId == _currentUserId) return;

      // If already in readBy, WhatsApp mutual exclusivity: do not add to delivered
      final isAlreadyRead = _readByList.any(
          (m) => (m is Map ? m['userId'] : m?.userId)?.toString() == recipientId);
      if (isAlreadyRead) return;

      final delAt = map['deliveredAt']?.toString() ?? DateTime.now().toIso8601String();
      final members = widget.groupController?.groupMembers ?? [];
      final member = members.firstWhereOrNull((m) => m.userId?.toString() == recipientId);

      final displayName = map['name'] ?? member?.name ?? "Member";
      final displayImage = map['profileImage'] ?? member?.profileImage ?? "";
      final phone = member?.mobileNo ?? "";
      final cId = member?.chatId;

      setState(() {
        final existingIdx = _deliveredToList.indexWhere(
            (m) => (m is Map ? m['userId'] : m?.userId)?.toString() == recipientId);
        final entry = {
          'userId': recipientId,
          'name': displayName,
          'profileImage': displayImage,
          'mobileNo': phone,
          'chatId': cId,
          'deliveredAt': delAt,
        };
        if (existingIdx >= 0) {
          _deliveredToList[existingIdx] = entry;
        } else {
          _deliveredToList.insert(0, entry);
        }

        _infoData ??= {};
        _infoData!['deliveredCount'] = _deliveredToList.length;
      });
    } catch (_) {}
  }

  Future<void> _fetchLiveInfo() async {
    final msgId = widget.message.id;
    if (msgId == null) {
      if (mounted) setState(() => _isLoading = false);
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
            if (_isGroup) {
              final readIds = _readByList
                  .map((m) => (m is Map ? m['userId'] : m?.userId)?.toString())
                  .whereType<String>()
                  .toSet();
              // WhatsApp Parity: Exclude anyone who already read the message from deliveredTo in group
              _deliveredToList = List<dynamic>.from(data['deliveredTo'])
                  .where((m) =>
                      !readIds.contains((m is Map ? m['userId'] : m?.userId)?.toString()))
                  .toList();
            } else {
              // 1-to-1 Private Chat Parity: Keep delivery time even when read
              _deliveredToList = List<dynamic>.from(data['deliveredTo']);
            }
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

    final privateReadCount = (_infoData?['isSeen'] == true ||
            (_infoData?['readBy'] is List && (_infoData!['readBy'] as List).isNotEmpty) ||
            _readByList.isNotEmpty ||
            ChatScreenRules.seenCount(widget.message, currentUserId: _currentUserId, isGroup: false) > 0)
        ? 1
        : 0;

    final privateDeliveredCount = (_infoData?['isDelivered'] == true ||
            (_infoData?['deliveredTo'] is List && (_infoData!['deliveredTo'] as List).isNotEmpty) ||
            _deliveredToList.isNotEmpty ||
            widget.message.isDelivered == true ||
            privateReadCount > 0)
        ? 1
        : 0;

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
                      count: _isGroup ? _readByList.length : privateReadCount,
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
                      count: _isGroup ? _deliveredToList.length : privateDeliveredCount,
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
        ? (isSeen ? (member['readAt'] ?? member['seenAt']) : member['deliveredAt'])
        : null;

    final formattedTime = timestamp != null ? _formatTimestamp(timestamp) : (isSeen ? "Seen" : "Delivered");

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
        _readByList.isNotEmpty ||
        ChatScreenRules.seenCount(
          widget.message,
          currentUserId: _currentUserId,
          isGroup: false,
        ) >
        0;

    if (!isSeen) {
      return _buildEmptyTile(appL10n.widget_notSeenYet);
    }

    final rawSeenAt = _infoData?['seenAt'] ??
        (_readByList.isNotEmpty && _readByList.first is Map
            ? (_readByList.first['readAt'] ?? _readByList.first['seenAt'])
            : null);
    final seenTime = rawSeenAt != null
        ? _formatTimestamp(rawSeenAt)
        : (_isLoading ? "Loading..." : "Seen");

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
      trailing: const Icon(
        Icons.done_all,
        color: Colors.blue,
        size: 18,
      ),
    );
  }

  Widget _buildPrivateDeliveredTile() {
    final isDelivered = _infoData?['isDelivered'] == true ||
        _deliveredToList.isNotEmpty ||
        widget.message.isDelivered == true ||
        _infoData?['isSeen'] == true ||
        _readByList.isNotEmpty;

    if (!isDelivered) {
      return _buildEmptyTile("Not delivered yet");
    }

    final rawDeliveredAt = _infoData?['deliveredAt'] ??
        (_deliveredToList.isNotEmpty && _deliveredToList.first is Map
            ? _deliveredToList.first['deliveredAt']
            : null);
    final deliveredTime = rawDeliveredAt != null
        ? _formatTimestamp(rawDeliveredAt)
        : (_isLoading ? "Loading..." : "Delivered");

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
        size: 18,
      ),
    );
  }
}
