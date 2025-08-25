import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetUi {
  void showMemberBottomSheet(BuildContext context, List<LocationData> members) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 5.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              reausabletext(
                "Group Members",
                fontsize: 18,
                fontweight: FontWeight.w600,
                align: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (_, index) {
                  final member = members[index];
                  final isOnline =
                      member.isOnline == true || member.isOnline == 1;
                  final profileUrl = (member.profileImage?.isNotEmpty ?? false)
                      ? "${Constant.ImagebaseUrl}${member.profileImage}"
                      : null;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundImage: profileUrl != null
                              ? NetworkImage(profileUrl)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              reausabletext(
                                member.name ?? 'Unknown',
                                fontsize: 16,
                                fontweight: FontWeight.w600,
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 10.r,
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.grey),
                                  SizedBox(width: 6.w),
                                  reausabletext(
                                    isOnline
                                        ? "Online"
                                        : "Last seen:"
                                        " ${Tracking().getTimeAgo(DateTime.parse(member.lastSeen ?? DateTime.now().toString()))}",
                                    fontsize: 13,
                                    color: Colors.grey[600],
                                  ),

                                ],
                              ),
                              SizedBox(height: 4.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    final Uri mapsUri = Uri.parse(
                                        "https://www.google.com/maps/dir/?api=1&destination=${member.latitude},${member.longitude}&travelmode=walking");
                                    launchUrl(mapsUri);
                                  },
                                  icon: const Icon(Icons.navigation),
                                  label: const Text("Navigate"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ToggleThemeData.Appcolor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    textStyle: TextStyle(fontSize: 13.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
