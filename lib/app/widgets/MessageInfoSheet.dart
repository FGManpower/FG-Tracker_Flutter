import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();
    final senderId = message.senderId?.toString();
    // Guard: Message info should only ever be opened for messages sent by me!
    if (senderId != null &&
        currentUserId != null &&
        senderId.isNotEmpty &&
        currentUserId.isNotEmpty &&
        senderId != currentUserId) {
      return;
    }

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

  // Private chat.
  List<dynamic> _readByList = [];
  List<dynamic> _deliveredToList = [];
  List<dynamic> _playedByList = [];

  // Group chat: userId -> time, forward-only (a reader is never removed).
  final Map<String, String?> _groupRead = {};
  final Map<String, String?> _groupDelivered = {};
  final Map<String, String?> _groupPlayed = {};

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
    if (_isGroup && (widget.groupController?.groupMembers.isEmpty ?? true)) {
      widget.groupController?.getGroupMembers().then((_) {
        if (mounted) {
          setState(() {
            _initLocalData();
          });
        }
      });
    }
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
        sm.privateChatSocket
            .on("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket
            .on("messages_delivered", _handlePrivateDeliveredUpdate);
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
        sm.privateChatSocket
            .off("messages_seen_update", _handlePrivateSeenUpdate);
        sm.privateChatSocket
            .off("messages_delivered", _handlePrivateDeliveredUpdate);
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
    seenDbg(
        'INFO apply ${u.isRead ? 'read' : 'delivered'} msg=$msgId user=$user');
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
      final map =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId != null && ids.contains(currentMsgId)) {
        final seenAt =
            map['seenAt']?.toString() ?? DateTime.now().toIso8601String();
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
      final map =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final ids = (map['messageIds'] is List
              ? (map['messageIds'] as List)
              : [map['messageId'], map['id']])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toSet();

      final currentMsgId = widget.message.id?.toString();
      if (currentMsgId != null && ids.contains(currentMsgId)) {
        final delAt =
            map['deliveredAt']?.toString() ?? DateTime.now().toIso8601String();
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
          } else if (_deliveredToList.isNotEmpty &&
              _deliveredToList.first is Map) {
            (_deliveredToList.first as Map)['deliveredAt'] = delAt;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchLiveInfo() async {
    final msgId = widget.message.id ??
        int.tryParse(widget.message.attendancePollId?.toString() ?? '') ??
        int.tryParse(widget.message.attendance?['id']?.toString() ?? '') ??
        int.tryParse(widget.message.attendance?['pollId']?.toString() ?? '');
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

      if (mounted &&
          res != null &&
          res['status'] == true &&
          res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        setState(() {
          _infoData = data;
          if (_isGroup) {
            _mergeGroupList(data['playedBy'] ?? data['played_by'], _groupPlayed,
                timeKeys: const ['playedAt', 'played_at', 'listenAt', 'listened_at']);
            _mergeGroupList(data['readBy'], _groupRead,
                timeKeys: const ['readAt', 'seenAt', 'read_at']);
            _mergeGroupList(data['deliveredTo'], _groupDelivered,
                timeKeys: const ['deliveredAt', 'delivered_at']);
            // A listener has read & received it, and a reader has also received it.
            for (final e in _groupPlayed.entries) {
              _groupRead.putIfAbsent(e.key, () => e.value);
              _groupDelivered.putIfAbsent(e.key, () => e.value);
            }
            for (final e in _groupRead.entries) {
              _groupDelivered.putIfAbsent(e.key, () => e.value);
            }
          } else {
            if (data['playedBy'] is List) {
              _playedByList = List<dynamic>.from(data['playedBy']);
            } else if (data['played_by'] is List) {
              _playedByList = List<dynamic>.from(data['played_by']);
            }
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

  DateTime? _parseTimestampToLocal(dynamic ts) {
    if (ts == null) return null;
    if (ts is DateTime) return ts.toLocal();
    final s = ts.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'undefined') return null;
    final numVal = int.tryParse(s);
    if (numVal != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        numVal > 10000000000 ? numVal : numVal * 1000,
        isUtc: true,
      ).toLocal();
    }
    if (!s.endsWith('Z') &&
        s.contains('-') &&
        (s.contains(' ') || s.contains('T'))) {
      final isoStr = s.replaceFirst(' ', 'T');
      final withZ = isoStr.endsWith('Z') ? isoStr : '${isoStr}Z';
      final dt = DateTime.tryParse(withZ);
      if (dt != null) return dt.toLocal();
    }
    return DateTime.tryParse(s)?.toLocal();
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return "---";
    final dt = _parseTimestampToLocal(ts);
    if (dt == null) {
      final s = ts.toString().trim();
      return (s.isEmpty || s == 'null' || s == 'undefined') ? "---" : s;
    }
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(dt.year, dt.month, dt.day);
      final timeStr = appDateFormat('hh:mm a').format(dt);
      if (itemDate == today) {
        return "${appL10n.common_today} $timeStr";
      } else if (itemDate == today.subtract(const Duration(days: 1))) {
        return "${appL10n.common_yesterday} $timeStr";
      } else if (now.year == dt.year) {
        return "${appDateFormat('dd MMM').format(dt)} $timeStr";
      } else {
        return "${appDateFormat('dd MMM yyyy').format(dt)} $timeStr";
      }
    } catch (_) {
      return ts.toString();
    }
  }

  /// Group, WhatsApp style: "READ BY", "DELIVERED TO", "REMAINING", and optional "PLAYED BY".
  List<Widget> _buildGroupSections() {
    final summary = MessageReceipts.summarizeMaps(
      senderId: widget.message.senderId,
      read: _groupRead,
      delivered: _groupDelivered,
      memberIds:
          widget.groupController?.groupMembers.map((m) => m.userId) ?? const [],
    );

    final isAudio = widget.message.messageType == 'audio' ||
        widget.message.messageType == 'voice';

    List<MapEntry<String, String?>> newestFirst(Map<String, String?> m) =>
        m.entries.toList()
          ..sort((a, b) => (b.value ?? '').compareTo(a.value ?? ''));

    final cards = <Widget>[];

    // 0. Optional Played section for Audio / Voice
    if (isAudio && _groupPlayed.isNotEmpty) {
      cards.addAll([
        SizedBox(height: 10.h),
        _groupCard(
          key: const ValueKey('msg_info_played_card'),
          icon: Icons.mic,
          iconColor: const Color(0xFF34B7F1),
          title: "PLAYED BY",
          count: _groupPlayed.length,
          emptyText: "Not played yet",
          rows: [
            for (final e in newestFirst(_groupPlayed))
              _groupMemberTile(e.key, time: e.value, kind: _RowKind.played),
          ],
        ),
      ]);
    }

    // 1. Read by (exclude members who already appear in PLAYED BY)
    final readFiltered = <String, String?>{
      for (final e in summary.read.entries)
        if (!isAudio || !_groupPlayed.containsKey(e.key)) e.key: e.value,
    };

    cards.addAll([
      SizedBox(height: 10.h),
      _groupCard(
        key: const ValueKey('msg_info_read_card'),
        icon: Icons.done_all,
        iconColor: const Color(0xFF34B7F1),
        title: "READ BY",
        count: readFiltered.length,
        emptyText: appL10n.widget_notSeenYet,
        rows: [
          for (final e in newestFirst(readFiltered))
            _groupMemberTile(e.key, time: e.value, kind: _RowKind.read),
        ],
      ),
    ]);

    // 2. Delivered to
    cards.addAll([
      SizedBox(height: 10.h),
      _groupCard(
        key: const ValueKey('msg_info_delivered_card'),
        icon: Icons.done_all,
        iconColor: Colors.grey.shade600,
        title: "DELIVERED TO",
        count: summary.delivered.length,
        emptyText: appL10n.chatSys_notDeliveredYet,
        rows: [
          for (final e in newestFirst(summary.delivered))
            _groupMemberTile(e.key, time: e.value, kind: _RowKind.delivered),
        ],
      ),
    ]);

    // 3. Remaining (Jinko deliver nahi hua)
    if (summary.remaining.isNotEmpty) {
      cards.addAll([
        SizedBox(height: 10.h),
        _groupCard(
          key: const ValueKey('msg_info_remaining_card'),
          icon: Icons.access_time_rounded,
          iconColor: Colors.grey.shade500,
          title: "REMAINING",
          count: summary.remaining.length,
          emptyText: null,
          rows: [
            for (final userId in summary.remaining)
              _groupMemberTile(userId, time: null, kind: _RowKind.remaining),
          ],
        ),
      ]);
    }

    return cards;
  }

  Widget _groupCard({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> rows,
    int? count,
    String? emptyText,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                    count != null && count > 0 ? "$title ($count)" : title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E202B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(icon, color: iconColor, size: 18.sp),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F1F5)),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Text(
                emptyText ?? "---",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...rows,
          SizedBox(height: 4.h),
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

    final IconData icon;
    final Color iconColor;
    final String timeDisplay;
    switch (kind) {
      case _RowKind.played:
        icon = Icons.mic;
        iconColor = const Color(0xFF34B7F1);
        timeDisplay = _formatTimestamp(time);
        break;
      case _RowKind.read:
        icon = Icons.done_all;
        iconColor = const Color(0xFF34B7F1);
        timeDisplay = _formatTimestamp(time);
        break;
      case _RowKind.delivered:
        icon = Icons.done_all;
        iconColor = Colors.grey.shade600;
        timeDisplay = _formatTimestamp(time);
        break;
      case _RowKind.remaining:
        icon = Icons.access_time_rounded;
        iconColor = Colors.grey.shade400;
        timeDisplay = "Pending";
        break;
    }

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
                  ? Icon(Icons.person,
                      size: 20.sp, color: const Color(0xFF5D47F1))
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E202B),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeDisplay,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(icon, color: iconColor, size: 16.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAudio = widget.message.messageType == 'audio' ||
        widget.message.messageType == 'voice';

    final isSeen = _infoData?['isSeen'] == true ||
        _readByList.isNotEmpty ||
        ChatScreenRules.seenCount(
              widget.message,
              currentUserId: _currentUserId,
              isGroup: false,
            ) >
            0;

    final isDelivered = _infoData?['isDelivered'] == true ||
        _deliveredToList.isNotEmpty ||
        widget.message.isDelivered == true ||
        isSeen;

    final isPlayed = isAudio &&
        (_infoData?['isPlayed'] == true ||
            _infoData?['playedAt'] != null ||
            _infoData?['played_at'] != null ||
            _playedByList.isNotEmpty);

    final rawPlayedAt = _infoData?['playedAt'] ??
        _infoData?['played_at'] ??
        (_playedByList.isNotEmpty && _playedByList.first is Map
            ? _playedByList.first['playedAt']
            : null);

    final rawSeenAt = _infoData?['seenAt'] ??
        _infoData?['readAt'] ??
        (_readByList.isNotEmpty && _readByList.first is Map
            ? (_readByList.first['readAt'] ?? _readByList.first['seenAt'])
            : null);

    final rawDeliveredAt = _infoData?['deliveredAt'] ??
        _infoData?['delivered_at'] ??
        (_deliveredToList.isNotEmpty && _deliveredToList.first is Map
            ? _deliveredToList.first['deliveredAt']
            : null);

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
                      // 0. Played Section for Voice/Audio (if played)
                      if (isPlayed) ...[
                        SizedBox(height: 10.h),
                        _buildSectionCard(
                          icon: Icons.mic,
                          iconColor: const Color(0xFF34B7F1),
                          title: "PLAYED",
                          child: _buildPrivateMemberRow(
                            name: widget.memberData?.name,
                            image: widget.memberData?.profileImage,
                            time: rawPlayedAt,
                            secondaryTime: rawDeliveredAt,
                            icon: Icons.mic,
                            tickColor: const Color(0xFF34B7F1),
                            userId: widget.memberData?.userId,
                            mobileNo: widget.memberData?.mobileNo,
                            chatId: widget.memberData?.chatId,
                          ),
                        ),
                      ] else if (isSeen) ...[
                        // 1. Read / Seen Section (ONLY when seen and not played)
                        SizedBox(height: 10.h),
                        _buildSectionCard(
                          icon: Icons.done_all,
                          iconColor: const Color(0xFF34B7F1),
                          title: "READ",
                          child: _buildPrivateMemberRow(
                            name: widget.memberData?.name,
                            image: widget.memberData?.profileImage,
                            time: rawSeenAt,
                            secondaryTime: rawDeliveredAt,
                            icon: Icons.done_all,
                            tickColor: const Color(0xFF34B7F1),
                            userId: widget.memberData?.userId,
                            mobileNo: widget.memberData?.mobileNo,
                            chatId: widget.memberData?.chatId,
                          ),
                        ),
                      ] else ...[
                        // 2. Delivered Section (ONLY when NOT seen / read yet!)
                        SizedBox(height: 10.h),
                        _buildSectionCard(
                          icon: Icons.done_all,
                          iconColor: Colors.grey.shade600,
                          title: "DELIVERED",
                          child: isDelivered
                              ? _buildPrivateMemberRow(
                                  name: widget.memberData?.name,
                                  image: widget.memberData?.profileImage,
                                  time: rawDeliveredAt,
                                  icon: Icons.done_all,
                                  tickColor: Colors.grey.shade600,
                                  userId: widget.memberData?.userId,
                                  mobileNo: widget.memberData?.mobileNo,
                                  chatId: widget.memberData?.chatId,
                                )
                              : _buildEmptyTile(appL10n.chatSys_notDeliveredYet),
                        ),
                      ],
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

  Widget _buildMediaThumbnail() {
    final type = (widget.message.messageType?.toString() ?? '').toLowerCase().trim();
    String? mediaPath;
    if (widget.message.images?.isNotEmpty ?? false) {
      mediaPath = widget.message.images!.first;
    } else if (type == 'image' || type == 'image_text' || type == 'media') {
      final c = widget.message.content?.toString() ?? '';
      if (c.isNotEmpty && !c.contains('||')) mediaPath = c;
    } else if (type == 'video') {
      if (widget.message.videos?.isNotEmpty ?? false) {
        final v = widget.message.videos!.first;
        mediaPath = v.thumbnail ?? v.videoUrl;
      }
    }

    if (mediaPath != null && mediaPath.trim().isNotEmpty) {
      final val = mediaPath.trim();
      final isLocal = val.startsWith('/') && !val.startsWith('http');
      Widget img;
      if (isLocal) {
        img = Image.file(
          File(val),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(_getMessageIcon(), color: Colors.grey.shade600, size: 22.sp),
        );
      } else {
        final fullUrl = val.startsWith('http://') || val.startsWith('https://')
            ? val
            : '${ConstRes.aImageBaseUrl}$val';
        img = Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(_getMessageIcon(), color: Colors.grey.shade600, size: 22.sp),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 48.w,
          height: 48.w,
          color: Colors.grey.shade200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              img,
              if (type == 'video')
                Center(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18.sp),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Default icon badge for non-image attachments or text
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Icon(
          _getMessageIcon(),
          color: const Color(0xFF5045B9),
          size: 22.sp,
        ),
      ),
    );
  }

  Widget _buildMessagePreview() {
    String preview;
    final caption = widget.message.caption?.toString().trim() ?? "";

    switch (widget.message.messageType?.toString()) {
      case "image":
      case "image_text":
      case "media":
        preview = caption.isNotEmpty ? caption : appL10n.util_previewPhoto;
        break;

      case "video":
        preview = caption.isNotEmpty ? caption : appL10n.util_previewVideo;
        break;

      case "audio":
        preview = caption.isNotEmpty ? caption : appL10n.util_previewVoice;
        break;

      case "document":
        final raw = widget.message.content?.toString() ?? "";
        final parts = raw.split("||");
        final docUrl = parts.isNotEmpty ? parts[0] : "";
        String docName = parts.length > 1 ? parts[1] : docUrl.split('/').last;
        if (docName.isEmpty || docName == 'null') docName = appL10n.util_previewDocument;
        preview = caption.isNotEmpty ? "$docName • $caption" : docName;
        break;

      case "location":
        preview = appL10n.util_previewLocation;
        break;

      case "contact":
        final c = widget.message.content?.toString() ?? "";
        preview = c.isNotEmpty && !c.startsWith('{') ? c : appL10n.util_previewContact;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMediaThumbnail(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Sent: $sentTime",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
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
      final dynamic att = widget.message.attendance;
      if (att is Map) {
        final title = att['title']?.toString().trim() ?? '';
        final desc = att['description']?.toString().trim() ?? '';
        if (title.isNotEmpty && desc.isNotEmpty) return '$title • $desc';
        if (title.isNotEmpty) return title;
      }
      final decoded = jsonDecode(widget.message.content?.toString() ?? "");
      if (decoded is Map) {
        final title = decoded["title"]?.toString().trim() ?? "";
        final desc = decoded["description"]?.toString().trim() ?? "";
        if (title.isNotEmpty && desc.isNotEmpty) return '$title • $desc';
        if (title.isNotEmpty) return title;
      }
    } catch (_) {}
    return appL10n.chat_previewAttendancePoll;
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E202B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(icon, color: iconColor, size: 18.sp),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F1F5)),
          child,
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildPrivateMemberRow({
    required dynamic name,
    required dynamic image,
    required dynamic time,
    required IconData icon,
    required Color tickColor,
    dynamic secondaryTime,
    IconData? secondaryIcon,
    Color? secondaryTickColor,
    dynamic userId,
    dynamic mobileNo,
    dynamic chatId,
  }) {
    final displayName = (name != null && name.toString().trim().isNotEmpty)
        ? name.toString().trim()
        : appL10n.chat_unknown;
    final imageStr = image?.toString() ?? "";
    final imageUrl = imageStr.startsWith('http://') || imageStr.startsWith('https://')
        ? imageStr
        : "${ConstRes.aImageBaseUrl}$imageStr";
    final timeStr = time != null
        ? _formatTimestamp(time)
        : (_isLoading ? "Loading..." : "Pending");

    return InkWell(
      onTap: () => showUserQuickProfile(
        userId: userId is int ? userId : int.tryParse(userId?.toString() ?? ''),
        name: displayName,
        profileImage: imageStr,
        mobileNo: mobileNo?.toString(),
        chatId: chatId is int ? chatId : int.tryParse(chatId?.toString() ?? ''),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage: imageStr.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageStr.isEmpty
                  ? Icon(Icons.person,
                      size: 20.sp, color: const Color(0xFF5D47F1))
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E202B),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(icon, color: tickColor, size: 16.sp),
                  ],
                ),
                if (secondaryTime != null) ...[
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(secondaryTime),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        secondaryIcon ?? Icons.done_all,
                        color: secondaryTickColor ?? Colors.grey.shade500,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTile(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
}

/// Which group section a member row belongs to.
enum _RowKind { played, read, delivered, remaining }
