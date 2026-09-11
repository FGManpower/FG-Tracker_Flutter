import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final controller = Get.put(NotificationController());

  final List<Map<String, dynamic>> filters = [
    {
      "title": "All",
      "value": "all",
    },
    {
      "title": "Unread",
      "value": "unread",
    },
    {
      "title": "Chats",
      "value": "chat",
    },
    {
      "title": "Calls",
      "value": "call",
    },
  ];

  final Color bgColor = const Color(0xffFAFAFF);
  final Color textDark = const Color(0xff12113A);
  final Color primaryPurple = const Color(0xff5736F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Row(
            children: [
              IconButton(
                key: null,
                icon: Icon(Icons.arrow_back, color: primaryPurple, size: 24.sp),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 4.w),
              Text(
                "Notifications",
                style: TextStyle(
                  color: textDark,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          _buildFilterTabs(),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              return Skeletonizer(
                enabled: controller.isLoading.value,
                child: controller.filteredNotifications.isEmpty
                    ? _emptyWidget()
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.isLoading.value
                            ? 8
                            : controller.filteredNotifications.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = controller.isLoading.value
                              ? null
                              : controller.filteredNotifications[index];

                          return _buildNotificationCard(item);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            controller.selectedFilter.value = "clear_history";
            controller.applyFilter();
            controller.selectedFilter.value = "all";
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: primaryPurple,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Clear all notifications",
                  style: TextStyle(
                    color: primaryPurple,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 33.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final filter = filters[index];

          return Obx(() {
            final isSelected =
                controller.selectedFilter.value == filter["value"];

            return GestureDetector(
              onTap: () {
                controller.selectedFilter.value = filter["value"];
                controller.applyFilter();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                  color: isSelected ? primaryPurple : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter["title"],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : textDark,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final profileImage = item?.data?["memberData"]?["ProfileImage"];
    final bool isUnread = item?.isRead == false;

    IconData leadingIcon = Icons.notifications;
    Color iconColor = primaryPurple;
    Color iconBgColor = primaryPurple.withOpacity(0.1);

    if (item?.type == "chat" || item?.data?["screen_name"] == "chatScreen") {
      leadingIcon = Icons.chat_bubble_outline_rounded;
      iconColor = primaryPurple;
      iconBgColor = primaryPurple.withOpacity(0.1);
    } else if (item?.type == "missed_call" ||
        item?.data?["screen_name"] == "incomingCall") {
      leadingIcon = Icons.phone_callback_rounded;
      iconColor = const Color(0xffFF8C00);
      iconBgColor = const Color(0xffFF8C00).withOpacity(0.1);
    } else if (item?.data?["screen_name"] == "groupChatScreen") {
      leadingIcon = Icons.people_alt_outlined;
      iconColor = primaryPurple;
      iconBgColor = primaryPurple.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: item == null
          ? null
          : () async {
              try {
                if (item.id != null) {
                  await controller.markAsRead(item.id!);
                }

                final data = item.data;
                if (data == null) return;

                if (data["screen_name"] == "chatScreen") {
                  if (data["memberData"] == null) return;

                  final memberData = MemberData.fromJson(
                    Map<String, dynamic>.from(data["memberData"]),
                  );

                  Get.toNamed(
                    Routes.chatScreen,
                    arguments: {
                      "userData": memberData,
                      "groupName": "Test",
                      "type": "chatScreen",
                    },
                  );
                } else if (data["screen_name"] == "groupChatScreen") {
                  Get.toNamed(
                    Routes.groupChatScreen,
                    arguments: {
                      "groupId": int.parse(item.groupId.toString()).toString(),
                      "groupName": item.data?['groupName'].toString(),
                      "groupImage": "",
                    },
                  );
                } else if (data["screen_name"] == "incomingCall" ||
                    item.type == "missed_call") {
                  final bool isVideo = data['callData']["isVideo"] == true;

                  Get.toNamed(
                    Routes.callScreen,
                    arguments: {
                      "callerId": Global.storageServices
                          .get(PrefConst.userId)
                          .toString(),
                      "remoteUserId": data['callData']["callerId"].toString(),
                      "callerName": data['callData']["callerName"] ?? "",
                      "offer": null,
                      "is_video": isVideo,
                      "callType": "outGoing",
                    },
                  );
                }
              } catch (e) {
                debugPrint("Notification Error => $e");
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isUnread
              ? const LinearGradient(
                  colors: [
                    Color(0xffF5F2FF),
                    Color(0xffFFFFFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUnread ? null : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnread
                ? primaryPurple.withOpacity(0.22)
                : Colors.grey.withOpacity(0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? primaryPurple.withOpacity(0.06)
                  : Colors.black.withOpacity(0.02),
              blurRadius: isUnread ? 14 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: profileImage != null
                    ? Image.network(
                        "${ConstRes.aImageBaseUrl}$profileImage",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(leadingIcon,
                              color: iconColor, size: 22.sp);
                        },
                      )
                    : Icon(leadingIcon, color: iconColor, size: 22.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    item?.title ?? "Loading...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item?.body ?? "Loading notification details",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xff6A6A8B),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item != null
                          ? controller.formatTime(item.createdAt ?? "")
                          : "...",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff6A6A8B),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isUnread)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 60.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Notifications Yet",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "You have no new alerts at the moment.",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
