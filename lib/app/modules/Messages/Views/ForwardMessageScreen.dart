import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Model/ForwardMessageModel.dart';
import '../Controller/ForwardMessageController.dart';

// ── Forward screen palette ───────────────────────────────────────────────────
const Color _kPurple = Color(0xFF6C4CF1);
const Color _kRowSelected = Color(0xFFF4F1FF);
const Color _kTitle = Color(0xFF1E1B4B);
const Color _kAppBarBg = Color(0xFFF6F7FB); // Calls screen header background
const Color _kSubtitle = Color(0xFF8A8AA0);
const Color _kSection = Color(0xFF6B6B80);
const Color _kSearchBg = Color(0xFFF3F3F8);

/// Initial-avatar colours (picked by name, so a person keeps one colour).
const List<Color> _kAvatarColors = [
  Color(0xFFF07C5A), // orange
  Color(0xFF7C5CF5), // violet
  Color(0xFF1FA67A), // green
  Color(0xFF3B82F6), // blue
  Color(0xFFE0457B), // pink
  Color(0xFF5B3FD8), // indigo
  Color(0xFFF59E0B), // amber
];

class ForwardMessageScreen extends StatefulWidget {
  const ForwardMessageScreen({super.key});

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final ForwardMessageController controller =
      Get.find<ForwardMessageController>();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onBack() {
    if (controller.searchController.text.isNotEmpty) {
      controller.clearSearch();
      _searchFocus.unfocus();
      setState(() {});
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // System back clears an active search first, then leaves the screen.
    return PopScope(
      canPop: controller.searchController.text.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.destinations.isEmpty) {
                  return const _ForwardSkeletonList();
                }

                if (controller.responseError.value.isNotEmpty &&
                    controller.destinations.isEmpty) {
                  return _buildError();
                }

                return Column(
                  children: [
                    _buildSelectedStrip(),
                    _buildSearchBar(),
                    Expanded(
                      child: RefreshIndicator(
                        color: _kPurple,
                        onRefresh: controller.refreshForwardList,
                        child: _buildDestinationList(),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedDestinations.isEmpty) {
          return const SizedBox.shrink();
        }
        final busy = controller.isForwarding.value;
        return GestureDetector(
          onTap: busy ? null : controller.forwardMessage,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: _kPurple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kPurple.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send_rounded, color: Colors.white, size: 24.sp),
            ),
          ),
        );
      }),
    );
  }

  // ── App bar: same look as the Calls screen header (light background,
  // standard app back button, dark title, purple subtitle) ────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kAppBarBg,
      elevation: 0,
      scrolledUnderElevation: AppBarStyle.scrolledUnderElevation,
      surfaceTintColor: AppBarStyle.surfaceTintColor,
      leadingWidth: AppBarStyle.leadingWidth,
      leading: AppBarStyle.leading(onTap: _onBack),
      titleSpacing: 6.w,
      centerTitle: false,
      title: Obx(() {
        final count = controller.selectedCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appL10n.chatList_forwardTo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _kTitle,
                fontSize: 19.sp,
                fontFamily: FontFamily.interBold,
                height: 1.15,
              ),
            ),
            if (count > 0) ...[
              SizedBox(height: 2.h),
              Text(
                appL10n.chatList_selectedCount(count),
                style: TextStyle(
                  color: const Color(0xFF6B4DFF),
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  height: 1.15,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // ── Search field (always visible) ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 4.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: _kSearchBg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),
            Icon(Icons.search_rounded, size: 20.sp, color: _kSubtitle),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 14.sp, color: _kTitle),
                cursorColor: _kPurple,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: appL10n.chatList_searchNameOrNumber,
                  hintStyle: TextStyle(fontSize: 14.sp, color: _kSubtitle),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  controller.search(val);
                  setState(() {});
                },
              ),
            ),
            if (controller.searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clearSearch();
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Icon(Icons.close_rounded,
                      size: 18.sp, color: _kSubtitle),
                ),
              )
            else
              SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  // ── Selected chips row ────────────────────────────────────────────────────
  Widget _buildSelectedStrip() {
    final selected = controller.selectedDestinations;
    if (selected.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 78.h,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
        scrollDirection: Axis.horizontal,
        itemCount: selected.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = selected[index];
          final firstName = item.displayName.trim().split(' ').first;
          return GestureDetector(
            onTap: () => controller.toggleDestination(item),
            child: SizedBox(
              width: 50.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildAvatar(item, radius: 20.r),
                      Positioned(
                        right: -3.w,
                        top: -3.h,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E8EA3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 10.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _kTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildDestinationList() {
    final recent = controller.recentChats;
    final groups = controller.allGroups;
    final contacts = controller.myContacts;
    final otherContacts = controller.otherContacts;

    if (recent.isEmpty &&
        groups.isEmpty &&
        contacts.isEmpty &&
        otherContacts.isEmpty) {
      return ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300.h,
            child: Center(
              child: Text(
                appL10n.chatList_noPeopleOrGroups,
                style: TextStyle(fontSize: 15.sp, color: _kSubtitle),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 96.h),
      children: [
        if (recent.isNotEmpty) ...[
          _sectionTitle(appL10n.chatList_sectionRecentChats),
          ...recent.map((item) => _buildTile(item, controller.isSelected(item))),
        ],
        if (groups.isNotEmpty) ...[
          _sectionTitle(appL10n.chatList_sectionGroups),
          ...groups.map((item) => _buildTile(item, controller.isSelected(item))),
        ],
        if (contacts.isNotEmpty) ...[
          _sectionTitle(appL10n.chatList_sectionMyContacts),
          ...contacts
              .map((item) => _buildTile(item, controller.isSelected(item))),
        ],
        if (otherContacts.isNotEmpty) ...[
          _sectionTitle(appL10n.chatList_sectionOtherContacts),
          ...otherContacts
              .map((item) => _buildTile(item, controller.isSelected(item))),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 6.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _kSection,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildTile(ForwardDestination item, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: isSelected ? _kRowSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => controller.toggleDestination(item),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              children: [
                _buildAvatar(item, radius: 21.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: _kTitle,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.isGroup
                            ? appL10n.chatList_groupFallback
                            : (item.mobileNo?.isNotEmpty == true
                                ? item.mobileNo!
                                : appL10n.chatList_defaultAbout),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: _kSubtitle),
                      ),
                    ],
                  ),
                ),
                _buildSelectionCheck(isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _avatarColor(ForwardDestination item) {
    final key = item.displayName.trim().toLowerCase();
    return _kAvatarColors[key.hashCode.abs() % _kAvatarColors.length];
  }

  String _initial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCodes(t.runes.take(1)).toUpperCase();
  }

  Widget _buildAvatar(ForwardDestination item, {required double radius}) {
    final image = item.displayImage;
    final hasImage =
        image.isNotEmpty && !image.toLowerCase().contains('default-profile');
    final url =
        image.startsWith("http") ? image : "${ConstRes.aImageBaseUrl}$image";

    final Color bg = _avatarColor(item);
    final Widget fallback = item.isGroup
        ? Icon(Icons.groups_rounded, color: Colors.white, size: radius * 1.05)
        : Text(
            _initial(item.displayName),
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.85,
              fontWeight: FontWeight.w700,
            ),
          );

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(child: fallback),
                errorWidget: (_, __, ___) => Center(child: fallback),
              ),
            )
          : fallback,
    );
  }

  Widget _buildSelectionCheck(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _kPurple : Colors.transparent,
        border: Border.all(
          color: isSelected ? _kPurple : const Color(0xFFCFCFDB),
          width: 1.6,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
          : null,
    );
  }

  Widget _buildError() {
    return RefreshIndicator(
      color: _kPurple,
      onRefresh: controller.refreshForwardList,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 55.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      controller.responseError.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: controller.refreshForwardList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(appL10n.common_retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForwardSkeletonList extends StatelessWidget {
  const _ForwardSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.only(
          top: 12.h,
          bottom: 100.h,
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Text(
              "PEOPLE",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          for (int i = 0; i < 6; i++) ...[
            const _ForwardSkeletonTile(),
            if (i < 5) SizedBox(height: 4.h),
          ],
        ],
      ),
    );
  }
}

class _ForwardSkeletonTile extends StatelessWidget {
  const _ForwardSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 9.h,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              "Loading contact name",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}