import 'package:fgtracker/app/Core/values/responsive.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _frequent = [
    {
      'name': 'Samad',
      'team': 'FG Manpower Team',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Neha Verma',
      'team': 'Construction Team',
      'avatar': 'https://i.pravatar.cc/150?img=45',
    },
    {
      'name': 'Rohit Patel',
      'team': 'Logistics Team',
      'avatar': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Riya Sharma',
      'team': 'Event Team',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
  ];

  final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Samad',
      'team': 'FG Manpower Team',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Riya Sharma',
      'team': 'Event Management Team',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
    {
      'name': 'Rohit Patel',
      'team': 'Logistics & Delivery Team',
      'avatar': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Neha Verma',
      'team': 'Construction Site Team',
      'avatar': 'https://i.pravatar.cc/150?img=45',
    },
    {
      'name': 'Imran Khan',
      'team': 'Site Operations Team',
      'avatar': 'https://i.pravatar.cc/150?img=33',
    },
    {
      'name': 'Vikram Singh',
      'team': 'Loading & Unloading Team',
      'avatar': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Pooja Sharma',
      'team': 'Administration Team',
      'avatar': 'https://i.pravatar.cc/150?img=48',
    },
  ];

  final List<Map<String, dynamic>> _groups = [
    {'name': 'FG Manpower Team', 'members': 12},
    {'name': 'Site Operations Team', 'members': 8},
    {'name': 'Event Management Team', 'members': 14},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            MediaQueryHelper.gapH(12, context),
            _buildTabs(),
            MediaQueryHelper.gapH(12, context),
            _buildSearchBar(),
            MediaQueryHelper.gapH(14, context),
            Expanded(
              child: ListView(
                padding: MediaQueryHelper.paddingSymmetric(
                    horizontal: 16, context: context),
                children: [
                  if (_selectedTab == 0) ...[
                    _buildFrequentSection(),
                    MediaQueryHelper.gapH(18, context),
                    _buildContactsSection(),
                    MediaQueryHelper.gapH(18, context),
                    _buildGroupsSection(),
                  ] else ...[
                    _buildGroupsSection(),
                  ],
                  MediaQueryHelper.gapH(20, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 16, vertical: 8, context: context),
      child: Row(
        children: [
          _roundIconBtn(Icons.arrow_back_ios_new, onTap: () => Get.back()),
          MediaQueryHelper.gapW(12, context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "Video Call",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Select a contact or group",
                  fontsize: 11.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          MediaQueryHelper.gapW(8, context),
          _roundIconBtn(Icons.more_horiz),
        ],
      ),
    );
  }

  Widget _roundIconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: Colors.black87),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding:
      MediaQueryHelper.paddingSymmetric(horizontal: 16, context: context),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;
            return Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: _selectedTab == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: tabWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4DFF),
                      borderRadius: BorderRadius.circular(26.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4DFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selectedTab = 0),
                        child: SizedBox(
                          height: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 16.sp,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : const Color(0xFF6B4DFF),
                              ),
                              MediaQueryHelper.gapW(6, context),
                              reausabletext(
                                "Contacts",
                                fontsize: 13.sp,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : const Color(0xFF6B4DFF),
                                fontfamily: FontFamily.interSemiBold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selectedTab = 1),
                        child: SizedBox(
                          height: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups,
                                size: 16.sp,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : const Color(0xFF6B4DFF),
                              ),
                              MediaQueryHelper.gapW(6, context),
                              reausabletext(
                                "Groups",
                                fontsize: 13.sp,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : const Color(0xFF6B4DFF),
                                fontfamily: FontFamily.interSemiBold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding:
      MediaQueryHelper.paddingSymmetric(horizontal: 16, context: context),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46.h,
              padding: MediaQueryHelper.paddingSymmetric(
                  horizontal: 14, context: context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.sp, color: Colors.grey),
                  MediaQueryHelper.gapW(8, context),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search contacts...",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                          fontFamily: FontFamily.interRegular,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MediaQueryHelper.gapW(10, context),
          Container(
            height: 46.h,
            width: 46.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Icon(Icons.tune,
                size: 18.sp, color: const Color(0xFF6B4DFF)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        reausabletext(
          title,
          fontsize: 14.sp,
          fontfamily: FontFamily.interBold,
          color: Colors.black87,
        ),
        Row(
          children: [
            reausabletext(
              "View All",
              fontsize: 12.sp,
              color: const Color(0xFF6B4DFF),
              fontfamily: FontFamily.interSemiBold,
            ),
            Icon(Icons.arrow_forward,
                size: 14.sp, color: const Color(0xFF6B4DFF)),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Frequently Called"),
        MediaQueryHelper.gapH(12, context),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _frequent.length,
            separatorBuilder: (_, __) => MediaQueryHelper.gapW(14, context),
            itemBuilder: (context, i) {
              final c = _frequent[i];
              return SizedBox(
                width: 72.w,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                          NetworkImage(c['avatar'] as String),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5.w),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B4DFF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5.w),
                            ),
                            child: Icon(Icons.videocam,
                                size: 12.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    MediaQueryHelper.gapH(6, context),
                    reausabletext(
                      c['name'] as String,
                      fontsize: 11.sp,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    reausabletext(
                      c['team'] as String,
                      fontsize: 9.sp,
                      color: Colors.grey,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Contacts"),
        MediaQueryHelper.gapH(10, context),
        ..._contacts.map((c) => _contactTile(c)),
      ],
    );
  }

  Widget _contactTile(Map<String, dynamic> c) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 12, vertical: 10, context: context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(c['avatar'] as String),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5.w),
                  ),
                ),
              ),
            ],
          ),
          MediaQueryHelper.gapW(12, context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  c['name'] as String,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                MediaQueryHelper.gapH(2, context),
                reausabletext(
                  c['team'] as String,
                  fontsize: 11.sp,
                  color: const Color(0xFF6B4DFF).withOpacity(0.7),
                ),
              ],
            ),
          ),
          _videoBtn(),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Groups"),
        MediaQueryHelper.gapH(10, context),
        ..._groups.map((g) => _groupTile(g)),
      ],
    );
  }

  Widget _groupTile(Map<String, dynamic> g) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 12, vertical: 10, context: context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.groups,
                    size: 22.sp, color: const Color(0xFF6B4DFF)),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5.w),
                  ),
                ),
              ),
            ],
          ),
          MediaQueryHelper.gapW(12, context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  g['name'] as String,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                MediaQueryHelper.gapH(2, context),
                reausabletext(
                  "${g['members']} Members",
                  fontsize: 11.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          _videoBtn(),
        ],
      ),
    );
  }

  Widget _videoBtn() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.videocam,
          size: 20.sp, color: const Color(0xFF6B4DFF)),
    );
  }
}