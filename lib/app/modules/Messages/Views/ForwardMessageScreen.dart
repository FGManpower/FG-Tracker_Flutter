import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/constant/const_res.dart';
import '../../../config/themes_data.dart';
import '../../../Model/ForwardMessageModel.dart';
import '../Controller/ForwardMessageController.dart';

class ForwardMessageScreen extends StatefulWidget {
  const ForwardMessageScreen({super.key});

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final ForwardMessageController controller =
      Get.find<ForwardMessageController>();

  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58.h),
        child: Obx(
          () => AppBar(
            backgroundColor: ToggleThemeData.darkPurple,
            elevation: 2,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () {
                if (_isSearching) {
                  setState(() => _isSearching = false);
                  controller.clearSearch();
                } else {
                  Get.back();
                }
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: _isSearching ? _buildSearchField() : _buildAppBarTitle(),
            actions: [
              if (!_isSearching)
                IconButton(
                  onPressed: () {
                    setState(() => _isSearching = true);
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                )
              else if (controller.searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    controller.clearSearch();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.destinations.isEmpty) {
          return const _ForwardSkeletonList();
        }

        if (controller.responseError.value.isNotEmpty &&
            controller.destinations.isEmpty) {
          return _buildError();
        }

        return Column(
          children: [
            _buildSelectedStrip(),
            Expanded(
              child: RefreshIndicator(
                color: ToggleThemeData.darkPurple,
                onRefresh: controller.refreshForwardList,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: false,
                  child: _buildDestinationList(),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final selected = controller.selectedDestinations;
        if (selected.isEmpty) return const SizedBox.shrink();

        final names = selected.map((d) => d.displayName).join(", ");
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    names,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: controller.isForwarding.value
                      ? null
                      : controller.forwardMessage,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: controller.isForwarding.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAppBarTitle() {
    final count = controller.selectedCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Forward to...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (count > 0)
          Text(
            "$count selected",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Search...",
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 16.sp,
        ),
        border: InputBorder.none,
      ),
      onChanged: (val) {
        controller.search(val);
        setState(() {});
      },
    );
  }

  Widget _buildSelectedStrip() {
    final selected = controller.selectedDestinations;
    if (selected.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 94.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: selected.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = selected[index];
          final firstName = item.displayName.trim().split(' ').first;
          return GestureDetector(
            onTap: () => controller.toggleDestination(item),
            child: SizedBox(
              width: 58.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildAvatar(item, radius: 23.r, showCheck: false),
                      Positioned(
                        right: -2.w,
                        bottom: -2.h,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 10.sp,
                            color: Colors.white,
                          ),
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
                      color: Colors.grey.shade800,
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
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300.h,
            child: Center(
              child: Text(
                "No people or groups found",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(
        top: 6.h,
        bottom: 24.h,
      ),
      children: [
        if (recent.isNotEmpty) ...[
          _sectionTitle("RECENT CHATS"),
          ...recent.map(
            (item) => _buildTile(item, controller.isSelected(item)),
          ),
        ],
        if (groups.isNotEmpty) ...[
          SizedBox(height: 10.h),
          _sectionTitle("GROUPS"),
          ...groups.map(
            (item) => _buildTile(item, controller.isSelected(item)),
          ),
        ],
        if (contacts.isNotEmpty) ...[
          SizedBox(height: 10.h),
          _sectionTitle("MY CONTACTS"),
          ...contacts.map(
            (item) => _buildTile(item, controller.isSelected(item)),
          ),
        ],
        if (otherContacts.isNotEmpty) ...[
          SizedBox(height: 10.h),
          _sectionTitle("OTHER CONTACTS"),
          ...otherContacts.map(
            (item) => _buildTile(item, controller.isSelected(item)),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 8.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTile(ForwardDestination item, bool isSelected) {
    return InkWell(
      onTap: () => controller.toggleDestination(item),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 9.h,
        ),
        child: Row(
          children: [
            _buildAvatar(item, radius: 24.r, showCheck: isSelected),
            SizedBox(width: 14.w),
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
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.isGroup
                        ? "Group"
                        : (item.mobileNo?.isNotEmpty == true
                            ? item.mobileNo!
                            : "Hey there! I am using FG Tracker"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildSelectionCheck(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    ForwardDestination item, {
    required double radius,
    required bool showCheck,
  }) {
    final image = item.displayImage;
    final hasImage =
        image.isNotEmpty && !image.toLowerCase().contains('default-profile');
    final url = image.startsWith("http")
        ? image
        : "${ConstRes.aImageBaseUrl}$image";

    final fallbackIcon = item.isGroup ? Icons.groups_rounded : Icons.person;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor:
              item.isGroup ? const Color(0xFFEDE9FE) : Colors.grey.shade200,
          child: hasImage
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => Icon(
                      fallbackIcon,
                      color: item.isGroup
                          ? ToggleThemeData.darkPurple
                          : Colors.grey.shade500,
                      size: radius * 1.1,
                    ),
                  ),
                )
              : Icon(
                  fallbackIcon,
                  color: item.isGroup
                      ? ToggleThemeData.darkPurple
                      : Colors.grey.shade500,
                  size: radius * 1.1,
                ),
        ),
        if (showCheck)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.8),
              ),
              child: Icon(
                Icons.check,
                size: 9.sp,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionCheck(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF25D366) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF25D366) : Colors.grey.shade400,
          width: 1.8,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 14.sp,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildError() {
    return RefreshIndicator(
      color: ToggleThemeData.darkPurple,
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
                        backgroundColor: ToggleThemeData.darkPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Retry"),
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