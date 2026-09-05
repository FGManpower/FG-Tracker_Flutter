import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

class _ContactItem {
  final String name;
  final String role;
  final bool isInvite;

  const _ContactItem({
    required this.name,
    required this.role,
    required this.isInvite,
  });
}

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxBool _isSearchCollapsed = false.obs;
  final RxBool _showSearchInAppBar = false.obs;

  final List<_ContactItem> _directContacts = const [
    _ContactItem(
        name: "Samad", role: "FG Manpower Development", isInvite: false),
    _ContactItem(
        name: "Riya Sharma", role: "Event Management Team", isInvite: false),
    _ContactItem(
        name: "Neha Verma", role: "Construction Site Team", isInvite: false),
    _ContactItem(
        name: "Arjun Patel",
        role: "Logistics & Delivery Team",
        isInvite: false),
  ];

  final List<_ContactItem> _inviteContacts = const [
    _ContactItem(name: "Pooja Mehta", role: "Accounts Team", isInvite: true),
    _ContactItem(
        name: "Rahul Chauhan", role: "Site Supervisor", isInvite: true),
    _ContactItem(name: "Mohit Kumar", role: "Field Operations", isInvite: true),
    _ContactItem(name: "Sandeep Yadav", role: "Warehouse Team", isInvite: true),
  ];

  List<_ContactItem> get _filteredDirect {
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _directContacts;
    return _directContacts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.role.toLowerCase().contains(q);
    }).toList();
  }

  List<_ContactItem> get _filteredInvite {
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _inviteContacts;
    return _inviteContacts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.role.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 40 && !_isSearchCollapsed.value) {
        _isSearchCollapsed.value = true;
      } else if (_scrollController.offset <= 40 && _isSearchCollapsed.value) {
        _isSearchCollapsed.value = false;
        _showSearchInAppBar.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child:
              (_isSearchCollapsed.value && !_showSearchInAppBar.value)
                  ? const SizedBox(width: double.infinity)
                  : _buildSearchBar(),
            )),
            Expanded(
              child: Obx(() {
                final direct = _filteredDirect;
                final invite = _filteredInvite;

                if (direct.isEmpty && invite.isEmpty) {
                  return Center(
                    child: reausabletext(
                      "No contacts found for '${_searchQuery.value}'",
                      fontsize: 13.sp,
                      color: Colors.grey,
                    ),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 40.h),
                  children: [
                    SizedBox(height: 12.h),

                    if (direct.isNotEmpty) ...[
                      _buildSectionTitle("Start a New Chat (Contacts)"),
                      _buildContactsCard(direct),
                      SizedBox(height: 16.h),
                    ],

                    if (invite.isNotEmpty) ...[
                      _buildSectionTitle("Invite to Chat (More Contacts)"),
                      _buildContactsCard(invite),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsCard(List<_ContactItem> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
          color: Colors.grey.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildContactRow(item);
        },
      ),
    );
  }

  Widget _buildContactRow(_ContactItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  item.name,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  item.role,
                  fontsize: 11.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ],
            ),
          ),
          if (item.isInvite)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: reausabletext(
                "Invite",
                fontsize: 12.sp,
                color: const Color(0xFF6B4DFF),
                fontfamily: FontFamily.interSemiBold,
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 18.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    size: 20.sp,
                    color: const Color(0xFF6B4DFF),
                  ),
                ),
              )
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "New Chat",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Start a conversation",
                  fontsize: 11.sp,
                  fontweight: FontWeight(450),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Obx(() {
            if (!_isSearchCollapsed.value) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                _showSearchInAppBar.value = true;
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 4.w),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 22.sp, color: const Color(0xFF6B4DFF)),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => _searchQuery.value = val,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interMedium,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontFamily: FontFamily.interRegular,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Obx(() {
              if (_searchQuery.value.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _searchQuery.value = '';
                  FocusScope.of(context).unfocus();
                },
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: reausabletext(
        title,
        fontsize: 13.sp,
        fontfamily: FontFamily.interBold,
        color: Colors.black87,
      ),
    );
  }
}