import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/util/profile_navigation.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Model/CallDetail.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../Model/recent_call.dart';
import '../Controller/contact_profile_controller.dart';

class ContactProfileScreen extends StatefulWidget {
  final MemberData? contactData;
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final String? groupAvatar;
  final String? callId;

  const ContactProfileScreen({
    Key? key,
    this.contactData,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.groupAvatar,
    this.callId,
  }) : super(key: key);

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
  static const Color _purple = Color(0xFF4818F0);
  static const Color _lavender = Color(0xFFF1F0FE);
  static const Color _dark = Color(0xFF1E1B4B);
  static const Color _grey = Color(0xFF8E94A7);

  late final String _tag;
  late final ContactProfileController controller;

  @override
  void initState() {
    super.initState();
    final String base = widget.isGroup
        ? "group_${widget.groupId ?? widget.groupName ?? '0'}"
        : "${widget.contactData?.userId ?? '0'}";
    _tag = "${base}_${widget.callId ?? ''}";

    if (Get.isRegistered<ContactProfileController>(tag: _tag)) {
      Get.delete<ContactProfileController>(tag: _tag, force: true);
    }
    controller = Get.put(
      ContactProfileController(
        contactData: widget.contactData,
        isGroup: widget.isGroup,
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupAvatar: widget.groupAvatar,
        callId: widget.callId,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<ContactProfileController>(tag: _tag)) {
      Get.delete<ContactProfileController>(tag: _tag, force: true);
    }
    super.dispose();
  }


  String? _valid(String? v) {
    final String t = v?.trim() ?? '';
    if (t.isEmpty ||
        t.toLowerCase() == 'unknown' ||
        t.toLowerCase() == 'null') {
      return null;
    }
    return t;
  }

  String? _firstValid(List<String?> values) {
    for (final v in values) {
      final String? t = _valid(v);
      if (t != null) return t;
    }
    return null;
  }

  String _displayName(CallHistoryDetailData? d) {
    if (widget.isGroup) {
      return _firstValid([
        widget.groupName,
        d?.group?.name,
        d?.group?.groupName,
      ]) ?? "Group";
    }
    return _firstValid([
      widget.contactData?.name,
      d?.callerName,
      d?.caller?.name,
      d?.contact?.name,
      d?.receiverName,
      d?.receiver?.name,
    ]) ?? "User";
  }

  String? _displayAvatar(CallHistoryDetailData? d) {
    if (widget.isGroup) {
      return _firstValid([
        widget.groupAvatar,
        d?.group?.avatar,
        d?.group?.groupProfile,
        d?.profileImage,
      ]);
    }
    return _firstValid([
      widget.contactData?.profileImage,
      d?.callerProfileImage,
      d?.profileImage,
      d?.caller?.avatar,
      d?.caller?.profileImage,
      d?.contact?.avatar,
      d?.contact?.profileImage,
      d?.receiverProfileImage,
      d?.receiver?.avatar,
      d?.receiver?.profileImage,
    ]);
  }

  String _displayPhone(CallHistoryDetailData? d) {
    return _firstValid([
      widget.contactData?.mobileNo,
      d?.caller?.phoneNumber,
      d?.contact?.phoneNumber,
      d?.receiver?.phoneNumber,
    ]) ?? '';
  }

  String? _displayEmail(CallHistoryDetailData? d) {
    return _firstValid([
      d?.contact?.email,
      d?.isCaller == true ? d?.receiver?.email : d?.caller?.email,
      d?.caller?.email,
      d?.receiver?.email,
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF7F7FD),
        child: SafeArea(
          top: false,
          child: NotificationListener<ScrollNotification>(
            // Recent calls pagination: load next batch near the bottom
            onNotification: (ScrollNotification n) {
              if (controller.showRecentCalls &&
                  n.metrics.axis == Axis.vertical &&
                  n.metrics.extentAfter < 200.h) {
                controller.loadMoreCalls();
              }
              return false;
            },
            child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                // Header band: full-width lavender block with back button,
                // avatar, name and number
                Container(
                  width: double.infinity,
                  color: const Color(0xFFEFECFE),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    MediaQuery.of(context).padding.top + 8.h,
                    16.w,
                    18.h,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: _softShadow,
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 15.sp, color: _purple),
                          ),
                        ),
                      ),
                      Obx(() => _buildHeader(controller.detail.value)),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [

                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.call_rounded,
                        label: "Audio Call",
                        onTap: () =>
                            controller.startCall(context, isVideo: false),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.videocam_rounded,
                        label: "Video Call",
                        onTap: () =>
                            controller.startCall(context, isVideo: true),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.chat_bubble_rounded,
                        label: "Message",
                        onTap: controller.openMessage,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                if (!controller.isListMode) ...[
                  // 1. Loading Skeleton for Call Details (Single call mode)
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Column(
                        children: [
                          _buildCallDetailsSkeleton(),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 2. Call Details Card (Single Call Mode when call detail is loaded)
                  Obx(() {
                    final d = controller.detail.value;
                    if (d != null) {
                      return Column(
                        children: [
                          _buildCallDetailsCard(d),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 3. Group Summary Card (if group and summary is present)
                  Obx(() {
                    final d = controller.detail.value;
                    if (d != null && (widget.isGroup || d.group != null) && d.summary != null) {
                      return Column(
                        children: [
                          _buildGroupSummaryCard(d),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 4. Participants Card (if participants are present)
                  Obx(() {
                    final participants = controller.participants;
                    if (participants.isNotEmpty) {
                      return Column(
                        children: [
                          _buildParticipantsCard(participants),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],

                // 5. Group Information Card (Contact Information removed
                //    for 1-to-1 contacts)
                Obx(() {
                  final d = controller.detail.value;
                  final bool isGroupInfo = widget.isGroup || (d?.group != null);
                  if (!isGroupInfo) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _buildInfoCard(
                        isGroupInfo,
                        _displayName(d),
                        _displayPhone(d),
                        email: _displayEmail(d),
                        groupCode: d?.group?.groupCode,
                        totalMembers:
                            d?.group?.totalMembers ?? d?.participantsCount,
                        groupDesc: d?.group?.groupDesc,
                      ),
                      SizedBox(height: 14.h),
                    ],
                  );
                }),

                // 6. Recent Calls (every 1-to-1 profile) / error fallback
                if (controller.isListMode)
                  _buildRecentCallsCard(context)
                else ...[
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty &&
                        controller.detail.value == null &&
                        !controller.isLoading.value) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _card(
                            child: _buildError(controller.errorMessage.value)),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  if (controller.showRecentCalls)
                    _buildRecentCallsCard(context),
                ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CallHistoryDetailData? d) {
    final bool isGroup = widget.isGroup || (d?.group != null);
    final String name = _displayName(d);
    final String phone = _displayPhone(d);
    final bool isOnline = widget.contactData?.isOnline == true;

    return Column(
      children: [
        _buildBigAvatar(name, _displayAvatar(d), isGroup),
        SizedBox(height: 10.h),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17.sp,
            fontFamily: FontFamily.interBold,
            color: _dark,
          ),
        ),
        SizedBox(height: 2.h),
        if (isGroup)
          Text(
            "Group",
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: FontFamily.interSemiBold,
              color: _purple,
            ),
          )
        else ...[
          if (phone.isNotEmpty)
            Text(
              phone,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interSemiBold,
                color: _purple,
              ),
            ),
          // SizedBox(height: 3.h),
          // Text(
          //   isOnline ? "Online" : "Offline",
          //   style: TextStyle(
          //     fontSize: 12.sp,
          //     fontFamily: FontFamily.interMedium,
          //     color: isOnline ? const Color(0xFF10B981) : _grey,
          //   ),
          // ),
        ],
      ],
    );
  }


  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _softShadow,
      ),
      child: child,
    );
  }

  Widget _iconCircle(IconData icon, {double size = 40, double iconSize = 18}) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: const BoxDecoration(color: _lavender, shape: BoxShape.circle),
      child: Icon(icon, color: _purple, size: iconSize.sp),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 0.8,
    color: const Color(0xFFF1F3F9),
  );

  Widget _buildBigAvatar(String name, String? raw, bool isGroup) {
    final String url = _buildAvatarUrl(raw);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    Widget fallback() => Center(
          child: isGroup
              ? Icon(Icons.groups_rounded, size: 34.sp, color: _purple)
              : Text(
                  initial,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: FontFamily.interBold,
                    color: _purple,
                  ),
                ),
        );

    // Compact rounded-square avatar with white border (call info header)
    return GestureDetector(
      onTap: url.isEmpty
          ? null
          : () => showFullScreenPhoto(name: name, imageUrl: url),
      child: Container(
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(3.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.r),
        child: Container(
          color: _lavender,
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => fallback(),
                  errorWidget: (_, __, ___) => fallback(),
                )
              : fallback(),
        ),
      ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: _softShadow,
        ),
        child: Column(
          children: [
            _iconCircle(icon, size: 44, iconSize: 20),
            SizedBox(height: 8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontFamily: FontFamily.interSemiBold,
                color: _dark,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCallStatusPill(String status) {
    final String st = status.toLowerCase();
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (st == 'completed' || st == 'accepted' || st == 'answered') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      icon = Icons.check_circle_rounded;
      label = "Completed";
    } else if (st == 'missed') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
      icon = Icons.call_missed_rounded;
      label = "Missed Call";
    } else if (st == 'rejected' || st == 'declined' || st == 'busy') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
      icon = Icons.call_end_rounded;
      label = st == 'busy' ? "Busy" : "Declined";
    } else if (st == 'cancelled' || st == 'canceled') {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
      icon = Icons.cancel_rounded;
      label = "Cancelled";
    } else {
      bg = _lavender;
      fg = _purple;
      icon = Icons.phone_in_talk_rounded;
      label = status.isNotEmpty
          ? status[0].toUpperCase() + status.substring(1)
          : "Call";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: fg),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontFamily: FontFamily.interSemiBold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallDetailsSkeleton() {
    return _card(
      child: Skeletonizer(
        enabled: true,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Call Information",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
            _divider(),
            for (int i = 0; i < 4; i++) ...[
              if (i > 0) _divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Call Detail Label",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(height: 2.h),
                        Text("Call Detail Value Here",
                            style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCallDetailsCard(CallHistoryDetailData d) {
    final bool isVideo =
        d.isVideo == true || (d.type ?? '').toLowerCase() == 'video';
    final bool isIncoming = (d.direction ?? '').toLowerCase() == 'incoming';
    final String callTitle =
        "${isIncoming ? 'Incoming' : 'Outgoing'} ${isVideo ? 'video' : 'audio'} call";
    final IconData callIcon = isVideo
        ? Icons.video_call_rounded
        : (isIncoming
            ? Icons.phone_callback_rounded
            : Icons.phone_forwarded_rounded);

    final String dateLabel = _callDateLabel(d.calledAt ?? d.startTime) ??
        d.formattedDate ??
        d.date ??
        _whenLabel(d.calledAt, d.time);

    DateTime? startDt = _parseCallTime(d.startTime) ?? _parseCallTime(d.calledAt);
    DateTime? endDt = _parseCallTime(d.endTime) ?? _parseCallTime(d.endedAt);
    final int seconds = _callSeconds(d, startDt, endDt);
    // Fill a missing side from the duration
    if (seconds > 0) {
      if (startDt != null && endDt == null) {
        endDt = startDt.add(Duration(seconds: seconds));
      } else if (startDt == null && endDt != null) {
        startDt = endDt.subtract(Duration(seconds: seconds));
      }
    }
    final String? startLabel = startDt != null
        ? _formatAmPm(startDt)
        : (d.time?.trim().isNotEmpty == true ? d.time!.trim() : null);
    final String? endLabel = endDt != null ? _formatAmPm(endDt) : null;
    final bool hasStart = startLabel != null;
    final bool hasEnd = endLabel != null;

    return _card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Call Information",
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: FontFamily.interBold,
                color: _dark,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _lavender,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(callIcon, color: _purple, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interBold,
                          color: _dark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (seconds > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _durationLong(seconds),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.interBold,
                          color: _purple,
                        ),
                      ),
                      Text(
                        "Duration",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (hasStart || hasEnd) ...[
              SizedBox(height: 12.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFECEAF6)),
                ),
                child: Row(
                  children: [
                    _timeColumn(
                      "Started",
                      startLabel ?? "--",
                      CrossAxisAlignment.start,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(child: _durationTimeline(seconds)),
                    SizedBox(width: 8.w),
                    _timeColumn(
                      "Ended",
                      endLabel ?? "--",
                      CrossAxisAlignment.end,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String value, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontFamily: FontFamily.interMedium,
            color: _grey,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interBold,
            color: _dark,
          ),
        ),
      ],
    );
  }

  /// green dot ── [16s] ── red dot
  Widget _durationTimeline(int seconds) {
    Widget dot(Color c) => Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        );
    Widget line() => Expanded(
          child: Container(height: 1.5, color: _purple.withValues(alpha: 0.6)),
        );

    return Row(
      children: [
        dot(const Color(0xFF10B981)),
        line(),
        if (seconds > 0)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              _durationShort(seconds),
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: FontFamily.interSemiBold,
                color: _purple,
              ),
            ),
          ),
        if (seconds > 0) line(),
        dot(const Color(0xFFEF4444)),
      ],
    );
  }

  /// 16 -> "16 sec", 75 -> "1 min 15 sec", 3700 -> "1 hr 1 min"
  String _durationLong(int s) {
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    if (h > 0) return m > 0 ? "$h hr $m min" : "$h hr";
    if (m > 0) return sec > 0 ? "$m min $sec sec" : "$m min";
    return "$sec sec";
  }

  /// 16 -> "16s", 75 -> "1m 15s", 3700 -> "1h 1m"
  String _durationShort(int s) {
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    if (h > 0) return m > 0 ? "${h}h ${m}m" : "${h}h";
    if (m > 0) return sec > 0 ? "${m}m ${sec}s" : "${m}m";
    return "${sec}s";
  }

  /// "Today, 30 Oct 2026" / "Yesterday, 29 Oct 2026" / "28 Oct 2026"
  String? _callDateLabel(String? raw) {
    final dt = DateTime.tryParse(raw?.trim() ?? '')?.toLocal();
    if (dt == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final String date = "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    if (diff == 0) return "Today, $date";
    if (diff == 1) return "Yesterday, $date";
    return date;
  }

  String _formatDetailTimestamp(String raw) {
    final trimmed = raw.trim();
    final dt = _parseCallTime(trimmed);
    if (dt == null) return trimmed;
    return _formatAmPm(dt);
  }

  /// 14:35:31 -> "2:35:31 PM"
  String _formatAmPm(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return "$hour:$min:$sec $ampm";
  }

  /// Parses ISO date-time ("2026-10-30T09:05:31Z") or a plain time
  /// ("14:35:31", "2:35 PM", "02:35:31 pm"). Plain times use today's date.
  DateTime? _parseCallTime(String? raw) {
    final String v = raw?.trim() ?? '';
    if (v.isEmpty || v.toLowerCase() == 'null') return null;

    final DateTime? iso = DateTime.tryParse(v);
    if (iso != null) return iso.toLocal();

    final m = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])?$')
        .firstMatch(v);
    if (m == null) return null;
    int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    final int sec = int.tryParse(m.group(3) ?? '') ?? 0;
    final String? ap = m.group(4)?.toLowerCase();
    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    if (h > 23 || min > 59 || sec > 59) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, min, sec);
  }

  /// Call length in seconds: `duration`, else `formattedDuration`
  /// ("00:16", "1:02:05", "16s", "16 sec"), else ended - started.
  int _callSeconds(CallHistoryDetailData d, DateTime? start, DateTime? end) {
    if ((d.duration ?? 0) > 0) return d.duration!;

    final String f = d.formattedDuration?.trim().toLowerCase() ?? '';
    if (f.isNotEmpty) {
      if (f.contains(':')) {
        final parts = f.split(':').map((p) => int.tryParse(p.trim())).toList();
        if (parts.every((p) => p != null)) {
          int total = 0;
          for (final p in parts) {
            total = total * 60 + p!;
          }
          if (total > 0) return total;
        }
      } else {
        int total = 0;
        for (final m in RegExp(r'(\d+)\s*(h|hr|m|min|s|sec)').allMatches(f)) {
          final int n = int.parse(m.group(1)!);
          final String u = m.group(2)!;
          total += u.startsWith('h') ? n * 3600 : (u.startsWith('m') ? n * 60 : n);
        }
        if (total > 0) return total;
      }
    }

    if (start != null && end != null) {
      final int diff = end.difference(start).inSeconds;
      if (diff > 0 && diff < 24 * 3600) return diff;
    }
    return 0;
  }

  Widget _buildGroupSummaryCard(CallHistoryDetailData d) {
    final s = d.summary;
    final total = s?.totalParticipants ?? d.participantsCount ?? 0;
    final joined = s?.joinedCount ?? d.joinedParticipantsCount ?? 0;
    final missed = s?.missedCount ?? 0;
    final rejected = s?.rejectedCount ?? 0;

    return _card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconCircle(Icons.analytics_rounded),
                SizedBox(width: 12.w),
                Text(
                  "Call Summary",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: FontFamily.interBold,
                    color: _dark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatPill(
                    "Total",
                    "$total",
                    _purple,
                    _lavender,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildStatPill(
                    "Joined",
                    "$joined",
                    const Color(0xFF16A34A),
                    const Color(0xFFDCFCE7),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildStatPill(
                    "Missed",
                    "$missed",
                    const Color(0xFFEF4444),
                    const Color(0xFFFEE2E2),
                  ),
                ),
                if (rejected > 0) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatPill(
                      "Declined",
                      "$rejected",
                      const Color(0xFFEA580C),
                      const Color(0xFFFFEDD5),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(
      String label, String count, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: FontFamily.interBold,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: FontFamily.interMedium,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard(List<CallParticipant> participants) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _iconCircle(Icons.groups_rounded),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "Participants",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      color: _dark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _lavender,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "${participants.length}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interBold,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          for (int i = 0; i < participants.length; i++) ...[
            if (i > 0) _divider(),
            _buildParticipantTile(participants[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantTile(CallParticipant p) {
    final name = p.name?.isNotEmpty == true
        ? p.name!
        : (p.phoneNumber?.isNotEmpty == true ? p.phoneNumber! : "Participant");
    final avatar = p.avatar ?? p.profileImage;
    final status = (p.status ?? '').toLowerCase();
    final bool isCaller = p.isCaller == true || p.role?.toLowerCase() == 'host';
    final dur = p.formattedDuration ??
        (p.duration != null && p.duration! > 0 ? "${p.duration}s" : null);

    Color statusColor = _grey;
    String statusText = p.status ?? '';
    if (status == 'joined' || status == 'completed' || status == 'accepted') {
      statusColor = const Color(0xFF16A34A);
      statusText = "Joined";
    } else if (status == 'missed') {
      statusColor = const Color(0xFFEF4444);
      statusText = "Missed";
    } else if (status == 'declined' || status == 'rejected') {
      statusColor = const Color(0xFFEA580C);
      statusText = "Declined";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          _buildSmallAvatar(name, avatar),
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
                          color: _dark,
                        ),
                      ),
                    ),
                    if (isCaller) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _lavender,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "Caller",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: FontFamily.interBold,
                            color: _purple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  p.phoneNumber?.isNotEmpty == true
                      ? p.phoneNumber!
                      : (dur != null ? "Duration: $dur" : (p.email ?? '')),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ),
          if (statusText.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                dur != null && status == 'joined' ? dur : statusText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: statusColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar(String name, String? raw) {
    final String url = _buildAvatarUrl(raw);
    final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();

    Widget fallback() => Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: FontFamily.interBold,
              color: _purple,
            ),
          ),
        );

    return Container(
      width: 38.w,
      height: 38.w,
      decoration: const BoxDecoration(
        color: _lavender,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback(),
                errorWidget: (_, __, ___) => fallback(),
              )
            : fallback(),
      ),
    );
  }

  Widget _buildInfoCard(
    bool isGroup,
    String displayName,
    String phone, {
    String? email,
    String? groupDesc,
    String? groupCode,
    int? totalMembers,
  }) {
    final List<Widget> rows = [];

    if (isGroup) {
      rows.add(
        _buildInfoItem(
          icon: Icons.groups_rounded,
          title: "Group Name",
          value: displayName,
        ),
      );
      if (groupCode != null && groupCode.isNotEmpty) {
        rows.add(_divider());
        rows.add(
          _buildInfoItem(
            icon: Icons.tag_rounded,
            title: "Group Code",
            value: groupCode,
          ),
        );
      }
      if (totalMembers != null && totalMembers > 0) {
        rows.add(_divider());
        rows.add(
          _buildInfoItem(
            icon: Icons.people_outline_rounded,
            title: "Total Members",
            value: "$totalMembers members",
          ),
        );
      }
      if (groupDesc != null && groupDesc.isNotEmpty) {
        rows.add(_divider());
        rows.add(
          _buildInfoItem(
            icon: Icons.description_outlined,
            title: "Description",
            value: groupDesc,
          ),
        );
      }
    } else {
      if (phone.isNotEmpty) {
        rows.add(
          _buildInfoItem(
            icon: Icons.call_rounded,
            title: "Mobile",
            value: phone,
          ),
        );
      }
      if (email != null && email.isNotEmpty) {
        if (rows.isNotEmpty) rows.add(_divider());
        rows.add(
          _buildInfoItem(
            icon: Icons.email_outlined,
            title: "Email",
            value: email,
          ),
        );
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _iconCircle(
                    isGroup ? Icons.group_outlined : Icons.person_outline_rounded),
                SizedBox(width: 12.w),
                Text(
                  isGroup ? "Group Information" : "Contact Information",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: FontFamily.interBold,
                    color: _dark,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          _iconCircle(icon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                    color: _grey,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: _dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecentCallsCard(BuildContext context) {
    return _card(
      child: Obx(() {
        // Single call mode: the list has its own loader and no error state
        // (the call detail above owns isLoading / errorMessage there).
        final bool showList = controller.showRecentCalls;
        final bool loading = controller.isListMode
            ? controller.isLoading.value
            : controller.isCallsLoading.value;
        final String error =
            controller.isListMode ? controller.errorMessage.value : '';
        final bool listMode = showList;
        final CallHistoryDetailData? d = controller.detail.value;
        final List<CallingDetail> list = controller.calls.toList();

        final bool hasData = !loading &&
            error.isEmpty &&
            (listMode ? list.isNotEmpty : d != null);
        final int count = listMode ? list.length : 1;

        Widget body;
        if (loading) {
          body = _buildSkeletonList();
        } else if (error.isNotEmpty) {
          body = _buildError(error);
        } else if (listMode) {
          body = list.isEmpty
              ? _buildEmptyCalls()
              : Column(
            children: [
              for (int i = 0; i < list.length; i++) ...[
                if (i > 0) _divider(),
                _buildListTile(context, list[i]),
              ],
              _buildLoadMoreFooter(),
            ],
          );
        } else if (d == null) {
          body = _buildError(error);
        } else {
          body = _buildHistoryTile(context, d);
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  _iconCircle(Icons.access_time_rounded),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Recent Calls",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.interBold,
                        color: _dark,
                      ),
                    ),
                  ),
                  if (hasData)
                    Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.interBold,
                        color: _purple,
                      ),
                    ),
                ],
              ),
            ),
            _divider(),
            body,
          ],
        );
      }),
    );
  }

  // Loader while the next batch loads; "Load more" if the list doesn't scroll
  Widget _buildLoadMoreFooter() {
    if (controller.isLoadingMore.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: const CircularProgressIndicator(strokeWidth: 2, color: _purple),
        ),
      );
    }
    if (!controller.hasMore.value) return const SizedBox.shrink();
    return Column(
      children: [
        _divider(),
        InkWell(
          onTap: controller.loadMoreCalls,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Text(
                "Load more",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: _purple,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCalls() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 32.sp, color: _grey),
          SizedBox(height: 8.h),
          Text(
            "No recent calls",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: FontFamily.interMedium,
              color: _grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 32.sp, color: _grey),
          SizedBox(height: 8.h),
          Text(
            message.isNotEmpty ? message : "Failed to load call detail",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: FontFamily.interMedium,
              color: _grey,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: controller.fetchDetail,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) _divider(),
            _buildSkeletonTile(),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonTile() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Outgoing Video Call",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Today, 10:24 AM",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, CallHistoryDetailData call) {
    final bool isVideo =
        call.isVideo == true || (call.type ?? '').toLowerCase() == 'video';
    return _buildCallTile(
      context,
      status: call.status,
      isVideo: isVideo,
      direction: call.direction,
      subtitleBase: _whenLabel(call.calledAt, call.time),
      duration: call.formattedDuration,
    );
  }

  Widget _buildListTile(BuildContext context, CallingDetail call) {
    final String type = (call.type ?? '').toLowerCase();
    return _buildCallTile(
      context,
      status: call.status,
      isVideo: type.contains('video'),
      direction: call.direction,
      subtitleBase:
      _whenLabel(call.calledAt, call.time ?? call.displayTime),
      duration: call.duration,
    );
  }

  Widget _buildCallTile(
      BuildContext context, {
        required String? status,
        required bool isVideo,
        required String? direction,
        required String subtitleBase,
        String? duration,
      }) {
    final String st = (status ?? '').toLowerCase();
    final bool isIncoming = (direction ?? '').toLowerCase() == 'incoming';

    final bool isMissed = st == 'missed';
    final bool isRejected =
        st == 'rejected' || st == 'declined' || st == 'busy';
    final bool isCancelled = st == 'cancelled' || st == 'canceled';

    final String mediaLabel = isVideo ? "Video Call" : "Audio Call";
    String title;
    IconData icon;
    Color iconColor;
    Color titleColor = _dark;

    if (isMissed) {
      title = "Missed $mediaLabel";
      icon = isIncoming
          ? Icons.call_missed_rounded
          : Icons.call_missed_outgoing_rounded;
      iconColor = const Color(0xFFEF4444);
      titleColor = iconColor;
    } else if (isRejected) {
      title = "Rejected $mediaLabel";
      icon = Icons.call_end_rounded;
      iconColor = const Color(0xFF9CA3AF);
    } else if (isCancelled) {
      title = "Cancelled $mediaLabel";
      icon = Icons.call_end_rounded;
      iconColor = const Color(0xFF9CA3AF);
    } else if (isIncoming) {
      title = "Incoming $mediaLabel";
      icon = Icons.call_received_rounded;
      iconColor = const Color(0xFF3B82F6);
    } else {
      title = "Outgoing $mediaLabel";
      icon = Icons.call_made_rounded;
      iconColor = const Color(0xFF10B981);
    }

    String subtitle = subtitleBase;
    final String dur = duration?.trim() ?? '';
    if (st == 'completed' && dur.isNotEmpty && dur != '00:00' && dur != '0') {
      subtitle = "$subtitle  •  $dur";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        size: 13.sp, color: _grey),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.startCall(context, isVideo: isVideo),
            child: _iconCircle(
              isVideo ? Icons.videocam_rounded : Icons.call_rounded,
              size: 38,
              iconSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  String _buildAvatarUrl(String? raw) {
    if (raw == null) return '';
    String v = raw.trim();
    if (v.isEmpty ||
        v.toLowerCase() == 'null' ||
        v.toLowerCase() == 'undefined' ||
        v.toLowerCase() == 'unknown') {
      return '';
    }
    v = v.replaceAll('\\', '/');
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return v.replaceAll(' ', '%20');
    }
    final baseUrl = ConstRes.aImageBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = v.replaceAll(RegExp(r'^/+'), '');
    return '$baseUrl/$cleanPath'.replaceAll(' ', '%20');
  }

  String _whenLabel(String? calledAt, String? timeRaw) {
    final String time = timeRaw ?? '';
    final DateTime? dt = DateTime.tryParse(calledAt ?? '')?.toLocal();
    if (dt == null) return time;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final DateTime now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    if (sameDay(dt, now)) return time;
    if (sameDay(dt, now.subtract(const Duration(days: 1)))) {
      return "Yesterday, $time";
    }
    return "${dt.day} ${months[dt.month - 1]}, $time";
  }
}