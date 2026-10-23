import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Messages/Controller/newChat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';
import '../../../Model/MemberDataRes.dart';
import '../../../routes/app_pages.dart';

class NewChatScreen extends StatefulWidget {
  final bool fromQuickAction;

  const NewChatScreen({super.key, this.fromQuickAction = false});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final RxBool _isSearchCollapsed = false.obs;
  final RxBool _showSearchInAppBar = false.obs;

  final NewChatController controller = Get.put(NewChatController());

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 40 && !_isSearchCollapsed.value) {
        _isSearchCollapsed.value = true;
      } else if (_scrollController.offset <= 40 && _isSearchCollapsed.value) {
        _isSearchCollapsed.value = false;
        _showSearchInAppBar.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final hasData = controller.matchedUsers.isNotEmpty ||
                  controller.otherUsers.isNotEmpty;

              if (!hasData && controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child:
                (_isSearchCollapsed.value && !_showSearchInAppBar.value)
                    ? const SizedBox(width: double.infinity)
                    : _buildSearchBar(),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.responseError.value.isNotEmpty) {
                  return LostinternetConnection(
                    retry: () => controller.getRegisteredContacts(),
                    messgae: controller.responseError.value,
                  );
                }

                if (controller.contactLoading.value) {
                  return _buildSkeletonList();
                }

                final direct = controller.filteredMatchedUsers;
                final invite = controller.filteredOtherUsers;

                if (direct.isEmpty && invite.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DataEmpty_AssetsIcon(
                            assetspath: Assets.images.notFount.path),
                        SizedBox(height: 12.h),
                        reausabletext(
                          controller.searchQuery.value.isEmpty
                              ? "No active tracker contacts found"
                              : "No results for '${controller.searchQuery.value}'",
                          fontsize: 13.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 40.h),
                  children: [
                    SizedBox(height: 12.h),
                    if (direct.isNotEmpty) ...[
                      if (!widget.fromQuickAction)
                        _buildSectionTitle("Start a New Chat (Contacts)"),
                      _buildContactsCard(direct, isInvite: false),
                      SizedBox(height: 16.h),
                    ],
                    if (invite.isNotEmpty) ...[
                      _buildSectionTitle("Invite to Chat (Unregistered Contacts)"),
                      _buildContactsCard(invite, isInvite: true),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsCard(List<UserListData> items,
      {required bool isInvite}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
          color: Colors.grey.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, index) {
          final user = items[index];
          return _buildContactRow(user, isInvite: isInvite);
        },
      ),
    );
  }

  Widget _buildContactRow(UserListData user, {required bool isInvite}) {
    final String? avatar = user.profileImage;
    final bool hasAvatar = avatar != null && avatar.isNotEmpty;
    final String imageUrl = hasAvatar ? (ConstRes.aImageBaseUrl + avatar) : '';
    final String displayName = (user.name?.trim().isNotEmpty == true)
        ? user.name!.trim()
        : (user.mobileNo ?? 'Unknown User');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: hasAvatar ? Colors.grey.shade200 : _getAvatarColor(displayName),
            backgroundImage: hasAvatar ? NetworkImage(imageUrl) : null,
            child: !hasAvatar
                ? reausabletext(
              _getInitials(displayName),
              fontsize: 13.sp,
              fontfamily: FontFamily.interBold,
              color: Colors.white,
            )
                : null,
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
          if (isInvite)
            GestureDetector(
              onTap: () => _handleOnAction(user, isInvite: true),
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
            )
          else
            GestureDetector(
              onTap: () => _handleOnAction(user, isInvite: false),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F0FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 18.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            ),
        ],
      ),
    );
  }


  String _buildInviteMessage(UserListData user) {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.fg.fgtracker&hl=en";
    const String appStoreLink = "https://apps.apple.com/app/id6470000000";

    return "Hey ${user.name ?? ''}! Join me on FG Tracker.\n\n"
        "Download for Android: $playStoreLink\n\n"
        "Download for iOS: $appStoreLink";
  }

  String _normalizedNumber(String? raw) {
    final String digits = (raw ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) return '91$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      return '91${digits.substring(1)}';
    }
    return digits;
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log("INVITE launch failed: $uri => $e");
      return false;
    }
  }

  Future<void> _inviteViaWhatsApp(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    final String encoded = Uri.encodeComponent(_buildInviteMessage(user));
    log("INVITE WHATSAPP NUMBER => $number");

    if (number.isNotEmpty) {
      if (await _tryLaunch(
          Uri.parse('whatsapp://send?phone=$number&text=$encoded'))) {
        return;
      }
      if (await _tryLaunch(Uri.parse('https://wa.me/$number?text=$encoded'))) {
        return;
      }
    }
    Get.snackbar("Error", "WhatsApp could not be opened");
  }

  Future<void> _inviteViaTelegram(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    log("INVITE TELEGRAM NUMBER => $number");

    if (number.isNotEmpty) {
      if (await _tryLaunch(Uri.parse('tg://resolve?phone=$number'))) {
        return;
      }
      if (await _tryLaunch(Uri.parse('https://t.me/+$number'))) {
        return;
      }
    }
    Get.snackbar("Error", "Telegram could not be opened");
  }

  Future<void> _inviteViaSms(UserListData user) async {
    final String number = _normalizedNumber(user.mobileNo);
    final String encoded = Uri.encodeComponent(_buildInviteMessage(user));
    log("INVITE SMS NUMBER => $number");

    if (number.isNotEmpty &&
        await _tryLaunch(Uri.parse('sms:+$number?body=$encoded'))) {
      return;
    }
    Get.snackbar("Error", "Messaging app could not be opened");
  }

  Future<void> _inviteViaShareSheet(UserListData user) async {
    try {
      await Share.share(_buildInviteMessage(user));
    } catch (e) {
      Get.snackbar("Error", "Could not open share menu: $e");
    }
  }

  void _showInviteOptions(UserListData user) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              reausabletext(
                "Invite ${user.name ?? ''}",
                fontsize: 16.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
              ),
              SizedBox(height: 4.h),
              reausabletext(
                "Choose how you want to send the invite",
                fontsize: 11.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 10.h),
              _inviteOption(
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                title: "WhatsApp",
                onTap: () {
                  Get.back();
                  _inviteViaWhatsApp(user);
                },
              ),
              _inviteOption(
                icon: Icons.send_rounded,
                color: const Color(0xFF229ED9),
                title: "Telegram",
                onTap: () {
                  Get.back();
                  _inviteViaTelegram(user);
                },
              ),
              _inviteOption(
                icon: Icons.sms_rounded,
                color: const Color(0xFF6C5DD3),
                title: "Message",
                onTap: () {
                  Get.back();
                  _inviteViaSms(user);
                },
              ),
              _inviteOption(
                icon: Icons.share_rounded,
                color: const Color(0xFF5A2BE0),
                title: "More apps",
                onTap: () {
                  Get.back();
                  _inviteViaShareSheet(user);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inviteOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: reausabletext(
                title,
                fontsize: 14.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 22.sp, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }


  void _handleOnAction(UserListData user, {required bool isInvite}) async {
    if (isInvite) {
      _showInviteOptions(user);
    } else {
      final int? chatId =
          user.privateChatId ?? user.chatId ?? user.conversationId;

      final memberData = MemberData(
        userId: user.userId,
        name: user.name,
        profileImage: user.profileImage,
        chatId: chatId,
        groupId: 0,
      );
      log("NEW CHAT USER ID => ${user.userId}");
      log("NEW CHAT chatId => ${user.chatId}");
      log("NEW CHAT privateChatId => ${user.privateChatId}");
      log("NEW CHAT conversationId => ${user.conversationId}");
      log("NEW CHAT FINAL chatId => $chatId");
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "type": "chatScreen",
          "chatType": "private",
          "userData": memberData,
          "chatId": chatId?.toString(),
        },
      );
    }
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
          GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    size: 20.sp,
                  ),
                ),
              )),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  widget.fromQuickAction ? "All Contacts" : "New Chat",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Start a conversation",
                  fontsize: 11.sp,
                  fontweight: FontWeight(450),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Obx(() {
            if (!_isSearchCollapsed.value) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                _showSearchInAppBar.value = true;
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 4.w),
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
                child: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 19.w, top: 10.h),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
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
            Icon(Icons.search, size: 25.sp, color: Colors.grey),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => controller.filterContacts(val),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interMedium,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Search by name or number...",
                  hintStyle: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontFamily: FontFamily.interRegular,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: () {
                  _searchController.clear();
                  controller.filterContacts('');
                  FocusScope.of(context).unfocus();
                },
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: reausabletext(
        title,
        fontsize: 13.sp,
        fontfamily: FontFamily.interBold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 25.r, backgroundColor: Colors.grey.shade200),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120.w, height: 14.h, color: Colors.grey),
                      SizedBox(height: 6.h),
                      Container(width: 80.w, height: 11.h, color: Colors.grey),
                    ],
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}