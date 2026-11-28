import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/attendance_controller.dart';
import '../models/attendance_poll_model.dart';
import '../views/view_attendance_sheet.dart';
import '../views/attendance_camera_screen.dart';

class AttendanceChatCard extends StatefulWidget {
  final int pollId;

  /// Poll summary embedded in the chat message (may be stale or missing);
  /// the live copy comes from [AttendanceController].
  final AttendancePoll? initialPoll;

  /// Group admin flag; reactive because group members load asynchronously.
  final RxBool? isAdmin;

  /// Group members, used for the "X Members" count.
  final RxList<dynamic>? groupMembers;
  final String senderName;
  final String groupName;
  final String? messageTime;

  /// Called after the admin deletes the poll, so the chat can update the
  /// message even if the socket event is not echoed back.
  final void Function(int pollId)? onDeleted;

  const AttendanceChatCard({
    super.key,
    required this.pollId,
    this.initialPoll,
    this.isAdmin,
    this.groupMembers,
    this.senderName = "",
    this.groupName = "",
    this.messageTime,
    this.onDeleted,
  });

  @override
  State<AttendanceChatCard> createState() => _AttendanceChatCardState();
}

class _AttendanceChatCardState extends State<AttendanceChatCard> {
  static const _accent = Color(0xFF5A3EFE);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _error = Color(0xFFEF4444);

  final AttendanceController _controller = AttendanceController.instance;

  String? _selectedOptionId;
  File? _attendancePhoto;
  bool _isSubmitting = false;
  bool _isChangingVote = false;

