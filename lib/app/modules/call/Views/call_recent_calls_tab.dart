import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Model/MemberDataRes.dart';
import '../../mediaStream/Views/contact_profile_screen.dart';

class CallRecentCallsTab extends StatefulWidget {
  const CallRecentCallsTab({super.key});

  @override
  State<CallRecentCallsTab> createState() => _CallRecentCallsTabState();
}

class _CallRecentCallsTabState extends State<CallRecentCallsTab> {
  final CallController controller = Get.find<CallController>();
  final ScrollController _scrollController = ScrollController();
  final _SwipeActionCoordinator _swipeCoordinator = _SwipeActionCoordinator();

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
    if (position > 50 && (maxExtent - position < 350.h)) {
      controller.loadMoreRecentCalls();
    }
  }

  /// Row tap + DP tap: seedha profile screen, API screen ke andar hit hoti hai.
  void _openProfile(Map<String, String> call) {
    final String callId = (call['callId'] ?? call['id'] ?? '').trim();
    final bool isGroup = call['isGroup'] == 'true';

    if (isGroup) {
      final String gId = (call['groupId']?.isNotEmpty == true)
          ? call['groupId']!
          : (call['callerId'] ?? '');

      Get.to(
            () => ContactProfileScreen(
          isGroup: true,
          groupId: gId,
          groupName: call['name'] ?? "Group",
          groupAvatar: call['avatar'],
          callId: callId,
        ),
      );
    } else {
      final String phone = (call['mobileNo']?.isNotEmpty == true)
          ? call['mobileNo']!
          : (call['phone'] ?? '');

      Get.to(
            () => ContactProfileScreen(
          isGroup: false,
          contactData: MemberData(
            userId: int.tryParse(call['callerId'] ?? '0'),
            name: call['name'],
            mobileNo: phone,
            profileImage: call['avatar'],
            isOnline: call['isOnline'] == 'true',
          ),
          callId: callId,
        ),
      );
    }
  }

  void _showDeleteConfirmationBottomSheet(Map<String, String> call) {
    final String callId = (call['callId'] ?? call['id'] ?? '').trim();
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade600,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Delete Call History",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "Are you sure you want to delete this call history?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interRegular,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessing
                                ? null
                                : () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: FontFamily.interSemiBold,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isProcessing ||
                                    controller.isDeletingCall(callId))
                                ? null
                                : () async {
                                    setModalState(() {
                                      isProcessing = true;
                                    });
                                    final bool success = await controller
                                        .deleteRecentCall(call);
                                    if (sheetContext.mounted) {
                                      if (success) {
                                        Navigator.pop(sheetContext);
                                      } else {
                                        setModalState(() {
                                          isProcessing = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              elevation: 0,
                              backgroundColor: Colors.red.shade600,
                              disabledBackgroundColor: Colors.red.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: isProcessing
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Yes, Delete",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: FontFamily.interSemiBold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(Map<String, String> call) {
    _showDeleteConfirmationBottomSheet(call);
  }

  void _showDeleteSelectedConfirmationDialog() {
    final int count = controller.selectedCallIds.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Obx(() {
          final bool isProcessing = controller.isDeletingMultiple.value;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: Colors.white,
            title: Text(
              "Delete Selected Calls",
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFF1E1B4B),
              ),
            ),
            content: Text(
              count == 1
                  ? "Are you sure you want to delete this selected call history?"
                  : "Are you sure you want to delete these $count selected call history entries?",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interRegular,
                color: const Color(0xFF4B5563),
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                              Navigator.pop(dialogContext);
                            },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interMedium,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              final success =
                                  await controller.deleteSelectedRecentCalls();
                              if (dialogContext.mounted && success) {
                                Navigator.pop(dialogContext);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        backgroundColor: Colors.red.shade600,
                        disabledBackgroundColor: Colors.red.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isProcessing
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.interSemiBold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildFixedBottomClearButton(bool isDialOpen) {
    final bool isSelectionMode = controller.isSelectionMode.value;
    final int selectedCount = controller.selectedCallIds.length;

    if (!isSelectionMode || selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: isDialOpen ? 390.h : 20.h,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isDeletingMultiple.value
                ? null
                : _showDeleteSelectedConfirmationDialog,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
              backgroundColor: Colors.red.shade600,
              disabledBackgroundColor: Colors.red.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: controller.isDeletingMultiple.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        selectedCount > 1
                            ? "Delete ($selectedCount)"
                            : "Delete",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
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

      final bool isDialOpen = controller.isDialPadOpen.value;
      final bool isSelectionMode = controller.isSelectionMode.value;
      final bool hasSelectedCalls = controller.selectedCallIds.isNotEmpty;

      if (controller.recentCallList.isEmpty || groupedCalls.isEmpty) {
        return RefreshIndicator(
          color: const Color(0xFF4818F0),
          onRefresh: controller.refreshRecentCalls,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: isDialOpen ? 390.h : 90.h),
            children: [
              _EmptyState(
                isDialOpen: isDialOpen,
                message: controller.searchQuery.value.isNotEmpty
                    ? "No recent calls match your search"
                    : "No recent calls yet",
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF4818F0),
            onRefresh: controller.refreshRecentCalls,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _swipeCoordinator.closeAll();
                } else if (notification is ScrollUpdateNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels > 50 &&
                      (metrics.maxScrollExtent - metrics.pixels < 350.h)) {
                    controller.loadMoreRecentCalls();
                  }
                }
                return false;
              },
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  4.h,
                  16.w,
                  (isSelectionMode && hasSelectedCalls)
                      ? (isDialOpen ? 430.h : 90.h)
                      : (isDialOpen ? 390.h : 90.h),
                ),
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
                            Builder(
                              builder: (context) {
                                final callItem = entry.value[i];
                                final String callId =
                                    (callItem['callId'] ?? callItem['id'] ?? '')
                                        .trim();
                                final bool isSelected =
                                    controller.selectedCallIds.contains(callId);

                                return _SwipeableRecentCallItem(
                                  key: ValueKey(
                                    callItem['localEntryId'] ??
                                        callItem['callId'] ??
                                        '${entry.key}_$i',
                                  ),
                                  itemId: callItem['localEntryId'] ??
                                      callItem['callId'] ??
                                      '${entry.key}_$i',
                                  coordinator: _swipeCoordinator,
                                  call: callItem,
                                  isSelectionMode: isSelectionMode,
                                  isSelected: isSelected,
                                  borderRadius: BorderRadius.vertical(
                                    top: i == 0
                                        ? Radius.circular(20.r)
                                        : Radius.zero,
                                    bottom: i == entry.value.length - 1
                                        ? Radius.circular(20.r)
                                        : Radius.zero,
                                  ),
                                  onTap: isSelectionMode
                                      ? () => controller.toggleCallSelection(callId)
                                      : () => _openProfile(callItem),
                                  onLongPress: isSelectionMode
                                      ? () => controller.toggleCallSelection(callId)
                                      : () => _showDeleteDialog(callItem),
                                  onDeleteTap: () =>
                                      _showDeleteConfirmationBottomSheet(callItem),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
                                    child: _RecentCallTile(
                                      call: callItem,
                                      isSelectionMode: isSelectionMode,
                                      isSelected: isSelected,
                                      onAvatarTap: isSelectionMode
                                          ? () => controller.toggleCallSelection(callId)
                                          : () => _openProfile(callItem),
                                      onCallTap: (type) {
                                        if (isSelectionMode) {
                                          controller.toggleCallSelection(callId);
                                          return;
                                        }
                                        final isGroup =
                                            callItem['isGroup'] == 'true';
                                        final bool isVideo = type == "video";

                                        if (isGroup) {
                                          final gId = callItem['groupId'] ??
                                              callItem['callerId'] ??
                                              '';
                                          GroupCallService.instance.startGroupCall(
                                            context,
                                            groupId: gId,
                                            groupName:
                                                callItem['name'] ?? "Group Call",
                                            groupProfile: callItem['avatar'],
                                            isVideo: isVideo,
                                            memberCount: int.tryParse(callItem[
                                                        'memberCount'] ??
                                                    '0') ??
                                                0,
                                          );
                                        } else {
                                          final remoteId = callItem['callerId']
                                                  ?.toString() ??
                                              '';
                                          final String phone =
                                              callItem['mobileNo'] ??
                                                  callItem['phone'] ??
                                                  '';

                                          if (!CallValidation.validateCall(
                                            destinationPhone: phone,
                                            destinationUserId: remoteId,
                                          )) {
                                            return;
                                          }

                                          final callerName =
                                              callItem['name']?.toString() ??
                                                  'User';

                                          final profileImage =
                                              callItem['avatar']?.toString() ??
                                                  'User';

                                          if (remoteId.isNotEmpty &&
                                              remoteId !=
                                                  Global.storageServices
                                                      .get(PrefConst.userId)
                                                      ?.toString()) {
                                            CallService().startOutGoingCall(
                                              context,
                                              callerId: Global.storageServices
                                                  .get(PrefConst.userId)
                                                  .toString(),
                                              remoteUserId: remoteId,
                                              is_video: isVideo,
                                              callerName: callerName,
                                              callerProfile: profileImage,
                                            );
                                          } else {
                                            if (phone.isNotEmpty) {
                                              controller.dialNumber.value = phone;
                                              controller.makeCall(isVideo: isVideo);
                                            } else {
                                              Utils().fluttertoast(
                                                  "Unable to call this contact");
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
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
            ),
          ),
          _buildFixedBottomClearButton(isDialOpen),
        ],
      );
    });
  }
}

class _RecentCallTile extends StatelessWidget {
  const _RecentCallTile({
    required this.call,
    required this.onCallTap,
    required this.onAvatarTap,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  final Map<String, String> call;
  final void Function(dynamic) onCallTap;
  final VoidCallback onAvatarTap;
  final bool isSelectionMode;
  final bool isSelected;

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
        if (isSelectionMode) ...[
          Container(
            width: 22.w,
            height: 22.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF4818F0) : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4818F0)
                    : const Color(0xFFCBD5E1),
                width: 1.8,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  )
                : null,
          ),
        ],
        GestureDetector(
          onTap: onAvatarTap,
          behavior: HitTestBehavior.opaque,
          child: _buildAvatar(name, avatar, isOnline, isGroup: isGroup),
        ),
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

    final String profile = raw.trim();

    if (profile.toLowerCase() == 'null') return '';

    if (profile.startsWith('http://') || profile.startsWith('https://')) {
      return profile;
    }

    return '${ConstRes.aImageBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/${profile.replaceFirst(RegExp(r'^/+'), '')}';
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
  const _EmptyState({required this.message, this.isDialOpen = false});

  final String message;
  final bool isDialOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: isDialOpen ? 15.h : 60.h),
        Center(
          child: Image.asset(
            Assets.images.notFount.path,
            width: isDialOpen ? 140.w : 240.w,
            height: isDialOpen ? 140.w : 240.w,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeActionCoordinator {
  String? _openedId;
  final Set<void Function(String?)> _listeners = {};

  String? get openedId => _openedId;

  void addListener(void Function(String?) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(String?) listener) {
    _listeners.remove(listener);
  }

  void onStartSwipe(String id) {
    if (_openedId != null && _openedId != id) {
      _openedId = null;
      _notify(null);
    }
  }

  void setOpened(String? id) {
    if (_openedId != id) {
      _openedId = id;
      _notify(id);
    }
  }

  void closeAll() {
    if (_openedId != null) {
      _openedId = null;
      _notify(null);
    }
  }

  void _notify(String? id) {
    for (final listener in List.of(_listeners)) {
      listener(id);
    }
  }
}

class _SwipeableRecentCallItem extends StatefulWidget {
  final String itemId;
  final _SwipeActionCoordinator coordinator;
  final Map<String, String> call;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDeleteTap;
  final Widget child;
  final bool isSelectionMode;
  final bool isSelected;

  const _SwipeableRecentCallItem({
    super.key,
    required this.itemId,
    required this.coordinator,
    required this.call,
    required this.borderRadius,
    required this.onTap,
    required this.onLongPress,
    required this.onDeleteTap,
    required this.child,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  State<_SwipeableRecentCallItem> createState() =>
      _SwipeableRecentCallItemState();
}

class _SwipeableRecentCallItemState extends State<_SwipeableRecentCallItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  static const double _maxReveal = 84.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    widget.coordinator.addListener(_onCoordinatorUpdate);
  }

  void _onCoordinatorUpdate(String? openId) {
    if (!mounted) return;
    if (openId != widget.itemId && _animController.value > 0) {
      _animController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant _SwipeableRecentCallItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinator != widget.coordinator) {
      oldWidget.coordinator.removeListener(_onCoordinatorUpdate);
      widget.coordinator.addListener(_onCoordinatorUpdate);
    }
    if (oldWidget.itemId != widget.itemId) {
      _animController.value = 0.0;
    }
    if (widget.isSelectionMode && _animController.value > 0) {
      _animController.value = 0.0;
    }
  }

  @override
  void dispose() {
    widget.coordinator.removeListener(_onCoordinatorUpdate);
    if (widget.coordinator.openedId == widget.itemId) {
      widget.coordinator.setOpened(null);
    }
    _animController.dispose();
    super.dispose();
  }

  void _close() {
    if (widget.coordinator.openedId == widget.itemId) {
      widget.coordinator.setOpened(null);
    }
    _animController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  void _open() {
    widget.coordinator.setOpened(widget.itemId);
    _animController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final double currentOffset = _animController.value * _maxReveal;
        final bool isRevealed = _animController.value > 0.05;

        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              // Background: revealed Delete action on the right (revealed by left-swipe)
              Positioned.fill(
                child: Container(
                  color: Colors.red.shade600,
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _close();
                        widget.onDeleteTap();
                      },
                      child: SizedBox(
                        width: _maxReveal.w,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: FontFamily.interSemiBold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Foreground: normal call item translating left
              Transform.translate(
                offset: Offset(-currentOffset.w, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    if (widget.isSelectionMode) return;
                    if (details.primaryDelta == null) return;
                    final double delta = -details.primaryDelta! / _maxReveal;
                    if (delta > 0 && _animController.value == 0) {
                      widget.coordinator.onStartSwipe(widget.itemId);
                    }
                    _animController.value =
                        (_animController.value + delta).clamp(0.0, 1.0);
                  },
                  onHorizontalDragEnd: (details) {
                    if (widget.isSelectionMode) return;
                    final double velocity = details.primaryVelocity ?? 0;
                    if (velocity < -300) {
                      _open();
                    } else if (velocity > 300) {
                      _close();
                    } else if (_animController.value > 0.4) {
                      _open();
                    } else {
                      _close();
                    }
                  },
                  child: Stack(
                    children: [
                      Material(
                        color: widget.isSelected
                            ? const Color(0xFFF3F0FF)
                            : Colors.white,
                        child: InkWell(
                          onTap: () {
                            if (widget.isSelectionMode) {
                              widget.onTap();
                              return;
                            }
                            if (widget.coordinator.openedId != null) {
                              widget.coordinator.closeAll();
                              return;
                            }
                            if (isRevealed) {
                              _close();
                            } else {
                              widget.onTap();
                            }
                          },
                          onLongPress: widget.onLongPress,
                          child: widget.child,
                        ),
                      ),
                      if (isRevealed)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _close,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}