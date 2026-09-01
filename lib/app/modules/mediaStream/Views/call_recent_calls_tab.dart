import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CallRecentCallsTab extends StatelessWidget {
   CallRecentCallsTab({super.key});

  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Map<String, String>> calls = controller.filteredRecentCalls;
      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
        children: [
          reausabletext(
            "Recent Calls",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          SizedBox(height: 4.h),
          if (calls.isEmpty)
            const _EmptyState(message: "No recent calls found")
          else
            for (int i = 0; i < calls.length; i++) ...[
              _RecentCallTile(call: calls[i]),
              SizedBox(height: 14.h),
            ],
        ],
      );
    });
  }
}

class _RecentCallTile extends StatelessWidget {
  const _RecentCallTile({required this.call});

  final Map<String, String> call;

  @override
  Widget build(BuildContext context) {
    final String type = call['type'] ?? '';
    final bool missed = type.contains('Missed');
    final bool incoming = type.contains('Incoming');
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(call['avatar'] ?? ''),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(
                call['name'] ?? '',
                fontsize: 14.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    missed
                        ? Icons.call_missed_rounded
                        : incoming
                        ? Icons.call_received_rounded
                        : Icons.call_made_rounded,
                    size: 13.sp,
                    color: const Color(0xFF6B4DFF).withOpacity(0.8),
                  ),
                  SizedBox(width: 4.w),
                  reausabletext(
                    type,
                    fontsize: 11.sp,
                    color: const Color(0xFF6B4DFF).withOpacity(0.75),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        reausabletext(
          call['time'] ?? '',
          fontsize: 11.sp,
          color: const Color(0xFF6B4DFF).withOpacity(0.6),
        ),
        SizedBox(width: 10.w),
        const _CallActionChip(icon: Icons.videocam_rounded),
      ],
    );
  }
}

class _CallActionChip extends StatelessWidget {
  const _CallActionChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFF4818F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, size: 16.sp, color: Colors.white),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: reausabletext(
          message,
          fontsize: 14.sp,
          color: Colors.grey,
        ),
      ),
    );
  }
}