  String? _statusError;
  String? _photoError;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller.watch(widget.pollId);
    _load();
  }

  @override
  void dispose() {
    _controller.unwatch(widget.pollId);
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    if (_loadFailed) setState(() => _loadFailed = false);
    await _controller.ensureLoaded(widget.pollId, force: force);
    if (mounted &&
        _controller.polls[widget.pollId] == null &&
        widget.initialPoll == null) {
      setState(() => _loadFailed = true);
    }
  }

  String get _timeLabel {
    final parsed = DateTime.tryParse(widget.messageTime ?? "")?.toLocal();
    return parsed != null ? DateFormat("hh:mm a").format(parsed) : "";
  }

  /// userId → profile image, from the group's member list (fallback for
  /// voter rows that come without a picture).
  Map<String, String> _memberImages() {
    final map = <String, String>{};
    for (final m in widget.groupMembers ?? const []) {
      try {
        final id = (m as dynamic).userId?.toString();
        final image = (m as dynamic).profileImage?.toString();
        if (id != null && image != null && image.isNotEmpty && image != "null") {
          map[id] = image;
        }
      } catch (_) {}
    }
    return map;
  }

  Future<void> _openCamera(AttendancePoll poll) async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceCameraScreen(
          groupName: widget.groupName,
          memberCount: widget.groupMembers?.length ?? 0,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _attendancePhoto = File(result);
        _photoError = null;
      });
      // The camera screen's "Submit" confirms the photo, so submit right away.
      _submitVote(poll);
    }
  }

  Future<void> _submitVote(AttendancePoll poll) async {
    if (_isSubmitting) return;
    setState(() {
      _statusError = null;
      _photoError = null;
    });

    final option = poll.optionById(_selectedOptionId);
    if (option == null) {
      setState(() => _statusError = "Please select your status");
    } else if (poll.requiresPhoto(option.id) && _attendancePhoto == null) {
      // Go straight to the camera; it submits after the photo is confirmed.
      _openCamera(poll);
      return;
    }
    if (_statusError != null || _photoError != null) {
      _showSnack("Validation Error", _photoError ?? _statusError!,
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _controller.vote(
        pollId: poll.id,
        optionId: option!.id,
        photoPath:
            poll.requiresPhoto(option.id) ? _attendancePhoto?.path : null,
      );
      if (!mounted) return;
      setState(() {
        _isChangingVote = false;
        _selectedOptionId = null;
        _attendancePhoto = null;
      });
      _showSnack("Attendance Submitted", "Marked as ${option.label}");
    } catch (e) {
      _showSnack("Attendance Failed", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _removeVote(AttendancePoll poll) async {
    final ok = await _confirm(
      "Remove your response?",
      "Your attendance for this poll will be cleared.",
      "Remove",
    );
    if (!ok) return;
    setState(() => _isSubmitting = true);
    try {
      await _controller.removeVote(poll.id);
    } catch (e) {
      _showSnack("Unable to remove", e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _closePoll(AttendancePoll poll) async {
    final ok = await _confirm(
      "Close attendance?",
      "Members won't be able to respond after it is closed.",
      "Close",
    );
    if (!ok) return;
    try {
      await _controller.closePoll(poll.id);
    } catch (e) {
      _showSnack("Unable to close", e.toString(), isError: true);
    }
  }

  // Attendance can't be deleted from the chat (product rule): the card only
  // offers "Close attendance". A poll deleted elsewhere still shows the
  // deleted state through AttendanceController.deletedPolls.

  Widget _buildDeletedCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, size: 16.sp, color: _textMuted),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              "This attendance was deleted",
              style: TextStyle(
                fontSize: 12.5.sp,
                fontStyle: FontStyle.italic,
                color: _textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: const TextStyle(color: _error)),
          ),
        ],
      ),
    );
    return result == true;
  }

  void _showSnack(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? _error : _accent,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Deleted (here or on another device): never fall back to the copy
      // the card was built with.
      if (_controller.deletedPolls.contains(widget.pollId)) {
        return _buildDeletedCard();
      }
      final poll = _controller.polls[widget.pollId] ?? widget.initialPoll;
      final isAdmin = widget.isAdmin?.value == true;
      final memberCount = widget.groupMembers?.length ?? 0;

      final Widget body;
      if (poll == null) {
        body = _loadFailed ? _buildLoadErrorCard() : _buildLoadingCard();
      } else if (isAdmin || poll.isClosed) {
        body = _buildSummaryCard(poll, memberCount, isAdmin: isAdmin);
      } else if (poll.myVote != null && !_isChangingVote && !_isSubmitting) {
        // Shown only once the server confirms; while submitting the form
        // stays visible with its spinner.
        body = _buildVotedCard(poll, memberCount);
      } else {
        body = _buildVoteForm(poll, memberCount);
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.senderName.isNotEmpty) _buildSenderHeader(),
            body,
          ],
        ),
      );
    });
  }

  Widget _buildSenderHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(
              widget.senderName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              widget.senderName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "Admin",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6D28D9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22.r),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildLoadErrorCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: _error, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "Couldn't load attendance",
              style: TextStyle(fontSize: 13.sp, color: _textDark),
            ),
          ),
          TextButton(
            onPressed: () => _load(force: true),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: _cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
      ),
    );
  }

  Widget _buildTitleRow(AttendancePoll poll, {Widget? trailing}) {
    final subtitle = [
      if (poll.longDate.isNotEmpty) poll.longDate,
      if (poll.eventTime != null) poll.eventTime!,
    ].join(" • ");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: _accent,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll.title.isNotEmpty ? poll.title : "Attendance",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color fg, Color bg, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.sp, color: fg),
            SizedBox(width: 3.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge() => _buildStatusBadge(
        "Completed",
        const Color(0xFF16A34A),
        const Color(0xFFE8F9EF),
      );

  Widget _buildMyVoteBadge(AttendancePoll poll) {
    final option = poll.optionById(poll.myVote?.optionId);
    if (option == null) return const SizedBox.shrink();
    final color = option.displayColor;
    return _buildStatusBadge(
      option.label,
      color,
      color.withValues(alpha: 0.12),
      icon: Icons.check_rounded,
    );
  }

  Widget _buildCountRows(AttendancePoll poll, int memberCount) {
    final denominator = memberCount > 0 ? memberCount : poll.totalVotes;
    return Column(
      children: [
        for (final option in poll.options) ...[
          _buildCountRow(
            option,
            poll.countFor(option.id),
            denominator,
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _buildCountRow(AttendanceOption option, int count, int denominator) {
    final ratio = denominator > 0 ? (count / denominator).clamp(0.0, 1.0) : 0.0;
    final color = option.displayColor;
    final label = option.label.toLowerCase();
    final icon = label == "absent"
        ? Icons.close_rounded
        : (label == "present" ? Icons.check_rounded : Icons.circle);

    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon,
              color: Colors.white, size: icon == Icons.circle ? 8.sp : 15.sp),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 64.w,
          child: Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8.h,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          "$count",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AttendancePoll poll, int memberCount) {
    final members = memberCount > 0 ? "$memberCount Members • " : "";
    return Row(
      children: [
        Icon(Icons.groups_rounded, color: _textMuted, size: 16.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            "$members${poll.totalVotes} responded",
            style: TextStyle(fontSize: 11.5.sp, color: _textMuted),
          ),
        ),
        if (_timeLabel.isNotEmpty)
          Text(
            _timeLabel,
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
          ),
      ],
    );
  }

  Widget _buildViewButton(AttendancePoll poll) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton(
        onPressed: () => ViewAttendanceSheet.show(
          context,
          poll.id,
          groupName: widget.groupName,
          memberCount: widget.groupMembers?.length ?? 0,
          isAdmin: widget.isAdmin?.value == true,
          memberImages: _memberImages(),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: _accent, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          "View Attendance",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _accent,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminMenu(AttendancePoll poll) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: _textMuted, size: 20.sp),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == "close") _closePoll(poll);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: "close", child: Text("Close attendance")),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // ── SUMMARY CARD (admin, or any user once closed) ──
  // ════════════════════════════════════════════════════════
  Widget _buildSummaryCard(
    AttendancePoll poll,
    int memberCount, {
    required bool isAdmin,
  }) {
    final canViewVoters = isAdmin || poll.voterVisibility == "all";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(color: const Color(0xFFF7F8FE)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(
            poll,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (poll.isClosed) _buildCompletedBadge(),
                if (!isAdmin && poll.myVote != null) ...[
                  SizedBox(width: 4.w),
                  _buildMyVoteBadge(poll),
                ],
                // The menu's only action is "Close", so it exists only while
                // the poll is open.
                if (isAdmin && poll.isOpen) _buildAdminMenu(poll),
              ],
            ),
          ),
          if (poll.description != null) ...[
            SizedBox(height: 10.h),
            Text(
              poll.description!,
              style: TextStyle(fontSize: 12.5.sp, color: _textMuted),
            ),
          ],
          SizedBox(height: 14.h),
          _buildCountRows(poll, memberCount),
          SizedBox(height: 4.h),
          _buildFooter(poll, memberCount),
          if (canViewVoters) ...[
            SizedBox(height: 14.h),
            _buildViewButton(poll),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── MEMBER: ALREADY VOTED ──
  // ════════════════════════════════════════════════════════
  Widget _buildVotedCard(AttendancePoll poll, int memberCount) {
    final photo = poll.myVote?.photoFullUrl;
    final canChange = poll.isOpen && poll.allowVoteChange;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(poll, trailing: _buildMyVoteBadge(poll)),
          if (photo != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: photo.startsWith("http")
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Image.file(
                      File(photo),
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 16.sp, color: const Color(0xFF16A34A)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "Attendance marked successfully",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
              if (photo != null)
                Text(
                  "Photo verified",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildCountRows(poll, memberCount),
          SizedBox(height: 4.h),
          _buildFooter(poll, memberCount),
          if (canChange) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() {
                            _isChangingVote = true;
                            _selectedOptionId = poll.myVote?.optionId;
                          }),
                  child: const Text("Change response"),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isSubmitting ? null : () => _removeVote(poll),
                  child: const Text(
                    "Remove",
                    style: TextStyle(color: _error),
                  ),
                ),
              ],
            ),
          ],
          if (poll.voterVisibility == "all") ...[
            SizedBox(height: 8.h),
            _buildViewButton(poll),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── MEMBER: MARK ATTENDANCE FORM ──
  // ════════════════════════════════════════════════════════
  Widget _buildVoteForm(AttendancePoll poll, int memberCount) {
    final selected = poll.optionById(_selectedOptionId);
    final needsPhoto = poll.requiresPhoto(_selectedOptionId);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(poll),
          SizedBox(height: 16.h),
          Text(
            "Mark your attendance",
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            poll.description ?? "Please select your status",
            style: TextStyle(fontSize: 12.sp, color: _textMuted),
          ),
          if (poll.deadlineAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              "Closes ${DateFormat("dd MMM, hh:mm a").format(poll.deadlineAt!)}",
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_statusError != null) ...[
            SizedBox(height: 6.h),
            Text(
              _statusError!,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: _error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          for (int i = 0; i < poll.options.length; i++) ...[
            _buildOptionTile(i + 1, poll.options[i], poll),
            SizedBox(height: 10.h),
          ],
          if (needsPhoto) ...[
            _buildPhotoTile(poll, selected!),
            if (_photoError != null) ...[
              SizedBox(height: 4.h),
              Text(
                _photoError!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: _error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: 10.h),
          ],
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitVote(poll),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                disabledBackgroundColor: _accent.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isChangingVote ? "Update Attendance" : "Submit Attendance",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (_isChangingVote)
            Center(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                          _isChangingVote = false;
                          _attendancePhoto = null;
                          _statusError = null;
                          _photoError = null;
                        }),
                child: const Text("Cancel"),
              ),
            ),
          SizedBox(height: 6.h),
          _buildFooter(poll, memberCount),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(AttendancePoll poll, AttendanceOption option) {
    return GestureDetector(
      onTap: () => _openCamera(poll),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _photoError != null ? _error : _border,
            width: _photoError != null ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.camera_alt_rounded, color: _accent, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Photo",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _attendancePhoto != null
                        ? "Photo captured ✓ (Tap to retake)"
                        : "⚠ Photo required for ${option.label}",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: _attendancePhoto != null
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_attendancePhoto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  _attendancePhoto!,
                  width: 36.w,
                  height: 36.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Icon(Icons.chevron_right_rounded, color: _textMuted, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int number, AttendanceOption option, AttendancePoll poll) {
    final isSelected = _selectedOptionId == option.id;

    return GestureDetector(
      onTap: _isSubmitting
          ? null
          : () {
              setState(() {
                _selectedOptionId = option.id;
                _statusError = null;
                if (!poll.requiresPhoto(option.id)) _photoError = null;
              });
              // Warm up GPS so submitting doesn't wait on it.
              _controller.prefetchLocation();
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF6F8FE) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? _accent : _border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: isSelected ? _accent : const Color(0xFF818CF8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "$number",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ),
            if (poll.requiresPhoto(option.id)) ...[
              Icon(Icons.camera_alt_outlined, size: 16.sp, color: _textMuted),
              SizedBox(width: 8.w),
            ],
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _accent : const Color(0xFF94A3B8),
                  width: isSelected ? 2.0 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accent,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
