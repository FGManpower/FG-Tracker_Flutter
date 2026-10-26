import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/global_widget/invite_helper.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:fgtracker/app/modules/call/Controller/contact_controller.dart';
import 'package:fgtracker/app/modules/call/widget/SkeletonContactCard.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/contact_profile_screen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/constant/pref_res.dart';

class CallContactsTab extends StatefulWidget {
  const CallContactsTab({super.key});

  @override
  State<CallContactsTab> createState() => _CallContactsTabState();
}

class _CallContactsTabState extends State<CallContactsTab> {
  final CallController controller = CallController.instance;
  final ContactController contactController = ContactController.instance;
  final ScrollController scrollController = ScrollController();
  bool _loadMoreScheduled = false;

  @override
  void initState() {
    super.initState();

    contactController.checkContactPermission();
    contactController.getRegisteredContacts();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter > 500) return;
    if (_loadMoreScheduled) return;
    _loadMoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreScheduled = false;
      contactController.loadMoreContacts();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    final parts = trimmed.split(RegExp(r'\s+'));
    String first(String s) => String.fromCharCodes(s.runes.take(1));
    if (parts.length > 1) {
      return (first(parts[0]) + first(parts[1])).toUpperCase();
    }
    return first(parts[0]).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6B4DFF),
      const Color(0xFF1ECB9F),
      const Color(0xFFFF9F43),
      const Color(0xFF00A2FF),
      const Color(0xFFFF5252),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<UserListData> registered = contactController.filteredUsers;
      final List<UserListData> invites = contactController.filteredInviteUsers;
      final bool noData = contactController.allUserProfileData.isEmpty &&
          contactController.inviteUsers.isEmpty;

      if (contactController.responseError.value.isNotEmpty && noData) {
        return LostinternetConnection(
          retry: () {
            contactController.getRegisteredContacts();
          },
          messgae: contactController.responseError.value,
        );
      }

      if (contactController.contactLoading.value && noData) {
        return _buildContactsListUi(isLoading: true);
      }

      // Registered aur invite, dono khali ho tabhi empty screen
      if (registered.isEmpty && invites.isEmpty) {
        return _buildEmptyUi();
      }

      return _buildContactsListUi(
        contactData: registered,
        inviteData: invites,
        isLoading: false,
      );
    });
  }

  Widget _buildEmptyUi() {
    final bool isDialOpen = controller.isDialPadOpen.value;
    final bool isSearching = controller.searchQuery.value.isNotEmpty ||
        controller.dialNumber.value.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: contactController.refreshContacts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: isDialOpen ? 390.h : 90.h),
        children: [
          SizedBox(height: isDialOpen ? 15.h : 60.h),
          Center(
            child: Image.asset(
              Assets.images.notFount.path,
              width: isDialOpen ? 140.w : 240.w,
              height: isDialOpen ? 140.w : 240.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              isSearching
                  ? "No contacts match your search"
                  : "No registered contacts found",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsListUi({
    List<UserListData> contactData = const [],
    List<UserListData> inviteData = const [],
    bool isLoading = false,
  }) {
    final bool loading = isLoading;
    final int registeredCount = loading ? 8 : contactData.length;
    final bool isDialOpen = controller.isDialPadOpen.value;
    final bool showRegisteredHeader = loading || contactData.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: contactController.refreshContacts,
      child: Skeletonizer(
        enabled: loading,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 500,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                isDialOpen ? 390.h : 90.h,
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  if (!contactController.isContactPermissionGranted.value &&
                      !loading)
                    SliverToBoxAdapter(
                      child: buildPermissionBanner(
                          controller: contactController),
                    ),

                  if (showRegisteredHeader)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                        EdgeInsets.only(left: 4.w, bottom: 12.h, top: 4.h),
                        child: Text(
                          "All Contacts",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: FontFamily.interBold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ),

                  // Registered contacts (lazy)
                  SliverList.builder(
                    itemCount: registeredCount,
                    itemBuilder: (context, index) {
                      if (loading) return const SkeletonContactCard();
                      final UserListData user = contactData[index];
                      return ContactCard(
                        user: user,
                        onTapCard: () {
                          Get.to(
                                () => ContactProfileScreen(
                              contactData: MemberData(
                                userId: user.userId,
                                name: user.name,
                                mobileNo: user.mobileNo,
                                profileImage: user.profileImage,
                                isOnline: user.isOnline ?? false,
                                chatId:
                                contactController.chatIdFor(user.userId),
                              ),
                            ),
                          );
                        },
                        onTapAudio: () => _startCall(user, false),
                        onTapVideo: () => _startCall(user, true),
                      );
                    },
                  ),

                  if (contactController.contactLoadingMore.value)
                    SliverToBoxAdapter(
                      child: Skeletonizer(
                        enabled: true,
                        child: Column(
                          children: List<Widget>.generate(
                            3,
                                (int index) => const SkeletonContactCard(),
                          ),
                        ),
                      ),
                    ),

                  // Invite section (jo contacts app par nahi hain)
                  if (!loading && inviteData.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                        EdgeInsets.only(left: 4.w, bottom: 12.h, top: 16.h),
                        child: Text(
                          "Invite to FG Tracker",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: FontFamily.interBold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: inviteData.length,
                      itemBuilder: (context, index) =>
                          _buildInviteRow(inviteData[index]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteRow(UserListData user) {
    final String displayName = (user.name?.trim().isNotEmpty == true)
        ? user.name!.trim()
        : (user.mobileNo ?? 'Unknown User');

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
      child: Row(
        children: [
          RepaintBoundary(
            child: CircleAvatar(
              radius: 25.r,
              backgroundColor: _getAvatarColor(displayName),
              child: reausabletext(
                _getInitials(displayName),
                fontsize: 13.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  displayName,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  user.mobileNo ?? '',
                  fontsize: 11.sp,
                  fontweight: FontWeight(500),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => InviteHelper.showInviteOptions(user),
            child: Container(
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
            ),
          ),
        ],
      ),
    );
  }

  void _startCall(UserListData user, bool isVideo) {
    if (!CallValidation.validateCall(
      destinationPhone: user.mobileNo,
      destinationUserId: user.userId?.toString(),
    )) {
      return;
    }
    CallService().startOutGoingCall(
        context,
        callerId: Global.storageServices.get(PrefConst.userId).toString(),
        remoteUserId: user.userId.toString(),
        is_video: isVideo,
        callerName: user.name ?? "User",
        callerProfile: user.profileImage);
  }
}