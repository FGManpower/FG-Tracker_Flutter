import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SosUserSheet {
  Future<UserListData?> showAllUserBottomSheet(
      BuildContext context,
      List<UserListData> usersList,
      ) async {
    final searchController = TextEditingController();
    var filteredList = RxList<UserListData>.from(usersList);

    return await showModalBottomSheet<UserListData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .85,
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
          ),
          child: Column(
            children: [
              Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              SizedBox(height: 20.h),
              Column(
                children: [
                  Text(
                    "Add Family Member",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${usersList.length} Available Users",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  value = value.trim().toLowerCase();
                  if (value.isEmpty) {
                    filteredList.value = usersList;
                  } else {
                    filteredList.value = usersList.where((user) {
                      final name = (user.name ?? '').toLowerCase();
                      final mobile = (user.mobileNo ?? '').toLowerCase();
                      return name.contains(value) || mobile.contains(value);
                    }).toList();
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search users",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 22.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: Obx(() {
                  if (usersList.isEmpty) {
                    return Center(
                      child: Text(
                        "No Users Found",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        "No Match Found",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) {
                      final user = filteredList[index];

                      final profileUrl = (user.profileImage?.isNotEmpty ?? false)
                          ? "${ConstRes.aImageBaseUrl}${user.profileImage}"
                          : null;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18.r),
                        onTap: () {
                          Get.back(result: user);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58.w,
                                height: 58.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ToggleThemeData.darkPurple,
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28.r,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                  child: profileUrl == null
                                      ? Text(
                                    (user.name?.isNotEmpty ?? false) ? user.name![0].toUpperCase() : "U",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      user.mobileNo ?? "",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 24.sp,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}