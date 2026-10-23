import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
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
    Get.delete<ContactProfileController>(tag: _tag);
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
      return _firstValid([widget.groupName, d?.group?.name]) ?? "Group";
    }
    return _firstValid([
      widget.contactData?.name,
      d?.contact?.name,
      d?.isCaller == true ? d?.receiver?.name : d?.caller?.name,
    ]) ??
        "User";
  }

  String? _displayAvatar(CallHistoryDetailData? d) {
    if (widget.isGroup) {
      return _firstValid([widget.groupAvatar, d?.group?.avatar]);
    }
    return _firstValid([
      widget.contactData?.profileImage,
      d?.contact?.avatar,
      d?.isCaller == true ? d?.receiver?.avatar : d?.caller?.avatar,
    ]);
  }

  String _displayPhone(CallHistoryDetailData? d) {
    return _firstValid([
      widget.contactData?.mobileNo,
      d?.contact?.phoneNumber,
      d?.isCaller == true
          ? d?.receiver?.phoneNumber
          : d?.caller?.phoneNumber,
    ]) ??
        '';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAE6FF), Color(0xFFF7F7FD)],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: _softShadow,
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 17.sp, color: _purple),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                Obx(() => _buildHeader(controller.detail.value)),
                SizedBox(height: 18.h),

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

                Obx(() {
                  final d = controller.detail.value;
                  return _buildInfoCard(
                    widget.isGroup,
                    _displayName(d),
                    _displayPhone(d),
                  );
                }),
                SizedBox(height: 14.h),

                _buildRecentCallsCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CallHistoryDetailData? d) {
    final bool isGroup = widget.isGroup;
    final String name = _displayName(d);
    final String phone = _displayPhone(d);
    final bool isOnline = widget.contactData?.isOnline == true;

    return Column(
      children: [
        _buildBigAvatar(name, _displayAvatar(d), isGroup),
        SizedBox(height: 12.h),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: FontFamily.interBold,
            color: _dark,
          ),
        ),
        SizedBox(height: 4.h),
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
                fontSize: 16.sp,
                fontFamily: FontFamily.interSemiBold,
                color: _purple,
              ),
            ),
          SizedBox(height: 3.h),
          Text(
            isOnline ? "Online" : "Offline",
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: FontFamily.interMedium,
              color: isOnline ? const Color(0xFF10B981) : _grey,
            ),
          ),
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
          ? Icon(Icons.groups_rounded, size: 40.sp, color: _purple)
          : Text(
        initial,
        style: TextStyle(
          fontSize: 32.sp,
          fontFamily: FontFamily.interBold,
          color: _purple,
        ),
      ),
    );

    return Container(
      width: 96.w,
      height: 96.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: _softShadow,
      ),
      child: ClipOval(
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


  Widget _buildInfoCard(bool isGroup, String displayName, String phone) {
    return _card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _iconCircle(Icons.person_rounded),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _iconCircle(
                    isGroup ? Icons.groups_rounded : Icons.call_rounded),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGroup ? "Group Name" : "Mobile",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interSemiBold,
                          color: _dark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isGroup
                            ? displayName
                            : (phone.isNotEmpty ? phone : '-'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _grey,
                        ),
                      ),
                    ],
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
        final bool loading = controller.isLoading.value;
        final String error = controller.errorMessage.value;
        final bool listMode = controller.isListMode;
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
    if (raw == null || raw.trim().isEmpty) return '';
    String v = raw.trim();
    if (v.toLowerCase() == 'null') return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) v = v.substring(1);
    return '${ConstRes.aImageBaseUrl}$v';
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