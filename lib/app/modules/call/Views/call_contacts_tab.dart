import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:fgtracker/app/modules/call/Controller/contact_controller.dart';
import 'package:fgtracker/app/modules/call/widget/SkeletonContactCard.dart';
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (contactController.responseError.value.isNotEmpty &&
          contactController.allUserProfileData.isEmpty) {
        return LostinternetConnection(
          retry: () {
            contactController.getRegisteredContacts();
          },
          messgae: contactController.responseError.value,
        );
      }

      if (contactController.contactLoading.value &&
          contactController.allUserProfileData.isEmpty) {
        return _buildContactsListUi(isLoading: true);
      }

      if (contactController.allUserProfileData.isEmpty ||
          contactController.filteredUsers.isEmpty) {
        return _buildEmptyUi();
      }

      return _buildContactsListUi(
        contactData: contactController.filteredUsers,
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
    List<UserListData>? contactData,
    bool isLoading = false,
  }) {
    final bool loading = isLoading || contactData == null;
    final int count = loading ? 8 : contactData.length;
    final bool isDialOpen = controller.isDialPadOpen.value;

    return RefreshIndicator(
      color: const Color(0xFF4818F0),
      onRefresh: contactController.refreshContacts,
      child: Skeletonizer(
        enabled: loading,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            isDialOpen ? 390.h : 90.h,
          ),
          children: [
            if (!contactController.isContactPermissionGranted.value && !loading)
              buildPermissionBanner(controller: contactController),

            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 4.h),
              child: Text(
                "All Contacts",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
            ),

            for (int index = 0; index < count; index++)
              loading
                  ? const SkeletonContactCard()
                  : ContactCard(
                user: contactData[index],
                onTapCard: () {
                  Get.to(
                        () => ContactProfileScreen(
                      contactData: MemberData(
                        userId: contactData[index].userId,
                        name: contactData[index].name,
                        mobileNo: contactData[index].mobileNo,
                        profileImage: contactData[index].profileImage,
                        isOnline: contactData[index].isOnline ?? false,
                      ),
                    ),
                  );
                },
                onTapAudio: () => _startCall(contactData[index], false),
                onTapVideo: () => _startCall(contactData[index], true),
              ),

            if (contactController.contactLoadingMore.value)
              Skeletonizer(
                enabled: true,
                child: Column(
                  children: List<Widget>.generate(
                    3,
                        (int index) => const SkeletonContactCard(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startCall(UserListData user, bool isVideo) {
    CallService().startCall(
      context,
      callerId: Global.storageServices.get(PrefConst.userId).toString(),
      remoteUserId: user.userId.toString(),
      is_video: isVideo,
      callerName: user.name ?? "User",
    );
  }
}
