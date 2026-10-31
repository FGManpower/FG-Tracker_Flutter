import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/attendance_controller.dart';
import '../models/attendance_poll_model.dart';

class ViewAttendanceSheet extends StatefulWidget {
  final AttendancePollData pollData;
  final String groupName;

  const ViewAttendanceSheet({
    super.key,
    required this.pollData,
    this.groupName = "",
  });

  static Future<void> show(
    BuildContext context,
    AttendancePollData pollData, {
    String groupName = "",
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

  late AttendancePollData _data;
  bool _isLoading = true;
  String? _error;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.pollData;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _loadDetails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AttendanceController.instance
          .fetchDetails(widget.pollData.attendanceId);
      if (!mounted) return;
      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<AttendanceMemberResponse> get _filteredMembers {
    final list = _data.responses;
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
              child: RefreshIndicator(
                onRefresh: _loadDetails,
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    if (_isLoading && _data.responses.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 36.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5A3EFE),
                          ),
                        ),
                      )
                    else if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36.h),
                          child: Text(
                            _error ??
                                (_searchQuery.isEmpty
                                    ? "No members recorded yet"
                                    : "No members match your search"),
                            textAlign: TextAlign.center,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName.isNotEmpty ? widget.groupName : "Attendance",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "${_data.totalMembers} Members • ${_data.respondedCount} responded",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Attendance • ${_data.shortDate}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (_data.question.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        _data.question,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _data.isActive
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFE8F9EF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _data.isActive ? "Active" : "Completed",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: _data.isActive
                        ? const Color(0xFF5A3EFE)
                        : const Color(0xFF22C55E),
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
                        "${_data.presentCount}",
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
                        "${_data.absentCount}",
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
    final isPresent = member.isPresent;
    final Color badgeBg;
    final Color badgeFg;
    final IconData badgeIcon;
    if (!member.hasResponded) {
      badgeBg = const Color(0xFFF1F5F9);
      badgeFg = const Color(0xFF64748B);
      badgeIcon = Icons.schedule_rounded;
    } else if (isPresent) {
      badgeBg = const Color(0xFFE8F9EF);
      badgeFg = const Color(0xFF16A34A);
      badgeIcon = Icons.check_circle_rounded;
    } else {
      badgeBg = const Color(0xFFFEF2F2);
      badgeFg = const Color(0xFFDC2626);
      badgeIcon = Icons.cancel_rounded;
    }

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
              _buildAvatar(member),
              SizedBox(width: 12.w),
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
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 13.sp, color: badgeFg),
                          SizedBox(width: 4.w),
                          Text(
                            member.status,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (member.time.isNotEmpty)
                Text(
                  member.time,
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
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            title: member.hasLocation
                ? (member.locationName ??
                    "${member.latitude!.toStringAsFixed(5)}, ${member.longitude!.toStringAsFixed(5)}")
                : "No location available",
            onView: member.hasLocation ? () => _openMap(member) : null,
          ),

          // Photo Proof Row
          if (member.photoFullUrl != null) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              icon: Icons.camera_alt_rounded,
              title: "Photo Proof",
              onView: () => _previewPhoto(context, member),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
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
          Icon(icon, color: const Color(0xFF64748B), size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: onView != null
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
              ),
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
    );
  }

  Future<void> _openMap(AttendanceMemberResponse member) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${member.latitude},${member.longitude}",
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        "Unable to open map",
        member.locationName ?? "",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildAvatar(AttendanceMemberResponse member) {
    final avatar = member.profileImageUrl;
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
              member.userName.isNotEmpty
                  ? member.userName[0].toUpperCase()
                  : "M",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5A3EFE),
              ),
            ),
    );
  }

  void _previewPhoto(BuildContext context, AttendanceMemberResponse member) {
    final photo = member.photoFullUrl;
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
                  Icon(Icons.camera_alt_rounded,
                      color: const Color(0xFF5A3EFE), size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "${member.userName}'s Photo Proof",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: photo.startsWith("http")
                    ? CachedNetworkImage(
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        height: 320.h,
                        width: double.infinity,
                        placeholder: (_, __) => SizedBox(
                          height: 320.h,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5A3EFE),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => SizedBox(
                          height: 200.h,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      )
                    : Image.file(File(photo),
                        fit: BoxFit.cover,
                        height: 320.h,
                        width: double.infinity),
              ),
              if (member.time.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  "Captured at ${member.time} • Verified",
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

  String _csvCell(dynamic value) {
    final str = value?.toString() ?? "";
    if (str.contains(",") || str.contains("\"") || str.contains("\n")) {
      return "\"${str.replaceAll("\"", "\"\"")}\"";
    }
    return str;
  }

  Future<void> _downloadReport() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
    });

    try {
      final report = await AttendanceController.instance
          .fetchReport(_data.attendanceId);

      final rawMembers =
          report["members"] is List ? report["members"] as List : const [];
      final members = rawMembers
          .whereType<Map>()
          .map((m) =>
              AttendanceMemberResponse.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      final buffer = StringBuffer()
        ..writeln("Attendance Report")
        ..writeln("Group,${_csvCell(report["groupName"] ?? widget.groupName)}")
        ..writeln("Question,${_csvCell(report["question"] ?? _data.question)}")
        ..writeln("Date,${_csvCell(report["date"] ?? _data.date)}")
        ..writeln("Created By,${_csvCell(report["createdBy"])}")
        ..writeln("Present,${report["presentCount"] ?? _data.presentCount}")
        ..writeln("Absent,${report["absentCount"] ?? _data.absentCount}")
        ..writeln(
            "Total Members,${report["totalMembers"] ?? _data.totalMembers}")
        ..writeln()
        ..writeln(
            "Name,Status,Marked At,Location,Latitude,Longitude,Photo URL");

      for (final m in members) {
        buffer.writeln([
          m.userName,
          m.status,
          m.markedAt != null
              ? DateFormat("dd MMM yyyy hh:mm a").format(m.markedAt!)
              : "",
          m.locationName ?? "",
          m.latitude ?? "",
          m.longitude ?? "",
          m.photoFullUrl ?? "",
        ].map(_csvCell).join(","));
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/attendance_report_${_data.attendanceId}_${_data.date}.csv",
      );
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: "text/csv")],
        subject: "Attendance Report • ${_data.shortDate}",
      );
    } catch (e) {
      Get.snackbar(
        "Report Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildDownloadButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: _isDownloading ? null : _downloadReport,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF5A3EFE), width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: _isDownloading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF5A3EFE),
                  ),
                )
              : Row(
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
