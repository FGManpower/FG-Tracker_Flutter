import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/attendance_controller.dart';
import '../models/attendance_poll_model.dart';
import '../views/view_attendance_sheet.dart';
import '../views/attendance_camera_screen.dart';

class AttendanceChatCard extends StatefulWidget {
  /// Data parsed from the chat message content (attendanceId, question, date,
  /// options). Live counts are loaded from the API and socket events.
  final AttendancePollData pollData;

  /// Group admin flag; reactive because group members load asynchronously.
  final RxBool? isAdmin;
  final String senderName;
  final String groupName;

  const AttendanceChatCard({
    super.key,
    required this.pollData,
    this.isAdmin,
    this.senderName = "",
    this.groupName = "",
  });

  @override
  State<AttendanceChatCard> createState() => _AttendanceChatCardState();
}

class _AttendanceChatCardState extends State<AttendanceChatCard> {
  final AttendanceController _controller = AttendanceController.instance;

  String? _selectedStatus;
  File? _attendancePhoto;
  bool _isSubmitting = false;

  String? _statusError;
  String? _photoError;

  int get _attendanceId => widget.pollData.attendanceId;

  AttendancePollData get _poll =>
      _controller.polls[_attendanceId] ?? widget.pollData;

  bool _requiresPhoto(String? status) => status?.toLowerCase() == "present";

