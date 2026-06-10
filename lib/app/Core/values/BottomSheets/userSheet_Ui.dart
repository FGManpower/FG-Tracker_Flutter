import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/search_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:fgtracker/app/Model/user_profileList_res.dart';

class UserSheetUi {
  final SearchUserController controller = Get.put(SearchUserController());

  Future<UserListData?> showAllUserBottomSheet(
    BuildContext context,
  ) async {
    await controller.getAllUserOrJoinGroup();

    return await showModalBottomSheet<UserListData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .75,
            child: Column(
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 15.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                Text(
                  "Select User",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: controller.searchValues,
                  keyboardType: TextInputType.phone,
                  onChanged: controller.filterUsers,
                  decoration: InputDecoration(
                    hintText: "Search User with Mobile Number",
                    hintStyle: TextStyle(
                      color: ToggleThemeData.darkPurple,
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interMedium,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: controller.searchValues.text.isNotEmpty
                        ? IconButton(
                      onPressed: controller.clearSearch,
                      icon: Icon(
                        Icons.close,
                        size: 20.sp,
                      ),
                    )
                        : const SizedBox(),
                  ),
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: Obx(() {
                    if (controller.allUserDataLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (controller.filteredUsers.isEmpty) {
                      return Center(
                        child: Text(
                          "No User Found",
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (_, index) {
                        final user = controller.filteredUsers[index];

                        final profileUrl = (user.profileImage?.isNotEmpty ??
                                false)
                            ? "${ConstRes.aImageBaseUrl}${user.profileImage}"
                            : null;

                        return InkWell(
                          onTap: () {
                            Get.back(result: user);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25.r,
                                  backgroundImage: profileUrl != null
                                      ? NetworkImage(profileUrl)
                                      : null,
                                  child: profileUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 25.sp,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name ?? "",
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
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.sp,
                                  color: Colors.grey,
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
          ),
        );
      },
    );
  }
}
