import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MentionlistItem extends StatelessWidget {
  const MentionlistItem({
    super.key,
    required this.filteredMembers,
    required this.onTap,
  });

  final List<LocationData> filteredMembers;
  final void Function(dynamic) onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, left: 8.w, right: 8.w),
        decoration: BoxDecoration(
          color: ToggleThemeData.Appcolor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: filteredMembers.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.white.withValues(alpha: 0.15),
              indent: 70.w,
            ),
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                leading: CircleAvatar(
                  radius: 22.r,
                  backgroundImage: member.profileImage != null
                      ? NetworkImage(
                          "${ConstRes.aImageBaseUrl}${member.profileImage}")
                      : null,
                  child: (member.profileImage == null && member.name != null)
                      ? Text(
                          (member.name!)[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Text(
                  member.name ?? "Unknown",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => onTap(member),
              );
            },
          ),
        ),
      ),
    );
  }
}
