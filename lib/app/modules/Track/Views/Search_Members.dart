import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/AppText.dart';
import '../../../Core/values/colors.dart';
import '../../../Data/Services/Tracking.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import '../../../routes/app_pages.dart';
import '../Controller/SearchController.dart';

class SearchMembers extends GetView<SearchMemberController> {
  const SearchMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: ToggleThemeData.darkPurple,
          elevation: 4.0,
          titleSpacing: 0,
          toolbarHeight: 70.h,
          leading: IconButton(
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            icon: Container(
              height: 33.w,
              width: 33.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ToggleThemeData.white, width: 2.w),
              ),
              child: Center(
                child: Icon(Icons.arrow_back_outlined,
                    color: AppColors.white, size: 24.sp),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: TextField(
                controller: controller.searchValues,
                onChanged: controller.filterMembers,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Members...",
                    hintStyle: TextStyle(
                        color: ToggleThemeData.darkPurple,
                        fontSize: 13,
                        fontFamily: FontFamily.interMedium),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                    suffixIcon: controller.searchValues.text.isNotEmpty
                        ? InkWell(
                            onTap: controller.clearSearch,
                            child: Padding(
                              padding: EdgeInsets.all(6.r),
                              child: CircleAvatar(
                                backgroundColor: ToggleThemeData.darkPurple,
                                child: Icon(Icons.close,
                                    color: AppColors.white, size: 18.sp),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
            ),
          ),
        ),
        body: Container(
          color: AppColors.white,
          child: controller.filteredMembers.isEmpty
              ? Center(
                  child: Text("No members found",
                      style: TextStyle(fontSize: 18.sp)))
              : _memberList(),
        ),
      ),
    );
  }

  Widget _memberList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: controller.filteredMembers.length,
      itemBuilder: (context, index) {
        final data = controller.filteredMembers[index];
        bool isOnline = Tracking().isOnline(
          rawIsOnline: data.isOnline,
          lastSeen: data.lastSeen,
          thresholdMinutes: 5,
        );
        String timeAgoText = isOnline ? "Online" : "Offline";

        if (!isOnline && data.lastSeen != null && data.lastSeen!.isNotEmpty) {
          try {
            final dt = Tracking.parseDateTime(data.lastSeen!);
            if (dt != null) {
              timeAgoText = Tracking().getTimeAgo(dt);
            }
          } catch (_) {}
        }

        final String? imgUrl = data.profileImage != null && data.profileImage!.isNotEmpty
            ? (data.profileImage!.startsWith("http")
                ? data.profileImage!
                : "${ConstRes.aImageBaseUrl}${data.profileImage}")
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.pop(context, data.userId.toString());
          },
          child: Container(
            color: AppColors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                      backgroundColor: AppColors.appGreybackgroundcolor,
                      child: imgUrl == null
                          ? Icon(Icons.person, color: AppColors.primaryElement, size: 28.sp)
                          : null,
                    ),
                    Positioned(
                      right: 4.w,
                      child: Container(
                        height: 12.w,
                        width: 12.w,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.primaryElementStatus : AppColors.darkRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 1.5.w),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reausabletext(
                              data.name ?? AppText.unnamedMember,
                              fontsize: 15,
                              fontfamily: FontFamily.interSemiBold,
                            ),
                            SizedBox(height: 4.h),
                            reausabletext(
                              timeAgoText,
                              fontsize: 10,
                              fontfamily: FontFamily.interMedium,
                              color: isOnline
                                  ? AppColors.primaryElementStatus
                                  : AppColors.primarySecondaryElementText,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 8.h),
                          InkWell(
                            borderRadius: BorderRadius.circular(20.r),
                            onTap: () {
                              final MemberData memberData = MemberData(
                                userId: data.userId,
                                groupId: data.groupId ?? 0,
                                name: data.name,
                                profileImage: data.profileImage,
                                lastSeen: data.lastSeen,
                                isOnline: isOnline,
                              );

                              Get.toNamed(
                                Routes.chatScreen,
                                arguments: {
                                  "userData": memberData,
                                  "groupName": "Members Chat",
                                  "isCreator": false,
                                  "type": "",
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ToggleThemeData.darkPurple
                                    .withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: ToggleThemeData.darkPurple,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
