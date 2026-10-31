import 'package:flutter/material.dart';
import 'package:fgtracker/app/Core/constant/BottomSheet/attendance_sheet.dart';

class AttendanceView extends StatelessWidget {
  final int groupId;
  final List<dynamic>? groupMembers;
  const AttendanceView({super.key, required this.groupId, this.groupMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Create Attendance"),
        centerTitle: true,
      ),
      body: AttendanceSheet(groupId: groupId, groupMembers: groupMembers),
    );
  }
}
