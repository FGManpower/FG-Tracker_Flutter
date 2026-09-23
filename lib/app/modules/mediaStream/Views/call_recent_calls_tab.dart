import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'contact_profile_screen.dart';

class CallRecentCallsTab extends StatefulWidget {
  const CallRecentCallsTab({super.key});

  @override
  State<CallRecentCallsTab> createState() => _CallRecentCallsTabState();
}

class _CallRecentCallsTabState extends State<CallRecentCallsTab> {
  final CallController controller = Get.find<CallController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (controller.recentCallList.isEmpty &&
        !controller.recentCallLoading.value) {
      controller.getRecentCall();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double position = _scrollController.position.pixels;
    final double maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent - position < 300.h) {
      controller.loadMoreRecentCalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentCallLoading.value &&
          controller.recentCallList.isEmpty) {
        return const _RecentSkeletonList();
      }
      if (controller.recentCallResponseError.value.isNotEmpty &&
          controller.recentCallList.isEmpty) {
        return LostinternetConnection(
          retry: controller.refreshRecentCalls,
          messgae: controller.recentCallResponseError.value,
        );
      }

      final Map<String, List<Map<String, String>>> groupedCalls =
          controller.groupedRecentCalls;

      if (controller.recentCallList.isEmpty) {
        return RefreshIndicator(
          color: const Color(0xFF4818F0),
          onRefresh: controller.refreshRecentCalls,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              _EmptyState(message: "No recent calls yet"),
            ],
          ),
        );
      }

      if (groupedCalls.isEmpty) {
        return RefreshIndicator(
          color: const Color(0xFF4818F0),
          onRefresh: controller.refreshRecentCalls,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              _EmptyState(message: "No recent calls found"),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF4818F0),
        onRefresh: controller.refreshRecentCalls,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
          children: [
            for (final entry in groupedCalls.entries) ...[
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 8.h, left: 2.w),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < entry.value.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: const Color(0xFFF1F3F9),
                          indent: 62.w,
                          endIndent: 14.w,
                        ),
                      InkWell(
                        onTap: () {
                          final isGroup = entry.value[i]['isGroup'] == 'true';
                          if (isGroup) {
                            final gId = entry.value[i]['groupId'] ??
                                entry.value[i]['callerId'];
                            if (gId != null && gId.isNotEmpty) {
                              Get.toNamed(
                                Routes.groupChatScreen,
                                arguments: {
                                  "groupId": gId,
                                  "groupName":
                                      entry.value[i]['name'] ?? "Group",
                                  "groupProfile": entry.value[i]['avatar'],
                                },
                              );
                            }
                          } else {
                            Get.to(() => ContactProfileScreen(
                                  contactData: entry.value[i],
                                ));
                          }
                        },
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? Radius.circular(20.r) : Radius.zero,
                          bottom: i == entry.value.length - 1
                              ? Radius.circular(20.r)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          child: _RecentCallTile(
                            call: entry.value[i],
                            onCallTap: (type) {
                              final isGroup =
                                  entry.value[i]['isGroup'] == 'true';
                              final bool isVideo = type == "video";

                              if (isGroup) {
                                final gId = entry.value[i]['groupId'] ??
                                    entry.value[i]['callerId'] ??
                                    '';
                                GroupCallService.instance.startGroupCall(
                                  context,
                                  groupId: gId,
                                  groupName:
                                      entry.value[i]['name'] ?? "Group Call",
                                  groupProfile: entry.value[i]['avatar'],
                                  isVideo: isVideo,
                                  memberCount: int.tryParse(entry.value[i]
                                              ['memberCount'] ??
                                          '0') ??
                                      0,
                                );
                              } else {
                                if (isVideo) {
                                  CallService().startCall(
                                    context,
                                    callerId: Global.storageServices
                                        .get(PrefConst.userId)
                                        .toString(),
                                    remoteUserId:
                                        entry.value[i]['callerId'].toString(),
                                    is_video: true,
                                    callerName:
                                        entry.value[i]['name'].toString(),
                                  );
                                } else {
                                  CallService().startCall(
                                    context,
                                    callerId: Global.storageServices
                                        .get(PrefConst.userId)
                                        .toString(),
                                    remoteUserId:
                                        entry.value[i]['callerId'].toString(),
                                    is_video: false,
                                    callerName:
                                        entry.value[i]['name'].toString(),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 6.h),
            ],
            if (controller.recentCallLoadingMore.value) ...[
              SizedBox(height: 12.h),
              const _BottomSkeletonLoader(),
            ],
          ],
        ),
      );
    });
  }
}

