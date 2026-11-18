import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:convert';
import 'package:fgtracker/app/modules/Messages/Controller/message_receipts.dart';

import '../Core/constant/const_res.dart';
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

class _MessageInfoSheetState extends State<MessageInfoSheet>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  Map<String, dynamic>? _infoData;

  // Private chat (unchanged behaviour).
  List<dynamic> _readByList = [];
  List<dynamic> _deliveredToList = [];

  // Group chat: userId -> time, forward-only (a reader is never removed).
  final Map<String, String?> _groupRead = {};
  final Map<String, String?> _groupDelivered = {};

  /// userId -> {name, profileImage, mobileNo, chatId} for the member rows.
  final Map<String, Map<String, dynamic>> _people = {};

  StreamSubscription<ReceiptUpdate>? _receiptSub;
  StreamSubscription<void>? _reconnectSub;
  Timer? _refetchTimer;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Receipts may have changed while the app was in the background.
    if (state == AppLifecycleState.resumed && _isGroup) _scheduleRefetch();
  }

  void _initLocalData() {
    if (_isGroup) {
      for (final m in widget.groupController?.groupMembers ?? const []) {
        final id = normalizeReceiptId(m.userId);
        if (id == null) continue;
        _people[id] = {
          'name': m.name,
          'profileImage': m.profileImage,
          'mobileNo': m.mobileNo,
          'chatId': m.chatId,
        };
      }
      _groupRead.addAll(MessageReceipts.readMap(widget.message));
      _groupDelivered.addAll(MessageReceipts.deliveredMap(widget.message));
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
        // App-level receipt stream (one socket listener for the whole app).
        _receiptSub = sm.groupReceipts.listen(_onGroupReceipt);
        _reconnectSub = sm.chatConnected.listen((_) => _scheduleRefetch());
        WidgetsBinding.instance.addObserver(this);
      } else {
        sm.privateChatSocket.on("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket.on("messages_delivered", _handlePrivateDeliveredUpdate);
      }
    } catch (_) {}
  }

  void _removeRealtimeListeners() {
    try {
      if (_isGroup) {
        _receiptSub?.cancel();
        _reconnectSub?.cancel();
        _refetchTimer?.cancel();
        WidgetsBinding.instance.removeObserver(this);
      } else {
        final sm = SocketMessageService.instance;
        sm.privateChatSocket.off("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket.off("messages_delivered", _handlePrivateDeliveredUpdate);
      }
    } catch (_) {}
  }

  /// Live group receipt. With message ids: applied at once if this message
  /// is one of them. Without ids (older server payloads): the Info API is
  /// re-read (debounced) instead of guessing.
  void _onGroupReceipt(ReceiptUpdate u) {
    if (!mounted) return;
    final gid = widget.groupController?.groupId.toString();
    if (u.groupId != null && gid != null && u.groupId != gid) return;
    final user = u.userId;
    if (user == null || user == normalizeReceiptId(_currentUserId)) return;
    if (user == normalizeReceiptId(widget.message.senderId)) return;
    if (u.messageIds.isEmpty) {
      _scheduleRefetch();
      return;
    }
    final msgId = normalizeReceiptId(widget.message.id);
    if (msgId == null || !u.messageIds.contains(msgId)) return;
    seenDbg('INFO apply ${u.isRead ? 'read' : 'delivered'} msg=$msgId user=$user');
    setState(() {
      if (u.isRead) {
        _groupRead.putIfAbsent(user, () => u.at);
        _groupDelivered.putIfAbsent(user, () => u.at);
      } else {
        _groupDelivered.putIfAbsent(user, () => u.at);
      }
    });
  }

  void _scheduleRefetch() {
    _refetchTimer?.cancel();
    _refetchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _fetchLiveInfo();
    });
  }

  /// Merges a `readBy` / `deliveredTo` list from the Info API into [into]
  /// (forward-only) and remembers names / photos for the rows.
  void _mergeGroupList(
    dynamic list,
    Map<String, String?> into, {
    required List<String> timeKeys,
  }) {
    if (list is! List) return;
    for (final e in list) {
      final id = normalizeReceiptId(e);
      if (id == null) continue;
      String? at;
      if (e is Map) {
        for (final k in timeKeys) {
          if (e[k] != null) {
            at = e[k].toString();
            break;
          }
        }
        final person = _people.putIfAbsent(id, () => {});
        for (final k in const ['name', 'profileImage', 'mobileNo', 'chatId']) {
          if (e[k] != null) person[k] = e[k];
        }
      }
      if (!into.containsKey(id) || (into[id] == null && at != null)) {
        into[id] = at;
      }
    }
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

  Future<void> _fetchLiveInfo() async {
    final msgId = widget.message.id;
    if (msgId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final chatType = _isGroup ? "group" : "private";
      seenDbg('INFO API GET /messages/$msgId/info?chatType=$chatType');
      final res = await MessageRepo.getMessageInfo(
        messageId: msgId,
        chatType: chatType,
      );
      seenDbg('INFO API response => $res');

      if (mounted && res != null && res['status'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        setState(() {
          _infoData = data;
          if (_isGroup) {
            _mergeGroupList(data['readBy'], _groupRead,
                timeKeys: const ['readAt', 'seenAt', 'read_at']);
            _mergeGroupList(data['deliveredTo'], _groupDelivered,
                timeKeys: const ['deliveredAt', 'delivered_at']);
            // A reader has also received it.
            for (final e in _groupRead.entries) {
              _groupDelivered.putIfAbsent(e.key, () => e.value);
            }
          } else {
            if (data['readBy'] is List) {
              _readByList = List<dynamic>.from(data['readBy']);
            }
            if (data['deliveredTo'] is List) {
              // 1-to-1 Private Chat Parity: Keep delivery time even when read
              _deliveredToList = List<dynamic>.from(data['deliveredTo']);
            }
          }
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      seenDbg('INFO API error => $e');
    }

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

  /// Group, WhatsApp style: "Read by" and "Delivered to" cards, each with
  /// the members and their time on the right, and "N remaining" under it.
  /// Built with the same aggregation as the bubble tick (MessageReceipts).
  List<Widget> _buildGroupSections() {
    final summary = MessageReceipts.summarizeMaps(
      senderId: widget.message.senderId,
      read: _groupRead,
      delivered: _groupDelivered,
      memberIds:
          widget.groupController?.groupMembers.map((m) => m.userId) ?? const [],
    );
    final recipients = summary.recipients.toSet();
    final notRead =
        recipients.where((id) => !summary.read.containsKey(id)).length;
    final notReceived = summary.remaining.length;

    List<MapEntry<String, String?>> newestFirst(Map<String, String?> m) =>
        m.entries.toList()
          ..sort((a, b) => (b.value ?? '').compareTo(a.value ?? ''));

    return [
      SizedBox(height: 10.h),
      _groupCard(
        key: const ValueKey('msg_info_read_card'),
        icon: Icons.done_all,
        iconColor: const Color(0xFF34B7F1),
        title: appL10n.msgInfo_readBy,
        rows: [
          for (final e in newestFirst(summary.read))
            _groupMemberTile(e.key, time: e.value, kind: _RowKind.read),
        ],
        remaining: notRead,
      ),
      SizedBox(height: 10.h),
      _groupCard(
        key: const ValueKey('msg_info_delivered_card'),
        icon: Icons.done_all,
        iconColor: Colors.grey.shade600,
        title: appL10n.msgInfo_deliveredTo,
        rows: [
          for (final e in newestFirst(summary.delivered))
            _groupMemberTile(e.key, time: e.value, kind: _RowKind.delivered),
        ],
        remaining: notReceived,
      ),
    ];
  }

  Widget _groupCard({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> rows,
    required int remaining,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                ),
                Icon(icon, color: iconColor, size: 20.sp),
              ],
            ),
          ),
          ...rows,
          if (remaining > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
              child: Text(
                appL10n.msgInfo_remainingCount(remaining),
                style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade600),
              ),
            )
          else
            SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _groupMemberTile(
    String userId, {
    required String? time,
    required _RowKind kind,
  }) {
    final person = _people[userId] ?? const <String, dynamic>{};
    final name = person['name']?.toString().trim();
    final displayName =
        (name != null && name.isNotEmpty) ? name : appL10n.chat_unknown;
    final image = person['profileImage']?.toString() ?? '';
    final imageUrl = image.startsWith('http://') || image.startsWith('https://')
        ? image
        : "${ConstRes.aImageBaseUrl}$image";

    return InkWell(
      key: ValueKey('msg_info_${kind.name}_$userId'),
      onTap: () => showUserQuickProfile(
        userId: int.tryParse(userId),
        name: displayName,
        profileImage: image,
        mobileNo: person['mobileNo']?.toString(),
        chatId: int.tryParse(person['chatId']?.toString() ?? ''),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage: image.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: image.isEmpty
                  ? Icon(Icons.person, size: 20.sp, color: const Color(0xFF5D47F1))
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            if (time != null) ...[
              SizedBox(width: 8.w),
              Text(
                _formatTimestamp(time),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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

                    if (_isGroup)
                      ..._buildGroupSections()
                    else ...[
                    // 1. Read / Seen Section
                    _buildSectionTitle(
                      icon: Icons.done_all,
                      iconColor: Colors.blue,
                      title: appL10n.widget_seen,
                      count: privateReadCount,
                    ),
                    _buildPrivateReadTile(),

                    SizedBox(height: 8.h),
                    Divider(height: 1, color: Colors.grey.shade200),

                    // 2. Delivered Section
                    _buildSectionTitle(
                      icon: Icons.done_all,
                      iconColor: Colors.grey.shade600,
                      title: appL10n.chatSys_delivered,
                      count: privateDeliveredCount,
                    ),
                    _buildPrivateDeliveredTile(),
                    ],

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

      case "attendance":
        preview = _attendanceTitle();
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

      case "attendance":
        return Icons.event_available_outlined;

      default:
        return Icons.message_outlined;
    }
  }

  /// Attendance content is JSON like {"attendancePollId":1,"title":"…"}.
  /// Show its title, never the raw JSON.
  String _attendanceTitle() {
    try {
      final decoded = jsonDecode(widget.message.content?.toString() ?? "");
      if (decoded is Map) {
        final title = decoded["title"]?.toString().trim() ?? "";
        if (title.isNotEmpty) return title;
      }
    } catch (_) {}
    return appL10n.chat_previewAttendancePoll;
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
      return _buildEmptyTile(appL10n.chatSys_notDeliveredYet);
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

/// Which group section a member row belongs to.
enum _RowKind { read, delivered }
