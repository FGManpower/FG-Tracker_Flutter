import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Model/CallDetail.dart';
import '../../../Model/MemberDataRes.dart';
import '../Controller/contact_profile_controller.dart';

class ContactProfileScreen extends StatefulWidget {
  final MemberData? contactData;
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final String? groupAvatar;

  const ContactProfileScreen({
    Key? key,
    this.contactData,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.groupAvatar,
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
    _tag = widget.isGroup
        ? "group_${widget.groupId ?? widget.groupName ?? '0'}"
        : "${widget.contactData?.userId ?? '0'}";

    controller = Get.put(
      ContactProfileController(
        contactData: widget.contactData,
        isGroup: widget.isGroup,
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupAvatar: widget.groupAvatar,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ContactProfileController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isGroup = widget.isGroup;
    final String displayName = isGroup
        ? (widget.groupName ?? "Group")
        : (widget.contactData?.name ?? "User");
    final String? avatarRaw =
        isGroup ? widget.groupAvatar : widget.contactData?.profileImage;
    final String phone = widget.contactData?.mobileNo ?? '';
    final bool isOnline = widget.contactData?.isOnline == true;

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

                _buildBigAvatar(displayName, avatarRaw, isGroup),
                SizedBox(height: 12.h),

                Text(
                  displayName,
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

                // Information card
                _buildInfoCard(isGroup, displayName, phone),
                SizedBox(height: 14.h),

                // Recent calls card
                _buildRecentCallsCard(context),
              ],
            ),
          ),
        ),
      ),
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
        final calls = controller.recentCalls;

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
                  if (!loading || calls.isNotEmpty)
                    Text(
                      "${calls.length}",
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
            if (loading && calls.isEmpty)
              _buildSkeletonList()
            else if (calls.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                child: Center(
                  child: Text(
                    "No call history found for this ${widget.isGroup ? 'group' : 'contact'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interMedium,
                      color: _grey,
                    ),
                  ),
                ),
              )
            else
              for (int i = 0; i < calls.length; i++) ...[
                if (i > 0) _divider(),
                _buildHistoryTile(context, calls[i]),
              ],
          ],
        );
      }),
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
    final String status = (call.status ?? '').toLowerCase();
    final bool isVideo =
        call.isVideo == true || (call.type ?? '').toLowerCase() == 'video';
    final bool isIncoming = (call.direction ?? '').toLowerCase() == 'incoming';

    final bool isMissed = status == 'missed';
    final bool isRejected =
        status == 'rejected' || status == 'declined' || status == 'busy';
    final bool isCancelled = status == 'cancelled' || status == 'canceled';

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

    String subtitle = _whenLabel(call);
    final String dur = call.formattedDuration ?? '';
    if (status == 'completed' && dur.isNotEmpty && dur != '00:00') {
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
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) v = v.substring(1);
    return '${ConstRes.aImageBaseUrl}$v';
  }

  String _whenLabel(CallHistoryDetailData c) {
    final String time = c.time ?? '';
    final DateTime? dt = DateTime.tryParse(c.calledAt ?? '')?.toLocal();
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