  @override
  void initState() {
    super.initState();
    _controller.loadMessageData(_attendanceId);
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceCameraScreen(
          groupName: widget.groupName,
          memberCount: _poll.totalMembers,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _attendancePhoto = File(result);
        _photoError = null;
      });
    }
  }

  Future<void> _submitAttendance() async {
    setState(() {
      _statusError = null;
      _photoError = null;
    });

    if (_selectedStatus == null) {
      setState(() {
        _statusError = "Please select your status";
      });
    } else if (_requiresPhoto(_selectedStatus) && _attendancePhoto == null) {
      setState(() {
        _photoError = "Photo required for Present. Please take a photo.";
      });
    }

    if (_statusError != null || _photoError != null) {
      _showSnack(
        "Validation Error",
        _photoError ?? _statusError!,
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _controller.markAttendance(
        attendanceId: _attendanceId,
        response: _selectedStatus!,
        photoPath: _attendancePhoto?.path,
      );

      _showSnack(
        "Attendance Submitted",
        "Marked as $_selectedStatus successfully!",
      );
    } catch (e) {
      _showSnack("Attendance Failed", e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnack(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? const Color(0xFFEF4444) : const Color(0xFF5A3EFE),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final poll = _poll;
      final Widget body;
      if (widget.isAdmin?.value == true) {
        body = _buildSummaryCard(poll, showViewButton: true);
      } else if (poll.userResponse != null) {
        body = _buildRespondedCard(poll);
      } else if (!poll.isActive) {
        body = _buildSummaryCard(poll, footerNote: "Attendance closed");
      } else {
        body = _buildMemberCard(poll);
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
                color: const Color(0xFF5A3EFE),
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
                color: const Color(0xFF5A3EFE),
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

  // ════════════════════════════════════════════════════════
  // ── SUMMARY CARD (counts + progress bars) ──
  // ════════════════════════════════════════════════════════
  Widget _buildSummaryCard(
    AttendancePollData poll, {
    bool showViewButton = false,
    String? footerNote,
  }) {
    final denominator =
        poll.totalMembers > 0 ? poll.totalMembers : poll.respondedCount;
    final presentRatio =
        denominator > 0 ? (poll.presentCount / denominator).clamp(0.0, 1.0) : 0.0;
    final absentRatio =
        denominator > 0 ? (poll.absentCount / denominator).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FE),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(poll),

          SizedBox(height: 16.h),

          _buildCountRow(
            label: "Present",
            icon: Icons.check_rounded,
            color: const Color(0xFF22C55E),
            ratio: presentRatio,
            count: poll.presentCount,
          ),

          SizedBox(height: 12.h),

          _buildCountRow(
            label: "Absent",
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
            ratio: absentRatio,
            count: poll.absentCount,
          ),

          SizedBox(height: 14.h),

          // Responded Members info
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: const Color(0xFF64748B),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "${poll.totalMembers} Members • ${poll.respondedCount} responded",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (footerNote != null)
                Text(
                  footerNote,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          if (showViewButton) ...[
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                onPressed: () {
                  ViewAttendanceSheet.show(
                    context,
                    poll,
                    groupName: widget.groupName,
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF5A3EFE), width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  "View Attendance",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A3EFE),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleRow(AttendancePollData poll, {Widget? trailing}) {
    return Row(
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
            color: const Color(0xFF5A3EFE),
            size: 22.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance • ${poll.shortDate}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (poll.question.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  poll.question,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
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

  Widget _buildCountRow({
    required String label,
    required IconData icon,
    required Color color,
    required double ratio,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 15.sp),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 58.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE2E8F0),
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
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // ── MEMBER: ALREADY RESPONDED ──
  // ════════════════════════════════════════════════════════
  Widget _buildRespondedCard(AttendancePollData poll) {
    final response = poll.userResponse!;
    final isPresent = response.toLowerCase() == "present";
    final color = isPresent ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final photo = attendanceMediaUrl(poll.userPhotoUrl);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(
            poll,
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isPresent
                    ? const Color(0xFFE8F9EF)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPresent ? Icons.check_rounded : Icons.close_rounded,
                    size: 13.sp,
                    color: color,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    response,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),

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

          SizedBox(height: 8.h),

          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: const Color(0xFF64748B),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "${poll.totalMembers} Members • ${poll.respondedCount} responded",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── MEMBER: MARK ATTENDANCE CARD ──
  // ════════════════════════════════════════════════════════
  Widget _buildMemberCard(AttendancePollData poll) {
    final needsPhoto = _requiresPhoto(_selectedStatus);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(poll),

          SizedBox(height: 16.h),

          // Subtitle
          Text(
            "Mark your attendance",
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "Please select your status for ${poll.longDate}",
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),

          if (_statusError != null) ...[
            SizedBox(height: 6.h),
            Text(
              _statusError!,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          SizedBox(height: 12.h),

          for (int i = 0; i < poll.options.length; i++) ...[
            _buildOptionTile(i + 1, poll.options[i]),
            SizedBox(height: 10.h),
          ],

          // Attendance Photo Tile (opens dedicated camera screen)
          if (needsPhoto) ...[
            GestureDetector(
              onTap: _openCamera,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: _photoError != null
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE2E8F0),
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
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: const Color(0xFF5A3EFE),
                        size: 20.sp,
                      ),
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
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _attendancePhoto != null
                                ? "Photo captured ✓ (Tap to retake)"
                                : "Take a selfie",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: _attendancePhoto != null
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B),
                              fontWeight: _attendancePhoto != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF64748B),
                      size: 22.sp,
                    ),
                  ],
                ),
              ),
            ),

            if (_photoError != null) ...[
              SizedBox(height: 4.h),
              Text(
                _photoError!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            SizedBox(height: 4.h),
          ],

          SizedBox(height: 4.h),

          // Submit Attendance Button
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A3EFE),
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
                      "Mark Attendance",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 10.h),

          // Footer info
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: const Color(0xFF64748B),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "${poll.totalMembers} Members • ${poll.respondedCount} responded",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int number, String label) {
    final isSelected = _selectedStatus == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = label;
          _statusError = null;
          if (!_requiresPhoto(label)) _photoError = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF6F8FE) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5A3EFE)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5A3EFE)
                    : const Color(0xFF818CF8),
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
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5A3EFE)
                      : const Color(0xFF94A3B8),
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
                          color: Color(0xFF5A3EFE),
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
