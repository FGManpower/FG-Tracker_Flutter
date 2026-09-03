import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final chatController = Get.find<GroupMessageController>();
  final groupController = Get.put(GroupController());

  static const Color _purple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF5F3FB);

  final RxBool notificationsOn = true.obs;
  final RxBool showAllMembers = false.obs;

  String get _myId =>
      Global.storageServices.get(PrefConst.userId).toString();

  List<MessageData> get _mediaMessages {
    return chatController.messageData.where((m) {
      final t = (m.messageType ?? "").toLowerCase();
      return t == "image" ||
          t == "image_text" ||
          t == "video" ||
          t == "document";
    }).toList();
  }

  int get _onlineCount {
    int c = 0;
    for (final m in chatController.groupMembers) {
      if (_isOnline(m)) c++;
    }
    return c;
  }

  bool _isOnline(LocationData m) {
    if (m.locationSharing == false) return false;
    if (m.isOnline == true) return true;
    if (m.lastSeen == null || m.lastSeen.toString().isEmpty) return false;
    final parsed = DateTime.tryParse(m.lastSeen.toString());
    if (parsed == null) return false;
    try {
      return Tracking().getTimeAgo(parsed).toLowerCase() == "just now";
    } catch (_) {
      return false;
    }
  }

  String _statusText(LocationData m) {
    if (m.locationSharing == false) return "Ghost Mode";
    if (_isOnline(m)) return "Online";
    if (m.lastSeen == null || m.lastSeen.toString().isEmpty) return "Offline";
    final parsed = DateTime.tryParse(m.lastSeen.toString());
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

  String _videoDuration(MessageData m) {
    final parts = (m.content ?? "").split("||");
    if (parts.length > 2) return parts[2];
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Obx(() {
                final _ = chatController.groupMembers.length;
                final __ = chatController.pinnedMessage.value;

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  children: [
                    _buildProfileHeader(),
                    SizedBox(height: 18.h),
                    _buildQuickActions(context),
                    SizedBox(height: 16.h),
                    _buildMediaCard(context),
                    SizedBox(height: 12.h),
                    _buildSettingsCard(context),
                    SizedBox(height: 16.h),
                    _buildMembersSection(context),
                    SizedBox(height: 12.h),
                    _buildDangerSection(context),
                    SizedBox(height: 24.h),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Row(
        children: [
          _roundBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
          const Spacer(),
          if (chatController.isCreator.value)
            _roundBtn(
              icon: Icons.edit_rounded,
              onTap: () {
                groupController.groupName.text = chatController.groupName;
                DialogBox().showUpdateGroupBottomSheet(
                  context: context,
                  controller: groupController,
                  groupId: chatController.groupId.toString(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.w,
        width: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _purple, size: 20.sp),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final total = chatController.groupMembers.length;
    final online = _onlineCount;

    return Column(
      children: [
        Container(
          height: 88.w,
          width: 88.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF8B78FF), Color(0xFF6A5AE0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: chatController.groupImage.isNotEmpty
              ? ClipOval(
            child: Image.network(
              "${ConstRes.aImageBaseUrl}${chatController.groupImage}",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
          )
              : Icon(Icons.groups_rounded, color: Colors.white, size: 40.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          chatController.groupName.isEmpty
              ? "Unknown Group"
              : chatController.groupName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "$total Members",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: "  •  ",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
              TextSpan(
                text: "$online Online",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF2BB673),
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
          icon: Icons.call_rounded,
          label: "Audio Call",
          onTap: () {
            Utils().fluttertoast("Select a member to call");
          },
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.videocam_rounded,
          label: "Video Call",
          onTap: () {
            Utils().fluttertoast("Select a member for video call");
          },
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.person_add_alt_1_rounded,
          label: "Add Members",
          onTap: () {
            // TODO: navigate to add member / join by code screen
            Utils().fluttertoast("Add members");
          },
        ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.search_rounded,
          label: "Search",
          onTap: () {
            Get.back();
            chatController.startSearch();
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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: _purple, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
              Utils().fluttertoast("$total media items");
            },
            child: Row(
              children: [
                Icon(Icons.photo_library_outlined, color: _purple, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Media, Links & Docs",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "$total",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade500, size: 20.sp),
              ],
            ),
          ),
          if (media.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 72.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: media.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final m = media[i];
                  final type = (m.messageType ?? "").toLowerCase();
                  final thumb = _mediaThumb(m);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      color: const Color(0xFFEDEBFB),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (thumb.isNotEmpty)
                            Image.network(
                              thumb,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _mediaPlaceholder(type),
                            )
                          else
                            _mediaPlaceholder(type),
                          if (type == "video")
                            Positioned(
                              left: 6.w,
                              bottom: 6.h,
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 14.sp),
                                  Text(
                                    _videoDuration(m),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
    return Center(child: Icon(icon, color: _purple, size: 28.sp));
  }

  Widget _buildSettingsCard(BuildContext context) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _settingTile(
            icon: Icons.star_border_rounded,
            iconColor: _purple,
            title: "Starred Messages",
            onTap: () {
              final pinned = chatController.pinnedMessage.value;
              if (pinned != null) {
                Get.back();
                chatController.scrollToPinnedMessage();
              } else {
                Utils().fluttertoast("No starred/pinned message");
              }
            },
          ),
          _divider(),
          Obx(() => _settingTile(
            icon: Icons.notifications_none_rounded,
            iconColor: _purple,
            title: "Notifications",
            subtitle: notificationsOn.value ? "All Messages" : "Muted",
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: notificationsOn.value,
                activeColor: _purple,
                onChanged: (v) => notificationsOn.value = v,
              ),
            ),
          )),
          _divider(),
          _settingTile(
            icon: Icons.timer_outlined,
            iconColor: _purple,
            title: "Disappearing Messages",
            subtitle: "Messages will disappear after 7 days",
            trailingText: "Off",
            onTap: () => Utils().fluttertoast("Coming soon"),
          ),
          _divider(),
          _settingTile(
            icon: Icons.link_rounded,
            iconColor: _purple,
            title: "Invite via Link",
            onTap: () async {
              final code = Get.arguments?["groupCode"]?.toString() ?? "";
              final text = code.isNotEmpty
                  ? "Join my group \"${chatController.groupName}\" on FG Tracker. Code: $code"
                  : "Join my group \"${chatController.groupName}\" on FG Tracker";
              try {
                await Share.share(text);
              } catch (_) {
                await Clipboard.setData(ClipboardData(text: text));
                Utils().fluttertoast("Invite text copied");
              }
            },
          ),
          if (chatController.isCreator.value) ...[
            _divider(),
            _settingTile(
              icon: Icons.admin_panel_settings_outlined,
              iconColor: _purple,
              title: "Member Permissions",
              subtitle: "Only admins can send messages",
              onTap: () => Utils().fluttertoast("Coming soon"),
            ),
            _divider(),
            _settingTile(
              icon: Icons.settings_outlined,
              iconColor: _purple,
              title: "Group Settings",
              subtitle: "Edit group info, privacy, and more",
              onTap: () {
                groupController.groupName.text = chatController.groupName;
                DialogBox().showUpdateGroupBottomSheet(
                  context: context,
                  controller: groupController,
                  groupId: chatController.groupId.toString(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    final members = chatController.groupMembers.toList();
    members.sort((a, b) {
      final aMe = a.userId.toString() == _myId ? 0 : 1;
      final bMe = b.userId.toString() == _myId ? 0 : 1;
      if (aMe != bMe) return aMe.compareTo(bMe);
      final aAdmin = a.isCreator == true ? 0 : 1;
      final bAdmin = b.isCreator == true ? 0 : 1;
      return aAdmin.compareTo(bAdmin);
    });

    final visible = showAllMembers.value ? members : members.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              Text(
                "Members",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                "${members.length}".padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.search_rounded, color: _purple, size: 18.sp),
            ],
          ),
        ),
        _whiteCard(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            children: [
              ...visible.map((m) => _memberTile(context, m)),
              if (members.length > 3)
                TextButton(
                  onPressed: () =>
                  showAllMembers.value = !showAllMembers.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAllMembers.value
                            ? "Show less"
                            : "View all members",
                        style: TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      Icon(
                        showAllMembers.value
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _purple,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberTile(BuildContext context, LocationData m) {
    final isMe = m.userId.toString() == _myId;
    final isAdmin = m.isCreator == true;
    final online = _isOnline(m);
    final name = m.name?.toString() ?? "Unknown";
    final img = (m.profileImage?.toString().isNotEmpty ?? false)
        ? "${ConstRes.aImageBaseUrl}${m.profileImage}"
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: const Color(0xFFE8E4FF),
            backgroundImage: img != null ? NetworkImage(img) : null,
            child: img == null
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                color: _purple,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? "$name (You)" : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isMe && isAdmin) ...[
                      SizedBox(width: 6.w),
                      _badge("Admin", const Color(0xFFE7F8EC),
                          const Color(0xFF2BB673)),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _statusText(m),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: online
                        ? const Color(0xFF2BB673)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isMe && isAdmin)
            _badge("Group Admin", const Color(0xFFE7F8EC),
                const Color(0xFF2BB673)),
          SizedBox(width: 4.w),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: Colors.grey.shade500, size: 20.sp),
            onSelected: (value) {
              if (value == "chat") {
                final memberData = MemberData(
                  id: int.tryParse(m.id?.toString() ?? ""),
                  userId: int.tryParse(m.userId?.toString() ?? ""),
                  groupId: int.tryParse(m.groupId?.toString() ?? "0") ?? 0,
                  name: m.name?.toString(),
                  profileImage: m.profileImage?.toString(),
                  lastSeen: m.lastSeen?.toString(),
                  isOnline: online,
                );
                Get.toNamed(Routes.chatScreen, arguments: {
                  "userData": memberData,
                  "groupName": "Members Chat",
                  "isCreator": false,
                  "type": "",
                });
              } else if (value == "call") {
                Get.toNamed(Routes.callScreen, arguments: {
                  "callerId": _myId,
                  "remoteUserId": m.userId.toString(),
                  "callerName": name,
                  "offer": null,
                  "is_video": false,
                  "callType": "outGoing",
                });
              } else if (value == "video") {
                Get.toNamed(Routes.callScreen, arguments: {
                  "callerId": _myId,
                  "remoteUserId": m.userId.toString(),
                  "callerName": name,
                  "offer": null,
                  "is_video": true,
                  "callType": "outGoing",
                });
              } else if (value == "remove" &&
                  chatController.isCreator.value &&
                  !isMe) {
                CommonDialog.ConfirmationDialog(
                  title: "Remove Member",
                  content:
                  "Are you sure you want to remove $name from the group?",
                  confirm: "Remove",
                  onConfirm: () {
                    Get.back();
                    groupController.deleteGroupMember(
                      context,
                      groupId: chatController.groupId.toString(),
                      groupMemberId: m.userId.toString(),
                      onSuccess: (success) {
                        if (success) {
                          chatController.groupMembers
                              .removeWhere((e) => e.userId == m.userId);
                        }
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (_) => [
              if (!isMe)
                const PopupMenuItem(value: "chat", child: Text("Message")),
              if (!isMe)
                const PopupMenuItem(value: "call", child: Text("Audio Call")),
              if (!isMe)
                const PopupMenuItem(value: "video", child: Text("Video Call")),
              if (!isMe && chatController.isCreator.value)
                const PopupMenuItem(
                    value: "remove", child: Text("Remove from group")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDangerSection(BuildContext context) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _settingTile(
            icon: Icons.favorite_border_rounded,
            iconColor: _purple,
            title: "Add to Favorites",
            onTap: () => Utils().fluttertoast("Added to favorites"),
          ),
          _divider(),
          _settingTile(
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.redAccent,
            title: "Clear Chat",
            titleColor: Colors.redAccent,
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: "Clear Chat",
                content: "Delete all messages from this device?",
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
            icon: Icons.logout_rounded,
            iconColor: Colors.redAccent,
            title: "Exit Group",
            titleColor: Colors.redAccent,
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: "Exit Group",
                content:
                "Are you sure you want to exit \"${chatController.groupName}\"?",
                confirm: "Exit",
                onConfirm: () {
                  Get.back();
                  MemberController().exitGroup(
                    context,
                    groupId: chatController.groupId.toString(),
                    userId: _myId,
                    onSuccess: (success) {
                      if (success) {
                        Get.offAllNamed(Routes.Home_Screen);
                      }
                    },
                  );
                },
              );
            },
          ),
          _divider(),
          _settingTile(
            icon: Icons.flag_outlined,
            iconColor: Colors.redAccent,
            title: "Report Group",
            titleColor: Colors.redAccent,
            onTap: () => Utils().fluttertoast("Report submitted"),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  Widget _settingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailingText,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.black87,
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
            else if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailing == null)
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20.sp),
          ],
        ),
      ),
    );
  }
}