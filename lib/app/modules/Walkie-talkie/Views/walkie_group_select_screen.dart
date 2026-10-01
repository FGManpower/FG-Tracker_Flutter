import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/BottomSheet/bottom_actions_bar.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
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
  final bool isSelfPurchased;
  final bool isPurchasedByOtherAdmin;

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
    this.isSelfPurchased = false,
    this.isPurchasedByOtherAdmin = false,
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

  // Pagination state for members
  final RxInt _currentMemberPage = 1.obs;
  final RxBool _hasNextMemberPage = false.obs;
  final RxBool _isLoadingMoreMembers = false.obs;

  // Active Subscription ID & in-progress updates
  final RxnInt activeSubscriptionId = RxnInt();
  final RxBool isSubmittingMembers = false.obs;

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

  Future<void> fetchMembersFromApi({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreMembers.value || !_hasNextMemberPage.value) return;
      _isLoadingMoreMembers.value = true;
    } else {
      isMembersLoading.value = true;
      _currentMemberPage.value = 1;
    }

    try {
      final int pageToFetch = loadMore ? _currentMemberPage.value + 1 : 1;
      final List<AssignedMemberItem> loaded = [];

      // 1. Primary: All Group Members API (filter=subscription)
      try {
        debugPrint(
            "🚀 [Walkie] Fetching subscription group members (filter=subscription, page=$pageToFetch)...");
        final GroupMemberModel subRes = await TrackRepo.getGroupMember(
          page: pageToFetch.toString(),
          filter: 'subscription',
          limit: 20,
          groupId: _currentGroupId.isNotEmpty ? _currentGroupId : null,
        );

        if (subRes.status == true && subRes.data != null) {
          // Update pagination metadata from API
          if (subRes.pagination != null) {
            _hasNextMemberPage.value = subRes.pagination?.hasNextPage ?? false;
            _currentMemberPage.value =
                subRes.pagination?.currentPage ?? pageToFetch;
          } else {
            _hasNextMemberPage.value = false;
          }

          final List<GroupMemberData> subscribedList =
              subRes.data?.subscriptionData?.subscribed ?? [];
          final List<GroupMemberData> expiredList =
              subRes.data?.subscriptionData?.expired ?? [];
          final List<GroupMemberData> members =
              subRes.data?.allMemberList ?? [...subscribedList, ...expiredList];

          if (!loadMore) {
            WalkieCurrentSubscription? activeTeamSub;
            WalkieCurrentSubscription? activeIndivSub;
            try {
              final overviewData =
                  await WalkieTalkieTrialService().getOverview();
              final myId = int.tryParse(
                  Global.storageServices.get(PrefConst.userId)?.toString() ??
                      '');
              final allSubs =
                  overviewData.subscription?.activeSubscriptions ?? [];
              final ownedSubs = myId != null
                  ? allSubs.where((s) => s.ownerUserId == myId).toList()
                  : allSubs;
              activeTeamSub = ownedSubs.firstWhereOrNull((s) =>
                  s.isGroup ||
                  s.purchasedSeats > 1 ||
                  s.plan?.planType.toLowerCase() == 'group' ||
                  s.plan?.planType.toLowerCase() == 'team');
              if (activeTeamSub == null && allSubs.isNotEmpty) {
                activeTeamSub = allSubs.firstWhereOrNull((s) =>
                    s.isGroup ||
                    s.purchasedSeats > 1 ||
                    s.plan?.planType.toLowerCase() == 'group' ||
                    s.plan?.planType.toLowerCase() == 'team');
              }
              activeIndivSub = ownedSubs.firstWhereOrNull((s) =>
                  s.isIndividual ||
                  s.plan?.planType.toLowerCase() == 'individual');
            } catch (e) {
              debugPrint("Overview fetch error in group select: $e");
            }

            final user = subRes.user;
            final userSub = subRes.user?.subscription;
            final subMeta = subRes.data?.subscriptionData?.metaData;

            final bool hasTeamPlan = activeTeamSub != null ||
                user?.accessType?.toLowerCase() == 'team' ||
                userSub?.isTeamPlanActive == true ||
                userSub?.teamPlan != null ||
                (userSub?.teamPlans != null &&
                    userSub!.teamPlans!.isNotEmpty) ||
                (subMeta?.teamPlans != null &&
                    subMeta!.teamPlans!.isNotEmpty) ||
                (subMeta?.canAssignMember == true) ||
                userSub?.planType?.toLowerCase() == 'group' ||
                userSub?.planType?.toLowerCase() == 'team' ||
                (userSub?.purchasedSeats != null &&
                    userSub!.purchasedSeats! > 1) ||
                (subMeta?.totalPurchasedSeats != null &&
                    subMeta!.totalPurchasedSeats! > 1);

            final bool isIndiv = !hasTeamPlan &&
                (activeIndivSub != null ||
                    user?.accessType?.toLowerCase() == 'individual' ||
                    userSub?.isIndividualOnly == true ||
                    userSub?.individual != null ||
                    userSub?.planType?.toLowerCase() == 'individual' ||
                    userSub?.purchasedSeats == 1);

            final bool isSubscribed = activeTeamSub != null ||
                activeIndivSub != null ||
                user?.isSubscribed == true ||
                user?.subscriptionStatus?.toLowerCase() == 'active' ||
                userSub?.subscriptionId != null ||
                userSub?.planId != null;

            final bool isNoSub = !isSubscribed || (!hasTeamPlan && !isIndiv);
            final bool allowAssign = hasTeamPlan &&
                ((subMeta?.canAssignMember ?? userSub?.allowAssign) ?? true);

            isIndividualPlan.value = isIndiv;
            hasNoPlan.value = isNoSub;
            canAssignMembers.value = allowAssign;

            if (activeTeamSub != null) {
              planTitleName.value =
                  activeTeamSub.plan?.name.isNotEmpty == true
                      ? activeTeamSub.plan!.name
                      : "Team Plan";
              activeSubscriptionId.value = activeTeamSub.id;
              maxAllowedSeats.value = activeTeamSub.purchasedSeats > 0
                  ? activeTeamSub.purchasedSeats
                  : 1;
            } else if (isIndiv && activeIndivSub != null) {
              planTitleName.value =
                  activeIndivSub.plan?.name.isNotEmpty == true
                      ? activeIndivSub.plan!.name
                      : "Individual Plan";
              activeSubscriptionId.value = activeIndivSub.id;
              maxAllowedSeats.value = 1;
            } else {
              // Fallback to subRes
              if (userSub?.teamPlan?.planName != null) {
                planTitleName.value = userSub!.teamPlan!.planName!;
              } else if (userSub?.teamPlans != null &&
                  userSub!.teamPlans!.isNotEmpty) {
                planTitleName.value =
                    userSub!.teamPlans!.first.planName ?? "Team Plan";
              } else if (subMeta?.teamPlans != null &&
                  subMeta!.teamPlans!.isNotEmpty) {
                planTitleName.value =
                    subMeta!.teamPlans!.first.planName ?? "Team Plan";
              } else if (userSub?.planName != null &&
                  userSub!.planName!.isNotEmpty) {
                planTitleName.value = userSub.planName!;
              } else if (isIndiv && userSub?.individual?.planName != null) {
                planTitleName.value = userSub!.individual!.planName!;
              } else {
                planTitleName.value = "";
              }

              int? detectedSubId = userSub?.teamPlan?.subscriptionId;
              if (detectedSubId == null &&
                  userSub?.teamPlans != null &&
                  userSub!.teamPlans!.isNotEmpty) {
                detectedSubId = userSub.teamPlans!.first.subscriptionId;
              }
              if (detectedSubId == null &&
                  subMeta?.teamPlans != null &&
                  subMeta!.teamPlans!.isNotEmpty) {
                detectedSubId = subMeta.teamPlans!.first.subscriptionId;
              }
              detectedSubId ??= userSub?.subscriptionId ??
                  userSub?.individual?.subscriptionId;

              if (detectedSubId == null) {
                for (var m in subscribedList) {
                  if (m.subscription?.subscriptionId != null) {
                    detectedSubId = m.subscription!.subscriptionId;
                    break;
                  }
                }
              }
              activeSubscriptionId.value = detectedSubId;

              // Compute team-specific seats
              int? teamSeats = userSub?.teamPlan?.purchasedSeats;
              if (teamSeats == null || teamSeats <= 0) {
                if (userSub?.teamPlans != null &&
                    userSub!.teamPlans!.isNotEmpty) {
                  teamSeats = userSub!.teamPlans!.first.purchasedSeats;
                }
              }
              if (teamSeats == null || teamSeats <= 0) {
                if (subMeta?.teamPlans != null &&
                    subMeta!.teamPlans!.isNotEmpty) {
                  teamSeats = subMeta!.teamPlans!.first.purchasedSeats;
                }
              }
              if (teamSeats == null || teamSeats <= 0) {
                for (var m in subscribedList) {
                  if (m.subscription?.teamPlan?.purchasedSeats != null &&
                      m.subscription!.teamPlan!.purchasedSeats! > 0) {
                    teamSeats = m.subscription!.teamPlan!.purchasedSeats;
                    break;
                  }
                }
              }

              if (isNoSub) {
                maxAllowedSeats.value = 0;
              } else if (isIndiv) {
                maxAllowedSeats.value = 1;
              } else if (teamSeats != null && teamSeats > 0) {
                maxAllowedSeats.value = teamSeats;
              } else if (subMeta?.totalPurchasedSeats != null &&
                  subMeta!.totalPurchasedSeats! > 0) {
                maxAllowedSeats.value = subMeta!.totalPurchasedSeats!;
              } else if (subscribedList.isNotEmpty) {
                maxAllowedSeats.value = subscribedList.length;
              } else {
                maxAllowedSeats.value = 1;
              }
            }

            debugPrint(
                "🎯 [Walkie] Plan: ${planTitleName.value} | SubId: ${activeSubscriptionId.value} | MaxSeats: ${maxAllowedSeats.value} | AllowAssign: $allowAssign");
          }

          final List<AssignedMemberItem> loadedSubscribed = [];
          final List<AssignedMemberItem> loadedExpired = [];

          for (var m in members) {
            final String uid = m.userId?.toString() ?? "";
            if (uid.isNotEmpty) {
              if (loadMore) {
                if (assignedMembers.any((e) => e.id == uid) ||
                    availableMembers.any((e) => e.id == uid) ||
                    loaded.any((e) => e.id == uid)) {
                  continue;
                }
              } else {
                if (loaded.any((e) => e.id == uid)) continue;
              }
            }

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

            final bool isSub =
                subscribedList.any((s) => s.userId == m.userId) ||
                    m.isSubscribedByAdmin == true;

            final bool hasAccess = m.existingAccess?.hasAccess == true;
            final String? accessType =
                m.existingAccess?.accessType?.toLowerCase();

            // Self purchased if explicitly marked or if existing access is individual
            final bool selfPurchased =
                m.existingAccess?.individual?.isSelfPurchased == true ||
                    (hasAccess && accessType == "individual");

            // Other admin's plan if member has active access, but wasn't assigned by current admin and isn't self-purchased
            final bool otherAdmin = hasAccess && !isSub && !selfPurchased;

            // If someone else already assigned a seat to this member, do NOT show in the list at all
            if (otherAdmin) {
              continue;
            }

            final item = AssignedMemberItem(
              id: uid.isNotEmpty ? uid : UniqueKey().toString(),
              name: m.displayName.isNotEmpty ? m.displayName : "Member",
              role: role,
              imageUrl: img,
              isSubscribedByAdmin: isSub,
              canRemoveTeam: m.canRemoveTeam ??
                  m.canRemove ??
                  m.adminSubscription?.canRemoveTeam ??
                  true,
              canAssignTeamSeat: m.canAssignTeamSeat ?? true,
              existingAccessType: accessType,
              hasExistingAccess: hasAccess,
              isSelfPurchased: selfPurchased,
              isPurchasedByOtherAdmin: otherAdmin,
            );

            loaded.add(item);

            if (isSub) {
              loadedSubscribed.add(item);
            } else {
              loadedExpired.add(item);
            }
          }

          if (loadMore) {
            if (loadedSubscribed.isNotEmpty) {
              assignedMembers.addAll(loadedSubscribed);
            }
            if (loadedExpired.isNotEmpty) {
              availableMembers.addAll(loadedExpired);
            }
          } else {
            if (loadedSubscribed.isNotEmpty || loadedExpired.isNotEmpty) {
              if (isIndividualPlan.value && loadedSubscribed.length > 1) {
                assignedMembers.assignAll([loadedSubscribed.first]);
                final extra = loadedSubscribed.skip(1);
                availableMembers.assignAll([...extra, ...loadedExpired]);
              } else {
                assignedMembers.assignAll(loadedSubscribed);
                availableMembers.assignAll(loadedExpired);
              }
            }
          }

          debugPrint(
              "✅ [Walkie] ${loadMore ? 'Page $pageToFetch' : 'Initial'} Loaded ${loaded.length} members (Subscribed: ${loadedSubscribed.length}, Expired/Available: ${loadedExpired.length})");
        }
      } catch (e) {
        debugPrint("❌ Error fetching filter=subscription members: $e");
      }

      // 2. Secondary fallback: GroupRepo.getMemberData if available (only on initial load)
      if (!loadMore && loaded.isEmpty && controller.groupData.isNotEmpty) {
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

      // 3. Fallback: try TrackRepo.getGroupMember without filter (filter='all') (only on initial load)
      if (!loadMore && loaded.isEmpty) {
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

      if (!loadMore && loaded.isNotEmpty) {
        if (assignedMembers.isEmpty && availableMembers.isEmpty) {
          if (loaded.length <= 5) {
            assignedMembers.assignAll(loaded);
            availableMembers.clear();
          } else {
            assignedMembers.assignAll(loaded.sublist(0, 5));
            availableMembers.assignAll(loaded.sublist(5));
          }
        }
      } else if (!loadMore) {
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
      _isLoadingMoreMembers.value = false;
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

  Future<bool> _canAccessWalkie() async {
    if (!hasNoPlan.value) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(PrefConst.userId) ?? '';
      final trialRemaining = prefs.getInt('walkie_trial_remaining_seconds_$userId');
      if (trialRemaining == null || trialRemaining > 0) {
        return true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  Widget _apiGroupCard(GroupsResData group, int index) {
    final colors = colorPool[index % colorPool.length];
    final String groupId = group.id?.toString() ?? "unknown";
    final bool isOnline = (index % 2 == 0);

    return InkWell(
      onTap: () async {
        final canAccess = await _canAccessWalkie();
        if (!canAccess) {
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
            'isSubscribed': !hasNoPlan.value,
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
              onTap: () async {
                final canAccess = await _canAccessWalkie();
                if (!canAccess) {
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
                    'isSubscribed': !hasNoPlan.value,
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
    final ScrollController sheetScrollController = ScrollController();
    final RxString sheetQuery = ''.obs;

    sheetScrollController.addListener(() {
      if (sheetScrollController.hasClients &&
          sheetScrollController.position.pixels >=
              sheetScrollController.position.maxScrollExtent - 200) {
        if (_hasNextMemberPage.value &&
            !_isLoadingMoreMembers.value &&
            !isMembersLoading.value) {
          fetchMembersFromApi(loadMore: true);
        }
      }
    });

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
                                      ? "Individual Plan (Self Access Only) • Upgrade to Team to assign members"
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

              // Basic Plan Details Banner
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h),
                child: Obx(() {
                  final bool noPlan = hasNoPlan.value;
                  final bool isIndiv = isIndividualPlan.value;
                  final String title = planTitleName.value.isNotEmpty
                      ? planTitleName.value
                      : (isIndiv
                          ? "Individual Plan"
                          : (noPlan ? "No Active Plan" : "Team Plan"));
                  final int totalSeats = maxAllowedSeats.value > 0
                      ? maxAllowedSeats.value
                      : (isIndiv ? 1 : 0);
                  final int assignedCount = assignedMembers.length;
                  final int remainingSeats =
                      (totalSeats - assignedCount).clamp(0, totalSeats);

                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: noPlan
                            ? [
                                const Color(0xFFFFF1F2),
                                const Color(0xFFFFE4E6)
                              ]
                            : (isIndiv
                                ? [
                                    const Color(0xFFFFF7ED),
                                    const Color(0xFFFFEDD5)
                                  ]
                                : [
                                    const Color(0xFFF5F3FF),
                                    const Color(0xFFEDE9FE)
                                  ]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: noPlan
                            ? const Color(0xFFFECDD3)
                            : (isIndiv
                                ? const Color(0xFFFED7AA)
                                : const Color(0xFFDDD6FE)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: noPlan
                                ? const Color(0xFFE11D48)
                                : (isIndiv
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF5B4DFF)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            noPlan
                                ? Icons.lock_outline_rounded
                                : (isIndiv
                                    ? Icons.person_rounded
                                    : Icons.workspace_premium_rounded),
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontFamily: FontFamily.interBold,
                                        color: const Color(0xFF1E1B4B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!noPlan)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                            color: const Color(0xFFA7F3D0),
                                            width: 0.6),
                                      ),
                                      child: Text(
                                        "Active",
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontFamily: FontFamily.interBold,
                                          color: const Color(0xFF047857),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                noPlan
                                    ? "Subscribe to a Team Plan to assign seats"
                                    : (isIndiv
                                        ? "1 Seat Included (Self Access Only)"
                                        : "$totalSeats Total Seats • $assignedCount Assigned • $remainingSeats Available"),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: FontFamily.interRegular,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
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
                    controller: sheetScrollController,
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
                      Obx(() {
                        if (_isLoadingMoreMembers.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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
                      return SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
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
                                Icons.groups_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              reausabletext(
                                "Upgrade to Team Plan (Assign Members)",
                                fontsize: 14.5.sp,
                                fontfamily: FontFamily.interSemiBold,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: Obx(() {
                        final bool isSubmitting = isSubmittingMembers.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B4DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () => _submitAssignedMembers(),
                          child: isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoActivityIndicator(
                                      color: Colors.white,
                                      radius: 9.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    reausabletext(
                                      "Updating Members...",
                                      fontsize: 15.sp,
                                      fontfamily: FontFamily.interSemiBold,
                                      color: Colors.white,
                                    ),
                                  ],
                                )
                              : Row(
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
                        );
                      }),
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
            "Currently Assigned (2)",
            fontsize: 14.sp,
            fontfamily: FontFamily.interBold,
            color: const Color(0xFF1E1B4B),
          ),
          SizedBox(height: 8.h),
          ...List.generate(
            2,
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
            8,
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
      final bool isIndiv = isIndividualPlan.value;
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
                  // SizedBox(height: 2.h),
                  // reausabletext(
                  //   member.role,
                  //   fontsize: 12.sp,
                  //   color: const Color(0xFF6B7280),
                  // ),
                ],
              ),
            ),
            if (isIndiv || member.isSelfPurchased)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 13.sp, color: const Color(0xFF1D4ED8)),
                    SizedBox(width: 4.w),
                    Text(
                      "Self Access",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF1D4ED8),
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ],
                ),
              )
            else if (member.isPurchasedByOtherAdmin || !member.canRemoveTeam)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 13.sp, color: const Color(0xFFB45309)),
                    SizedBox(width: 4.w),
                    Text(
                      "Other Team",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFFB45309),
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ],
                ),
              )
            else
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
                  // SizedBox(height: 2.h),
                  // reausabletext(
                  //   member.role,
                  //   fontsize: 12.sp,
                  //   color: const Color(0xFF6B7280),
                  // ),
                ],
              ),
            ),
            if (member.isSelfPurchased)
              // User has already purchased plan by herself -> No Add/Remove option visible
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 12.sp, color: const Color(0xFF1D4ED8)),
                    SizedBox(width: 3.w),
                    Text(
                      "Self Plan",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF1D4ED8),
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ],
                ),
              )
            else if (member.isPurchasedByOtherAdmin)
              // Plan purchased by someone else -> Current user cannot Add/Remove
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 12.sp, color: const Color(0xFFB45309)),
                    SizedBox(width: 3.w),
                    Text(
                      "Other Team",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFFB45309),
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ],
                ),
              )
            else if (isIndiv)
              // Admin has Individual Plan -> Show Team Plan lock prompt
              GestureDetector(
                onTap: () {
                  _showUpgradePrompt(context: context, isNoPlan: false);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: const Color(0xFFFFEDD5), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 12.sp, color: const Color(0xFFEA580C)),
                      SizedBox(width: 3.w),
                      Text(
                        "Team Plan",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFFEA580C),
                          fontFamily: FontFamily.interSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (isNoSub)
              // No plan -> Show Get Plan prompt
              GestureDetector(
                onTap: () {
                  _showUpgradePrompt(context: context, isNoPlan: true);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: const Color(0xFFFECDD3), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 12.sp, color: const Color(0xFFE11D48)),
                      SizedBox(width: 3.w),
                      Text(
                        "Get Plan",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFFE11D48),
                          fontFamily: FontFamily.interSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Person whose plan is expired or not subscribed -> Add (+) button
              GestureDetector(
                onTap: () {
                  if (isTeamLimitReached) {
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
                    color: isTeamLimitReached
                        ? const Color(0xFFF3F4F6)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTeamLimitReached
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF6B4DFF),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18.sp,
                    color: isTeamLimitReached
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B4DFF),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _submitAssignedMembers() async {
    final int? subId = activeSubscriptionId.value;
    if (subId == null) {
      Utils().fluttertoast("No active subscription found");
      return;
    }

    if (assignedMembers.isEmpty) {
      Utils().fluttertoast("Please select at least one member to assign");
      return;
    }

    final List<int> targetUserIds = assignedMembers
        .map((m) => int.tryParse(m.id))
        .whereType<int>()
        .toList();

    if (targetUserIds.isEmpty) {
      Utils().fluttertoast("No valid members selected to assign");
      return;
    }

    try {
      isSubmittingMembers.value = true;
      final res = await WalkiePlanRepo.updateMemberSubscription(
        subscriptionId: subId,
        targetUserIds: targetUserIds,
      );

      if (res.status == true) {
        final msg = res.message;
        Utils().fluttertoast((msg != null && msg.isNotEmpty)
            ? msg
            : "Assigned members updated successfully");
        Get.back();
        fetchMembersFromApi();
      } else {
        final msg = res.message;
        Utils().fluttertoast((msg != null && msg.isNotEmpty)
            ? msg
            : "Failed to update assigned members");
      }
    } catch (e) {
      debugPrint("❌ [Walkie] Error submitting member subscriptions: $e");
      Utils().fluttertoast("Error: ${e.toString()}");
    } finally {
      isSubmittingMembers.value = false;
    }
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
