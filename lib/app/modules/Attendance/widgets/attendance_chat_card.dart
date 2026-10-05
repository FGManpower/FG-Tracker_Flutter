import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/attendance_poll_model.dart';
import '../views/view_attendance_sheet.dart';
import '../views/attendance_camera_screen.dart';

class AttendanceChatCard extends StatefulWidget {
  final AttendancePollData pollData;
  final bool isAdmin;
  final String currentUserId;
  final String currentUserName;
  final String groupName;
  final Function(AttendanceMemberResponse response)? onAttendanceSubmitted;

  const AttendanceChatCard({
    super.key,
    required this.pollData,
    this.isAdmin = false,
    this.currentUserId = "user_1",
    this.currentUserName = "You",
    this.groupName = "Site Team",
    this.onAttendanceSubmitted,
  });

  @override
  State<AttendanceChatCard> createState() => _AttendanceChatCardState();
}

class _AttendanceChatCardState extends State<AttendanceChatCard> {
  String? _selectedStatus; // "Present" or "Absent"
  File? _attendancePhoto;
  bool _isSubmitting = false;

  String? _statusError;
  String? _photoError;

  bool? _previewAsAdmin;

  bool get _hasUserResponded {
    return widget.pollData.responses
        .any((r) => r.userId == widget.currentUserId);
  }

  bool get _effectiveIsAdmin {
    if (_previewAsAdmin != null) return _previewAsAdmin!;
    return widget.isAdmin || _hasUserResponded;
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceCameraScreen(
          groupName: widget.groupName,
          memberCount: widget.pollData.totalMembers,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
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

    bool hasError = false;

    if (_selectedStatus == null) {
      setState(() {
        _statusError = "Please select your status (Present or Absent)";
      });
      hasError = true;
    }

    if (_selectedStatus == "Present" && _attendancePhoto == null) {
      setState(() {
        _photoError = "Photo required for Present. Please take a photo.";
      });
      hasError = true;
    }

    if (hasError) {
      Get.snackbar(
        "Validation Error",
        _photoError ?? _statusError ?? "Please fill all required fields",
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
    final timeStr = DateFormat("hh:mm a").format(now);

    String locationName = _selectedStatus == "Present"
        ? "Ghatkopar, Mumbai"
        : "- \nNo location available";
    String distanceStr = "Just now • Within 50 m";

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 2));

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 2));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final loc =
            "${p.locality ?? p.subLocality ?? ''}, ${p.administrativeArea ?? ''}"
                .trim();
        if (loc.isNotEmpty) {
          locationName = loc.startsWith(",") ? loc.substring(1).trim() : loc;
        }
      }
    } catch (_) {}

    final response = AttendanceMemberResponse(
      userId: widget.currentUserId,
      userName: widget.currentUserName,
      status: _selectedStatus!,
      photoUrl: _attendancePhoto?.path,
      time: timeStr,
      location: locationName,
      locationDistance: distanceStr,
    );

    setState(() {
      _isSubmitting = false;
      if (_selectedStatus == "Present") {
        widget.pollData.presentCount++;
      } else {
        widget.pollData.absentCount++;
      }
      widget.pollData.respondedCount++;
      widget.pollData.responses
          .removeWhere((r) => r.userId == widget.currentUserId);
      widget.pollData.responses.add(response);
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info with Admin badge
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    widget.pollData.creatorName.isNotEmpty
                        ? widget.pollData.creatorName[0].toUpperCase()
                        : "A",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5A3EFE),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.pollData.creatorName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A3EFE),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
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
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _previewAsAdmin = !_effectiveIsAdmin;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _effectiveIsAdmin
                              ? Icons.visibility_outlined
                              : Icons.admin_panel_settings_outlined,
                          size: 13.sp,
                          color: const Color(0xFF5A3EFE),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _effectiveIsAdmin ? "Test as Member" : "Test as Admin",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A3EFE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Show Admin summary card OR Member submission card
          _effectiveIsAdmin ? _buildAdminCard() : _buildMemberCard(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── IMAGE 5: ADMIN / SUMMARY CARD ──
  // ════════════════════════════════════════════════════════
  Widget _buildAdminCard() {
    final total = widget.pollData.presentCount + widget.pollData.absentCount;
    final presentRatio = total > 0 ? widget.pollData.presentCount / total : 0.0;
    final absentRatio = total > 0 ? widget.pollData.absentCount / total : 0.0;

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
          // Header Row
          Row(
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
                child: Text(
                  "Attendance • ${widget.pollData.date}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Present progress row
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15.sp,
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
              SizedBox(width: 12.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: presentRatio,
                    minHeight: 8.h,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF22C55E),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
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

          SizedBox(height: 12.h),

          // Absent progress row
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 15.sp,
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
              SizedBox(width: 15.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: absentRatio,
                    minHeight: 8.h,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
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

          // View Attendance Button
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton(
              onPressed: () {
                ViewAttendanceSheet.show(
                  context,
                  widget.pollData,
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
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ── IMAGE 2: MEMBER MARK ATTENDANCE CARD ──
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
          // Top Header Row
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
                  Icons.calendar_month_rounded,
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
          SizedBox(height: 2.h),
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

          // Option 1: Present
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = "Present";
                _statusError = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
                          : const Color(0xFF818CF8),
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

          // Option 2: Absent
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = "Absent";
                _statusError = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
                          : const Color(0xFF818CF8),
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

          // Attendance Photo Tile (opens dedicated camera screen)
          GestureDetector(
            onTap: _openCamera,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
