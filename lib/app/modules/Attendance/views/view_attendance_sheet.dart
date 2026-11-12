import 'dart:async';
import 'package:fgtracker/l10n/l10n.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import '../controller/attendance_controller.dart';
import '../models/attendance_poll_model.dart';

/// Voter filter: all responded, one option, or members who haven't voted.
class _VoterFilter {
  final String? optionId;
  final bool notVoted;
  const _VoterFilter({this.optionId, this.notVoted = false});

  @override
  bool operator ==(Object other) =>
      other is _VoterFilter &&
      other.optionId == optionId &&
      other.notVoted == notVoted;

  @override
  int get hashCode => Object.hash(optionId, notVoted);
}

class ViewAttendanceSheet extends StatefulWidget {
  final int pollId;
  final String groupName;
  final int memberCount;
  final bool isAdmin;

  /// userId → profile image path from the group's member list.
  final Map<String, String> memberImages;

  const ViewAttendanceSheet({
    super.key,
    required this.pollId,
    this.groupName = "",
    this.memberCount = 0,
    this.isAdmin = true,
    this.memberImages = const {},
  });

  static Future<void> show(
    BuildContext context,
    int pollId, {
    String groupName = "",
    int memberCount = 0,
    bool isAdmin = true,
    Map<String, String> memberImages = const {},
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewAttendanceSheet(
          pollId: pollId,
          groupName: groupName,
          memberCount: memberCount,
          isAdmin: isAdmin,
          memberImages: memberImages,
        ),
      ),
    );
  }

  @override
  State<ViewAttendanceSheet> createState() => _ViewAttendanceSheetState();
}

class _ViewAttendanceSheetState extends State<ViewAttendanceSheet> {
  static const _accent = Color(0xFF5A3EFE);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _pageSize = 50;

  final AttendanceController _controller = AttendanceController.instance;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _liveDebounce;

  _VoterFilter _filter = const _VoterFilter();
  final List<AttendanceVoter> _voters = [];
  int _page = 1;
  bool _hasNext = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _notVotedCount = 0;
  bool _isExporting = false;

  Worker? _pollWorker;
  String? _countsSignature;

  @override
  void initState() {
    super.initState();
    _controller.watch(widget.pollId);
    _controller.ensureLoaded(widget.pollId, force: true);
    _loadVoters();
    SocketMessageService.instance.subscribeAttendance(
      widget.pollId,
      _onVoteChanged,
    );
    // Also follow the shared poll store: group-room `attendance:updated`
    // events change the counts there even if `attendance:vote_changed`
    // (admin detail room) doesn't arrive, and the list must follow.
    _countsSignature = _signatureOf(_controller.polls[widget.pollId]);
    _pollWorker = ever<Map<int, AttendancePoll>>(_controller.polls, (map) {
      final signature = _signatureOf(map[widget.pollId]);
      if (signature == _countsSignature) return;
      _countsSignature = signature;
      _scheduleLiveRefresh();
    });
  }