class _RecentCallTile extends StatelessWidget {
  const _RecentCallTile({
    required this.call,
    required this.onCallTap,
  });

  final Map<String, String> call;
  final void Function(dynamic) onCallTap;

  @override
  Widget build(BuildContext context) {
    final String type = call['type'] ?? '';
    final String callType = call['callType'] ?? '';
    final bool missed = type.toLowerCase().contains('missed');
    final bool incoming = type.toLowerCase().contains('incoming');
    final bool cancelled = type.toLowerCase().contains('cancelled') ||
        type.toLowerCase().contains('reject');

    final Color statusColor = missed
        ? const Color(0xFFEF4444)
        : incoming
            ? const Color(0xFF3B82F6)
            : cancelled
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF10B981);

    final IconData statusIcon = missed
        ? Icons.south_west_rounded
        : cancelled
            ? Icons.call_end_rounded
            : incoming
                ? Icons.south_west_rounded
                : Icons.arrow_outward_rounded;

    final String name = call['name'] ?? '';
    final String? avatar = call['avatar'];
    final bool isOnline = (call['isOnline'] ?? '').toLowerCase() == 'true';
    final bool isGroup = (call['isGroup'] ?? '').toLowerCase() == 'true';

    return Row(
      children: [
        _buildAvatar(name, avatar, isOnline, isGroup: isGroup),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.interSemiBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  if (isGroup) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEAFD),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "Group",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: const Color(0xFF4818F0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    statusIcon,
                    size: 13.sp,
                    color: statusColor,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _formatDisplayTime(call['time'] ?? ''),
          style: TextStyle(
            fontSize: 10.5.sp,
            color: const Color(0xFF6B4DFF),
            fontFamily: FontFamily.interMedium,
          ),
        ),
        SizedBox(width: 10.w),
        CallActionChip(
          icon:
              callType == "video" ? Icons.videocam_rounded : Icons.call_rounded,
          onTap: () {
            onCallTap(callType);
          },
        ),
      ],
    );
  }

  String _formatDisplayTime(String raw) {
    final String trimmed = raw.trim();
    final String cleaned = trimmed
        .replaceAll(
            RegExp(r'^(today|yesterday),?\s*', caseSensitive: false), '')
        .trim();
    return cleaned.isNotEmpty ? cleaned : trimmed;
  }

  String _buildAvatarUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    raw = raw.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) raw = raw.substring(1);
    return '${ConstRes.aImageBaseUrl}$raw';
  }

  Widget _buildAvatar(
    String name,
    String? avatar,
    bool isOnline, {
    bool isGroup = false,
  }) {
    final String avatarUrl = _buildAvatarUrl(avatar);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    Widget placeholderOrFallback() {
      if (isGroup) {
        return Center(
          child: Icon(
            Icons.groups_rounded,
            size: 20.sp,
            color: const Color(0xFF4818F0),
          ),
        );
      }
      return Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interBold,
            color: const Color(0xFF4818F0),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Container(
            width: 42.w,
            height: 42.w,
            color: const Color(0xFFECEAFD),
            child: avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => placeholderOrFallback(),
                    errorWidget: (context, url, error) =>
                        placeholderOrFallback(),
                  )
                : placeholderOrFallback(),
          ),
        ),
        if (isOnline && !isGroup)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 8.5.w,
              height: 8.5.w,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5.w),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentSkeletonList extends StatelessWidget {
  const _RecentSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 8.h, left: 2.w),
            child: Text(
              "Today",
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFF1E1B4B),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  const _RecentSkeletonTile(),
                  if (i < 4) SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSkeletonLoader extends StatelessWidget {
  const _BottomSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            for (int i = 0; i < 2; i++) ...[
              const _RecentSkeletonTile(),
              if (i < 1) SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSkeletonTile extends StatelessWidget {
  const _RecentSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 21.r, backgroundColor: Colors.grey.shade200),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Loading contact",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interSemiBold,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Outgoing Video Call",
                style: TextStyle(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          "Today, 10:24 AM",
          style: TextStyle(fontSize: 10.5.sp),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 38.w,
          height: 38.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F0FE),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
            fontFamily: FontFamily.interRegular,
          ),
        ),
      ),
    );
  }
}
