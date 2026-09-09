import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class totalGroup extends StatelessWidget {
  const totalGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Groups",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontFamily: FontFamily.interBold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "10 Groups",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontFamily: FontFamily.interRegular,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // Search Bar matching image UI
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search groups...",
                  hintStyle: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.grey.shade400,
                    fontFamily: FontFamily.interRegular,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // List of Groups
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => apiGroupCard(
                  GroupsResData(
                    id: index,
                    groupCode: "FG-00$index",
                    groupDesc: index % 2 == 0
                        ? "Arjun: Safety meeting at 4 PM today."
                        : "Vikram: Tools checklist update.",
                    groupName: index == 0
                        ? "Construction Team"
                        : index == 1
                        ? "Event Crew"
                        : index == 2
                        ? "Site Workers - Ghatkopar"
                        : "Team Member $index",
                    groupProfile: "",
                    memberCount: 12 + index,
                  ),
                  index,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget apiGroupCard(GroupsResData group, int index) {
    final colors = colorPool[index % colorPool.length];

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // Colored Avatar Icon matching reference image
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colors['bg'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: colors['icon'],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),

              // Group Details (Name, Members Count, Description/Latest Message)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName ?? "No Name Group",
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Text(
                          "${group.memberCount ?? 0} Members",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B4DFF),
                            fontFamily: FontFamily.interMedium,
                          ),
                        ),
                      ],
                    ),
                    if (group.groupDesc != null && group.groupDesc!.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        group.groupDesc!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Right side timestamp, counter badge, and arrow icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    index == 0 ? "Yesterday" : index == 1 ? "22 May" : "${21 - index} May",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: Colors.grey.shade500,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B4DFF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "3",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}