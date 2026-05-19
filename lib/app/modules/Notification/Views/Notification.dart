import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
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
import '../../../config/themes_data.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final controller = Get.put(NotificationController());

  final List<Map<String, dynamic>> filters = [
    {
      "title": "All",
      "value": "all",
      "icon": Icons.notifications,
    },
    {
      "title": "Unread",
      "value": "unread",
      "icon": Icons.mark_chat_unread,
    },
    {
      "title": "Chats",
      "value": "chat",
      "icon": Icons.chat_bubble,
    },
    {
      "title": "Calls",
      "value": "call",
      "icon": Icons.call,
    },
    {
      "title": "Clear History",
      "value": "clear_history",
      "icon": Icons.delete_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: ()=>Navigator.pop(context),
          child:
              reausableIcon(icon: Icons.arrow_back_ios, color: AppColors.white),
        ),
        backgroundColor: ToggleThemeData.Appcolor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Skeletonizer(
          enabled: controller.isLoading.value,
          child: controller.filteredNotifications.isEmpty
              ? _emptyWidget()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  itemCount: controller.isLoading.value
                      ? 8
                      : controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final item = controller.isLoading.value
                        ? null
                        : controller.filteredNotifications[index];

                    final profileImage =
                        item?.data?["memberData"]?["ProfileImage"];

                    return GestureDetector(
                        onTap: item == null
                            ? null
                            : () async {
                                try {
                                  if (item.id != null) {
                                    await controller.markAsRead(
                                      item.id!,
                                    );
                                  }

                                  final data = item.data;

                                  if (data == null) {
                                    return;
                                  }

                                  if (data["screen_name"] == "chatScreen") {
                                    if (data["memberData"] == null) {
                                      return;
                                    }

                                    final memberData = MemberData.fromJson(
                                      Map<String, dynamic>.from(
                                        data["memberData"],
                                      ),
                                    );

                                    Get.toNamed(
                                      Routes.chatScreen,
                                      arguments: {
                                        "userData": memberData,
                                        "groupName": "Test",
                                        "type": "chatScreen",
                                      },
                                    );
                                  } else if (data["screen_name"] ==
                                          "incomingCall" ||
                                      item.type == "missed_call") {
                                    final bool isVideo =
                                        data['callData']["isVideo"] == true;

                                    Get.toNamed(
                                      Routes.callScreen,
                                      arguments: {
                                        "callerId": Global.storageServices
                                            .get(PrefConst.userId)
                                            .toString(),
                                        "remoteUserId": data['callData']
                                                ["callerId"]
                                            .toString(),
                                        "callerName": data['callData']
                                                ["callerName"] ??
                                            "",
                                        "offer": null,
                                        "is_video": isVideo,
                                        "callType": "outGoing",
                                      },
                                    );
                                  }
                                } catch (e) {
                                  debugPrint(
                                    "Notification Error => $e",
                                  );
                                }
                              },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          margin: EdgeInsets.only(
                            bottom: 14.h,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: item?.isRead == false
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xffF3F0FF),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: item?.isRead == true ? Colors.white : null,
                            borderRadius: BorderRadius.circular(7.r),
                            border: Border.all(
                              color: item?.isRead == false
                                  ? Colors.deepPurple.shade100
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Stack(
                                children: [
                                  Container(
                                    width: 62.w,
                                    height: 62.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade200,
                                          Colors.deepPurple.shade400,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple
                                              .withOpacity(0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.all(2.w),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        100.r,
                                      ),
                                      child: profileImage != null
                                          ? Image.network(
                                              "${ConstRes.aImageBaseUrl}$profileImage",
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.white,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 28.sp,
                                                    color: Colors.deepPurple,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.white,
                                              child: Icon(
                                                Icons.person,
                                                size: 28.sp,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: item?.type == "chat"
                                            ? const Color(0xff22C55E)
                                            : const Color(0xffEF4444),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        item?.type == "chat"
                                            ? Icons.chat_bubble_rounded
                                            : Icons.call_rounded,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 14.w),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item?.title ?? "Loading...",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.5.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                              color: const Color(
                                                0xff111827,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (item?.isRead == false)
                                          Container(
                                            width: 11.w,
                                            height: 11.w,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xff4F46E5),
                                                  Color(0xff7C3AED),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      item?.body ?? "Loading notification",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.2.sp,
                                        height: 1.55,
                                        color: const Color(
                                          0xff6B7280,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              30.r,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.schedule_rounded,
                                                size: 12.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                controller.formatTime(
                                                  item?.createdAt ?? "",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 13.sp,
                                          color: Colors.grey.shade400,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
        );
      }),
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 70.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            "No Notifications Yet",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Your chats and calls will appear here",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(
                  20.r,
                ),
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              "Filter Notifications",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            ...filters.map((e) {
              return Obx(() {
                final selected = controller.selectedFilter.value == e["value"];

                return GestureDetector(
                  onTap: () {
                    controller.selectedFilter.value = e["value"];

                    controller.applyFilter();

                    Get.back();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 12.h,
                    ),
                    padding: EdgeInsets.all(
                      16.w,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.deepPurple.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        18.r,
                      ),
                      border: Border.all(
                        color:
                            selected ? Colors.deepPurple : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          e["icon"],
                          color: selected ? Colors.deepPurple : Colors.black87,
                        ),
                        SizedBox(
                          width: 14.w,
                        ),
                        Expanded(
                          child: Text(
                            e["title"],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.deepPurple : Colors.black87,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.deepPurple,
                          )
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ],
        ),
      ),
    );
  }
}
