import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
      final List<Map<String, String>> calls = controller.filteredRecentCalls;
      return RefreshIndicator(
        color: const Color(0xFF4818F0),
        onRefresh: controller.refreshRecentCalls,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
          child: Column(
            children: [
              if (controller.recentCallList.isNotEmpty) ...[
                const _CallFilterBar(),
                SizedBox(height: 7.h),
              ],
              if (controller.recentCallList.isEmpty)
                const _EmptyState(message: "No recent calls yet")
              else if (calls.isEmpty)
                const _EmptyState(message: "No recent calls found")
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: calls.length,
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: InkWell(
                            child: _RecentCallTile(
                          call: calls[index],
                          onCallTap: (type) {
                            if (type == "video") {
                              CallService().startCall(
                                context,
                                callerId: Global.storageServices
                                    .get(PrefConst.userId)
                                    .toString(),
                                remoteUserId:
                                    calls[index]['callerId'].toString(),
                                is_video: true,
                                callerName: calls[index]['name'].toString(),
                              );
                            } else {
                              CallService().startCall(
                                context,
                                callerId: Global.storageServices
                                    .get(PrefConst.userId)
                                    .toString(),
                                remoteUserId:
                                    calls[index]['callerId'].toString(),
                                is_video: false,
                                callerName: calls[index]['name'].toString(),
                              );
                            }
                          },
                        )),
                      );
                    },
                  ),
                ),
              if (controller.recentCallLoadingMore.value)
                const _BottomSkeletonLoader(),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      );
    });
  }
}

class _CallFilterBar extends StatelessWidget {
  const _CallFilterBar();

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.find<CallController>();
    return Obx(() {
      final String selected = controller.recentCallFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterPill(
              label: "All",
              selected: selected == 'All',
              onTap: () => controller.setRecentCallFilter('All'),
            ),
            SizedBox(width: 10.w),
            _FilterPill(
              label: "Missed",
              selected: selected == 'Missed',
              onTap: () => controller.setRecentCallFilter('Missed'),
            ),
            SizedBox(width: 10.w),
            _FilterPill(
              label: "Outgoing",
              selected: selected == 'Outgoing',
              onTap: () => controller.setRecentCallFilter('Outgoing'),
            ),
            SizedBox(width: 10.w),
            _FilterPill(
              label: "Incoming",
              selected: selected == 'Incoming',
              onTap: () => controller.setRecentCallFilter('Incoming'),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECEAFD) : const Color(0xFFF3F4F7),
          borderRadius: BorderRadius.circular(19.r),
        ),
        child: reausabletext(
          label,
          fontsize: 13.sp,
          fontfamily:
              selected ? FontFamily.interSemiBold : FontFamily.interRegular,
          color: selected ? const Color(0xFF6B4DFF) : Colors.black87,
        ),
      ),
    );
  }
}

class _RecentCallTile extends StatelessWidget {
  _RecentCallTile({required this.call, required this.onCallTap});

  final Map<String, String> call;
  void Function(dynamic) onCallTap;

  @override
  Widget build(BuildContext context) {
    final String type = call['type'] ?? '';
    final String callType = call['callType'] ?? '';
    final bool missed = type.contains('Missed');
    final bool incoming = type.contains('Incoming');
    final bool cancelled = type.contains('Cancelled');
    final Color accent = missed
        ? const Color(0xFFE53935)
        : incoming
            ? const Color(0xFF43A047)
            : cancelled
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF6B4DFF);
    final IconData statusIcon = missed
        ? Icons.call_missed_rounded
        : cancelled
            ? Icons.call_end_rounded
            : incoming
                ? Icons.call_received_rounded
                : Icons.call_made_rounded;

    final String name = call['name'] ?? '';
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(
              Utility.isNullEmptyOrFalse(call['avatar'])
                  ? MyAppTheme.notFoundImg
                  : ConstRes.aImageBaseUrl + call['avatar']!),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    statusIcon,
                    size: 11.sp,
                    color: accent,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: reausabletext(type,
                        fontsize: 9.sp,
                        color: accent,
                        fontfamily: FontFamily.interMedium),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        reausabletext(call['time'] ?? '',
            fontsize: 9.sp,
            color: Color(0xFF6B4DFF),
            fontfamily: FontFamily.interMedium),
        SizedBox(width: 10.w),
        CallActionChip(
          icon: callType == "video" ? Icons.videocam_rounded : Icons.call,
          onTap: () {
            onCallTap(callType);
          },
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
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 120.h),
        children: [
          reausabletext(
            "Recent Calls",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          SizedBox(height: 4.h),
          for (int i = 0; i < 8; i++) ...[
            const _RecentSkeletonTile(),
            SizedBox(height: 14.h),
          ],
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
      child: Column(
        children: [
          for (int i = 0; i < 2; i++) ...[
            const _RecentSkeletonTile(),
            SizedBox(height: 14.h),
          ],
        ],
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
        CircleAvatar(radius: 22.r, backgroundColor: Colors.grey.shade200),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(
                "Loading contact",
                fontsize: 14.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
              ),
              SizedBox(height: 3.h),
              reausabletext(
                "Outgoing Video Call",
                fontsize: 11.sp,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        reausabletext(
          "Today, 10:24 AM",
          fontsize: 11.sp,
          color: Colors.black45,
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Color(0xFFECEAFD),
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
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: reausabletext(
          message,
          fontsize: 14.sp,
          color: Colors.grey,
        ),
      ),
    );
  }
}
