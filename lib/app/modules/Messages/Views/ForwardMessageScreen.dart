import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Core/constant/const_res.dart';
import '../../../config/themes_data.dart';
import '../../../Model/GroupRes.dart';
import '../../../Model/user_profileList_res.dart';
import '../Controller/ForwardMessageController.dart';

class ForwardMessageScreen extends GetView<ForwardMessageController> {
  const ForwardMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Text(
          "Forward Message",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            _searchBar(),
            SizedBox(height: 8.h),
            Expanded(
              child: _destinationList(),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!controller.hasSelection) {
          return const SizedBox.shrink();
        }

        return _sendButton();
      }),
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
              : null,
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
    final users = controller.filteredUsers;
    final groups = controller.filteredGroups;

    if (users.isEmpty && groups.isEmpty) {
      return Center(
        child: Text(
          "No people or groups found",
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView(
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

  Widget _userTile(UserListData user) {
    return Obx(() {
      final selected = controller.isUserSelected(user);

      final image = user.profileImage ?? "";

      return InkWell(
        onTap: () {
          controller.toggleUser(user);
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
                        ? NetworkImage(
                            "${ConstRes.aImageBaseUrl}$image",
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
                  user.name ?? "Unnamed User",
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

  Widget _groupTile(GroupsResData group) {
    return Obx(() {
      final selected = controller.isGroupSelected(group);

      final image = group.groupProfile ?? "";

      return InkWell(
        onTap: () {
          controller.toggleGroup(group);
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
                        ? NetworkImage(
                            "${ConstRes.aImageBaseUrl}$image",
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
                  group.groupName ?? "Unnamed Group",
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
          child: ElevatedButton.icon(

              onPressed: controller.forwardMessage,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            label: Obx(
              () => Text(
                "Send (${controller.selectedCount})",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ToggleThemeData.darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
