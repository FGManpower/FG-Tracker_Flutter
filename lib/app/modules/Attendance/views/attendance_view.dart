import 'package:flutter/material.dart';
import 'package:fgtracker/l10n/l10n.dart';
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
        title: Text(context.l10n.attendance_createTitle),
        centerTitle: true,
      ),
      body: AttendanceSheet(groupId: groupId, groupMembers: groupMembers),
    );
  }
}
