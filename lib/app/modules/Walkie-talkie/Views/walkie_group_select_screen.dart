import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/BottomSheet/bottom_actions_bar.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Group/controller/Group_Controller.dart';

class AssignedMemberItem {
  final String id;
  final String name;
  final String role;
  final String imageUrl;

  AssignedMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}

class WalkieGroupSelectScreen extends StatefulWidget {
  const WalkieGroupSelectScreen({super.key});

  @override
  State<WalkieGroupSelectScreen> createState() =>
      _WalkieGroupSelectScreenState();
}

class _WalkieGroupSelectScreenState extends State<WalkieGroupSelectScreen> {
  final GroupController controller = Get.put(GroupController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RxString _searchQuery = ''.obs;
  final RxMap<String, bool> activeToggles = <String, bool>{}.obs;
  final RxBool isMembersLoading = false.obs;

  // Assigned and available members
  final RxList<AssignedMemberItem> assignedMembers = <AssignedMemberItem>[
    AssignedMemberItem(
      id: "1",
      name: "Rohit Sharma",
      role: "Site Supervisor",
      imageUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "2",
      name: "Amit Verma",
      role: "Electrician",
      imageUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "3",
      name: "Suresh Yadav",
      role: "Carpenter",
      imageUrl:
          "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "4",
      name: "Imran Khan",
      role: "Helper",
      imageUrl:
          "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "5",
      name: "Vikash Patel",
      role: "Painter",
      imageUrl:
          "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80",
    ),
  ].obs;

  final RxList<AssignedMemberItem> availableMembers = <AssignedMemberItem>[
    AssignedMemberItem(
      id: "6",
      name: "Arjun Mehta",
      role: "Helper",
      imageUrl:
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "7",
      name: "Sameer Shaikh",
      role: "Electrician",
      imageUrl:
          "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80",
    ),
    AssignedMemberItem(
      id: "8",
      name: "Manoj Tiwari",
      role: "Mason",
      imageUrl:
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80",
    ),
  ].obs;

  String get _currentGroupId {
    if (controller.groupData.isNotEmpty &&
        controller.groupData.first.id != null) {
      return controller.groupData.first.id.toString();
    }
    return "";
  }

  List<GroupsResData> get _filteredGroups {
    final String query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return controller.groupData;
    return controller.groupData.where((group) {
      final String name = (group.groupName ?? '').toLowerCase();
      final String code = (group.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();
  }

  Future<void> fetchMembersFromApi() async {
    try {
      isMembersLoading.value = true;
      final List<AssignedMemberItem> loaded = [];

      // 1. Primary: Proper All Members API (TrackRepo.getGroupMember)
      try {
        final GroupMemberModel allRes = await TrackRepo.getGroupMember(
          page: '1',
          filter: 'all',
          limit: 50,
        );

        if (allRes.status == true) {
          final List<GroupMemberData> members =
              allRes.data?.allMember?.memberList ??
                  allRes.data?.active ??
                  allRes.data?.recentActive ??
                  allRes.data?.allMemberList ??
                  [];

          for (var m in members) {
            final String uid = m.userId?.toString() ?? "";
            if (uid.isNotEmpty && loaded.any((e) => e.id == uid)) continue;

            String img = m.profileImage?.toString() ?? "";
            if (img.isNotEmpty &&
                !img.startsWith("http") &&
                img.toLowerCase() != "null") {
              img = "${ConstRes.aImageBaseUrl}$img";
            } else if (img.toLowerCase() == "null") {
              img = "";
            }

            final String role = (m.role != null && m.role!.trim().isNotEmpty)
                ? m.role!.trim()
                : ((m.department != null && m.department!.trim().isNotEmpty)
                    ? m.department!.trim()
                    : "Member");

            loaded.add(
              AssignedMemberItem(
                id: uid.isNotEmpty ? uid : UniqueKey().toString(),
                name: (m.name != null && m.name!.trim().isNotEmpty)
                    ? m.name!.trim()
                    : "Member",
                role: role,
                imageUrl: img,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Error fetching from TrackRepo.getGroupMember: $e");
      }

      // 2. Secondary fallback: GroupRepo.getMemberData if available
      if (loaded.isEmpty && controller.groupData.isNotEmpty) {
        for (var grp in controller.groupData) {
          final gId = grp.id?.toString() ?? "";
          if (gId.isEmpty) continue;
          try {
            final MemberDataRes grpRes = await GroupRepo.getMemberData(gId);
            if (grpRes.status == true &&
                grpRes.memberData != null &&
                grpRes.memberData!.isNotEmpty) {
              for (var m in grpRes.memberData!) {
                final String uid =
                    m.userId?.toString() ?? m.id?.toString() ?? "";
                if (uid.isNotEmpty && loaded.any((e) => e.id == uid)) continue;

                String img = m.profileImage?.toString() ?? "";
                if (img.isNotEmpty &&
                    !img.startsWith("http") &&
                    img.toLowerCase() != "null") {
                  img = "${ConstRes.aImageBaseUrl}$img";
                } else if (img.toLowerCase() == "null") {
                  img = "";
                }

                final String role = (m.department != null &&
                        m.department!.trim().isNotEmpty)
                    ? m.department!.trim()
                    : ((m.team != null && m.team!.trim().isNotEmpty)
                        ? m.team!.trim()
                        : "Member");

                loaded.add(
                  AssignedMemberItem(
                    id: uid.isNotEmpty ? uid : UniqueKey().toString(),
                    name: (m.name != null && m.name!.trim().isNotEmpty)
                        ? m.name!.trim()
                        : "Member",
                    role: role,
                    imageUrl: img,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint("Error fetching group members for $gId: $e");
          }
          if (loaded.length >= 10) break;
        }
      }

      if (loaded.isNotEmpty) {
        if (loaded.length <= 5) {
          assignedMembers.assignAll(loaded);
          availableMembers.clear();
        } else {
          assignedMembers.assignAll(loaded.sublist(0, 5));
          availableMembers.assignAll(loaded.sublist(5));
        }
      }
    } catch (e) {
      debugPrint("Error in fetchMembersFromApi: $e");
    } finally {
      isMembersLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getGroupData();
      fetchMembersFromApi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  SizedBox(width: 10.w),
                  _buildAssignedButton(),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                if (controller.responseError.value.isNotEmpty) {
                  return LostinternetConnection(
                    retry: () {
                      controller.getGroupData();
                    },
                    messgae: controller.responseError.value.toString(),
                  );
                }
                if (controller.groupDataLoading.value) {
                  return _buildGroupList(isLoading: true);
                }
                final List<GroupsResData> groups = _filteredGroups;
                if (groups.isEmpty) {
                  return controller.groupData.isEmpty
                      ? DataEmpty_AssetsIcon(
                          assetspath: Assets.images.notFount.path)
                      : Center(
                          child: reausabletext(
                            "No groups found",
                            fontsize: 14.sp,
                            color: Colors.grey,
                          ),
                        );
                }
                return _buildGroupList(data: groups, isLoading: false);
              }),
            ),
          ],
        ),
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
          _circleIcon(
            icon: Icons.arrow_back,
            color: const Color(0xFF6B4DFF),
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "Walkie Talkie",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Select a group to connect",
                  fontsize: 11.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _circleIcon(
          icon: Icons.search,
          color: const Color(0xFF6B4DFF),
          onTap: () {
            _searchFocusNode.requestFocus();
          },
        ),
        SizedBox(width: 8.w),
        _circleIcon(
          icon: Icons.add,
          color: const Color(0xFF6B4DFF),
          onTap: () {
            try {
              controller.groupName.clear();
              controller.groupDesc.clear();
            } catch (e) {
              debugPrint("Clear error: $e");
            }
            showCreateGroupSheet();
          },
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
          Icon(Icons.search, size: 20.sp, color: const Color(0xFF6B4DFF)),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() {
              return TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => _searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: "Search groups",
                  hintStyle: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.grey,
                    fontFamily: FontFamily.interRegular,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: _searchQuery.value.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _searchQuery.value = '';
                          },
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedButton() {
    return GestureDetector(
      onTap: () {
        fetchMembersFromApi();
        _showEditAssignedMembersBottomSheet(context);
      },
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4DFF).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_rounded,
              size: 16.sp,
              color: const Color(0xFF6B4DFF),
            ),
            SizedBox(width: 6.w),
            Obx(
              () => reausabletext(
                "Assigned (${assignedMembers.length})",
                fontsize: 12.sp,
                fontfamily: FontFamily.interSemiBold,
                color: const Color(0xFF6B4DFF),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList({
    List<GroupsResData>? data,
    bool isLoading = false,
  }) {
    final List<GroupsResData>? items = isLoading ? null : data;
    final int itemCount = items?.length ?? 6;
    return Skeletonizer(
      enabled: items == null,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 4.h, bottom: 12.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final List<GroupsResData>? list = items;
          if (list == null) return const _GroupCardSkeleton();
          return _apiGroupCard(list[index], index);
        },
      ),
    );
  }

  Widget _apiGroupCard(GroupsResData group, int index) {
    final colors = colorPool[index % colorPool.length];
    final String groupId = group.id?.toString() ?? "unknown";
    final bool isOnline = (index % 2 == 0);

    return InkWell(
      onTap: () {
        Get.to(
          () => const GroupWalkieScreen(),
          arguments: {
            'groupId': groupId,
            'groupName': group.groupName ?? "Unknown Group",
            'groupDesc': group.groupDesc ?? "",
            'groupCode': group.groupCode ?? "",
          },
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: colors['bg'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_rounded,
                color: colors['icon'],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    group.groupName ?? "No Name Group",
                    fontsize: 15.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        size: 13.sp,
                        color: const Color(0xFF8C90A0),
                      ),
                      SizedBox(width: 4.w),
                      reausabletext(
                        "${group.memberCount ?? 0} Members",
                        fontsize: 12.sp,
                        color: const Color(0xFF8C90A0),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        width: 3.5.w,
                        height: 3.5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8C90A0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      reausabletext(
                        isOnline ? "Online" : "Offline",
                        fontsize: 12.sp,
                        fontfamily: FontFamily.interMedium,
                        color: isOnline
                            ? const Color(0xFF00C853)
                            : const Color(0xFF9E9E9E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              final bool isToggled = activeToggles[groupId] ?? false;
              return CupertinoSwitch(
                value: isToggled,
                activeColor: const Color(0xFF6B4DFF),
                onChanged: (bool value) {
                  activeToggles[groupId] = value;
                },
              );
            }),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () {
                Get.to(
                  () => const GroupWalkieScreen(),
                  arguments: {
                    'groupId': groupId,
                    'groupName': group.groupName ?? "Unknown Group",
                    'groupDesc': group.groupDesc ?? "",
                    'groupCode': group.groupCode ?? "",
                  },
                );
              },
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFF),
                  border: Border.all(
                    color: const Color(0xFFECEBFA),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Image.asset(
                    Assets.icons.walkieTalkie.path,
                    width: 20.w,
                    height: 20.w,
                    color: const Color(0xFF6B4DFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showEditAssignedMembersBottomSheet(BuildContext context) {
    final TextEditingController sheetSearchController = TextEditingController();
    final RxString sheetQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4B7CC),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reausabletext(
                            "Edit Assigned Members",
                            fontsize: 18.sp,
                            fontfamily: FontFamily.interBold,
                            color: const Color(0xFF1E1B4B),
                          ),
                          SizedBox(height: 4.h),
                          reausabletext(
                            "You can have up to 5 members in this group",
                            fontsize: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          reausabletext(
                            "${assignedMembers.length}/5",
                            fontsize: 18.sp,
                            fontfamily: FontFamily.interBold,
                            color: const Color(0xFF5B4DFF),
                          ),
                          reausabletext(
                            "Assigned",
                            fontsize: 11.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 14.h),
                child: Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20.sp,
                        color: const Color(0xFF6B4DFF),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: sheetSearchController,
                          onChanged: (val) => sheetQuery.value = val,
                          decoration: InputDecoration(
                            hintText: "Search members...",
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF9E9E9E),
                              fontFamily: FontFamily.interRegular,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      Obx(() => sheetQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                sheetSearchController.clear();
                                sheetQuery.value = '';
                              },
                              child: Icon(
                                Icons.close,
                                size: 18.sp,
                                color: Colors.grey,
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFFF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: const Color(0xFF5B4DFF),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reausabletext(
                              "Each member can be assigned only once.",
                              fontsize: 12.sp,
                              fontfamily: FontFamily.interSemiBold,
                              color: const Color(0xFF4338CA),
                            ),
                            SizedBox(height: 2.h),
                            reausabletext(
                              "If you remove a member, you cannot assign them again.",
                              fontsize: 11.sp,
                              color: const Color(0xFF6366F1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (isMembersLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CupertinoActivityIndicator(
                          radius: 14,
                          color: Color(0xFF6B4DFF),
                        ),
                      ),
                    );
                  }

                  final q = sheetQuery.value.trim().toLowerCase();
                  final assignedList = assignedMembers.where((m) {
                    if (q.isEmpty) return true;
                    return m.name.toLowerCase().contains(q) ||
                        m.role.toLowerCase().contains(q);
                  }).toList();

                  final availableList = availableMembers.where((m) {
                    if (q.isEmpty) return true;
                    return m.name.toLowerCase().contains(q) ||
                        m.role.toLowerCase().contains(q);
                  }).toList();

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reausabletext(
                            "Currently Assigned (${assignedMembers.length})",
                            fontsize: 14.sp,
                            fontfamily: FontFamily.interBold,
                            color: const Color(0xFF1E1B4B),
                          ),
                          if (assignedMembers.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                availableMembers.addAll(assignedMembers);
                                assignedMembers.clear();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF5B4DFF),
                                  ),
                                  SizedBox(width: 4.w),
                                  reausabletext(
                                    "Remove All",
                                    fontsize: 12.sp,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: const Color(0xFF5B4DFF),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (assignedList.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            "No members currently assigned",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        ...assignedList.map((m) => _buildAssignedMemberTile(m)),
                      SizedBox(height: 16.h),
                      reausabletext(
                        "Available Members",
                        fontsize: 14.sp,
                        fontfamily: FontFamily.interBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                      SizedBox(height: 8.h),
                      if (availableList.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            "No available members",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        ...availableList.map((m) => _buildAvailableMemberTile(m)),
                    ],
                  );
                }),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 20.w, right: 20.w, bottom: 16.h, top: 8.h),
                  child: Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.back();
                          Utils().fluttertoast("Assigned members updated");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            reausabletext(
                              "Update Members (${assignedMembers.length})",
                              fontsize: 15.sp,
                              fontfamily: FontFamily.interSemiBold,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberAvatar(AssignedMemberItem member) {
    final bool hasValidUrl = member.imageUrl.isNotEmpty &&
        member.imageUrl.startsWith("http") &&
        member.imageUrl.toLowerCase() != "null";

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: hasValidUrl
          ? CachedNetworkImage(
              imageUrl: member.imageUrl,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => _avatarFallback(member.name),
              errorWidget: (context, url, error) =>
                  _avatarFallback(member.name),
            )
          : _avatarFallback(member.name),
    );
  }

  Widget _avatarFallback(String name) {
    final displayName = name.trim();
    final letter = displayName.isNotEmpty ? displayName[0].toUpperCase() : "M";
    return Container(
      width: 40.w,
      height: 40.w,
      color: const Color(0xFFEDE9FE),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: const Color(0xFF6B4DFF),
            fontFamily: FontFamily.interSemiBold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedMemberTile(AssignedMemberItem member) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _buildMemberAvatar(member),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  member.name,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: const Color(0xFF1E1B4B),
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  member.role,
                  fontsize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              assignedMembers.remove(member);
              availableMembers.insert(0, member);
            },
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 16.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableMemberTile(AssignedMemberItem member) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _buildMemberAvatar(member),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  member.name,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: const Color(0xFF1E1B4B),
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  member.role,
                  fontsize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (assignedMembers.length >= 5) {
                Utils().fluttertoast(
                    "You can have up to 5 members in this group");
              } else {
                availableMembers.remove(member);
                assignedMembers.add(member);
              }
            },
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6366F1),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18.sp,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Group name placeholder",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Members placeholder",
                  style: TextStyle(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(width: 40.w, height: 24.h, color: Colors.grey.shade200),
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
