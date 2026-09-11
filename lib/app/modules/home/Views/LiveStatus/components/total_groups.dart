import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Model/GroupChatListModel.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Controller/total_group_controller.dart';

class totalGroup extends StatelessWidget {
  const totalGroup({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TotalGroupController());

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
                border: Border.all(
                  color: Colors.grey.withOpacity(0.12),
                ),
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
        title: Obx(
          () => Column(
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
                "${controller.groupList.length} Groups",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        child: Column(
          children: [
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
                border: Border.all(
                  color: Colors.grey.withOpacity(0.12),
                ),
              ),
              child: Obx(
                () => TextField(
                  controller: controller.searchController,
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
                    suffixIcon: controller.searchText.value.isNotEmpty
                        ? GestureDetector(
                            onTap: controller.clearSearch,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.groupList.isEmpty) {
                  return _buildGroupList(
                    controller: controller,
                    isLoading: true,
                  );
                }

                if (controller.hasError.value && controller.groupList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 45.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : "Something went wrong",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            fontFamily: FontFamily.interRegular,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: controller.refreshGroups,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final groups = controller.filteredGroupList;

                if (groups.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshGroups,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 250.h,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  controller.searchText.value.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.groups_outlined,
                                  size: 45.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  controller.searchText.value.isNotEmpty
                                      ? "No groups found"
                                      : "No groups available",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                    fontFamily: FontFamily.interRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshGroups,
                  child: _buildGroupList(
                    controller: controller,
                    data: groups,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList({
    required TotalGroupController controller,
    List<GroupChatData>? data,
    bool isLoading = false,
  }) {
    final List<GroupChatData>? items = isLoading ? null : data;

    final int itemCount = items?.length ?? 6;

    return Skeletonizer(
      enabled: items == null,
      child: ListView.separated(
        controller: controller.scrollController,
        padding: EdgeInsets.only(bottom: 8.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          if (items == null) {
            return const _GroupCardSkeleton();
          }

          return apiGroupCard(
            items[index],
            index,
            controller,
          );
        },
      ),
    );
  }

  Widget apiGroupCard(
    GroupChatData group,
    int index,
    TotalGroupController controller,
  ) {
    final colors = colorPool[index % colorPool.length];

    final String groupName = controller.getGroupName(group);
    final String description = controller.getGroupDescription(group);
    final int memberCount = controller.getMemberCount(group);
    final int unreadCount = controller.getUnreadCount(group);
    final String groupDate = controller.getGroupDate(group);

    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
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
            border: Border.all(
              color: Colors.grey.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "$memberCount Members",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B4DFF),
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        description,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (groupDate.isNotEmpty)
                    Text(
                      groupDate,
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
                      if (unreadCount > 0)
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 20.w,
                            minHeight: 20.w,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B4DFF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? "99+" : unreadCount.toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (unreadCount > 0) SizedBox(width: 8.w),
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

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Group Name Placeholder",
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "12 Members",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Last message placeholder",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Yesterday",
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