  @override
  void dispose() {
    _pollWorker?.dispose();
    _controller.unwatch(widget.pollId);
    SocketMessageService.instance.unsubscribeAttendance(widget.pollId);
    _searchDebounce?.cancel();
    _liveDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String? _signatureOf(AttendancePoll? poll) => poll == null
      ? null
      : "${poll.totalVotes}|${poll.countsByOption}|${poll.status}";

  void _onVoteChanged(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    // Accept {poll, version} or a flat payload carrying pollId/counts.
    _controller.handleSocketEvent(
      "attendance:updated",
      map["poll"] is Map
          ? {"poll": map["poll"], "version": map["version"]}
          // A flat vote event's own `id` may be the vote's, not the poll's.
          : {...map, "id": map["pollId"] ?? widget.pollId},
    );
    _scheduleLiveRefresh();
  }

  /// Coalesces bursts of votes into one silent list refresh.
  void _scheduleLiveRefresh() {
    _liveDebounce?.cancel();
    _liveDebounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _loadVoters(silent: true);
    });
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadVoters);
  }

  Future<void> _loadVoters({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      var page = await _controller.fetchVoters(
        pollId: widget.pollId,
        optionId: _filter.optionId,
        notVoted: _filter.notVoted,
        page: 1,
        limit: _pageSize,
        search: _searchController.text,
      );

      // If the unfiltered "Responded" list is empty while the poll has votes,
      // load each option's list and merge them.
      final poll = _controller.polls[widget.pollId];
      if (_filter == const _VoterFilter() &&
          page.voters.isEmpty &&
          (poll?.totalVotes ?? 0) > 0) {
        final perOption = await Future.wait([
          for (final o in poll!.options)
            _controller.fetchVoters(
              pollId: widget.pollId,
              optionId: o.id,
              limit: _pageSize,
              search: _searchController.text,
            ),
        ]);
        final merged = perOption.expand((p) => p.voters).toList()
          ..sort((a, b) => (b.votedAt ?? DateTime(0))
              .compareTo(a.votedAt ?? DateTime(0)));
        page = AttendanceVotersPage(
          voters: merged,
          total: merged.length,
          countsByOption: page.countsByOption,
          notVoted: page.notVoted,
          hasNext: perOption.any((p) => p.hasNext),
        );
      }

      if (!mounted) return;
      setState(() {
        _voters
          ..clear()
          ..addAll(page.voters);
        _page = 1;
        _hasNext = page.hasNext;
        _notVotedCount = page.notVoted;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNext) return;
    setState(() => _isLoadingMore = true);
    try {
      final page = await _controller.fetchVoters(
        pollId: widget.pollId,
        optionId: _filter.optionId,
        notVoted: _filter.notVoted,
        page: _page + 1,
        limit: _pageSize,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _voters.addAll(page.voters);
        _page += 1;
        _hasNext = page.hasNext;
      });
    } catch (e) {
      _showError(appL10n.attendance_loadMoreFailed, e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _controller.ensureLoaded(widget.pollId, force: true),
      _loadVoters(silent: true),
    ]);
  }

  void _setFilter(_VoterFilter filter) {
    if (filter == _filter) return;
    setState(() => _filter = filter);
    _loadVoters();
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  Future<void> _closePoll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.attendance_closeConfirmTitle),
        content: Text(
            appL10n.attendance_closeConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appL10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appL10n.common_close),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _controller.closePoll(widget.pollId);
    } catch (e) {
      _showError(appL10n.attendance_closeFailedShort, e.toString());
    }
  }

  Widget _buildDeletedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text(appL10n.attendance_viewTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block_rounded, size: 40.sp, color: _textMuted),
              SizedBox(height: 12.h),
              Text(
                appL10n.attendance_deletedText,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 16.h),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(appL10n.common_back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Downloads the CSV, then lets the admin save it to the device, open it,
  /// or share it. Saving uses the system "Save as" screen (Android Storage
  /// Access Framework / iOS Files), which needs no storage permission on any
  /// Android version.
  Future<void> _exportReport(AttendancePoll? poll) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    File? file;
    String fileName = "";
    try {
      final csv = (await _controller.exportCsv(widget.pollId)).trim();
      if (csv.isEmpty) throw appL10n.attendance_reportEmpty;
      // An error page/JSON instead of CSV means the server failed.
      if (csv.startsWith("{") || csv.startsWith("<")) {
        throw appL10n.attendance_reportInvalid;
      }

      final date = poll?.eventDate ?? DateFormat("yyyy-MM-dd").format(DateTime.now());
      final group = widget.groupName
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), "_")
          .replaceAll(RegExp(r'^_+|_+$'), "");
      fileName =
          "Attendance_${group.isNotEmpty ? "${group}_" : ""}${date}_${widget.pollId}.csv";

      final dir = await getTemporaryDirectory();
      file = File("${dir.path}/$fileName");
      // UTF-8 BOM so Excel shows names and symbols (•, ₹, Hindi) correctly.
      await file.writeAsBytes(
        [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)],
        flush: true,
      );
    } catch (e) {
      _showError(appL10n.attendance_reportFailed, e.toString());
      return;
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }

    if (!mounted) return;
    await _showReportActions(file, fileName, poll);
  }

  Future<void> _showReportActions(
    File file,
    String fileName,
    AttendancePoll? poll,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
                child: Text(
                  appL10n.attendance_reportReady(fileName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded, color: _accent),
                title: Text(appL10n.attendance_saveToDevice),
                subtitle: Text(Platform.isIOS
                    ? appL10n.attendance_saveInFiles
                    : appL10n.attendance_chooseFolder),
                onTap: () => Navigator.pop(ctx, "save"),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: _accent),
                title: Text(appL10n.common_open),
                subtitle: Text(appL10n.attendance_openSubtitle),
                onTap: () => Navigator.pop(ctx, "open"),
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: _accent),
                title: Text(appL10n.common_share),
                subtitle: Text(appL10n.attendance_shareSubtitle),
                onTap: () => Navigator.pop(ctx, "share"),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;

    try {
      switch (action) {
        case "save":
          final savedPath = await FilePicker.saveFile(
            dialogTitle: appL10n.attendance_saveReportDialog,
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: const ["csv"],
            bytes: await file.readAsBytes(),
          );
          if (savedPath != null && mounted) {
            Get.snackbar(
              appL10n.attendance_reportSaved,
              fileName,
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF16A34A),
              colorText: Colors.white,
              margin: EdgeInsets.all(16.w),
            );
          }
          break;
        case "open":
          final result = await OpenFile.open(file.path, type: "text/csv");
          if (result.type != ResultType.done) {
            throw result.type == ResultType.noAppToOpen
                ? appL10n.attendance_noCsvApp
                : result.message;
          }
          break;
        case "share":
          final size = MediaQuery.of(context).size;
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path, mimeType: "text/csv", name: fileName)],
              subject:
                  poll != null
                  ? appL10n.attendance_reportSubjectWithTitle(poll.title)
                  : appL10n.attendance_reportSubject,
              // Required on iPad, where the share sheet is a popover.
              sharePositionOrigin:
                  Rect.fromLTWH(0, size.height / 2, size.width, 1),
            ),
          );
          break;
      }
    } catch (e) {
      _showError(appL10n.attendance_reportFailed, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.deletedPolls.contains(widget.pollId)) {
        return _buildDeletedScreen();
      }
      final poll = _controller.polls[widget.pollId];

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(poll),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    children: [
                      if (poll != null) _buildSummaryCard(poll),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          Expanded(
                            child: AutoFitText(
                              widget.memberCount > 0
                                  ? appL10n.attendance_membersWithCount(widget.memberCount)
                                  : appL10n.attendance_members,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                          ),
                          _buildSearchBar(),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (poll != null) _buildFilterChips(poll),
                      SizedBox(height: 12.h),
                      ..._buildVoterList(poll),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              if (widget.isAdmin) _buildDownloadButton(poll),
            ],
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(AttendancePoll? poll) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: _accent, size: 22.sp),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _accent,
            ),
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName.isNotEmpty ? widget.groupName : appL10n.attendance_title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  [
                    if (widget.memberCount > 0) appL10n.common_membersCount(widget.memberCount),
                    appL10n.attendance_respondedCount(poll?.totalVotes ?? 0),
                  ].join(" • "),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.isAdmin && poll != null && poll.isOpen)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: _accent, size: 20.sp),
            onSelected: (value) {
              if (value == "close") _closePoll();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: "close", child: Text(appL10n.attendance_closeAction)),
            ],
          ),
      ],
    );
  }

  Widget _buildSummaryCard(AttendancePoll poll) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.calendar_month_rounded,
                    color: _accent, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poll.title.isNotEmpty ? poll.title : appL10n.attendance_title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    if (poll.description != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        poll.description!,
                        style: TextStyle(fontSize: 12.sp, color: _textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: poll.isOpen
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFE8F9EF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  poll.isOpen ? appL10n.attendance_statusOpen : appL10n.attendance_statusCompleted,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: poll.isOpen ? _accent : const Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              for (int i = 0; i < poll.options.length; i++) ...[
                if (i > 0) SizedBox(width: 10.w),
                Expanded(child: _buildCountTile(poll, poll.options[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountTile(AttendancePoll poll, AttendanceOption option) {
    final color = option.displayColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "${poll.countFor(option.id)}",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AttendancePoll poll) {
    Widget chip(String label, _VoterFilter filter) {
      final selected = _filter == filter;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => _setFilter(filter),
          selectedColor: _accent,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textDark,
          ),
          side: BorderSide(
            color: selected ? _accent : const Color(0xFFE2E8F0),
          ),
          showCheckmark: false,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(appL10n.attendance_filterResponded(poll.totalVotes), const _VoterFilter()),
          for (final o in poll.options)
            chip("${o.label} (${poll.countFor(o.id)})",
                _VoterFilter(optionId: o.id)),
          chip(
            _notVotedCount > 0
                ? appL10n.attendance_filterNotRespondedCount(_notVotedCount)
                : appL10n.attendance_notResponded,
            const _VoterFilter(notVoted: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 160.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              size: 16.sp, color: const Color(0xFF94A3B8)),
          SizedBox(width: 6.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 11.5.sp, color: _textDark),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: appL10n.attendance_searchMember,
                hintStyle: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVoterList(AttendancePoll? poll) {
    if (_isLoading && _voters.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 36.h),
          child: const Center(
            child: CircularProgressIndicator(color: _accent),
          ),
        ),
      ];
    }
    if (_voters.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 36.h),
          child: Text(
            _error ??
                (_searchController.text.isNotEmpty
                    ? appL10n.attendance_noMembersMatch
                    : (_filter.notVoted
                        ? appL10n.attendance_everyoneResponded
                        : appL10n.attendance_noResponses)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    }
    return [
      for (final voter in _voters) ...[
        _buildVoterCard(voter, poll),
        SizedBox(height: 12.h),
      ],
      if (_hasNext)
        Center(
          child: _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(color: _accent),
                )
              : TextButton(
                  onPressed: _loadMore,
                  child: Text(appL10n.attendance_loadMore),
                ),
        ),
    ];
  }

  String _locationSubtitle(AttendanceVoter voter) {
    final parts = <String>[];
    if (voter.votedAt != null) {
      final diff = DateTime.now().difference(voter.votedAt!);
      if (diff.inMinutes < 1) {
        parts.add(appL10n.common_justNow);
      } else if (diff.inMinutes < 60) {
        parts.add(appL10n.common_minutesAgo(diff.inMinutes));
      } else if (diff.inHours < 24) {
        parts.add(appL10n.common_hoursAgo(diff.inHours));
      }
    }
    final accuracy = voter.location?.accuracy;
    if (accuracy != null) {
      parts.add(accuracy < 1000
          ? appL10n.attendance_withinMeters(accuracy.round())
          : appL10n.attendance_withinKm((accuracy / 1000).toStringAsFixed(1)));
    }
    return parts.join(" • ");
  }

  Widget _buildVoterCard(AttendanceVoter voter, AttendancePoll? poll) {
    final option = poll?.optionById(voter.optionId);
    final color = option?.displayColor ?? const Color(0xFF94A3B8);
    final label = voter.optionLabel ?? option?.label ?? appL10n.attendance_notResponded;
    final location = voter.location;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(voter),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voter.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (voter.time.isNotEmpty)
                Text(
                  voter.time,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
            ],
          ),
          if (voter.hasVoted) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              title: location == null
                  ? appL10n.attendance_noLocation
                  : (location.name ??
                      "${location.lat?.toStringAsFixed(5)}, ${location.lng?.toStringAsFixed(5)}"),
              subtitle: location != null ? _locationSubtitle(voter) : null,
              onView: location?.hasCoordinates == true
                  ? () => _openMap(location!)
                  : null,
            ),
            if (voter.photoFullUrl != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow(
                icon: Icons.camera_alt_rounded,
                title: appL10n.attendance_photoProof,
                onView: () => _previewPhoto(voter),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onView,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: _textMuted, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: onView != null
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5.sp, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (onView != null)
            GestureDetector(
              onTap: onView,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEFE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  appL10n.attendance_view,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openMap(AttendanceLocation location) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}",
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showError(appL10n.attendance_openMapFailed, e.toString());
    }
  }

  Widget _buildAvatar(AttendanceVoter voter) {
    // Voter rows without a picture fall back to the group member list.
    final avatar = voter.profileImageUrl ??
        attendanceMediaUrl(widget.memberImages[voter.userId]);
    final hasNetworkAvatar = avatar != null && avatar.startsWith("http");

    return CircleAvatar(
      radius: 22.r,
      backgroundColor: const Color(0xFFEEF2FF),
      backgroundImage:
          hasNetworkAvatar ? CachedNetworkImageProvider(avatar) : null,
      onBackgroundImageError: hasNetworkAvatar ? (_, __) {} : null,
      child: hasNetworkAvatar
          ? null
          : Text(
              voter.name.isNotEmpty ? voter.name[0].toUpperCase() : "M",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
    );
  }

  void _previewPhoto(AttendanceVoter voter) {
    final photo = voter.photoFullUrl;
    if (photo == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.camera_alt_rounded, color: _accent, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      appL10n.attendance_photoProofOf(voter.name),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: const Icon(Icons.close_rounded, color: _textMuted),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: CachedNetworkImage(
                  imageUrl: photo,
                  fit: BoxFit.cover,
                  height: 320.h,
                  width: double.infinity,
                  placeholder: (_, __) => SizedBox(
                    height: 320.h,
                    child: const Center(
                      child: CircularProgressIndicator(color: _accent),
                    ),
                  ),
                  errorWidget: (_, __, ___) => SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              if (voter.time.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  appL10n.attendance_capturedAtVerified(voter.time),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(AttendancePoll? poll) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: _isExporting ? null : () => _exportReport(poll),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: _accent, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: _isExporting
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_download_outlined,
                        color: _accent, size: 20.sp),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: AutoFitText(
                        appL10n.attendance_downloadReport,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
