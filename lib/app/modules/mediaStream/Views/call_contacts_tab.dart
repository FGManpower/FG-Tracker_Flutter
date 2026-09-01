import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CallContactsTab extends StatelessWidget {
   CallContactsTab({super.key});

  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Map<String, String>> contacts = controller.filteredContacts;
      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
        children: [
          reausabletext(
            "All Contacts",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          SizedBox(height: 8.h),
          if (contacts.isEmpty)
            const _EmptyState(message: "No contacts found")
          else
            for (int i = 0; i < contacts.length; i++) ...[
              _ContactTile(contact: contacts[i]),
              SizedBox(height: 14.h),
            ],
        ],
      );
    });
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final Map<String, String> contact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(contact['avatar'] ?? ''),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(
                contact['name'] ?? '',
                fontsize: 14.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
              ),
              SizedBox(height: 3.h),
              reausabletext(
                contact['phone'] ?? '',
                fontsize: 11.sp,
                color: const Color(0xFF6B4DFF).withOpacity(0.7),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        const _CallActionChip(icon: Icons.videocam_rounded),
        SizedBox(width: 10.w),
        const _CallActionChip(icon: Icons.call_rounded),
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
