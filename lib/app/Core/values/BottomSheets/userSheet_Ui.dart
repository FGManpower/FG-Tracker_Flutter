import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/search_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';

class UserSheetUi {
  final SearchUserController controller = Get.put(SearchUserController());

  Future<UserListData?> showAllUserBottomSheet(
    BuildContext context,
  ) async {
    await controller.getRegisteredContacts();

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
              Obx(
                () => Column(
                  children: [
                    Text(
                      "Add Group Member",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${controller.allUserProfileData.length} Registered Contacts",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: controller.searchValues,
                onChanged: controller.filterUsers,
                decoration: InputDecoration(
                  hintText: "Search contacts",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                    fontFamily: FontFamily.interMedium,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 22.sp,
                  ),
                  suffixIcon: controller.searchValues.text.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clearSearch,
                          icon: Icon(
                            Icons.close,
                            size: 20.sp,
                          ),
                        )
                      : null,
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
                  if (controller.contactLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.responseError.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.responseError.value,
                      ),
                    );
                  }

                  if (controller.allUserProfileData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contacts_outlined,
                            size: 70.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "No Registered Contacts",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "Your contacts are not using FG Tracker yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 60.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "No User Found",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshContacts,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (_, index) {
                        final user = controller.filteredUsers[index];

                        final profileUrl = (user.profileImage?.isNotEmpty ??
                                false)
                            ? "${ConstRes.aImageBaseUrl}${user.profileImage}"
                            : null;

                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            18.r,
                          ),
                          onTap: () {
                            Get.back(
                              result: user,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 10.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                18.r,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.04,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(
                                    0,
                                    2,
                                  ),
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
                                    backgroundImage: profileUrl != null
                                        ? NetworkImage(
                                            profileUrl,
                                          )
                                        : null,
                                    child: profileUrl == null
                                        ? Text(
                                            (user.name?.isNotEmpty ?? false)
                                                ? user.name![0].toUpperCase()
                                                : "U",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 14.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      // SizedBox(
                                      //   height: 4.h,
                                      // ),
                                      // Text(
                                      //   user.mobileNo ??
                                      //       "",
                                      //   style:
                                      //   TextStyle(
                                      //     fontSize:
                                      //     13.sp,
                                      //     color: Colors
                                      //         .grey
                                      //         .shade600,
                                      //   ),
                                      // ),
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
                    ),
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
