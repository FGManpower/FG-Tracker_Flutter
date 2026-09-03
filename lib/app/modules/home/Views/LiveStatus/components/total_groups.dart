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
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios,size: 20.sp,)),
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [


            Padding(
              padding:  EdgeInsets.only(bottom: 10.h),
              child: TextField(
                // controller: _searchController,
                // onChanged: (value) => _searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: "Search groups",
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    fontFamily: FontFamily.interRegular,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide(
                      color:  Colors.grey.shade400,
                      width: 1.w,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide(
                      color:  Colors.grey.shade400,
                      width: 1.w,
                    ),
                  ),


                  isDense: true,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      // _searchController.clear();
                      // _searchQuery.value = '';
                    },
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => apiGroupCard(GroupsResData(
                  id: 1,
                  groupCode: "44343",
                  groupDesc: "As Dev",
                  groupName: "FG Manpower",
                  groupProfile: "",
                  // isActive: t,
                  // isCreator: ,
                  memberCount: 1,
                ),index),),
            ),
          ],
        ),
      )
    );
  }

  Widget apiGroupCard(GroupsResData group, int index) {
    final colors = colorPool[index % colorPool.length];

    return Padding(
      padding:  EdgeInsets.only(top:7.h),
      child: InkWell(
        onTap: () {

        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors['bg'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups,
                  color: colors['icon'],
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      group.groupName ?? "No Name Group",
                      fontsize: 14.sp,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        reausabletext(
                          "${group.memberCount ?? 0} Members",
                          fontsize: 11.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
