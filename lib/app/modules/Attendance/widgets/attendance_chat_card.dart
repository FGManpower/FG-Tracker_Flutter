import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/attendance_poll_model.dart';
import '../views/view_attendance_sheet.dart';

class AttendanceChatCard extends StatefulWidget {
  final AttendancePollData pollData;
  final bool isAdmin;
  final String currentUserId;
  final String currentUserName;
  final Function(AttendanceMemberResponse response)? onAttendanceSubmitted;

  const AttendanceChatCard({
    super.key,
    required this.pollData,
    this.isAdmin = false,
    this.currentUserId = "user_1",
    this.currentUserName = "You",
    this.onAttendanceSubmitted,
  });

  @override
  State<AttendanceChatCard> createState() => _AttendanceChatCardState();
}

class _AttendanceChatCardState extends State<AttendanceChatCard> {
  late bool _isAdminView;
  String? _selectedStatus; // "Present" or "Absent"
  File? _attendancePhoto;
  bool _isSubmitting = false;

  // Validation feedback
  String? _statusError;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    _isAdminView = widget.isAdmin;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _attendancePhoto = File(picked.path);
        _photoError = null;
      });
    }
  }

  void _submitAttendance() {
    setState(() {
      _statusError = null;
      _photoError = null;
    });

    bool hasError = false;

    if (_selectedStatus == null) {
      setState(() {
        _statusError = "Please select your status (Present or Absent)";
      });
      hasError = true;
    }

    if (_attendancePhoto == null) {
      setState(() {
        _photoError = "Attendance photo is required. Please take a photo.";
      });
      hasError = true;
    }

    if (hasError) {
      Get.snackbar(
        "Validation Error",
        _statusError ?? _photoError ?? "Please fill all required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final response = AttendanceMemberResponse(
      userId: widget.currentUserId,
      userName: widget.currentUserName,
      status: _selectedStatus!,
      photoUrl: _attendancePhoto?.path,
      time: timeStr,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (_selectedStatus == "Present") {
          widget.pollData.presentCount++;
        } else {
          widget.pollData.absentCount++;
        }
        widget.pollData.respondedCount++;
        widget.pollData.responses.add(response);
        _isAdminView = true; // Switch to results view after submission
      });

      widget.onAttendanceSubmitted?.call(response);

      Get.snackbar(
        "Attendance Submitted",
        "Marked as $_selectedStatus successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5A3EFE),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sender Info & Admin Badge (as in screenshot) ──
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
            child: Row(
              children: [
                Text(
                  widget.pollData.creatorName,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A3EFE),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ),
                const Spacer(),
                // Toggle view button (Allows testing both Admin and Member views)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAdminView = !_isAdminView;
                    });
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      _isAdminView ? "View as Member" : "View as Admin",
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Attendance Card (Admin View OR Member View) ──
          _isAdminView ? _buildAdminCard() : _buildMemberCard(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── IMAGE 1: ADMIN POLL RESULT CARD ──
  // ════════════════════════════════════════════════════════
  Widget _buildAdminCard() {
    final total = widget.pollData.presentCount + widget.pollData.absentCount;
    final presentRatio = total > 0 ? widget.pollData.presentCount / total : 0.0;
    final absentRatio = total > 0 ? widget.pollData.absentCount / total : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FE),
        borderRadius: BorderRadius.circular(20.r),
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
          // Header: Calendar Icon + Title
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: const Color(0xFF5A3EFE),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Attendance • ${widget.pollData.date}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Present Bar ──
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Present",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                "${widget.pollData.presentCount}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: presentRatio,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            ),
          ),

          SizedBox(height: 14.h),

          // ── Absent Bar ──
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Absent",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                "${widget.pollData.absentCount}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: absentRatio,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          ),

          SizedBox(height: 14.h),

          // ── Responded Info ──
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: const Color(0xFF64748B),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "${widget.pollData.totalMembers} Members • ${widget.pollData.respondedCount} responded",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // ── View Attendance Button ──
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: OutlinedButton(
              onPressed: () {
                ViewAttendanceSheet.show(context, widget.pollData);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF6366F1), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                "View Attendance",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A3EFE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── IMAGE 2: MEMBER / EMPLOYEE ATTENDANCE CARD ──
  // ════════════════════════════════════════════════════════
  Widget _buildMemberCard() {
    final isPresentSelected = _selectedStatus == "Present";
    final isAbsentSelected = _selectedStatus == "Absent";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          // Header Row
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: const Color(0xFF5A3EFE),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Attendance",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${widget.pollData.date} •",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_vert_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ],
          ),

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
          SizedBox(height: 3.h),
          Text(
            "Please select your status for today",
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

          // ── Option 1: Present ──
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = "Present";
                _statusError = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isPresentSelected
                    ? const Color(0xFFF6F8FE)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isPresentSelected
                      ? const Color(0xFF5A3EFE)
                      : const Color(0xFFE2E8F0),
                  width: isPresentSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isPresentSelected
                          ? const Color(0xFF5A3EFE)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "1",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Present",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPresentSelected
                            ? const Color(0xFF5A3EFE)
                            : const Color(0xFF94A3B8),
                        width: isPresentSelected ? 2.0 : 1.5,
                      ),
                    ),
                    child: isPresentSelected
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
          ),

          SizedBox(height: 10.h),

          // ── Option 2: Absent ──
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = "Absent";
                _statusError = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isAbsentSelected
                    ? const Color(0xFFF6F8FE)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isAbsentSelected
                      ? const Color(0xFF5A3EFE)
                      : const Color(0xFFE2E8F0),
                  width: isAbsentSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isAbsentSelected
                          ? const Color(0xFF5A3EFE)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "2",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Absent",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAbsentSelected
                            ? const Color(0xFF5A3EFE)
                            : const Color(0xFF94A3B8),
                        width: isAbsentSelected ? 2.0 : 1.5,
                      ),
                    ),
                    child: isAbsentSelected
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
          ),

          SizedBox(height: 12.h),

          // ── Attendance Photo Tile ──
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _photoError != null
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF1F5F9),
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
                              : "Take a photo",
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

          SizedBox(height: 14.h),

          // ── Submit Attendance Button ──
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
                "Submit Attendance",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Footer
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: const Color(0xFF64748B),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                "${widget.pollData.totalMembers} members",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Text(
                "09:15 AM",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
