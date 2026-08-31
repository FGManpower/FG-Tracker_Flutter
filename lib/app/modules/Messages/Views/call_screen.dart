import 'package:fgtracker/app/Core/values/responsive.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int _selectedTab = 0;
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _todayCalls = [
    {
      'name': 'Rohit Sharma',
      'type': 'Incoming',
      'time': '10:32 AM',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Maxwell Bravo',
      'type': 'Missed',
      'time': '09:15 AM',
      'avatar': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Anjali Mehta',
      'type': 'Outgoing',
      'time': '08:48 AM',
      'avatar': 'https://i.pravatar.cc/150?img=45',
    },
  ];

  final List<Map<String, dynamic>> _yesterdayCalls = [
    {
      'name': 'Vikram Singh',
      'type': 'Incoming',
      'time': 'Yesterday',
      'avatar': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Rushi Accounted',
      'type': 'Missed',
      'time': 'Yesterday',
      'avatar': '',
      'initials': 'RA',
    },
    {
      'name': 'Pooja Patel',
      'type': 'Outgoing',
      'time': 'Yesterday',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
  ];

  final List<Map<String, dynamic>> _mayCalls = [
    {
      'name': 'Sagar Gupta',
      'type': 'Incoming',
      'time': '12 May, 06:20 PM',
      'dateShort': '12 May',
      'avatar': 'https://i.pravatar.cc/150?img=17',
    },
    {
      'name': 'Arjun Verma',
      'type': 'Outgoing',
      'time': '12 May, 04:10 PM',
      'dateShort': '12 May',
      'avatar': 'https://i.pravatar.cc/150?img=18',
    },
    {
      'name': 'Neha Singh',
      'type': 'Missed',
      'time': '12 May, 01:05 PM',
      'dateShort': '12 May',
      'avatar': 'https://i.pravatar.cc/150?img=48',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            MediaQueryHelper.gapH(8, ),
            _buildSearchBar(),
            MediaQueryHelper.gapH(14, ),
            _buildTopTabs(),
            MediaQueryHelper.gapH(14, ),
            _buildFilters(),
            MediaQueryHelper.gapH(10, ),
            Expanded(child: _buildCallList()),
            _buildKeypadBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 16, vertical: 8,),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back,
                color: const Color(0xFF6B4DFF), size: 24.sp),
          ),
          Expanded(
            child: Center(
              child: reausabletext(
                "Calls",
                fontsize: 20.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black,
              ),
            ),
          ),
          Icon(Icons.more_vert, color: const Color(0xFF6B4DFF), size: 22.sp),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
          MediaQueryHelper.paddingSymmetric(horizontal: 16, ),
      child: Container(
        height: 48.h,
        padding:
            MediaQueryHelper.paddingSymmetric(horizontal: 14, ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20.sp, color: Colors.grey),
            MediaQueryHelper.gapW(10, ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search contacts or number",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    fontFamily: FontFamily.interRegular,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Icon(Icons.mic, size: 20.sp, color: const Color(0xFF6B4DFF)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs() {
    return Padding(
      padding:
          MediaQueryHelper.paddingSymmetric(horizontal: 16, ),
      child: Row(
        children: [
          _topTab("Recent", 0),
          _topTab("Contacts", 1),
        ],
      ),
    );
  }

  Widget _topTab(String title, int index) {
    final bool selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: reausabletext(
                title,
                fontsize: 15.sp,
                color: selected ? const Color(0xFF6B4DFF) : Colors.black54,
                fontfamily:
                    selected ? FontFamily.interBold : FontFamily.interSemiBold,
              ),
            ),
            Container(
              height: 2.5.h,
              color: selected
                  ? const Color(0xFF6B4DFF)
                  : Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            MediaQueryHelper.paddingSymmetric(horizontal: 16, ),
        children: [
          _filterChip("All", null, 0),
          MediaQueryHelper.gapW(8, ),
          _filterChip("Missed", Icons.call_missed, 1, iconColor: Colors.red),
          MediaQueryHelper.gapW(8, ),
          _filterChip("Outgoing", Icons.call_made, 2,
              iconColor: const Color(0xFF10B981)),
          MediaQueryHelper.gapW(8, ),
          _filterChip("Incoming", Icons.call_received, 3,
              iconColor: const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData? icon, int index,
      {Color? iconColor}) {
    final bool selected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: MediaQueryHelper.paddingSymmetric(
            horizontal: 14, vertical: 6, ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE9FF) : const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: iconColor ?? Colors.grey),
              MediaQueryHelper.gapW(6, ),
            ],
            reausabletext(
              label,
              fontsize: 12.sp,
              color: selected ? const Color(0xFF6B4DFF) : Colors.black87,
              fontfamily: FontFamily.interSemiBold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        _sectionTitle("Today"),
        ..._todayCalls.map(_callTile),
        MediaQueryHelper.gapH(10, ),
        _sectionTitle("Yesterday"),
        ..._yesterdayCalls.map(_callTile),
        MediaQueryHelper.gapH(10, ),
        _sectionTitle("12 May 2024"),
        ..._mayCalls.map(_callTile),
        MediaQueryHelper.gapH(10, ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: reausabletext(
        title,
        fontsize: 13.sp,
        color: Colors.grey,
        fontfamily: FontFamily.interSemiBold,
      ),
    );
  }

  Widget _callTile(Map<String, dynamic> c) {
    final String type = c['type'] as String;
    final IconData typeIcon;
    final Color typeColor;

    switch (type) {
      case 'Missed':
        typeIcon = Icons.call_missed;
        typeColor = Colors.red;
        break;
      case 'Outgoing':
        typeIcon = Icons.call_made;
        typeColor = const Color(0xFF10B981);
        break;
      default:
        typeIcon = Icons.call_received;
        typeColor = const Color(0xFF10B981);
    }

    final String rightTime =
        (c['dateShort'] as String?) ?? (c['time'] as String);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          _avatar(c),
          MediaQueryHelper.gapW(12, ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  c['name'] as String,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                MediaQueryHelper.gapH(3, ),
                Row(
                  children: [
                    Icon(typeIcon, size: 12.sp, color: typeColor),
                    MediaQueryHelper.gapW(4, ),
                    reausabletext(
                      "$type • ${c['time']}",
                      fontsize: 11.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          reausabletext(
            rightTime.contains(',') ? rightTime.split(',').first : rightTime,
            fontsize: 12.sp,
            color: Colors.grey,
          ),
          MediaQueryHelper.gapW(12, ),
          Icon(Icons.phone, color: const Color(0xFF6B4DFF), size: 22.sp),
        ],
      ),
    );
  }

  Widget _avatar(Map<String, dynamic> c) {
    final String? initials = c['initials'] as String?;
    final String avatar = c['avatar'] as String;

    if (initials != null && initials.isNotEmpty) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: const Color(0xFFDBEAFE),
        child: reausabletext(
          initials,
          fontsize: 13.sp,
          color: const Color(0xFF2563EB),
          fontfamily: FontFamily.interBold,
        ),
      );
    }

    return CircleAvatar(
      radius: 22.r,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
      child: avatar.isEmpty
          ? Icon(Icons.person, size: 22.sp, color: Colors.grey)
          : null,
    );
  }

  Widget _buildKeypadBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4DFF).withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4DFF).withOpacity(0.08),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.dialpad,
                  color: const Color(0xFF6B4DFF),
                  size: 22.sp,
                ),
              ),
              MediaQueryHelper.gapH(4),
              reausabletext(
                "Keypad",
                fontsize: 11.sp,
                color: const Color(0xFF6B4DFF),
                fontfamily: FontFamily.interSemiBold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
