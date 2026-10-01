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
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Group/controller/Group_Controller.dart';

class AssignedMemberItem {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final bool isSubscribedByAdmin;
  final bool canRemoveTeam;
  final bool canAssignTeamSeat;
  final String? existingAccessType;
  final bool hasExistingAccess;

  AssignedMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    this.isSubscribedByAdmin = false,
    this.canRemoveTeam = true,
    this.canAssignTeamSeat = true,
    this.existingAccessType,
    this.hasExistingAccess = false,
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
  final RxString membersError = ''.obs;
  final RxInt maxAllowedSeats = 5.obs;
  final RxBool canAssignMembers = true.obs;
  final RxBool isIndividualPlan = false.obs;
  final RxBool hasNoPlan = false.obs;
  final RxString planTitleName = "".obs;

  // Assigned and available members (loaded dynamically from API)
  final RxList<AssignedMemberItem> assignedMembers = <AssignedMemberItem>[].obs;
  final RxList<AssignedMemberItem> availableMembers =
      <AssignedMemberItem>[].obs;

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

      // 1. Primary: All Group Members API (filter=subscription)
      try {
        debugPrint("🚀 [Walkie] Fetching subscription group members (filter=subscription)...");
        final GroupMemberModel subRes = await TrackRepo.getGroupMember(
          page: '1',
          filter: 'subscription',
          limit: 50,
        );

        if (subRes.status == true && subRes.data != null) {
          final List<GroupMemberData> subscribedList =
              subRes.data?.subscriptionData?.subscribed ?? [];
          final List<GroupMemberData> expiredList =
              subRes.data?.subscriptionData?.expired ?? [];
          final List<GroupMemberData> members =
              subRes.data?.allMemberList ?? [...subscribedList, ...expiredList];

          // Extract subscription plan type and permissions
          final userSub = subRes.user?.subscription;
          final subMeta = subRes.data?.subscriptionData?.metaData;

          final bool isSubscribed = subRes.user?.isSubscribed == true ||
              userSub?.subscriptionId != null ||
              userSub?.planId != null ||
              (subMeta?.totalPurchasedSeats != null &&
                  subMeta!.totalPurchasedSeats! > 0);

          final bool hasTeamPlan = isSubscribed &&
              (userSub?.isTeamPlanActive == true ||
                  userSub?.teamPlan != null ||
                  (userSub?.teamPlans != null &&
                      userSub!.teamPlans!.isNotEmpty) ||
                  (subMeta?.teamPlans != null &&
                      subMeta!.teamPlans!.isNotEmpty) ||
                  (subMeta?.canAssignMember == true) ||
                  userSub?.planType == 'group' ||
                  userSub?.planType == 'team' ||
                  (userSub?.purchasedSeats != null &&
                      userSub!.purchasedSeats! > 1) ||
                  (subMeta?.totalPurchasedSeats != null &&
                      subMeta!.totalPurchasedSeats! > 1));

          final bool isIndiv = isSubscribed &&
              !hasTeamPlan &&
              (userSub?.isIndividualOnly == true ||
                  userSub?.individual != null ||
                  userSub?.planType?.toLowerCase() == 'individual' ||
                  userSub?.purchasedSeats == 1);

          final bool isNoSub = !hasTeamPlan && !isIndiv;
          final bool allowAssign = hasTeamPlan &&
              ((subMeta?.canAssignMember ?? userSub?.allowAssign) ?? true);

          isIndividualPlan.value = isIndiv;
          hasNoPlan.value = isNoSub;
          canAssignMembers.value = allowAssign;

          if (userSub?.planName != null && userSub!.planName!.isNotEmpty) {
            planTitleName.value = userSub.planName!;
          } else if (hasTeamPlan && userSub?.teamPlan?.planName != null) {
            planTitleName.value = userSub!.teamPlan!.planName!;
          } else if (hasTeamPlan &&
              userSub?.teamPlans != null &&
              userSub!.teamPlans!.isNotEmpty) {
            planTitleName.value =
                userSub!.teamPlans!.first.planName ?? "Team Plan";
          } else if (hasTeamPlan &&
              subMeta?.teamPlans != null &&
              subMeta!.teamPlans!.isNotEmpty) {
            planTitleName.value =
                subMeta!.teamPlans!.first.planName ?? "Team Plan";
          } else if (isIndiv && userSub?.individual?.planName != null) {
            planTitleName.value = userSub!.individual!.planName!;
          } else {
            planTitleName.value = "";
          }

          int? apiSeats = subMeta?.totalPurchasedSeats ??
              userSub?.teamPlan?.purchasedSeats ??
              userSub?.purchasedSeats;
          if (apiSeats == null || apiSeats <= 0) {
            if (userSub?.teamPlans != null && userSub!.teamPlans!.isNotEmpty) {
              apiSeats = userSub!.teamPlans!.first.purchasedSeats;
            }
          }
          if (apiSeats == null || apiSeats <= 0) {
            for (var m in subscribedList) {
              if (m.subscription?.teamPlan?.purchasedSeats != null &&
                  m.subscription!.teamPlan!.purchasedSeats! > 0) {
                apiSeats = m.subscription!.teamPlan!.purchasedSeats;
                break;
              } else if (m.subscription?.purchasedSeats != null &&
                  m.subscription!.purchasedSeats! > 0) {
                apiSeats = m.subscription!.purchasedSeats;
                break;
              }
            }
          }

          if (isNoSub) {
            maxAllowedSeats.value = 0;
            debugPrint(
                "🎯 [Walkie] No Plan detected: Member assignment disabled");
          } else if (isIndiv) {
            maxAllowedSeats.value = 1;
            debugPrint(
                "🎯 [Walkie] Individual Plan detected: 1 seat (Assignment disabled)");
          } else if (apiSeats != null && apiSeats > 0) {
            maxAllowedSeats.value = apiSeats;
            debugPrint(
                "🎯 [Walkie] Bound purchasedSeats: $apiSeats | allowAssign: $allowAssign");
          } else if (subscribedList.isNotEmpty) {
            maxAllowedSeats.value = subscribedList.length;
          } else {
            maxAllowedSeats.value = 5;
          }

          final List<AssignedMemberItem> loadedSubscribed = [];
          final List<AssignedMemberItem> loadedExpired = [];

          for (var m in members) {
            final String uid = m.userId?.toString() ?? "";
            if (uid.isNotEmpty && loaded.any((e) => e.id == uid)) continue;

            String img = m.resolvedImageUrl;
            if (img.isEmpty) {
              img = m.profileImage?.toString() ?? "";
              if (img.isNotEmpty &&
                  !img.startsWith("http") &&
                  img.toLowerCase() != "null") {
                img = "${ConstRes.aImageBaseUrl}$img";
              } else if (img.toLowerCase() == "null") {
                img = "";
              }
            }

            final String role = (m.role != null && m.role!.trim().isNotEmpty)
                ? m.role!.trim()
                : ((m.department != null && m.department!.trim().isNotEmpty)
                    ? m.department!.trim()
                    : (m.displayDepartment.isNotEmpty
                        ? m.displayDepartment
                        : "Member"));

            final bool isSub = subscribedList.any((s) => s.userId == m.userId) ||
                m.isSubscribedByAdmin == true;

            final bool hasAccess = m.existingAccess?.hasAccess == true;
            final String? accessType = m.existingAccess?.accessType?.toLowerCase();

            final item = AssignedMemberItem(
              id: uid.isNotEmpty ? uid : UniqueKey().toString(),
              name: m.displayName.isNotEmpty ? m.displayName : "Member",
              role: role,
              imageUrl: img,
              isSubscribedByAdmin: isSub,
              canRemoveTeam: m.canRemoveTeam ?? m.canRemove ?? true,
              canAssignTeamSeat: m.canAssignTeamSeat ?? true,
              existingAccessType: accessType,
              hasExistingAccess: hasAccess,
            );

            loaded.add(item);

            if (isSub) {
              loadedSubscribed.add(item);
            } else {
              loadedExpired.add(item);
            }
          }

          if (loadedSubscribed.isNotEmpty || loadedExpired.isNotEmpty) {
            if (isIndiv && loadedSubscribed.length > 1) {
              assignedMembers.assignAll([loadedSubscribed.first]);
              final extra = loadedSubscribed.skip(1);
              availableMembers.assignAll([...extra, ...loadedExpired]);
            } else {
              assignedMembers.assignAll(loadedSubscribed);
              availableMembers.assignAll(loadedExpired);
            }
          }

          debugPrint(
              "✅ [Walkie] Loaded ${loaded.length} members (Subscribed: ${loadedSubscribed.length}, Expired/Available: ${loadedExpired.length})");
        }
      } catch (e) {
        debugPrint("❌ Error fetching filter=subscription members: $e");
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

                final String role =
                    (m.department != null && m.department!.trim().isNotEmpty)
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

      // 3. Fallback: try TrackRepo.getGroupMember without filter (filter='all')
      if (loaded.isEmpty) {
        try {
          final GroupMemberModel allRes = await TrackRepo.getGroupMember(
            page: '1',
            filter: 'all',
            limit: 50,
          );
          final allList = allRes.data?.allMemberList ?? [];
          for (var m in allList) {
            final String uid = m.userId?.toString() ?? "";
            if (uid.isNotEmpty && loaded.any((e) => e.id == uid)) continue;

            String img = m.resolvedImageUrl;
            if (img.isEmpty) {
              img = m.profileImage?.toString() ?? "";
              if (img.isNotEmpty &&
                  !img.startsWith("http") &&
                  img.toLowerCase() != "null") {
                img = "${ConstRes.aImageBaseUrl}$img";
              } else if (img.toLowerCase() == "null") {
                img = "";
              }
            }

            final String role = (m.role != null && m.role!.trim().isNotEmpty)
                ? m.role!.trim()
                : ((m.department != null && m.department!.trim().isNotEmpty)
                    ? m.department!.trim()
                    : "Member");

            final item = AssignedMemberItem(
              id: uid.isNotEmpty ? uid : UniqueKey().toString(),
              name: m.displayName.isNotEmpty ? m.displayName : "Member",
              role: role,
              imageUrl: img,
            );
            loaded.add(item);
            availableMembers.add(item);
          }
        } catch (e) {
          debugPrint("Fallback filter=all error: $e");
        }
      }

      if (loaded.isNotEmpty) {
        if (assignedMembers.isEmpty && availableMembers.isEmpty) {
          if (loaded.length <= 5) {
            assignedMembers.assignAll(loaded);
            availableMembers.clear();
          } else {
            assignedMembers.assignAll(loaded.sublist(0, 5));
            availableMembers.assignAll(loaded.sublist(5));
          }
        }
      } else {
        membersError.value = "";
      }
    } catch (e) {
      debugPrint("Error in fetchMembersFromApi: $e");
      final errStr = e.toString().toLowerCase();
      if (errStr.contains("socketexception") ||
          errStr.contains("network is unreachable") ||
          errStr.contains("failed host lookup")) {
        membersError.value =
            "No internet connection. Please check your network.";
      } else {
        membersError.value = "";
      }
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
            _buildPlanStatusBanner(),
            SizedBox(height: 4.h),
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
        padding:
            EdgeInsets.only(left: 16.w, right: 16.w, top: 4.h, bottom: 12.h),
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
        if (hasNoPlan.value) {
          _showUpgradePrompt(context: context, isNoPlan: true);
          return;
        }
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
                if (hasNoPlan.value) {
                  _showUpgradePrompt(context: context, isNoPlan: true);
                  return;
                }
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

  Widget _buildPlanStatusBanner() {
    return Obx(() {
      if (hasNoPlan.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4DFF), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4DFF).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reausabletext(
                        "Plan Required to Talk",
                        fontsize: 13.5.sp,
                        fontfamily: FontFamily.interBold,
                        color: Colors.white,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Subscribe to start voice talk & assign members",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showUpgradePrompt(
                      context: context, isNoPlan: true),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: reausabletext(
                      "Get Plan",
                      fontsize: 11.5.sp,
                      fontfamily: FontFamily.interSemiBold,
                      color: const Color(0xFF5B4DFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (isIndividualPlan.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: const Color(0xFFEA580C), size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Individual Plan (1 Member). Upgrade to Team Plan to connect more members.",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF9A3412),
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showUpgradePrompt(
                      context: context, isNoPlan: false),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: reausabletext(
                      "Upgrade",
                      fontsize: 11.sp,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  void _showUpgradePrompt({
    required BuildContext context,
    required bool isNoPlan,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: isNoPlan
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNoPlan
                      ? Icons.workspace_premium_rounded
                      : Icons.groups_rounded,
                  color: isNoPlan
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFEA580C),
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              reausabletext(
                isNoPlan ? "Walkie Talkie Plan Required" : "Team Plan Required",
                fontsize: 18.sp,
                fontfamily: FontFamily.interBold,
                color: const Color(0xFF1E1B4B),
                align: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  isNoPlan
                      ? "You do not have an active Walkie Talkie subscription. Subscribe to a plan to assign members and start instant voice communication."
                      : "Your Individual Plan allows 1 member seat only. To assign multiple members and connect your entire team, please upgrade to a Team Plan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: FontFamily.interRegular,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
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
                    Get.to(() => WalkieTalkiePlanScreen(
                          initialTabIndex: isNoPlan ? 0 : 1,
                        ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isNoPlan
                            ? Icons.shopping_bag_outlined
                            : Icons.upgrade_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      reausabletext(
                        isNoPlan ? "Choose a Plan" : "Upgrade to Team Plan",
                        fontsize: 15.sp,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => Get.back(),
                child: reausabletext(
                  "Maybe Later",
                  fontsize: 13.sp,
                  color: const Color(0xFF9CA3AF),
                  fontfamily: FontFamily.interMedium,
                ),
              ),
              SizedBox(height: 6.h),
            ],
          ),
        );
      },
    );
  }

  void _showEditAssignedMembersBottomSheet(BuildContext context) {
    final TextEditingController sheetSearchController = TextEditingController();
    final RxString sheetQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
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
                          Obx(
                            () => reausabletext(
                              hasNoPlan.value
                                  ? "No active plan • Subscribe to assign members"
                                  : (isIndividualPlan.value
                                      ? "Individual Plan (1 Seat) • Upgrade to Team for more"
                                      : (maxAllowedSeats.value > 0
                                          ? "You can assign up to ${maxAllowedSeats.value} members in this group"
                                          : "Assign members to communicate in this group")),
                              fontsize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Obx(
                      () {
                        if (hasNoPlan.value) {
                          return GestureDetector(
                            onTap: () {
                              _showUpgradePrompt(
                                  context: context, isNoPlan: true);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(20.r),
                                border:
                                    Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline_rounded,
                                      size: 13.sp,
                                      color: const Color(0xFFE11D48)),
                                  SizedBox(width: 4.w),
                                  reausabletext(
                                    "Get Plan",
                                    fontsize: 11.sp,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (isIndividualPlan.value) {
                          return GestureDetector(
                            onTap: () {
                              _showUpgradePrompt(
                                  context: context, isNoPlan: false);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F0FF),
                                borderRadius: BorderRadius.circular(20.r),
                                border:
                                    Border.all(color: const Color(0xFFDDD6FE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded,
                                      size: 13.sp,
                                      color: const Color(0xFF5B4DFF)),
                                  SizedBox(width: 4.w),
                                  reausabletext(
                                    "${assignedMembers.length}/1 (Individual)",
                                    fontsize: 11.sp,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: const Color(0xFF5B4DFF),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            reausabletext(
                              "${assignedMembers.length}/${maxAllowedSeats.value > 0 ? maxAllowedSeats.value : 5}",
                              fontsize: 18.sp,
                              fontfamily: FontFamily.interBold,
                              color: const Color(0xFF5B4DFF),
                            ),
                            reausabletext(
                              "Selected",
                              fontsize: 11.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ],
                        );
                      },
                    ),
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
              // Clean UI: No error/warning banners shown here
              const SizedBox.shrink(),
              Expanded(
                child: Obx(() {
                  if (isMembersLoading.value &&
                      assignedMembers.isEmpty &&
                      availableMembers.isEmpty) {
                    return _buildMembersSkeleton();
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

                  if (assignedList.isEmpty && availableList.isEmpty) {
                    final bool isOffline = membersError.value.isNotEmpty &&
                        (membersError.value
                                .toLowerCase()
                                .contains("internet") ||
                            membersError.value
                                .toLowerCase()
                                .contains("network"));

                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 36.h, horizontal: 20.w),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0EFFF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isOffline
                                    ? Icons.wifi_off_rounded
                                    : (sheetQuery.value.isNotEmpty
                                        ? Icons.search_off_rounded
                                        : Icons.people_outline_rounded),
                                color: const Color(0xFF6B4DFF),
                                size: 32.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              isOffline
                                  ? "No Internet Connection"
                                  : (sheetQuery.value.isNotEmpty
                                      ? "No Members Match"
                                      : "No Members Found"),
                              style: TextStyle(
                                color: const Color(0xFF1E1B4B),
                                fontSize: 15.sp,
                                fontFamily: FontFamily.interBold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              isOffline
                                  ? "Please check your network connection and try again."
                                  : (sheetQuery.value.isNotEmpty
                                      ? "No members match '${sheetQuery.value}'"
                                      : "No group members available to assign."),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 12.sp,
                                fontFamily: FontFamily.interRegular,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            GestureDetector(
                              onTap: () => fetchMembersFromApi(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5B4DFF),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "Retry",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontFamily: FontFamily.interSemiBold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                          if (assignedMembers.isNotEmpty &&
                              !isIndividualPlan.value &&
                              canAssignMembers.value)
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
                        ...availableList
                            .map((m) => _buildAvailableMemberTile(m)),
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
                    if (hasNoPlan.value) {
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
                            Get.to(() => const WalkieTalkiePlanScreen(
                                  initialTabIndex: 0,
                                ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              reausabletext(
                                "Choose a Plan",
                                fontsize: 15.sp,
                                fontfamily: FontFamily.interSemiBold,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (isIndividualPlan.value) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
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
                                Utils().fluttertoast(
                                    "Assigned member saved (${assignedMembers.length}/1)");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 19.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  reausabletext(
                                    "Save Member (${assignedMembers.length}/1)",
                                    fontsize: 14.5.sp,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: double.infinity,
                            height: 44.h,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFEA580C), width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              onPressed: () {
                                Get.back();
                                Get.to(() => const WalkieTalkiePlanScreen(
                                      initialTabIndex: 1,
                                    ));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upgrade_rounded,
                                    size: 19.sp,
                                    color: const Color(0xFFEA580C),
                                  ),
                                  SizedBox(width: 6.w),
                                  reausabletext(
                                    "Upgrade to Team Plan (Add More)",
                                    fontsize: 13.5.sp,
                                    fontfamily: FontFamily.interSemiBold,
                                    color: const Color(0xFFEA580C),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

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
                              "Update Members (${assignedMembers.length}/${maxAllowedSeats.value})",
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

  Widget _buildMembersSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        children: [
          reausabletext(
            "Currently Assigned (3)",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
          ),
          SizedBox(height: 8.h),
          ...List.generate(
            3,
            (index) => _buildAssignedMemberTile(
              AssignedMemberItem(
                id: "sk_as_$index",
                name: "Loading Member Name",
                role: "Loading Role Title",
                imageUrl: "",
              ),
            ),
          ),
          SizedBox(height: 16.h),
          reausabletext(
            "Available Members",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
          ),
          SizedBox(height: 8.h),
          ...List.generate(
            4,
            (index) => _buildAvailableMemberTile(
              AssignedMemberItem(
                id: "sk_av_$index",
                name: "Loading Member Name",
                role: "Loading Role Title",
                imageUrl: "",
              ),
            ),
          ),
        ],
      ),
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
    return Obx(() {
      final bool isNoSub = hasNoPlan.value;
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
                if (isNoSub) {
                  _showUpgradePrompt(context: context, isNoPlan: true);
                } else if (!member.canRemoveTeam) {
                  Utils().fluttertoast(
                      "Cannot remove seat assigned by another admin");
                } else {
                  assignedMembers.remove(member);
                  availableMembers.insert(0, member);
                }
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
    });
  }

  Widget _buildAvailableMemberTile(AssignedMemberItem member) {
    return Obx(() {
      final bool isNoSub = hasNoPlan.value;
      final bool isIndiv = isIndividualPlan.value;
      final bool isIndivLimitReached = isIndiv && assignedMembers.length >= 1;
      final bool isTeamLimitReached = !isIndiv &&
          !isNoSub &&
          (assignedMembers.length >= maxAllowedSeats.value);

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
                  Row(
                    children: [
                      Flexible(
                        child: reausabletext(
                          member.role,
                          fontsize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (member.hasExistingAccess) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: member.existingAccessType == "individual"
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: member.existingAccessType == "individual"
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFFDE68A),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            member.existingAccessType == "individual"
                                ? "Self Plan"
                                : "Other Team",
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: member.existingAccessType == "individual"
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFFB45309),
                              fontFamily: FontFamily.interSemiBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (isNoSub) {
                  _showUpgradePrompt(context: context, isNoPlan: true);
                } else if (isIndivLimitReached) {
                  _showUpgradePrompt(context: context, isNoPlan: false);
                } else if (isTeamLimitReached) {
                  _showUpgradePrompt(context: context, isNoPlan: false);
                } else {
                  availableMembers.remove(member);
                  assignedMembers.add(member);
                }
              },
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: isNoSub
                      ? const Color(0xFFF3F4F6)
                      : (isIndivLimitReached
                          ? const Color(0xFFFFF7ED)
                          : (isTeamLimitReached
                              ? const Color(0xFFF3F4F6)
                              : Colors.white)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isNoSub
                        ? const Color(0xFFD1D5DB)
                        : (isIndivLimitReached
                            ? const Color(0xFFFDBA74)
                            : (isTeamLimitReached
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF6366F1))),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isIndivLimitReached
                      ? Icons.upgrade_rounded
                      : (isNoSub
                          ? Icons.lock_outline_rounded
                          : Icons.add_rounded),
                  size: (isIndivLimitReached || isNoSub) ? 15.sp : 18.sp,
                  color: isNoSub
                      ? const Color(0xFF9CA3AF)
                      : (isIndivLimitReached
                          ? const Color(0xFFEA580C)
                          : (isTeamLimitReached
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6366F1))),
                ),
              ),
            ),
          ],
        ),
      );
    });
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
