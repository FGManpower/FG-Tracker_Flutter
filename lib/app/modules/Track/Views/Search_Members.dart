import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/AppText.dart';
import '../../../Data/Services/Tracking.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import '../Controller/SearchController.dart';

class SearchMembers extends GetView<SearchMemberController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: ToggleThemeData.darkPurple,
          elevation: 4,
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
                    color: Colors.white, size: 24.sp),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: TextField(
                controller: controller.searchValues,
                onChanged: controller.filterMembers,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Members...",
                    hintStyle: TextStyle(color: ToggleThemeData.darkPurple,fontSize: 13,fontFamily: FontFamily.interMedium),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 15.h),
                    suffixIcon: controller.searchValues.text.isNotEmpty
                        ? InkWell(
                            onTap: controller.clearSearch,
                            child: Padding(
                              padding: EdgeInsets.all(6.r),
                              child: CircleAvatar(
                                backgroundColor: ToggleThemeData.darkPurple,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 18.sp),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xffF2F0FF),
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
        bool isOnline = (data.isOnline == true) ||
            (data.lastSeen != null &&
                Tracking()
                    .getTimeAgo(DateTime.parse(data!.lastSeen!))
                    .toLowerCase() ==
                    "just now");
        return GestureDetector(
          onTap: () {
            Navigator.pop(context,data.name);
          },
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: NetworkImage(
                          "${ConstRes.aImageBaseUrl}${data.profileImage ?? ""}"),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Positioned(
                      right: 4.w,
                      child: Container(
                        height: 12.w,
                        width: 12.w,
                        decoration: BoxDecoration(
                          color: isOnline?Colors.green:Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5.w),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: reausabletext(
                                data.name ?? AppText.unnamedMember,
                                fontsize: 15,
                                fontfamily: FontFamily.interSemiBold),
                          ),
                          reausabletext("12:08 PM",
                              fontsize: 10,
                              fontfamily: FontFamily.interMedium,
                              color: Colors.grey.shade500),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      reausabletext("Online",
                          fontsize: 10,
                          fontfamily: FontFamily.interMedium,
                          color: ToggleThemeData.darkPurple),
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
