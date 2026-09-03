import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/Views/QrScreen.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupsListScreen extends StatefulWidget {
  GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final groupController = Get.find<GroupController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = "".obs;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  reausabletext(
                    "All Groups",
                    fontsize: 18.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                  ),
                  Obx(() => reausabletext(
                    "${_filteredGroups().length} Total",
                    fontsize: 12.sp,
                    fontfamily: FontFamily.interMedium,
                    color: const Color(0xff5045B9),
                  )),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() {
                if (groupController.responseError.value.isNotEmpty) {
                  return LostinternetConnection(
                    retry: groupController.getGroupData,
                    messgae: groupController.responseError.value.toString(),
                  );
                }
                final bool isLoading = groupController.groupDataLoading.value;
                final List<GroupsResData> data =
                isLoading ? [] : _filteredGroups();

                if (!isLoading && data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: reausabletext(
                        _searchQuery.value.isNotEmpty
                            ? "No group found for '${_searchQuery.value}'"
                            : AppText.youHaventJoindOrCreatedGroup,
                        align: TextAlign.center,
                        color: Colors.grey[600],
                        fontsize: 14,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xff5045B9),
                  onRefresh: () async {
                    await groupController.getGroupData();
                  },
                  child: ListView.separated(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    itemCount: isLoading ? 5 : data.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final GroupsResData? group =
                      isLoading ? null : data[index];
                      return _buildGroupCard(context, group, isLoading);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<GroupsResData> _filteredGroups() {
    final all = groupController.groupData;
    if (_searchQuery.value.trim().isEmpty) return all;
    final q = _searchQuery.value.toLowerCase();
    return all.where((g) {
      final name = (g.groupName ?? "").toLowerCase();
      final code = (g.groupCode ?? "").toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(9.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: const Color(0xff5045B9),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    "All Groups",
                    fontsize: 20.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                  ),
                  reausabletext(
                    "Stay connected with your teams",
                    fontsize: 12.sp,
                    fontfamily: FontFamily.interMedium,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 28.sp,
                color: const Color(0xff5045B9),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  height: 8.h,
                  width: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        height: 45.h,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade500, size: 22.sp),
            SizedBox(width: 10.w),
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
                  hintText: "Search groups...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
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
                  _searchQuery.value = "";
                  FocusScope.of(context).unfocus();
                },
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
      BuildContext context, GroupsResData? data, bool isLoading) {
    final bool isActive = data?.isActive ?? false;
    final bool isCreator = data?.isCreator ?? false;

    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () {
          if (data == null) return;
          if (isActive) {
            Get.toNamed(Routes.Memberscreen, arguments: {
              "groupId": data.id.toString(),
              "groupName": data.groupName.toString(),
              "groupCode": data.groupCode.toString(),
              "isCreator": data.isCreator.toString(),
              "isActive": data.isActive.toString(),
            })?.then((value) {
              if (value == true) {
                groupController.getGroupData();
              }
            });
          }
        },
        child: Opacity(
          opacity: isActive ? 1.0 : 0.7,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50.h,
                  width: 50.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B78FF), Color(0xFF6A5AE0)],
                    ),
                  ),
                  child: Icon(Icons.groups_rounded,
                      color: Colors.white, size: 32.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: reausabletext(
                              data?.groupName ?? "Unnamed Group",
                              fontsize: 14.sp,
                              fontfamily: FontFamily.interSemiBold,
                              color: Colors.black87,
                              maxline: 1,
                              textoverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE7F8EC)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: reausabletext(
                              isActive ? "Active" : "Inactive",
                              fontsize: 10.sp,
                              color: isActive
                                  ? const Color(0xFF2BB673)
                                  : Colors.grey.shade600,
                              fontfamily: FontFamily.interMedium,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          if (isCreator)
                            Transform.scale(
                              scale: 0.7,
                              child: CupertinoSwitch(
                                value: isActive,
                                activeColor: const Color(0xff5045B9),
                                trackColor: Colors.grey.shade300,
                                onChanged: (value) {
                                  if (data == null) return;
                                  groupController.updateGroup(
                                    groupController,
                                    groupId: data.id.toString(),
                                    groupStatus: value.toString(),
                                  );
                                },
                              ),
                            )
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _infoColumn(
                                  title: "Team Code",
                                  value: data?.groupCode ?? "--",
                                  showCopy: true,
                                  flex: 3,
                                  onCopy: () {
                                    Clipboard.setData(ClipboardData(
                                        text: data?.groupCode ?? ""));
                                    Utils().fluttertoast("Group code copied!");
                                  },
                                ),
                                _vDivider(),
                                _infoColumn(
                                  title: "Created By",
                                  value: isCreator ? "You" : "Admin",
                                  flex: 2,
                                ),
                                _vDivider(),
                                _infoColumn(
                                  title: "Members",
                                  value: data?.memberCount?.toString() ?? "0",
                                  flex: 2,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (isActive)
                            GestureDetector(
                              onTap: () {
                                if (data == null) return;
                                QrCodeBottomSheet.show(
                                  context,
                                  groupName: data.groupName ?? "Group",
                                  groupCode: data.groupCode ?? "",
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(7.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xff5045B9),
                                    width: 1.4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 20.sp,
                                  color: const Color(0xff5045B9),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isActive && !isCreator) ...[
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {
                            if (data == null) return;
                            CommonDialog.ConfirmationDialog(
                              title: AppText.areYouSure,
                              content: AppText.doYouWantToExitGroup,
                              onConfirm: () {
                                Get.back();
                                MemberController().exitGroup(
                                  context,
                                  groupId: data.id.toString(),
                                  userId: Global.storageServices
                                      .get(PrefConst.userId)
                                      .toString(),
                                  onSuccess: (success) {
                                    if (success) {
                                      groupController.groupData
                                          .removeWhere((g) => g.id == data.id);

                                      groupController.getGroupData();
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffB3261E),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                reausabletext(
                                  "Exit Group",
                                  fontfamily: FontFamily.interSemiBold,
                                  fontsize: 11,
                                  color: Colors.white,
                                ),
                                const Icon(
                                  Icons.exit_to_app_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoColumn({
    required String title,
    required String value,
    bool showCopy = false,
    VoidCallback? onCopy,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reausabletext(
            title,
            fontsize: 9.sp,
            color: Colors.grey.shade600,
            fontfamily: FontFamily.interRegular,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Flexible(
                child: reausabletext(
                  value,
                  fontsize: 11.sp,
                  color: const Color(0xff5045B9),
                  fontfamily: FontFamily.interSemiBold,
                  maxline: 1,
                  textoverflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCopy) ...[
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(Icons.copy,
                      size: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      height: 26.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      color: Colors.grey.shade300,
    );
  }
}