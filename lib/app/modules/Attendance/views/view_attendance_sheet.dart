import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/attendance_poll_model.dart';

class ViewAttendanceSheet extends StatelessWidget {
  final AttendancePollData pollData;

  const ViewAttendanceSheet({super.key, required this.pollData});

  static Future<void> show(BuildContext context, AttendancePollData pollData) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ViewAttendanceSheet(pollData: pollData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // ── Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
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
                        "Attendance • ${pollData.date}",
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${pollData.respondedCount} of ${pollData.totalMembers} members responded",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF5A3EFE),
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),

          // ── Summary Cards (Present / Absent) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF16A34A),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Present",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${pollData.presentCount}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_rounded,
                          color: const Color(0xFFDC2626),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Absent",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${pollData.absentCount}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Members List ──
          Flexible(
            child: pollData.responses.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  "No responses recorded yet",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 6.h,
              ),
              itemCount: pollData.responses.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = pollData.responses[index];
                final isPresent = item.status.toLowerCase() == "present";

                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: Text(
                          item.userName.isNotEmpty
                              ? item.userName[0].toUpperCase()
                              : "M",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A3EFE),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.userName,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Marked at ${item.time}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.photoUrl != null &&
                          item.photoUrl!.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _previewPhoto(context, item.photoUrl!),
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: item.photoUrl!.startsWith("http")
                                  ? Image.network(
                                item.photoUrl!,
                                fit: BoxFit.cover,
                              )
                                  : Image.file(
                                File(item.photoUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E8),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: isPresent
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _previewPhoto(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: path.startsWith("http")
                  ? Image.network(path, fit: BoxFit.contain)
                  : Image.file(File(path), fit: BoxFit.contain),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: EdgeInsets.all(12.w),
              ),
              child: const Icon(Icons.close, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
