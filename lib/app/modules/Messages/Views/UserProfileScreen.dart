import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/profile_details_model.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Views/Group/media_links_docs_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import '../Controller/user_profile_details_controller.dart';
import 'package:fgtracker/app/Model/GetMessage.dart' hide BlockStatus;

class UserProfileScreen extends StatefulWidget {
  final MemberData? userData;
  final int? chatId;

  const UserProfileScreen({super.key, this.userData, this.chatId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileDetailsController _apiController =
      Get.put(UserProfileDetailsController());

  MessageController? get _chatController =>
      Get.isRegistered<MessageController>()
          ? Get.find<MessageController>()
          : null;

  static const Color _purple = Color(0xFF1E1466);
  static const Color _lightPurple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF4F3F8);

  String get _myId => Global.storageServices.get(PrefConst.userId).toString();

  @override
  void initState() {
    super.initState();
    int cId = widget.chatId ??
        int.tryParse(_chatController?.privateChatId.value.toString() ?? '') ??
        0;

    if (cId != 0) {
      _apiController.fetchProfileDetails(cId);
    } else {
      _apiController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
          child: _roundBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_apiController.isLoading.value) {
            return _buildSkeleton();
          }

          final data = _apiController.profileData.value;
          if (data == null || data.user == null) {
            return Center(
              child: Text(
                "Profile details not found",
                style: TextStyle(fontSize: 16.sp, color: _purple),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              _buildProfileHeader(data.user!),
              SizedBox(height: 24.h),
              _buildQuickActions(data.user!),
              SizedBox(height: 16.h),
              _buildMediaCard(data.media, data.mediaSummary),
              SizedBox(height: 12.h),
              _buildAboutCard(data.user!),
              SizedBox(height: 12.h),
              _buildEncryptionCard(),
              SizedBox(height: 8.h),
              _buildClearChatCard(),
              SizedBox(height: 8.h),
              _buildBlockCard(data.user!, data.blockStatus),
              SizedBox(height: 24.h),
            ],
          );
        }),
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _purple, size: 20.sp),
      ),
    );
  }

  Widget _buildProfileHeader(UserDetails user) {
    final img = user.profileImage ?? "";
    final name = user.name ?? "Member";
    final isOnline = user.isOnline ?? false;
    final statusText = user.lastSeen ?? "Offline";

    return Column(
      children: [
        Container(
          height: 100.w,
          width: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _lightPurple, width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFF8B78FF), Color(0xFF6A5AE0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: (img.isNotEmpty && img.toLowerCase() != 'null')
              ? ClipOval(
                  child: Image.network(
                    (img.startsWith('http://') || img.startsWith('https://'))
                        ? img
                        : "${ConstRes.aImageBaseUrl}$img",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.person, color: Colors.white, size: 45.sp),
                  ),
                )
              : Icon(Icons.person, color: Colors.white, size: 45.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: _purple,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "FG Tracker Member",
          style: TextStyle(
            fontSize: 13.sp,
            color: _lightPurple.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFFE8F6ED) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 8.w,
                width: 8.w,
                decoration: BoxDecoration(
                  color:
                      isOnline ? const Color(0xFF2BB673) : Colors.grey.shade500,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isOnline ? _lightPurple : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openChat(UserDetails user) {
    if (_chatController != null) {
      Get.back();
    } else {
      MemberData md = MemberData(
        userId: user.userId,
        name: user.name,
        profileImage: user.profileImage,
      );
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "userData": md,
          "groupName": user.name ?? "Chat",
          "isCreator": false,
          "type": "chatScreen",
          "chatType": "private",
          "groupId": 0,
        },
      );
    }
  }

  void _startCall(UserDetails user, {required bool isVideo}) {
    if (_chatController != null) {
      _chatController!.startCall(
        context,
        callerId: _myId,
        remoteUserId: (user.userId ?? "").toString(),
        is_video: isVideo,
        callerName: user.name,
      );
      return;
    }

    if (Get.isRegistered<CallingController>()) {
      Get.delete<CallingController>(force: true);
    }

    Get.toNamed(
      Routes.callScreen,
      arguments: {
        "callerId": _myId,
        "remoteUserId": (user.userId ?? "").toString(),
        "callerName": user.name ?? "Member",
        "callerProfile": user.profileImage,
        "offer": null,
        "is_video": isVideo,
        "callType": "outGoing",
      },
    );
  }

  Widget _buildQuickActions(UserDetails user) {
    return Row(
      children: [
        _quickAction(
          icon: Icons.chat_bubble_rounded,
          label: "Message",
          onTap: () => _openChat(user),
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.call,
          label: "Call",
          onTap: () => _startCall(user, isVideo: false),
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.videocam_rounded,
          label: "Video Call",
          onTap: () => _startCall(user, isVideo: true),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: _lightPurple, size: 24.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _purple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCard(MediaDetails? media, MediaSummary? summary) {
    List<MessageData> convertedMessages = [];

    if (media != null) {
      for (var p in media.photos ?? []) {
        convertedMessages.add(MessageData(
          messageType: 'image',
          content: p.url,
        ));
      }

      for (var v in media.videos ?? []) {
        convertedMessages.add(MessageData(
          messageType: 'video',
          content: '${v.url}||${v.displayUrl}',
        ));
      }
    }

    List<MediaItem> allMedia = [];
    if (media != null) {
      allMedia.addAll(media.photos ?? []);
      allMedia.addAll(media.videos ?? []);
    }

    final displayMedia = allMedia.take(4).toList();
    final total = summary?.totalMedia ?? 0;

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Get.to(
                () => MediaLinksDocsScreen(mediaMessages: convertedMessages),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Media, links and docs",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _purple,
                    ),
                  ),
                ),
                Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _lightPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _lightPurple,
                  size: 20.sp,
                ),
              ],
            ),
          ),
          if (displayMedia.isNotEmpty) ...[
            SizedBox(height: 14.h),
            SizedBox(
              height: 75.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayMedia.length > 4 ? 4 : displayMedia.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (_, i) {
                  if (i == 3 && total > 4) {
                    return GestureDetector(
                      onTap: () => Get.to(
                        () => MediaLinksDocsScreen(
                          mediaMessages: convertedMessages,
                        ),
                      ),
                      child: Container(
                        width: 75.h,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            "+${total - 4}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final m = displayMedia[i];
                  String thumb = "";
                  if (m.displayUrl != null && m.displayUrl!.isNotEmpty) {
                    thumb = (m.displayUrl!.startsWith('http://') ||
                            m.displayUrl!.startsWith('https://'))
                        ? m.displayUrl!
                        : "${ConstRes.aImageBaseUrl}${m.displayUrl}";
                  }

                  return GestureDetector(
                    onTap: () => Get.to(
                      () => MediaLinksDocsScreen(
                        mediaMessages: convertedMessages,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 75.h,
                        color: const Color(0xFFF3F1FB),
                        child: thumb.isNotEmpty
                            ? Image.network(
                                thumb,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _mediaPlaceholder(m.type ?? ""),
                              )
                            : _mediaPlaceholder(m.type ?? ""),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            SizedBox(height: 10.h),
            Text(
              "No media shared yet",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mediaPlaceholder(String type) {
    IconData icon = Icons.insert_drive_file_rounded;
    if (type == "image") icon = Icons.image_rounded;
    if (type == "video") icon = Icons.videocam_rounded;

    return Center(child: Icon(icon, color: _lightPurple, size: 28.sp));
  }

  Widget _buildAboutCard(UserDetails user) {
    final String phone = user.mobileNo ?? user.phone ?? "";
    String locationStr = "";
    if (user.location != null) {
      if (user.location!.area != null) {
        locationStr += "${user.location!.area}, ";
      }
      if (user.location!.city != null) {
        locationStr += user.location!.city!;
      }
    }

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact & Info",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: _purple,
            ),
          ),
          if (phone.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.phone_rounded, color: _lightPurple, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: _purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (locationStr.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: _lightPurple,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    locationStr.trim().replaceAll(RegExp(r',$'), ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            "Available for team communication.",
            style: TextStyle(
              fontSize: 13.sp,
              color: _purple.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionCard() {
    return _buildSingleTileCard(
      icon: Icons.lock_rounded,
      iconBgColor: const Color(0xFFF3F1FB),
      iconColor: _lightPurple,
      title: "Encryption",
      subtitle: "Messages and calls are end-to-end encrypted.",
      onTap: () => Utils().fluttertoast("Coming soon"),
    );
  }

  Widget _buildClearChatCard() {
    return _buildSingleTileCard(
      icon: Icons.delete_outline_rounded,
      iconBgColor: const Color(0xFFFFF0F0),
      iconColor: Colors.redAccent,
      title: "Clear Chat",
      titleColor: Colors.redAccent,
      arrowColor: Colors.redAccent,
      onTap: () {
        CommonDialog.ConfirmationDialog(
          title: "Clear Chat",
          content: "Delete all messages with this user?",
          confirm: "Clear",
          onConfirm: () {
            Get.back();
            final chatId = _chatController?.privateChatId.value;

            if (chatId == null) {
              Utils().fluttertoast("Unable to clear chat");
              return;
            }

            SocketMessageService.instance.clearPrivateChat(
              chatId: chatId.toString(),
            );

            _chatController?.messageData.clear();
            Utils().fluttertoast("Chat cleared");
          },
        );
      },
    );
  }

  Widget _buildBlockCard(UserDetails user, BlockStatus? blockStatus) {
    final controller = _chatController;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final blocked = controller.isBlocked.value;

      return _buildSingleTileCard(
        icon: blocked ? Icons.lock_open_rounded : Icons.block_rounded,
        iconBgColor:
            blocked ? const Color(0xFFF3F1FB) : const Color(0xFFFFF0F0),
        iconColor: blocked ? _lightPurple : Colors.redAccent,
        title: blocked
            ? "Unblock ${user.name ?? 'User'}"
            : "Block ${user.name ?? 'User'}",
        titleColor: blocked ? _lightPurple : Colors.redAccent,
        arrowColor: blocked ? _lightPurple : Colors.redAccent,
        onTap: blocked
            ? () {
                CommonDialog.ConfirmationDialog(
                  title: "Unblock User",
                  content: "Are you sure you want to unblock this user?",
                  confirm: "Unblock",
                  onConfirm: () => _handleUnblockUser(user.userId),
                );
              }
            : () {
                CommonDialog.ConfirmationDialog(
                  title: "Block User",
                  content: "Are you sure you want to block this user?",
                  confirm: "Block",
                  onConfirm: () => _handleBlockUser(user.userId),
                );
              },
      );
    });
  }

  Future<void> _handleBlockUser(int? userId) async {
    if (userId == null) {
      Utils().fluttertoast("User not found");
      return;
    }

    final controller = _chatController;
    if (controller == null) {
      Utils().fluttertoast("Unable to block user");
      return;
    }

    final message = await controller.blockUser(userId);

    if (message != null) {
      Utils().fluttertoast(message);
      Get.back();
    } else {
      Utils().fluttertoast("Unable to block user");
    }
  }

  Future<void> _handleUnblockUser(int? userId) async {
    if (userId == null) {
      Utils().fluttertoast("User not found");
      return;
    }

    final controller = _chatController;
    if (controller == null) {
      Utils().fluttertoast("Unable to unblock user");
      return;
    }

    final message = await controller.unblockUser(userId);

    if (message != null) {
      Utils().fluttertoast(message);
      Get.back();
    } else {
      Utils().fluttertoast("Unable to unblock user");
    }
  }

  Widget _buildSingleTileCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? arrowColor,
    VoidCallback? onTap,
  }) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                height: 36.w,
                width: 36.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? _purple,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: arrowColor ?? _lightPurple,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            _skel(height: 100.w, width: 100.w, radius: 50.r),
            SizedBox(height: 12.h),
            _skel(height: 22.h, width: 160.w, radius: 6.r),
            SizedBox(height: 8.h),
            _skel(height: 14.h, width: 120.w, radius: 6.r),
            SizedBox(height: 10.h),
            _skel(height: 28.h, width: 90.w, radius: 20.r),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(child: _skel(height: 70.h, radius: 14.r)),
            SizedBox(width: 10.w),
            Expanded(child: _skel(height: 70.h, radius: 14.r)),
            SizedBox(width: 10.w),
            Expanded(child: _skel(height: 70.h, radius: 14.r)),
          ],
        ),
        SizedBox(height: 16.h),
        _skelBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _skel(height: 16.h, width: 140.w, radius: 4.r),
                  ),
                  SizedBox(width: 8.w),
                  _skel(height: 14.h, width: 60.w, radius: 4.r),
                ],
              ),
              SizedBox(height: 14.h),
              SizedBox(
                height: 75.h,
                child: Row(
                  children: [
                    Expanded(child: _skel(height: 75.h, radius: 12.r)),
                    SizedBox(width: 10.w),
                    Expanded(child: _skel(height: 75.h, radius: 12.r)),
                    SizedBox(width: 10.w),
                    Expanded(child: _skel(height: 75.h, radius: 12.r)),
                    SizedBox(width: 10.w),
                    Expanded(child: _skel(height: 75.h, radius: 12.r)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _skelBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skel(height: 16.h, width: 120.w, radius: 4.r),
              SizedBox(height: 14.h),
              _skel(height: 14.h, width: 180.w, radius: 4.r),
              SizedBox(height: 10.h),
              _skel(height: 14.h, width: 140.w, radius: 4.r),
              SizedBox(height: 10.h),
              _skel(height: 14.h, width: 200.w, radius: 4.r),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _skel(height: 56.h, radius: 14.r),
        SizedBox(height: 8.h),
        _skel(height: 56.h, radius: 14.r),
        SizedBox(height: 8.h),
        _skel(height: 56.h, radius: 14.r),
      ],
    );
  }

  Widget _skel({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _skelBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
