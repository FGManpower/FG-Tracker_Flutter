import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

import 'dart:convert';
import 'package:fgtracker/app/modules/mediaStream/Views/contact_profile_screen.dart';
import 'package:fgtracker/app/modules/call/Views/call_recent_calls_tab.dart';
import '../../call/Controller/call_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;

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
  void initState() {
    super.initState();

    controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshNotifications();
    });
  }

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
                icon: Icon(
                  Icons.arrow_back,
                  color: primaryPurple,
                  size: 24.sp,
                ),
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
              if (controller.isLoading.value) {
                return const _NotificationSkeletonList();
              }

              if (controller.responseError.value.isNotEmpty &&
                  controller.filteredNotifications.isEmpty) {
                return LostinternetConnection(
                  retry: controller.refreshNotifications,
                  messgae: controller.responseError.value,
                );
              }

              if (controller.filteredNotifications.isEmpty) {
                return RefreshIndicator(
                  color: primaryPurple,
                  onRefresh: controller.refreshNotifications,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 300.h,
                        child: _emptyWidget(),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryPurple,
                onRefresh: controller.refreshNotifications,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.filteredNotifications.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = controller.filteredNotifications[index];

                    return _buildNotificationCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value ||
            (controller.responseError.value.isNotEmpty &&
                controller.filteredNotifications.isEmpty)) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: GestureDetector(
            onTap: () async {
              await controller.clearAllNotifications();

              controller.selectedFilter.value = "all";
              controller.applyFilter();
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                12.h,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12.h,
              ),
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
        );
      }),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 33.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
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
    final data = item?.data;
    final String screenName = data?["screen_name"]?.toString() ?? "";
    final String itemType = item?.type?.toString() ?? "";

    final bool isUnread = item?.isRead == false;

    // Call check condition
    final bool isCallType = itemType.contains("call") ||
        screenName.toLowerCase().contains("call") ||
        screenName == "incomingCall" ||
        screenName == "groupCall" ||
        itemType == "missed_call" ||
        itemType == "voice_call" ||
        itemType == "video_call" ||
        itemType == "group_call";

    IconData leadingIcon = Icons.notifications;
    Color iconColor = primaryPurple;
    Color iconBgColor = primaryPurple.withOpacity(0.1);
    String? profileImage;

    if (screenName == "chatScreen" || itemType == "chat") {
      leadingIcon = Icons.chat_bubble_outline_rounded;
      iconColor = primaryPurple;
      iconBgColor = primaryPurple.withOpacity(0.1);

      final memberData = data?["memberData"];
      if (memberData is Map) {
        profileImage = memberData["ProfileImage"]?.toString() ??
            memberData["profileImage"]?.toString();
      }
    }
    else if (screenName == "groupChatScreen" && !isCallType) {
      leadingIcon = Icons.people_alt_outlined;
      iconColor = primaryPurple;
      iconBgColor = primaryPurple.withOpacity(0.1);

      profileImage = data?["groupImage"]?.toString() ??
          data?["groupData"]?["groupImage"]?.toString() ??
          data?["groupData"]?["profileImage"]?.toString();
    }
    else if (isCallType) {
      leadingIcon = itemType.contains("missed")
          ? Icons.phone_missed_rounded
          : (screenName.contains("group") || itemType.contains("group"))
          ? Icons.phone_in_talk_rounded
          : Icons.phone_callback_rounded;

      iconColor = const Color(0xffFF8C00);
      iconBgColor = const Color(0xffFF8C00).withOpacity(0.1);

      dynamic callData = data?["callData"];
      if (callData is String && callData.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(callData);
          if (decoded is Map) {
            callData = decoded;
          }
        } catch (_) {}
      }

      if (callData is Map) {
        profileImage = callData["caller_profile_image"]?.toString() ??
            callData["callerProfileImage"]?.toString() ??
            callData["callerImage"]?.toString() ??
            callData["caller_image"]?.toString() ??
            callData["profile_image"]?.toString() ??
            callData["profileImage"]?.toString() ??
            callData["avatar"]?.toString();
      } else {
        profileImage = data?["caller_profile_image"]?.toString() ??
            data?["callerProfileImage"]?.toString() ??
            data?["callerImage"]?.toString() ??
            data?["caller_image"]?.toString() ??
            data?["groupImage"]?.toString() ??
            data?["group_image"]?.toString() ??
            data?["profile_image"]?.toString() ??
            data?["profileImage"]?.toString() ??
            data?["avatar"]?.toString();
      }
    }

    if (profileImage != null) {
      profileImage = profileImage.trim();
      if (profileImage.isEmpty || profileImage == "null") {
        profileImage = null;
      }
    }

    return GestureDetector(
      onTap: () async { // <-- async banaya
        try {
          if (item.id != null && isUnread) {
            controller.markAsRead(item.id!);

            await Future.delayed(const Duration(milliseconds: 200));
          }

          final notificationData = item.data;

          if (isCallType) {
            // 1. Decode nested callData if it's a Map or JSON String
            Map<String, dynamic> callDataMap = {};
            final rawCallData = notificationData?["callData"];
            if (rawCallData is Map) {
              callDataMap = Map<String, dynamic>.from(rawCallData);
            } else if (rawCallData is String && rawCallData.trim().isNotEmpty) {
              try {
                final decoded = jsonDecode(rawCallData);
                if (decoded is Map) {
                  callDataMap = Map<String, dynamic>.from(decoded);
                }
              } catch (_) {}
            }

            // 2. Extract callId from all possible keys
            String callId = (notificationData?["callId"] ??
                    notificationData?["call_id"] ??
                    notificationData?["callID"] ??
                    callDataMap["callId"] ??
                    callDataMap["call_id"] ??
                    callDataMap["callID"] ??
                    callDataMap["sessionId"] ??
                    callDataMap["session_id"] ??
                    notificationData?["sessionId"] ??
                    notificationData?["session_id"] ??
                    notificationData?["id"] ??
                    callDataMap["id"] ??
                    "")
                .toString()
                .trim();

            if (callId == "null") callId = "";

            // If callId is pure digits, prepend 'call_' to match backend format (call_9700)
            if (callId.isNotEmpty && RegExp(r'^\d+$').hasMatch(callId)) {
              callId = "call_$callId";
            }

            // 3. Determine if this is a group call
            final bool isGroup = itemType.contains("group") ||
                screenName.toLowerCase().contains("group") ||
                notificationData?["isGroup"] == true ||
                notificationData?["isGroup"] == "true" ||
                callDataMap["isGroup"] == true ||
                callDataMap["isGroup"] == "true" ||
                (item.groupId != null && item.groupId != 0) ||
                callDataMap["groupId"] != null;

            final String groupId = (item.groupId ??
                    notificationData?["groupId"] ??
                    notificationData?["group_id"] ??
                    callDataMap["groupId"] ??
                    callDataMap["group_id"] ??
                    "")
                .toString()
                .trim();

            final String groupName = (notificationData?["groupName"] ??
                    notificationData?["group_name"] ??
                    callDataMap["groupName"] ??
                    callDataMap["name"] ??
                    item.title ??
                    "Group")
                .toString()
                .trim();

            final String? groupAvatar =
                notificationData?["groupImage"]?.toString() ??
                    notificationData?["group_image"]?.toString() ??
                    notificationData?["groupAvatar"]?.toString() ??
                    callDataMap["groupImage"]?.toString() ??
                    callDataMap["avatar"]?.toString();

            // 4. Contact data for 1-to-1 call
            final String callerName = (callDataMap["callerName"] ??
                    callDataMap["name"] ??
                    notificationData?["callerName"] ??
                    notificationData?["name"] ??
                    item.title ??
                    "User")
                .toString()
                .trim();

            final String callerPhone = (callDataMap["mobileNo"] ??
                    callDataMap["phone"] ??
                    notificationData?["mobileNo"] ??
                    notificationData?["phone"] ??
                    "")
                .toString()
                .trim();

            final int callerId = int.tryParse(
                  (callDataMap["callerId"] ??
                          notificationData?["callerId"] ??
                          notificationData?["senderId"] ??
                          item.senderId ??
                          "0")
                      .toString(),
                ) ??
                0;

            final String? callerAvatar = profileImage ??
                callDataMap["caller_profile_image"]?.toString() ??
                callDataMap["callerProfileImage"]?.toString() ??
                callDataMap["callerImage"]?.toString() ??
                callDataMap["caller_image"]?.toString() ??
                callDataMap["profile_image"]?.toString() ??
                callDataMap["profileImage"]?.toString() ??
                callDataMap["avatar"]?.toString() ??
                notificationData?["caller_profile_image"]?.toString() ??
                notificationData?["callerProfileImage"]?.toString() ??
                notificationData?["profile_image"]?.toString() ??
                notificationData?["profileImage"]?.toString() ??
                notificationData?["avatar"]?.toString();

            // If callId is present, navigate directly to Call Detail screen
            // which triggers: /getCallDetail?callId=$callId
            if (callId.isNotEmpty) {
              Get.to(
                () => ContactProfileScreen(
                  isGroup: isGroup,
                  groupId: groupId.isNotEmpty ? groupId : null,
                  groupName: isGroup ? groupName : null,
                  groupAvatar: groupAvatar,
                  contactData: isGroup
                      ? null
                      : MemberData(
                          userId: callerId,
                          name: callerName,
                          mobileNo: callerPhone,
                          profileImage: callerAvatar,
                          isOnline: callDataMap["isOnline"] == true ||
                              callDataMap["isOnline"] == "true",
                        ),
                  callId: callId,
                ),
              );
              return;
            }

            // Fallback to Recent Calls list if no callId could be extracted
            if (!Get.isRegistered<CallController>()) {
              Get.put(CallController());
            }

            Get.to(
              () => Scaffold(
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
                          icon: Icon(
                            Icons.arrow_back,
                            color: primaryPurple,
                            size: 24.sp,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Recent Calls",
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
                body: const CallRecentCallsTab(),
              ),
            );
            return;
          }

          if (notificationData == null) {
            return;
          }

          if (notificationData["screen_name"] == "chatScreen") {
            if (notificationData["memberData"] == null) {
              return;
            }

            final memberData = MemberData.fromJson(
              Map<String, dynamic>.from(
                notificationData["memberData"],
              ),
            );
            final int? chatId = int.tryParse(
              (notificationData["chatId"] ??
                  notificationData["conversationId"] ??
                  notificationData["privateChatId"] ??
                  item.chatId ??
                  item.conversationId ??
                  item.privateChatId)
                  ?.toString() ??
                  "",
            );

            memberData.chatId = chatId;

            debugPrint("Notification chatId => $chatId");
            Get.toNamed(
              Routes.chatScreen,
              arguments: {
                "userData": memberData,
                "groupName": "Test",
                "chatId": chatId,
                "type": "chatScreen",
              },
            );
          }
          else if (notificationData["screen_name"] == "groupChatScreen") {
            final groupId = int.tryParse(
              item.groupId?.toString() ?? "",
            );

            if (groupId == null) {
              debugPrint("Invalid groupId => ${item.groupId}");
              return;
            }

            Get.toNamed(
              Routes.groupChatScreen,
              arguments: {
                "groupId": groupId.toString(),
                "groupName": notificationData["groupName"]?.toString() ?? "",
                "groupImage": notificationData["groupImage"]?.toString() ?? "",
              },
            );
          }
        } catch (e) {
          debugPrint("Notification Navigation Error => $e");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
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
                child: profileImage != null && profileImage.isNotEmpty
                    ? Image.network(
                  profileImage.startsWith("http://") ||
                          profileImage.startsWith("https://")
                      ? profileImage
                      : "${ConstRes.aImageBaseUrl.replaceAll(RegExp(r'/+$'), '')}/${profileImage.replaceAll(RegExp(r'^/+'), '')}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      leadingIcon,
                      color: iconColor,
                      size: 22.sp,
                    );
                  },
                )
                    : Icon(
                  leadingIcon,
                  color: iconColor,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    item?.title ?? "Loading notification details",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
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
                      controller.formatTime(
                        item.createdAt ?? "",
                      ),
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

class _NotificationSkeletonList extends StatelessWidget {
  const _NotificationSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 4.h,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, __) {
          return const _NotificationSkeletonCard();
        },
      ),
    );
  }
}

class _NotificationSkeletonCard extends StatelessWidget {
  const _NotificationSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Text(
                  "Loading notification",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Loading notification details",
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Loading notification details",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            "...",
            style: TextStyle(
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}