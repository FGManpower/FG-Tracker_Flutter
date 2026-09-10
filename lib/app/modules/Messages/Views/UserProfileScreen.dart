import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Views/Group/media_links_docs_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final chatController = Get.find<MessageController>();

  static const Color _purple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF5F3FB);

  final RxBool notificationsOn = false.obs;

  String get _myId => Global.storageServices.get(PrefConst.userId).toString();

  List<MessageData> get _mediaMessages {
    return chatController.messageData.where((m) {
      final t = (m.messageType ?? "").toLowerCase();
      return t == "image" ||
          t == "image_text" ||
          t == "video" ||
          t == "document";
    }).toList();
  }

  bool _isOnline() {
    final userData = chatController.memberData;
    if (userData.lastSeen == null || userData.lastSeen!.trim().isEmpty)
      return false;
    final parsed = DateTime.tryParse(userData.lastSeen!.trim());
    if (parsed == null) return false;
    try {
      return Tracking().getTimeAgo(parsed).toLowerCase() == "just now";
    } catch (_) {
      return false;
    }
  }

  String _statusText() {
    final userData = chatController.memberData;
    if (_isOnline()) return "Online";
    if (userData.lastSeen == null || userData.lastSeen!.trim().isEmpty)
      return "Offline";
    final parsed = DateTime.tryParse(userData.lastSeen!.trim());
    if (parsed == null) return "Offline";
    try {
      return Tracking().getTimeAgo(parsed);
    } catch (_) {
      return "Offline";
    }
  }

  String _mediaThumb(MessageData m) {
    final type = (m.messageType ?? "").toLowerCase();
    final content = m.content ?? "";
    if (type == "video") {
      final parts = content.split("||");
      if (parts.length > 1 && parts[1].isNotEmpty) {
        return "${ConstRes.aImageBaseUrl}${parts[1]}";
      }
      return "";
    }
    if (type == "image" || type == "image_text") {
      final part = content.split("||").first;
      return "${ConstRes.aImageBaseUrl}$part";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
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
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children: [
            _buildProfileHeader(),
            SizedBox(height: 18.h),
            _buildQuickActions(context),
            SizedBox(height: 16.h),
            _buildMediaCard(context),
            SizedBox(height: 12.h),
            _buildAboutCard(),
            SizedBox(height: 12.h),
            _buildSettingsCard(context),
            SizedBox(height: 24.h),
          ],
        ),
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
              color: _purple.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _purple, size: 20.sp),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userData = chatController.memberData;
    final isOnline = _isOnline();
    final img = userData.profileImage?.toString() ?? "";
    final name = userData.name?.toString() ?? "Unknown";

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _purple, width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B78FF), Color(0xFF6A5AE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: img.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        "${ConstRes.aImageBaseUrl}$img",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 45.sp,
                        ),
                      ),
                    )
                  : Icon(Icons.person, color: Colors.white, size: 45.sp),
            ),
            if (isOnline)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  height: 20.w,
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BB673),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: _purple,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Team Member",
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFFE7F8EC) : Colors.grey.shade200,
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
              Text(
                isOnline ? "Online" : _statusText(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      isOnline ? const Color(0xFF2BB673) : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: "Message",
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.call_outlined,
          label: "Call",
          onTap: () {
            chatController.startCall(
              context,
              callerId: _myId,
              remoteUserId: chatController.memberData.userId.toString(),
              is_video: false,
              callerName: chatController.memberData.name,
            );
          },
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.videocam_outlined,
          label: "Video Call",
          onTap: () {
            chatController.startCall(
              context,
              callerId: _myId,
              remoteUserId: chatController.memberData.userId.toString(),
              is_video: true,
              callerName: chatController.memberData.name,
            );
          },
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: _purple, size: 24.sp),
              SizedBox(height: 8.h),
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

  Widget _buildMediaCard(BuildContext context) {
    final media = _mediaMessages.reversed.take(4).toList();
    final total = _mediaMessages.length;

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              final all = chatController.messageData.where((m) {
                final t = (m.messageType ?? "").toLowerCase().trim();
                if (t == "image" ||
                    t == "image_text" ||
                    t == "video" ||
                    t == "document" ||
                    t == "doc" ||
                    t == "file" ||
                    t == "link" ||
                    t == "url" ||
                    t.contains("link")) {
                  return true;
                }
                final c = m.content ?? "";
                return RegExp(
                  r'(https?:\/\/[^\s]+)|(www\.[^\s]+)',
                  caseSensitive: false,
                ).hasMatch(c);
              }).toList();

              Get.to(() => MediaLinksDocsScreen(mediaMessages: all));
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Media, links and docs",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
                  ),
                ),
                Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _purple, size: 18.sp),
              ],
            ),
          ),
          if (media.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: media.length > 4 ? 4 : media.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  if (i == 3 && total > 4) {
                    return Container(
                      width: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "+${total - 4}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final m = media[i];
                  final type = (m.messageType ?? "").toLowerCase();
                  final thumb = _mediaThumb(m);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 70.h,
                      color: const Color(0xFFEDEBFB),
                      child: thumb.isNotEmpty
                          ? Image.network(
                              thumb,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _mediaPlaceholder(type),
                            )
                          : _mediaPlaceholder(type),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            SizedBox(height: 10.h),
            Text(
              "No media shared yet",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mediaPlaceholder(String type) {
    IconData icon = Icons.insert_drive_file_rounded;
    if (type == "image" || type == "image_text") icon = Icons.image_rounded;
    if (type == "video") icon = Icons.videocam_rounded;
    return Center(child: Icon(icon, color: _purple, size: 24.sp));
  }

  Widget _buildAboutCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _purple,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Available for work and team communication.",
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

  Widget _buildSettingsCard(BuildContext context) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 14.h, bottom: 4.h),
            child: Text(
              "Notifications",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _purple,
              ),
            ),
          ),
          Obx(() => _settingTile(
                icon: Icons.notifications_rounded,
                iconBgColor: const Color(0xFFE8E4FF),
                iconColor: _purple,
                title: "Mute notifications",
                trailing: Switch(
                  value: notificationsOn.value,
                  activeColor: Colors.white,
                  activeTrackColor: _purple,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (v) => notificationsOn.value = v,
                ),
              )),
          _divider(),
          _settingTile(
            icon: Icons.music_note_rounded,
            iconBgColor: const Color(0xFFE8E4FF),
            iconColor: _purple,
            title: "Custom notifications",
            onTap: () => Utils().fluttertoast("Coming soon"),
          ),
          _divider(),
          _settingTile(
            icon: Icons.lock_rounded,
            iconBgColor: const Color(0xFFE8E4FF),
            iconColor: _purple,
            title: "Encryption",
            subtitle: "Messages and calls are end-to-end encrypted.",
            onTap: () => Utils().fluttertoast("Coming soon"),
          ),
          _divider(),
          _settingTile(
            icon: Icons.star_rounded,
            iconBgColor: const Color(0xFFE8E4FF),
            iconColor: _purple,
            title: "Add to Favorite",
            onTap: () => Utils().fluttertoast("Added to favorites"),
          ),
          _divider(),
          _settingTile(
            icon: Icons.delete_outline_rounded,
            iconBgColor: const Color(0xFFFFEAEA),
            iconColor: Colors.redAccent,
            title: "Clear Chat",
            titleColor: Colors.redAccent,
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: "Clear Chat",
                content: "Delete all messages with this user?",
                confirm: "Clear",
                onConfirm: () {
                  Get.back();
                  Utils().fluttertoast("Clear chat coming soon");
                },
              );
            },
          ),
          _divider(),
          _settingTile(
            icon: Icons.block_rounded,
            iconBgColor: const Color(0xFFFFEAEA),
            iconColor: Colors.redAccent,
            title: "Block ${chatController.memberData.name}",
            titleColor: Colors.redAccent,
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: "Block User",
                content: "Are you sure you want to block this user?",
                confirm: "Block",
                onConfirm: () {
                  Get.back();
                  Utils().fluttertoast("User Blocked");
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider() => Divider(
      height: 1, color: Colors.grey.shade100, indent: 56.w, endIndent: 16.w);

  Widget _settingTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? _purple,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.chevron_right_rounded, color: _purple, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
