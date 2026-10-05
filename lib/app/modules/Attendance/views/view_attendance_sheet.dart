import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/attendance_poll_model.dart';

class ViewAttendanceSheet extends StatefulWidget {
  final AttendancePollData pollData;
  final String groupName;

  const ViewAttendanceSheet({
    super.key,
    required this.pollData,
    this.groupName = "Site Team",
  });

  static Future<void> show(
    BuildContext context,
    AttendancePollData pollData, {
    String groupName = "Site Team",
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewAttendanceSheet(
          pollData: pollData,
          groupName: groupName,
        ),
      ),
    );
  }

  @override
  State<ViewAttendanceSheet> createState() => _ViewAttendanceSheetState();
}

class _ViewAttendanceSheetState extends State<ViewAttendanceSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AttendanceMemberResponse> get _filteredMembers {
    final list = widget.pollData.responses;
    if (_searchQuery.isEmpty) return list;
    return list
        .where((m) =>
            m.userName.toLowerCase().contains(_searchQuery) ||
            m.status.toLowerCase().contains(_searchQuery) ||
            (m.location != null &&
                m.location!.toLowerCase().contains(_searchQuery)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Card: Summary info
                    _buildSummaryCard(),

                    SizedBox(height: 18.h),

                    // Members Header & Search Row
                    Row(
                      children: [
                        Text(
                          "Members (${filtered.length})",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        _buildSearchBar(),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Member Cards List
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36.h),
                          child: Text(
                            _searchQuery.isEmpty
                                ? "No members recorded yet"
                                : "No members match your search",
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return _buildMemberCard(filtered[index]);
                        },
                      ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Bottom Action: Download Report Button
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded,
            color: const Color(0xFF5A3EFE), size: 22.sp),
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
              color: Color(0xFF5A3EFE),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.groupName,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "${widget.pollData.totalMembers} Members",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone_rounded,
              color: const Color(0xFF5A3EFE), size: 20.sp),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.videocam_rounded,
              color: const Color(0xFF5A3EFE), size: 22.sp),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded,
              color: const Color(0xFF5A3EFE), size: 20.sp),
          onPressed: () {},
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
          // Title Row + Completed badge
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
                child: Text(
                  "Attendance • ${widget.pollData.date}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9EF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "Completed",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Two boxes: Present and Absent
          Row(
            children: [
              // Present Box
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9EF),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Present",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${widget.pollData.presentCount}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 14.w),

              // Absent Box
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Absent",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${widget.pollData.absentCount}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              style: TextStyle(
                fontSize: 11.5.sp,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: "Search member",
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

  Widget _buildMemberCard(AttendanceMemberResponse member) {
    final isPresent = member.status.toLowerCase() == "present";

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
          // Header Row: Avatar, Name + Status Badge, and Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(member),
              SizedBox(width: 12.w),

              // Name + Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.userName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? const Color(0xFFE8F9EF)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPresent
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 13.sp,
                            color: isPresent
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            member.status,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isPresent
                                 ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp
              Text(
                member.time.isNotEmpty ? member.time : "09:15 AM",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Location Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: const Color(0xFF64748B),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.location ??
                            (isPresent
                                ? "Ghatkopar, Mumbai"
                                : "- \nNo location available"),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (member.locationDistance != null &&
                          member.locationDistance!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          member.locationDistance!,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isPresent)
                  GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        "Location View",
                        member.location ?? "Ghatkopar, Mumbai",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF5A3EFE),
                        colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EEFE),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "View",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5A3EFE),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Photo Proof Row (Present members only)
          if (isPresent) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: const Color(0xFF64748B),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Photo Proof",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _previewPhoto(context, member),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EEFE),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "View",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5A3EFE),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(AttendanceMemberResponse member) {
    if (member.photoUrl != null && member.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: const Color(0xFFEEF2FF),
        backgroundImage: member.photoUrl!.startsWith("http")
            ? NetworkImage(member.photoUrl!) as ImageProvider
            : FileImage(File(member.photoUrl!)),
      );
    }

    // Default safety helmet avatar styling or initials
    return CircleAvatar(
      radius: 22.r,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Text(
        member.userName.isNotEmpty ? member.userName[0].toUpperCase() : "M",
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5A3EFE),
        ),
      ),
    );
  }

  void _previewPhoto(BuildContext context, AttendanceMemberResponse member) {
    final photo = member.photoUrl;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                      Icon(Icons.camera_alt_rounded,
                          color: const Color(0xFF5A3EFE), size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "${member.userName}'s Photo Proof",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: photo != null && photo.isNotEmpty
                        ? (photo.startsWith("http")
                            ? Image.network(photo, fit: BoxFit.cover,
                                height: 260.h, width: double.infinity)
                            : Image.file(File(photo), fit: BoxFit.cover,
                                height: 260.h, width: double.infinity))
                        : Container(
                            height: 200.h,
                            color: const Color(0xFFEEF2FF),
                            child: Center(
                              child: Icon(Icons.person,
                                  size: 60.sp,
                                  color: const Color(0xFF5A3EFE)),
                            ),
                          ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Captured on ${member.time} • Verified",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: () {
            Get.snackbar(
              "Report Downloaded",
              "Attendance report saved to downloads successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF5A3EFE),
              colorText: Colors.white,
              margin: EdgeInsets.all(16.w),
              borderRadius: 12.r,
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF5A3EFE), width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_download_outlined,
                color: const Color(0xFF5A3EFE),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Download Report",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A3EFE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
