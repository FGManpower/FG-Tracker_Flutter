import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/profile_navigation.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Views/Chat_Screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Controller/group_profile_details_controller.dart';
import 'media_links_docs_screen.dart';
import 'package:fgtracker/app/Model/group_profile_details_model.dart';

class GroupProfileScreen extends StatefulWidget {
  const GroupProfileScreen({super.key});

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  final chatController = Get.find<GroupMessageController>();
  final groupController = Get.put(GroupController());
  final GroupProfileDetailsController _apiController =
      Get.put(GroupProfileDetailsController());

  static const Color _purple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF5F3FB);
  final RxBool notificationsOn = true.obs;
  final RxBool showAllMembers = false.obs;

  String get _myId => Global.storageServices.get(PrefConst.userId).toString();

  @override
  void initState() {
    super.initState();
    int gId = int.tryParse(chatController.groupId.toString()) ?? 0;
    if (gId != 0) {
      _apiController.fetchProfileDetails(gId);
    } else {
      _apiController.isLoading.value = false;
    }
  }

  GroupProfileData? get _profileData {
    final dynamic val = _apiController.profileData.value;
    if (val is GroupProfileData) {
      return val;
    }
    if (val is GroupProfileDetailsModel) {
      return val.data;
    }
    return null;
  }

  GroupProfileData _getDummyData() {
    return GroupProfileData(
      group: GroupDetailsInfo(
        groupId: 0,
        groupName: "Loading Group Name...",
        groupProfile: "",
        groupCode: "XXXX",
      ),
      membersSummary: GroupMembersSummary(
        totalMembers: 12,
        onlineMembersCount: 4,
      ),
      permissions: GroupPermissions(
        canEditGroup: true,
        canAddMember: true,
        canLeaveGroup: true,
        canSendMessage: true,
      ),
      myStatus: MyStatus(
        isMember: true,
        isAdmin: true,
        isCreator: false,
      ),
      members: [
        GroupMemberInfo(
          userId: 1,
          name: "Loading Member 1",
          profileImage: "",
          isMe: true,
          isAdmin: true,
          isOnline: true,
        ),
        GroupMemberInfo(
          userId: 2,
          name: "Loading Member 2",
          profileImage: "",
          isMe: false,
          isAdmin: false,
          isOnline: false,
        ),
      ],
      mediaSummary: GroupMediaSummary(
        totalMedia: 4,
      ),
      media: GroupMediaDetails(
        photos: [
          GroupMediaItem(id: 1, type: "photo"),
          GroupMediaItem(id: 2, type: "photo")
        ],
        videos: [GroupMediaItem(id: 3, type: "video")],
        audio: [GroupMediaItem(id: 4, type: "audio")],
      ),
    );
  }

  bool _isOnline(GroupMemberInfo m) {
    return Tracking().isOnline(
      rawIsOnline: m.isOnline,
      lastSeen: m.rawLastSeen,
      thresholdMinutes: 5,
    );
  }

  String _statusText(GroupMemberInfo m) {
    if (_isOnline(m)) return "Online";
    if (m.rawLastSeen == null || m.rawLastSeen.toString().isEmpty) {
      return "Offline";
    }
    final parsed = Tracking.parseDateTime(m.rawLastSeen);
    if (parsed == null) return "Offline";
    try {
      return Tracking().getTimeAgo(parsed);
    } catch (_) {
      return "Offline";
    }
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
        actions: [
          if (chatController.isCreator.value)
            Padding(
              padding: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
              child: _roundBtn(
                icon: Icons.edit_rounded,
                onTap: () {
                  final currentGroup = _profileData?.group;
                  groupController.groupName.text = currentGroup?.groupName ??
                      chatController.groupName.toString();
                  DialogBox().showUpdateGroupBottomSheet(
                    context: context,
                    controller: groupController,
                    groupId: chatController.groupId.toString(),
                    currentImage:
                        currentGroup?.groupProfile ?? chatController.groupImage,
                  );
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final bool isLoading = _apiController.isLoading.value;
          final GroupProfileData? data =
              isLoading ? _getDummyData() : _profileData;

          if (!isLoading && (data == null || data.group == null)) {
            return Center(
                child: Text("Group details not found",
                    style: TextStyle(fontSize: 16.sp, color: _purple)));
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                _buildProfileHeader(data!),
                SizedBox(height: 18.h),
                _buildQuickActions(data),
                SizedBox(height: 16.h),
                _buildMediaCard(data.media, data.mediaSummary),
                SizedBox(height: 12.h),
                _buildSettingsCard(data),
                SizedBox(height: 16.h),
                _buildMembersSection(data),
                SizedBox(height: 16.h),
                // _buildFavoritesCard(),
                SizedBox(height: 12.h),
                _buildDangerSection(data),
                SizedBox(height: 24.h),
              ],
            ),
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

  Widget _buildProfileHeader(GroupProfileData data) {
    final group = data.group!;
    // final summary = data.membersSummary; // used by the hidden Members • Online line
    final img = group.groupProfile ?? "";
    final name = group.groupName ?? "Unknown Group";
    // Profile API may not send description → fall back to the group list's groupDesc
    final String apiDesc = (group.description ?? '').trim();
    final description =
        (apiDesc.isNotEmpty && apiDesc.toLowerCase() != 'null')
            ? apiDesc
            : chatController.groupDesc.value.trim();

    final bool hasImg = img.isNotEmpty && img.toLowerCase() != 'null';
    final String imgUrl =
        (img.startsWith('http://') || img.startsWith('https://'))
            ? img
            : "${ConstRes.aImageBaseUrl}$img";

    return Column(
      children: [
        // Tap → full screen group photo
        GestureDetector(
          onTap: hasImg ? () => _openFullImage(imgUrl, name) : null,
          child: Container(
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
          child: hasImg
              ? ClipOval(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.groups_rounded,
                        color: Colors.white, size: 40.sp),
                  ),
                )
              : Icon(Icons.groups_rounded, color: Colors.white, size: 40.sp),
        ),
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87),
        ),
        // Description (from API) replaces the "Members • Online" line;
        // without a description the Members / Online line shows as before
        if (description.isNotEmpty && description.toLowerCase() != 'null') ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
        // "Members • Online" line hidden (removed from header as requested)
        // SizedBox(height: 6.h),
        // Text.rich(
        //   TextSpan(
        //     children: [
        //       TextSpan(
        //         text:
        //             "${(summary?.totalMembers ?? 0).toString().padLeft(2, '0')} Members",
        //         style: TextStyle(
        //             fontSize: 12.sp,
        //             color: Colors.grey.shade600,
        //             fontWeight: FontWeight.w500),
        //       ),
        //       TextSpan(
        //         text: "  •  ",
        //         style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        //       ),
        //       TextSpan(
        //         text: "${summary?.onlineMembersCount ?? 0} Online",
        //         style: TextStyle(
        //             fontSize: 12.sp,
        //             color: const Color(0xFF2BB673),
        //             fontWeight: FontWeight.w600),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // Common WhatsApp-style full-screen photo viewer
  void _openFullImage(String url, String title) {
    showFullScreenPhoto(name: title, imageUrl: url);
  }

  Future<void> _initiateGroupCall(GroupProfileData data,
      {required bool isVideo}) async {
    try {
      Get.toNamed(
        Routes.groupCallingScreen,
        arguments: {
          "groupId": chatController.groupId.toString(),
          "groupName": data.group?.groupName ?? "Unknown Group",
          "groupProfile": data.group?.groupProfile ?? "",
          "isVideo": isVideo,
          "memberCount": data.membersSummary?.totalMembers ?? 0,
          "callType": "outgoing",
        },
      );
    } catch (e) {
      Get.snackbar("Error", "Could not start group call. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildQuickActions(GroupProfileData data) {
    return Row(
      children: [
        _quickAction(
            icon: Icons.call_outlined,
            label: "Audio Call",
            onTap: () => _initiateGroupCall(data, isVideo: false)),
        SizedBox(width: 10.w),
        _quickAction(
            icon: Icons.videocam_outlined,
            label: "Video Call",
            onTap: () => _initiateGroupCall(data, isVideo: true)),
        // SizedBox(width: 10.w),
        // _quickAction(
        //   icon: Icons.person_add_alt_1_outlined,
        //   label: "Add Members",
        //   onTap: () => Utils().fluttertoast("Add members"),
        // ),
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

  Widget _quickAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: _purple.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
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
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return "${ConstRes.aImageBaseUrl}$url";
  }

  Widget _buildMediaCard(GroupMediaDetails? media, GroupMediaSummary? summary) {
    List<MessageData> convertedMessages = [];

    if (media != null) {
      for (var p in media.photos ?? []) {
        String pUrl = _formatUrl(p.url ?? p.displayUrl);
        if (pUrl.isNotEmpty) {
          convertedMessages
              .add(MessageData(messageType: 'image', content: pUrl));
        }
      }
      for (var v in media.videos ?? []) {
        String vUrl = _formatUrl(v.url);
        String dUrl = _formatUrl(v.displayUrl);
        String videoContent = dUrl.isNotEmpty ? "$vUrl||$dUrl" : vUrl;
        if (vUrl.isNotEmpty) {
          convertedMessages
              .add(MessageData(messageType: 'video', content: videoContent));
        }
      }
      for (var a in media.audio ?? []) {
        String aUrl = _formatUrl(a.url);
        if (aUrl.isNotEmpty) {
          convertedMessages
              .add(MessageData(messageType: 'audio', content: aUrl));
        }
      }
      for (var d in media.documents ?? []) {
        String dUrl = _formatUrl(d.url);
        if (dUrl.isNotEmpty) {
          convertedMessages
              .add(MessageData(messageType: 'document', content: dUrl));
        }
      }
      for (var l in media.links ?? []) {
        String linkUrl = l.url ?? l.link ?? "";
        if (linkUrl.isNotEmpty) {
          convertedMessages
              .add(MessageData(messageType: 'link', content: linkUrl));
        }
      }
    }

    List<GroupMediaItem> previewMedia = [];
    if (media != null) {
      previewMedia.addAll(media.photos ?? []);
      previewMedia.addAll(media.videos ?? []);
      previewMedia.addAll(media.audio ?? []);
    }

    final displayMedia = previewMedia.take(4).toList();
    final total = summary?.totalMedia ?? 0;

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(
                () => MediaLinksDocsScreen(mediaMessages: convertedMessages)),
            child: Row(
              children: [
                Icon(Icons.photo_library_outlined, color: _purple, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text("Media, Links & Docs",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                ),
                Text("$total",
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600)),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 20.sp),
              ],
            ),
          ),
          if (displayMedia.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayMedia.length > 4 ? 4 : displayMedia.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  if (i == 3 && total > 4) {
                    return GestureDetector(
                      onTap: () => Get.to(() => MediaLinksDocsScreen(
                          mediaMessages: convertedMessages)),
                      child: Container(
                        width: 100.h,
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Center(
                          child: Text("+${total - 4}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  }

                  final m = displayMedia[i];
                  String rawThumb =
                      (m.displayUrl != null && m.displayUrl!.isNotEmpty)
                          ? m.displayUrl!
                          : (m.url != null ? m.url! : "");
                  String thumb = _formatUrl(rawThumb);

                  return GestureDetector(
                    onTap: () => Get.to(() =>
                        MediaLinksDocsScreen(mediaMessages: convertedMessages)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 100.h,
                        color: const Color(0xFFEDEBFB),
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
            Text("No media shared yet",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ],
        ],
      ),
    );
  }

  Widget _mediaPlaceholder(String type) {
    IconData icon = Icons.insert_drive_file_rounded;
    if (type == "image" || type == "photo") {
      icon = Icons.image_rounded;
    } else if (type == "video") {
      icon = Icons.videocam_rounded;
    } else if (type == "audio") {
      icon = Icons.audiotrack_rounded;
    } else if (type == "document") {
      icon = Icons.description_rounded;
    } else if (type == "link") {
      icon = Icons.link_rounded;
    }
    return Center(child: Icon(icon, color: _purple, size: 28.sp));
  }

  Widget _buildSettingsCard(GroupProfileData data) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // _settingTile(
          //   icon: Icons.star_border_rounded,
          //   iconColor: _purple,
          //   title: "Starred Messages",
          //   onTap: () {
          //     if (chatController.pinnedMessage.value != null) {
          //       Get.back();
          //       chatController.scrollToPinnedMessage();
          //     } else {
          //       Utils().fluttertoast("No starred/pinned message");
          //     }
          //   },
          // ),
          // _divider(),
          // Obx(() => _settingTile(
          //       icon: Icons.notifications_none_rounded,
          //       iconColor: _purple,
          //       title: "Notifications",
          //       subtitle: notificationsOn.value ? "All Messages" : "Muted",
          //       trailing: Transform.scale(
          //         scale: 0.8,
          //         child: Switch(
          //             value: notificationsOn.value,
          //             activeThumbColor: _purple,
          //             onChanged: (v) => notificationsOn.value = v),
          //       ),
          //     )),
          // _divider(),
          _settingTile(
            icon: Icons.reply_rounded,
            iconColor: _purple,
            title: "Invite via Link",
            onTap: () async {
              final code = data.group?.groupCode ?? "";
              final text = code.isNotEmpty
                  ? "Join my group \"${data.group?.groupName}\" on FG Tracker. Code: $code"
                  : "Join my group \"${data.group?.groupName}\" on FG Tracker";
              try {
                await Share.share(text);
              } catch (_) {
                await Clipboard.setData(ClipboardData(text: text));
                Utils().fluttertoast("Invite text copied");
              }
            },
          ),
          if (data.permissions?.canEditGroup == true) ...[
            _divider(),
            _settingTile(
              icon: Icons.settings_outlined,
              iconColor: _purple,
              title: "Group Settings",
              subtitle: "Edit group info, privacy, and more",
              onTap: () {
                groupController.groupName.text = data.group?.groupName ?? "";
                DialogBox().showUpdateGroupBottomSheet(
                  context: context,
                  controller: groupController,
                  groupId: data.group?.groupId.toString() ?? "",
                  currentImage: data.group?.groupProfile,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(GroupProfileData data) {
    final members = data.members ?? [];
    members.sort((a, b) {
      if (a.isMe == true) return -1;
      if (b.isMe == true) return 1;
      if (a.isAdmin == true && b.isAdmin != true) return -1;
      if (b.isAdmin == true && a.isAdmin != true) return 1;
      return 0;
    });

    final visible = showAllMembers.value ? members : members.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              Text("Members",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const Spacer(),
              Text(
                "${members.length}".padLeft(2, '0'),
                style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        _whiteCard(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            children: [
              for (int i = 0; i < visible.length; i++) ...[
                _memberTile(context, visible[i], data),
                if (i < visible.length - 1)
                  Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 64.w,
                      endIndent: 16.w),
              ],
              if (members.length > 3)
                TextButton(
                  onPressed: () => showAllMembers.value = !showAllMembers.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAllMembers.value ? "Show less" : "View all members",
                        style: TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp),
                      ),
                      Icon(
                          showAllMembers.value
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _purple),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openPrivateChat(
    GroupMemberInfo m,
    bool online,
  ) async {
    final receiverId = m.userId?.toString();
    if (receiverId == null ||
        receiverId.isEmpty ||
        receiverId == 'null' ||
        receiverId == _myId) {
      return;
    }

    final chatId = (m.chatId != null &&
            m.chatId.toString() != 'null' &&
            m.chatId.toString().isNotEmpty)
        ? m.chatId.toString()
        : null;

    final memberData = MemberData(
      userId: m.userId,
      groupId: 0,
      name: m.name ?? "Member",
      profileImage: m.profileImage,
      lastSeen: m.lastSeen,
      isOnline: online,
    );

    await Get.to(
      () => ChatScreen(),
      arguments: {
        "userData": memberData,
        "type": "chatScreen",
        "chatType": "private",
        "chatId": chatId,
        "groupId": 0,
        "groupName": m.name ?? "Chat",
        "isCreator": false,
      },
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MessageController>()) {
          Get.put(MessageController());
        }
      }),
    );
  }

  Widget _memberTile(
      BuildContext context, GroupMemberInfo m, GroupProfileData data) {
    final isMe = m.isMe ?? false;
    final isAdmin = m.isAdmin ?? false;
    final online = _isOnline(m);
    final name = m.name ?? "Unknown";
    final img = (m.profileImage?.isNotEmpty ?? false)
        ? _formatUrl(m.profileImage)
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: !isMe
                ? () => showUserQuickProfile(
                      userId: m.userId,
                      name: m.name,
                      profileImage: m.profileImage,
                      chatId: int.tryParse(m.chatId?.toString() ?? ''),
                    )
                : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: const Color(0xFFE8E4FF),
                  backgroundImage: img != null ? NetworkImage(img) : null,
                  child: img == null
                      ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: online
                          ? const Color(0xFF2BB673)
                          : const Color(0xFF9E9E9E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: InkWell(
              onTap: !isMe ? () => _openPrivateChat(m, online) : null,
              borderRadius: BorderRadius.circular(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(isMe ? "$name (You)" : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ),
                      if (isMe && isAdmin) ...[
                        SizedBox(width: 6.w),
                        _badge("Admin", const Color(0xFFE7F8EC),
                            const Color(0xFF2BB673)),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(_statusText(m),
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: online
                              ? const Color(0xFF2BB673)
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          if (!isMe && isAdmin)
            _badge("Group Admin", const Color(0xFFE7F8EC),
                const Color(0xFF2BB673)),
          SizedBox(width: 4.w),
          if (!isMe)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: Colors.grey.shade500, size: 20.sp),
            color: Colors.white,
            onSelected: (value) {
              if (value == "chat")
                _openPrivateChat(m, online);
              else if (value == "call")
                CallService().startOutGoingCall(context,
                    callerId: _myId,
                    remoteUserId: m.userId.toString(),
                    is_video: false,
                    callerName: name,
                    callerProfile: m.profileImage);
              else if (value == "video")
                CallService().startOutGoingCall(context,
                    callerId: _myId,
                    remoteUserId: m.userId.toString(),
                    is_video: true,
                    callerName: name,
                    callerProfile: m.profileImage);
              else if (value == "remove" &&
                  (data.permissions?.canAddMember ?? false) &&
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
                      groupId: data.group!.groupId.toString(),
                      groupMemberId: m.userId.toString(),
                      onSuccess: (success) {
                        if (success) {
                          _apiController
                              .fetchProfileDetails(data.group!.groupId!);
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
              if (!isMe && (data.permissions?.canAddMember ?? false))
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }

  // Widget _buildFavoritesCard() {
  //   return _whiteCard(
  //     padding: EdgeInsets.zero,
  //     child: _settingTile(
  //       icon: Icons.favorite_border_rounded,
  //       iconColor: _purple,
  //       title: "Add to Favorites",
  //       titleColor: _purple,
  //       onTap: () => Utils().fluttertoast("Added to favorites"),
  //     ),
  //   );
  // }

  Widget _buildDangerSection(GroupProfileData data) {
    return _whiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
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
                  chatController.clearGroupChat();
                },
              );
            },
          ),
          if (data.permissions?.canLeaveGroup == true) ...[
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
                      "Are you sure you want to exit \"${data.group?.groupName}\"?",
                  confirm: "Exit",
                  onConfirm: () {
                    Get.back();

                    MemberController().exitGroup(
                      context,
                      groupId: data.group!.groupId.toString(),
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
          ]
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
              offset: const Offset(0, 2))
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
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? Colors.black87)),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (trailingText != null)
              Text(trailingText,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            if (trailing == null)
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
