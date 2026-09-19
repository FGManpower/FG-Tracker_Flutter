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

  bool _isSearchCollapsed = false;
  bool _showSearchInAppBar = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.pixels;

    if (position > 40 && !_isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = true;
      });
    } else if (position <= 40 && _isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = false;
        _showSearchInAppBar = false;
      });
    }
  }

  void _showSearch() {
    setState(() {
      _showSearchInAppBar = true;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

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
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: ToggleThemeData.darkPurple,
          elevation: 4,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  "Forward Message",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isSearchCollapsed && !_showSearchInAppBar
                    ? IconButton(
                        key: const ValueKey("search"),
                        onPressed: _showSearch,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey("empty"),
                        width: 0,
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
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: (!_isSearchCollapsed || _showSearchInAppBar)
                  ? _searchBar()
                  : const SizedBox(
                      width: double.infinity,
                    ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: RefreshIndicator(
                color: ToggleThemeData.darkPurple,
                onRefresh: controller.refreshForwardList,
                child: _destinationList(),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar:Obx(
            () => controller.selectedDestinations.isNotEmpty
            ? _sendButton()
            : const SizedBox.shrink(),

      ),
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

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        8.h,
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: "Search people or groups",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.close),
          )
              : const SizedBox.shrink(),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 13.h,
          ),
        ),
      ),
    );
  }

  Widget _destinationList() {
    final users = controller.users;
    final groups = controller.groups;

    if (users.isEmpty && groups.isEmpty) {
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
        top: 4.h,
        bottom: 100.h,
      ),
      children: [
        if (users.isNotEmpty) ...[
          _sectionTitle("PEOPLE"),
          ...users.map(_userTile),
        ],
        if (groups.isNotEmpty) ...[
          SizedBox(height: 10.h),
          _sectionTitle("GROUPS"),
          ...groups.map(_groupTile),
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

  Widget _userTile(ForwardDestination user) {
    return Obx(() {
      final selected = controller.isSelected(user);
      final image = user.displayImage;

      return InkWell(
        onTap: () {
          controller.toggleDestination(user);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 9.h,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 27.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: image.isNotEmpty
                        ? CachedNetworkImageProvider(
                            image.startsWith("http")
                                ? image
                                : "${ConstRes.aImageBaseUrl}$image",
                          )
                        : null,
                    child: image.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.shade500,
                            size: 28.sp,
                          )
                        : null,
                  ),
                  if (selected)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _selectionIcon(selected),
            ],
          ),
        ),
      );
    });
  }

  Widget _groupTile(ForwardDestination group) {
    return Obx(() {
      final selected = controller.isSelected(group);
      final image = group.displayImage;

      return InkWell(
        onTap: () {
          controller.toggleDestination(group);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 9.h,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 27.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: image.isNotEmpty
                        ? CachedNetworkImageProvider(
                            image.startsWith("http")
                                ? image
                                : "${ConstRes.aImageBaseUrl}$image",
                          )
                        : null,
                    child: image.isEmpty
                        ? Icon(
                            Icons.groups,
                            color: ToggleThemeData.darkPurple,
                            size: 28.sp,
                          )
                        : null,
                  ),
                  if (selected)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  group.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _selectionIcon(selected),
            ],
          ),
        ),
      );
    });
  }

  Widget _selectionIcon(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? ToggleThemeData.darkPurple : Colors.grey.shade400,
          width: 2,
        ),
        color: selected ? ToggleThemeData.darkPurple : Colors.transparent,
      ),
      child: selected
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: 16.sp,
            )
          : null,
    );
  }

  Widget _sendButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          8.h,
          16.w,
          12.h,
        ),
        child: SizedBox(
          height: 52.h,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isForwarding.value
                  ? null
                  : controller.forwardMessage,
              icon: controller.isForwarding.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
              label: Text(
                controller.isForwarding.value
                    ? "Sending..."
                    : "Send (${controller.selectedCount})",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ToggleThemeData.darkPurple,
                disabledBackgroundColor:
                    ToggleThemeData.darkPurple.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
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
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14.r),
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
            radius: 27.r,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              "Loading user name",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
