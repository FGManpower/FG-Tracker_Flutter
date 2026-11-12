import 'dart:async';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum GroupSheetType { joined, left, created }

/// Confirmation bottom sheet shown after the current user successfully
/// joins, leaves or creates a group. UI only — it never calls any API.
class GroupMembershipSheet extends StatefulWidget {
  final GroupSheetType type;
  final String userName;
  final String groupName;
  final String? groupImage;
  final int? memberCount;
  final bool locationShared;
  final VoidCallback? onPrimary;

  /// Shown for [GroupSheetType.created] so the owner can share it.
  final String? groupCode;

  const GroupMembershipSheet({
    super.key,
    required this.type,
    required this.userName,
    required this.groupName,
    this.groupImage,
    this.memberCount,
    this.locationShared = false,
    this.onPrimary,
    this.groupCode,
  });

  static const Color _purple = Color(0xFF704AFA);
  static const Color _green = Color(0xFF2F8A5B);
  static const Color _navy = Color(0xFF1A1446);
  static const Color _grey = Color(0xFF666666);

  static bool _isOpen = false;

  /// Shows the sheet. A second call while one is open is ignored, so a
  /// success callback that fires twice still shows only one sheet.
  static Future<void> show({
    required GroupSheetType type,
    required String userName,
    required String groupName,
    String? groupImage,
    int? memberCount,
    bool locationShared = false,
    VoidCallback? onPrimary,
    String? groupCode,
  }) async {
    if (_isOpen) return;
    _isOpen = true;
    try {
      await Get.bottomSheet(
        GroupMembershipSheet(
          type: type,
          userName: userName,
          groupName: groupName,
          groupImage: groupImage,
          memberCount: memberCount,
          locationShared: locationShared,
          onPrimary: onPrimary,
          groupCode: groupCode,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        barrierColor: const Color.fromRGBO(16, 16, 64, 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      );
    } finally {
      _isOpen = false;
    }
  }

  static String get _currentUserName {
    try {
      return Global.storageServices.get(PrefConst.userName)?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Read-only: the user's location-sharing setting (not per group).
  static bool get _isLocationShared {
    try {
      return Global.storageServices.getBoolSync(PrefConst.locationSharing) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Join success. The join API returns no group details, so this waits for
  /// the group list refresh the caller already started, then finds the group
  /// by its code. Falls back to the code as the name if it is not found.
  static Future<void> showJoinedForCode({
    required String groupCode,
    required GroupController groupController,
  }) async {
    await _waitForListRefresh(groupController);

    final code = groupCode.trim().toUpperCase();
    final GroupsResData? group = groupController.groupData.firstWhereOrNull(
      (g) => (g.groupCode ?? '').trim().toUpperCase() == code,
    );

    await show(
      type: GroupSheetType.joined,
      userName: _currentUserName,
      groupName: (group?.groupName?.trim().isNotEmpty ?? false)
          ? group!.groupName!.trim()
          : groupCode,
      groupImage: group?.groupProfile,
      memberCount: group?.memberCount,
      locationShared: _isLocationShared,
      onPrimary: () => _openGroupOrList(group, groupController),
    );
  }

  /// Create success. The create API returns no group details, so this waits
  /// for the list refresh the caller already started, then finds the newest
  /// group with this name that the user created.
  static Future<void> showCreatedFor({
    required String groupName,
    required GroupController groupController,
  }) async {
    await _waitForListRefresh(groupController);

    final name = groupName.trim().toLowerCase();
    GroupsResData? group;
    for (final g in groupController.groupData) {
      if (g.isCreator == true &&
          (g.groupName ?? '').trim().toLowerCase() == name &&
          (group == null || (g.id ?? 0) > (group.id ?? 0))) {
        group = g;
      }
    }

    await show(
      type: GroupSheetType.created,
      userName: _currentUserName,
      groupName: (group?.groupName?.trim().isNotEmpty ?? false)
          ? group!.groupName!.trim()
          : groupName.trim(),
      groupImage: group?.groupProfile,
      memberCount: group?.memberCount ?? 1,
      groupCode: group?.groupCode,
      locationShared: _isLocationShared,
      onPrimary: () => _openGroupOrList(group, groupController),
    );
  }

  static Future<void> _waitForListRefresh(GroupController controller) async {
    try {
      if (controller.groupDataLoading.value) {
        await controller.groupDataLoading.stream
            .firstWhere((loading) => !loading)
            .timeout(const Duration(seconds: 8));
      }
    } catch (_) {}
  }

  /// "Open Group": opens the group chat on top of the screen the user is on
  /// (Home, Walkie group select, ...), so Back returns there. Uses the exact
  /// route and arguments the All Group List uses when a group is tapped.
  /// Unknown or inactive group: opens the All Group List instead.
  static void _openGroupOrList(
      GroupsResData? group, GroupController groupController) {
    if (group == null || group.isActive != true) {
      if (Get.currentRoute != Routes.GroupsList) Get.toNamed(Routes.GroupsList);
      return;
    }
    final data = group;
    Get.toNamed(Routes.groupChatScreen, arguments: {
      "groupId": data.id.toString(),
      "groupName": data.groupName ?? "",
      "groupImage": data.groupProfile ?? "",
      "groupDesc": data.groupDesc ?? "",
      "groupCode": data.groupCode ?? "",
      "isCreator": data.isCreator?.toString() ?? "false",
      "isActive": data.isActive?.toString() ?? "false",
    })?.then((value) {
      if (value == true) {
        groupController.getGroupData();
      } else {
        // Same as the group list: name / image may have changed inside the group
        groupController.refreshGroupListSilently();
      }
    });
  }

  /// Leave success. [memberCount] is the count before leaving; the sheet
  /// shows the count without the user. [delay] lets a caller's navigation
  /// (e.g. Get.offAllNamed) finish first so it does not close the sheet.
  static Future<void> showLeft({
    required String groupName,
    String? groupImage,
    int? memberCount,
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    await show(
      type: GroupSheetType.left,
      userName: _currentUserName,
      groupName: groupName,
      groupImage: groupImage,
      memberCount: memberCount == null ? null : (memberCount - 1).clamp(0, 1 << 30),
      locationShared: _isLocationShared,
      // "Go to Groups": already on the All Group List -> just close;
      // anywhere else (Chat List, Home, Walkie) -> open it on top.
      onPrimary: () {
        if (Get.currentRoute != Routes.GroupsList) {
          Get.toNamed(Routes.GroupsList);
        }
      },
    );
  }

  /// GetX names `Get.to(() => ChatListScreen())` '/ChatListScreen';
  /// the Chat List has no named route.
  static const String chatListRoute = '/ChatListScreen';

  /// Same for `Get.to(() => const WalkieGroupSelectScreen())` (used after a
  /// walkie purchase when the named route is not used).
  static const String walkieSelectRoute = '/WalkieGroupSelectScreen';
  static bool _leaveNavRunning = false;

  /// Navigation after a successful leave / exit: back to where the user
  /// started. Walks down the stack and stops at the nearest Chat List, All
  /// Group List, Walkie group select or Home (else the first screen). Every
  /// screen above it (the group's chat, info, members, walkie screen,
  /// dialogs) is closed. Never opens a screen the user didn't come from.
  /// Runs once.
  static void navigateAfterLeave({required String groupId}) {
    if (_leaveNavRunning) return;
    _leaveNavRunning = true;
    Future.delayed(const Duration(seconds: 1), () => _leaveNavRunning = false);

    String? landedOn;
    Get.until((route) {
      final name = route.settings.name;
      if (name == chatListRoute ||
          name == Routes.GroupsList ||
          name == Routes.WalkieGroupSelect ||
          name == walkieSelectRoute ||
          name == Routes.Home_Screen) {
        landedOn = name;
        return true;
      }
      return route.isFirst;
    });

    if (landedOn == chatListRoute) {
      // A: came from chatting → stay on the Chat List and refresh it.
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().refreshChats();
      }
      return;
    }

    // B: All Group List / Walkie group select / Home: refresh the group list
    // they show (the left group disappears). No new screen is opened.
    if (Get.isRegistered<GroupController>()) {
      final gc = Get.find<GroupController>();
      gc.groupData.removeWhere((g) => g.id?.toString() == groupId);
      gc.getGroupData();
    }
  }

  @override
  State<GroupMembershipSheet> createState() => _GroupMembershipSheetState();
}

class _GroupMembershipSheetState extends State<GroupMembershipSheet>
    with TickerProviderStateMixin {
  late final AnimationController _popController;
  late final AnimationController _pulseController;
  late final Animation<double> _popScale;

  bool get _joined => widget.type == GroupSheetType.joined;
  bool get _created => widget.type == GroupSheetType.created;
  bool get _left => widget.type == GroupSheetType.left;
  Color get _accent =>
      _left ? GroupMembershipSheet._purple : GroupMembershipSheet._green;

  String? get _code {
    final c = widget.groupCode?.trim() ?? '';
    return (c.isEmpty || c == 'null') ? null : c;
  }

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_popController);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _popController.forward().whenComplete(() {
      if (mounted) _pulseController.repeat();
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  void _onPrimary() {
    final action = widget.onPrimary;
    Navigator.of(context).pop();
    if (action != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => action());
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2EA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildIcon(),
              const SizedBox(height: 20),
              Text(
                _created
                    ? appL10n.group_sheetCreatedTitle
                    : (_joined
                        ? appL10n.group_sheetJoinedTitle
                        : appL10n.group_sheetLeftTitle),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: GroupMembershipSheet._navy,
                ),
              ),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 20),
              _buildGroupCard(),
              const SizedBox(height: 16),
              ..._buildInfoRows(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GroupMembershipSheet._purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _left ? appL10n.group_goToGroups : appL10n.group_openGroup,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _close,
                  child: Text(
                    appL10n.common_done,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GroupMembershipSheet._purple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final t = _pulseController.value;
              return Container(
                width: 84 + 36 * t,
                height: 84 + 36 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withValues(alpha: 0.18 * (1 - t)),
                ),
              );
            },
          ),
          ScaleTransition(
            scale: _popScale,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
              child: Icon(
                _created
                    ? Icons.group_add_rounded
                    : (_joined ? Icons.check_rounded : Icons.logout_rounded),
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    const base = TextStyle(
      fontSize: 14,
      color: GroupMembershipSheet._grey,
      height: 1.4,
    );
    const bold = TextStyle(
      fontWeight: FontWeight.w700,
      color: GroupMembershipSheet._navy,
    );
    final name = widget.userName.trim();
    final l10n = appL10n;
    final List<InlineSpan> spans;
    if (_created) {
      spans = name.isEmpty
          ? [TextSpan(text: l10n.group_sheetCreatedSubtitle)]
          : _boldNameSpans(
              l10n.group_sheetCreatedSubtitleNamed(name), name, bold);
    } else if (_joined) {
      spans = name.isEmpty
          ? [TextSpan(text: l10n.group_sheetJoinedSubtitle)]
          : _boldNameSpans(
              l10n.group_sheetJoinedSubtitleNamed(name), name, bold);
    } else {
      spans = name.isEmpty
          ? [TextSpan(text: l10n.group_sheetLeftSubtitle)]
          : _boldNameSpans(l10n.group_sheetLeftSubtitleNamed(name), name, bold);
    }
    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: TextAlign.center,
    );
  }

  /// Splits [text] around [name] so the name stays bold in any language.
  List<InlineSpan> _boldNameSpans(String text, String name, TextStyle bold) {
    final i = text.indexOf(name);
    if (i < 0) return [TextSpan(text: text)];
    return [
      if (i > 0) TextSpan(text: text.substring(0, i)),
      TextSpan(text: name, style: bold),
      if (i + name.length < text.length)
        TextSpan(text: text.substring(i + name.length)),
    ];
  }

  Widget _buildGroupCard() {
    final count = widget.memberCount;
    final when = _created
        ? appL10n.group_createdJustNow
        : (_joined ? appL10n.group_joinedJustNow : appL10n.group_leftJustNow);
    final meta = count == null
        ? when
        : appL10n.group_membersMeta(count, when);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        border: Border.all(color: const Color(0xFFECECF2)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GroupMembershipSheet._navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GroupMembershipSheet._grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GroupMembershipSheet._purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _initials(widget.groupName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = _imageUrl(widget.groupImage);
    if (url == null) return initials;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => initials,
      ),
    );
  }

  List<Widget> _buildInfoRows() {
    final code = _code;
    final rows = <MapEntry<IconData, String>>[
      if (_created) ...[
        MapEntry(
          Icons.vpn_key_outlined,
          code != null
              ? appL10n.group_codeShareInfo(code)
              : appL10n.group_shareCodeInfo,
        ),
        MapEntry(Icons.admin_panel_settings_outlined,
            appL10n.group_youAreAdmin),
      ] else if (_joined)
        MapEntry(Icons.chat_bubble_outline_rounded,
            appL10n.group_chatWithMembers)
      else
        MapEntry(Icons.notifications_off_outlined,
            appL10n.group_noNewMessages),
      if (widget.locationShared)
        MapEntry(
          _left ? Icons.location_off_outlined : Icons.location_on_outlined,
          _left
              ? appL10n.group_locationNoLongerShared
              : appL10n.group_locationShared,
        ),
    ];
    return [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEDFD),
                  shape: BoxShape.circle,
                ),
                child: Icon(r.key, size: 14, color: GroupMembershipSheet._purple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.value,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A4A)),
                ),
              ),
              if (_created && code != null && r.key == Icons.vpn_key_outlined)
                IconButton(
                  tooltip: appL10n.group_copyCode,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded,
                      size: 18, color: GroupMembershipSheet._purple),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Get.rawSnackbar(
                      message: appL10n.group_codeCopied,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
            ],
          ),
        ),
    ];
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "G";
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static String? _imageUrl(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty || v == 'null') return null;
    return v.startsWith('http') ? v : ConstRes.aImageBaseUrl + v;
  }
}
