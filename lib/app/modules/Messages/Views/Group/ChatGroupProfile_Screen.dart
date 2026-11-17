import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/app/Core/util/last_seen_formatter.dart';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/chat_navigation.dart';
import 'package:fgtracker/app/Core/util/profile_navigation.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Group/widgets/group_membership_sheet.dart';
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
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
    if (_isOnline(m)) return appL10n.common_online;
    if (m.rawLastSeen == null || m.rawLastSeen.toString().isEmpty) {
      return appL10n.common_offline;
    }
    final parsed = Tracking.parseDateTime(m.rawLastSeen);
    if (parsed == null) return appL10n.common_offline;
    try {
      return formatLastSeen(context, parsed) ?? appL10n.common_offline;
    } catch (_) {
      return appL10n.common_offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This screen has no text field of its own; its sheets (Add Members,
      // edit group) handle the keyboard themselves. Without this, the whole
      // Group Info page re-laid out on every keyboard frame behind the sheet.
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: AppBarStyle.scrolledUnderElevation,
        surfaceTintColor: AppBarStyle.surfaceTintColor,
        toolbarHeight: 64.h,
        leadingWidth: AppBarStyle.leadingWidth,
        leading: AppBarStyle.leading(onTap: () => Get.back()),
        actions: [
          if (chatController.isCreator.value)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: _roundBtn(
                  key: const ValueKey('group_profile_edit_button'),
                  icon: Icons.edit_rounded,
                  onTap: () {
                    final currentGroup = _profileData?.group;
                    groupController.groupName.text =
                        currentGroup?.groupName ??
                            chatController.groupName.toString();
                    DialogBox().showUpdateGroupBottomSheet(
                      context: context,
                      controller: groupController,
                      groupId: chatController.groupId.toString(),
                      currentImage: currentGroup?.groupProfile ??
                          chatController.groupImage,
                    );
                  },
                ),
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
                child: Text(context.l10n.groupInfo_detailsNotFound,
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

  /// White rounded square (edit). Fixed 44×44 and the whole square is
  /// tappable.
  Widget _roundBtn({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
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
    final name = group.groupName ?? appL10n.groupInfo_unknownGroup;
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
    if (!GroupCallService.isGroupCallEnabled) {
      GroupCallService.showComingSoon();
      return;
    }
    try {
      Get.toNamed(
        Routes.groupCallingScreen,
        arguments: {
          "groupId": chatController.groupId.toString(),
          "groupName": data.group?.groupName ?? appL10n.groupInfo_unknownGroup,
          "groupProfile": data.group?.groupProfile ?? "",
          "isVideo": isVideo,
          "memberCount": data.membersSummary?.totalMembers ?? 0,
          "callType": "outgoing",
        },
      );
    } catch (e) {
      Get.snackbar(appL10n.common_error, appL10n.groupInfo_groupCallFailed,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildQuickActions(GroupProfileData data) {
    return Row(
      children: [
        _quickAction(
            icon: Icons.call_outlined,
            label: appL10n.groupInfo_audioCall,
            onTap: () => _initiateGroupCall(data, isVideo: false)),
        SizedBox(width: 10.w),
        _quickAction(
            icon: Icons.videocam_outlined,
            label: appL10n.groupInfo_videoCall,
            onTap: () => _initiateGroupCall(data, isVideo: true)),
        // _quickAction(
        //   icon: Icons.person_add_alt_1_outlined,
        //   label: "Add Members",
        //   onTap: () => Utils().fluttertoast("Add members"),
        // ),
        SizedBox(width: 10.w),
        _quickAction(
          icon: Icons.search_rounded,
          label: appL10n.common_search,
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
                  child: Text(appL10n.groupInfo_mediaLinksDocs,
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
            Text(appL10n.groupInfo_noMediaYet,
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
            title: appL10n.groupInfo_inviteViaLink,
            onTap: () async {
              final code = data.group?.groupCode ?? "";
              final groupName = "${data.group?.groupName}";
              final text = code.isNotEmpty
                  ? appL10n.groupInfo_inviteTextWithCode(groupName, code)
                  : appL10n.groupInfo_inviteText(groupName);
              try {
                await Share.share(text);
              } catch (_) {
                await Clipboard.setData(ClipboardData(text: text));
                Utils().fluttertoast(appL10n.groupInfo_inviteCopied);
              }
            },
          ),
          if (data.permissions?.canEditGroup == true) ...[
            _divider(),
            _settingTile(
              icon: Icons.campaign_outlined,
              iconColor: _purple,
              title: appL10n.groupAdmin_sendMessagesTitle,
              subtitle: data.group?.onlyAdminsCanSend == true
                  ? appL10n.groupAdmin_onlyAdminsCanSend
                  : appL10n.groupAdmin_allMembersCanSend,
              trailing: Switch.adaptive(
                value: data.group?.onlyAdminsCanSend == true,
                activeColor: _purple,
                onChanged: (val) async {
                  final gId = data.group?.groupId.toString() ?? "";
                  final success = await groupController.updateOnlyAdminsCanSend(
                    groupId: gId,
                    onlyAdminsCanSend: val,
                  );
                  if (success) {
                    setState(() {
                      data.group?.onlyAdminsCanSend = val;
                    });
                    chatController.onlyAdminsCanSend.value = val;
                    _apiController.fetchProfileDetails(
                      int.tryParse(gId) ?? 0,
                      silent: true,
                    );
                  }
                },
              ),
              onTap: () async {
                final current = data.group?.onlyAdminsCanSend == true;
                final val = !current;
                final gId = data.group?.groupId.toString() ?? "";
                final success = await groupController.updateOnlyAdminsCanSend(
                  groupId: gId,
                  onlyAdminsCanSend: val,
                );
                if (success) {
                  setState(() {
                    data.group?.onlyAdminsCanSend = val;
                  });
                  chatController.onlyAdminsCanSend.value = val;
                  _apiController.fetchProfileDetails(
                    int.tryParse(gId) ?? 0,
                    silent: true,
                  );
                }
              },
            ),
            _divider(),
            _settingTile(
              icon: Icons.settings_outlined,
              iconColor: _purple,
              title: appL10n.groupInfo_groupSettings,
              subtitle: appL10n.groupInfo_groupSettingsSubtitle,
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
    final bool canAdd = data.myStatus?.isAdmin == true ||
        data.myStatus?.isCreator == true;

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
              Text(appL10n.groupInfo_members,
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
              if (canAdd) ...[
                _addMemberTile(context, data),
                Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 64.w,
                    endIndent: 16.w),
              ],
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
                      Flexible(
                        child: AutoFitText(
                          showAllMembers.value
                              ? appL10n.groupInfo_showLess
                              : appL10n.groupInfo_viewAllMembers,
                          style: TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp),
                        ),
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

  Widget _addMemberTile(BuildContext context, GroupProfileData data) {
    return InkWell(
      onTap: () => _showAddMemberBottomSheet(data),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: Color(0xFF2BB673),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.groupAdmin_addMembersTitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2BB673),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.l10n.groupAdmin_addMembersSubtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberBottomSheet(GroupProfileData data) {
    final bool canAdd = data.myStatus?.isAdmin == true ||
        data.myStatus?.isCreator == true;
    if (!canAdd) return;

    final int? gId = data.group?.groupId;
    if (gId == null) return;
    final existingMemberIds = (data.members ?? [])
        .map((m) => m.userId?.toString())
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddGroupMemberSheet(
          groupId: gId.toString(),
          groupName: data.group?.groupName ?? "Group",
          existingMemberIds: existingMemberIds,
          myUserId: _myId,
          onMemberAdded: () {
            _apiController.fetchProfileDetails(gId);
            chatController.getGroupMembers();
            chatController.getGroupMessages();
          },
        );
      },
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
      name: m.name ?? appL10n.groupInfo_member,
      profileImage: m.profileImage,
      lastSeen: m.lastSeen,
      isOnline: online,
    );

    await ChatNavigation.openPrivateChat({
      "userData": memberData,
      "type": "chatScreen",
      "chatType": "private",
      "chatId": chatId,
      "groupId": 0,
      "groupName": m.name ?? "Chat",
      "isCreator": false,
      "source": "group_profile_member_list",
    });
  }

  Widget _memberTile(
      BuildContext context, GroupMemberInfo m, GroupProfileData data) {
    final isMe = m.isMe ?? false;
    final isAdmin = m.isAdmin ?? false;
    final online = _isOnline(m);
    final name = m.name ?? appL10n.chat_unknown;
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
                        child: Text(isMe ? appL10n.groupInfo_nameYou(name) : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ),
                      if (isMe && isAdmin) ...[
                        SizedBox(width: 6.w),
                        _badge(appL10n.groupInfo_admin, const Color(0xFFE7F8EC),
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
            _badge(appL10n.groupInfo_groupAdmin, const Color(0xFFE7F8EC),
                const Color(0xFF2BB673)),
          SizedBox(width: 4.w),
          if (!isMe)
          Builder(builder: (context) {
            final bool myIsAdmin = data.myStatus?.isAdmin == true || data.myStatus?.isCreator == true;
            final bool myIsCreator = data.myStatus?.isCreator == true;
            final bool canPromote = !isMe && !isAdmin && myIsAdmin;
            final bool canDemote = !isMe && isAdmin && myIsCreator;
            final bool canRemove = !isMe && (myIsAdmin || (data.permissions?.canAddMember ?? false)) && (!isAdmin || myIsCreator);

            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: Colors.grey.shade500, size: 20.sp),
              color: Colors.white,
              onSelected: (value) {
                if (value == "chat") {
                  _openPrivateChat(m, online);
                } else if (value == "call") {
                  CallService().startOutGoingCall(context,
                      callerId: _myId,
                      remoteUserId: m.userId.toString(),
                      is_video: false,
                      callerName: name,
                      callerProfile: m.profileImage);
                } else if (value == "video") {
                  CallService().startOutGoingCall(context,
                      callerId: _myId,
                      remoteUserId: m.userId.toString(),
                      is_video: true,
                      callerName: name,
                      callerProfile: m.profileImage);
                } else if (value == "make_admin") {
                  CommonDialog.ConfirmationDialog(
                    title: appL10n.groupAdmin_makeAdminTitle,
                    content: appL10n.groupAdmin_makeAdminConfirm(name),
                    confirm: appL10n.groupAdmin_makeAdminAction,
                    onConfirm: () {
                      Get.back();
                      groupController.promoteAdmin(
                        context,
                        groupId: data.group!.groupId.toString(),
                        userId: m.userId.toString(),
                        onSuccess: (success) {
                          if (success) {
                            _apiController.fetchProfileDetails(data.group!.groupId!);
                            chatController.getGroupMembers();
                          }
                        },
                      );
                    },
                  );
                } else if (value == "dismiss_admin") {
                  CommonDialog.ConfirmationDialog(
                    title: appL10n.groupAdmin_dismissAdminTitle,
                    content: appL10n.groupAdmin_dismissAdminConfirm(name),
                    confirm: appL10n.groupAdmin_dismissAction,
                    onConfirm: () {
                      Get.back();
                      groupController.demoteAdmin(
                        context,
                        groupId: data.group!.groupId.toString(),
                        userId: m.userId.toString(),
                        onSuccess: (success) {
                          if (success) {
                            _apiController.fetchProfileDetails(data.group!.groupId!);
                            chatController.getGroupMembers();
                          }
                        },
                      );
                    },
                  );
                } else if (value == "remove" && canRemove) {
                  CommonDialog.ConfirmationDialog(
                    title: appL10n.chat_removeMember,
                    content: appL10n.groupInfo_removeMemberConfirm(name),
                    confirm: appL10n.common_remove,
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
                            chatController.getGroupMembers();
                            chatController.getGroupMessages();
                          }
                        },
                      );
                    },
                  );
                }
              },
              itemBuilder: (_) => [
                if (!isMe)
                  PopupMenuItem(
                      value: "chat", child: Text(appL10n.groupInfo_messageAction)),
                if (!isMe)
                  PopupMenuItem(
                      value: "call", child: Text(appL10n.groupInfo_audioCall)),
                if (!isMe)
                  PopupMenuItem(
                      value: "video", child: Text(appL10n.groupInfo_videoCall)),
                if (canPromote)
                  PopupMenuItem(
                      value: "make_admin", child: Text(appL10n.groupAdmin_menuMakeAdmin)),
                if (canDemote)
                  PopupMenuItem(
                      value: "dismiss_admin", child: Text(appL10n.groupAdmin_menuDismissAdmin)),
                if (canRemove)
                  PopupMenuItem(
                      value: "remove",
                      child: Text(appL10n.groupInfo_removeFromGroup)),
              ],
            );
          }),
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
            title: appL10n.chat_clearChat,
            titleColor: Colors.redAccent,
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: appL10n.chat_clearChat,
                content: appL10n.groupInfo_clearChatConfirm,
                confirm: appL10n.chat_clear,
                onConfirm: () async {
                  Get.back();
                  final cleared = await chatController.clearGroupChat();
                  if (!cleared) return;
                  // Media / Links / Docs used to keep the cleared files.
                  _apiController.clearMediaLocally();
                  final gId =
                      int.tryParse(chatController.groupId.toString()) ?? 0;
                  if (gId != 0) {
                    _apiController.fetchProfileDetails(gId, silent: true);
                  }
                },
              );
            },
          ),
          if (data.permissions?.canLeaveGroup == true) ...[
            _divider(),
            _settingTile(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              title: appL10n.groupInfo_exitGroup,
              titleColor: Colors.redAccent,
              onTap: () {
                CommonDialog.ConfirmationDialog(
                  title: appL10n.groupInfo_exitGroup,
                  content: appL10n
                      .groupInfo_exitGroupConfirm("${data.group?.groupName}"),
                  confirm: appL10n.common_exit,
                  onConfirm: () {
                    Get.back();

                    MemberController().exitGroup(
                      context,
                      groupId: data.group!.groupId.toString(),
                      userId: _myId,
                      onSuccess: (success) {
                        if (success) {
                          final leftGroupName =
                              data.group?.groupName ?? appL10n.groupInfo_group;
                          final leftGroupImage = data.group?.groupProfile;
                          final leftMemberCount =
                              data.membersSummary?.totalMembers;
                          GroupMembershipSheet.navigateAfterLeave(
                            groupId: data.group!.groupId.toString(),
                          );
                          GroupMembershipSheet.showLeft(
                            groupName: leftGroupName,
                            groupImage: leftGroupImage,
                            memberCount: leftMemberCount,
                            delay: const Duration(milliseconds: 600),
                          );
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

class _CandidateMember {
  final UserListData user;
  final bool isSavedContact;
  final bool isInOtherGroup;

  _CandidateMember({
    required this.user,
    required this.isSavedContact,
    required this.isInOtherGroup,
  });

  String get tag {
    if (isSavedContact && isInOtherGroup) return "Saved Contact • Other Group";
    if (isSavedContact) return "Saved Contact";
    if (isInOtherGroup) return "In Other Group";
    return "";
  }

  /// Compact label shown next to the Add button.
  String get shortTag {
    if (isSavedContact && isInOtherGroup) return appL10n.groupAdmin_tagContactAndGroup;
    if (isSavedContact) return appL10n.groupAdmin_tagSavedContact;
    if (isInOtherGroup) return appL10n.groupAdmin_tagYourGroups;
    return "";
  }
}

/// Lifts a bottom sheet above the keyboard without rebuilding it: only this
/// widget depends on the keyboard inset; [child] is the same instance on
/// every keyboard frame, so it is laid out again, not rebuilt. Height is
/// [maxHeight], shrunk when the keyboard leaves less room (the list inside
/// is `Expanded`, so it gets shorter and stays scrollable above the keys).
class _KeyboardAwareSheet extends StatelessWidget {
  const _KeyboardAwareSheet({required this.maxHeight, required this.child});

  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final room = MediaQuery.sizeOf(context).height -
        MediaQuery.paddingOf(context).top -
        inset;
    final height = room < maxHeight ? room : maxHeight;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SizedBox(height: height < 0 ? 0 : height, child: child),
    );
  }
}

class _AddGroupMemberSheet extends StatefulWidget {
  final String groupId;
  final String groupName;
  final Set<String?> existingMemberIds;
  final String myUserId;
  final VoidCallback onMemberAdded;

  const _AddGroupMemberSheet({
    required this.groupId,
    required this.groupName,
    required this.existingMemberIds,
    required this.myUserId,
    required this.onMemberAdded,
  });

  @override
  State<_AddGroupMemberSheet> createState() => _AddGroupMemberSheetState();
}

class _AddGroupMemberSheetState extends State<_AddGroupMemberSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final GroupController _groupCtrl = Get.find<GroupController>();

  bool _loading = true;
  String? _error;
  bool _contactPermissionGranted = false;
  List<_CandidateMember> _allCandidates = [];
  List<_CandidateMember> _filteredCandidates = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<List<String>> _getDeviceContactsPlatformWise() async {
    try {
      // Platform-wise permission check using permission_handler (Android & iOS)
      PermissionStatus status = await Permission.contacts.status;

      if (!status.isGranted && !status.isLimited) {
        status = await Permission.contacts.request();
      }

      if (status.isGranted || status.isLimited) {
        _contactPermissionGranted = true;
        final contactService = ContactService();
        return await contactService.getMobileNumbers();
      } else {
        // Fallback request via FlutterContacts
        final bool granted =
            await FlutterContacts.requestPermission(readonly: true);
        if (granted) {
          _contactPermissionGranted = true;
          final contactService = ContactService();
          return await contactService.getMobileNumbers();
        }
      }
    } catch (e) {
      log("Contact permission error: $e");
    }
    return [];
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Concurrently fetch contacts, all-group members, co-group IDs, and all users
      final contactNumbersFuture = _getDeviceContactsPlatformWise();
      final allGroupMembersFuture =
          TrackRepo.getGroupMember(filter: 'all', limit: 200);
      final coMemberIdsFuture = GroupRepo.getCoGroupMemberIds();
      final allUsersFuture = GroupRepo.getAllUserData();

      final results = await Future.wait([
        contactNumbersFuture,
        allGroupMembersFuture,
        coMemberIdsFuture,
        allUsersFuture,
      ]);

      final List<String> contactNumbers = results[0] as List<String>;
      final GroupMemberModel allGroupModel = results[1] as GroupMemberModel;
      final List<int> coMemberIds = results[2] as List<int>;
      final UserProfileListRes allUsersRes = results[3] as UserProfileListRes;

      final Set<String> contactSet = contactNumbers.toSet();
      final Set<String> coMemberIdSet =
          coMemberIds.map((id) => id.toString()).toSet();

      final Map<String, UserListData> candidateUsersMap = {};

      // 2. Extract co-members from allGroupMembers (covers all joined groups)
      final allGroupMembers = allGroupModel.data?.allMemberList ?? [];
      for (final m in allGroupMembers) {
        final idStr = m.userId?.toString();
        if (idStr != null && idStr.isNotEmpty && idStr != widget.myUserId) {
          coMemberIdSet.add(idStr);
          candidateUsersMap[idStr] = UserListData(
            userId: m.userId,
            name: m.name,
            mobileNo: m.mobileNo,
            profileImage: m.profileImage,
          );
        }
      }

      // 3. Merge users from getAllUserData
      if (allUsersRes.status == true && allUsersRes.userData != null) {
        for (final u in allUsersRes.userData!) {
          final idStr = u.userId?.toString();
          if (idStr != null && idStr.isNotEmpty && idStr != widget.myUserId) {
            candidateUsersMap[idStr] = u;
          }
        }
      }

      final List<_CandidateMember> candidates = [];

      for (final u in candidateUsersMap.values) {
        final uId = u.userId?.toString();
        if (uId == null || uId.isEmpty) continue;
        if (uId == widget.myUserId) continue;
        if (widget.existingMemberIds.contains(uId)) continue;

        String mob = (u.mobileNo ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        if (mob.startsWith('91') && mob.length > 10) mob = mob.substring(2);
        if (mob.length > 10) mob = mob.substring(mob.length - 10);

        final bool isSaved = mob.isNotEmpty && contactSet.contains(mob);
        final bool isInOther = coMemberIdSet.contains(uId);

        // ONLY Saved Member OR Who are in other group!
        if (isSaved || isInOther) {
          candidates.add(_CandidateMember(
            user: u,
            isSavedContact: isSaved,
            isInOtherGroup: isInOther,
          ));
        }
      }

      candidates.sort((a, b) {
        if (a.isSavedContact && !b.isSavedContact) return -1;
        if (!a.isSavedContact && b.isSavedContact) return 1;
        final nameA = (a.user.name ?? "").toLowerCase();
        final nameB = (b.user.name ?? "").toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        _allCandidates = candidates;
        _filteredCandidates = candidates;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredCandidates = _allCandidates;
      } else {
        _filteredCandidates = _allCandidates.where((c) {
          final name = (c.user.name ?? "").toLowerCase();
          final phone = (c.user.mobileNo ?? "").toLowerCase();
          return name.contains(q) || phone.contains(q);
        }).toList();
      }
    });
  }

  void _confirmAdd(UserListData user) {
    final userName = user.name ?? appL10n.groupInfo_member;
    CommonDialog.ConfirmationDialog(
      title: appL10n.group_addMember,
      content: appL10n.groupAdmin_addMemberConfirm(widget.groupName, userName),
      confirm: appL10n.common_add,
      onConfirm: () {
        Get.back(); // close confirmation dialog
        _groupCtrl.addGroupMember(
          context,
          groupId: widget.groupId,
          userId: user.userId.toString(),
          onSuccess: (success) {
            if (success) {
              Navigator.pop(context); // close bottom sheet
              widget.onMemberAdded();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color purple = Color(0xFF5045B9);
    // sizeOf, not of(): of() also listens to the keyboard inset, which
    // changes every frame while the keyboard opens / closes and rebuilt the
    // whole sheet each frame (search typing lagged). The keyboard is
    // handled by _KeyboardAwareSheet, which only re-lays out this child.
    final double sheetHeight = MediaQuery.sizeOf(context).height * 0.75;

    return _KeyboardAwareSheet(
      maxHeight: sheetHeight,
      child: _buildSheetBody(context, purple),
    );
  }

  Widget _buildSheetBody(BuildContext context, Color purple) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Title row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.groupAdmin_addMembersTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        context.l10n.groupAdmin_selectContactSubtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey.shade600,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: Colors.grey.shade500, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearch,
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: context.l10n.groupAdmin_searchHint,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _onSearch("");
                      },
                      child: Icon(Icons.clear_rounded,
                          color: Colors.grey.shade500, size: 18.sp),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 12.h, color: Colors.grey.shade200),
          if (!_contactPermissionGranted && !_loading && _error == null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  Icon(Icons.contacts_outlined,
                      size: 18.sp, color: const Color(0xFFF57F17)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.l10n.groupAdmin_contactsPermissionOff,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF5D4037),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await openAppSettings();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Text(
                        context.l10n.groupAdmin_enable,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: _loading
                ? _buildSkeletonList(purple)
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64.w,
                                height: 64.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDECEC),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.cloud_off_rounded,
                                    size: 30.sp,
                                    color: const Color(0xFFD9534F)),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                context.l10n.groupAdmin_loadFailedTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                context.l10n.groupAdmin_loadFailedBody,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              ElevatedButton.icon(
                                key: const ValueKey('add_member_retry'),
                                onPressed: _fetchUsers,
                                icon: Icon(Icons.refresh_rounded,
                                    size: 18.sp, color: Colors.white),
                                label: Text(
                                  context.l10n.common_retry,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purple,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredCandidates.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      size: 48.sp,
                                      color: Colors.grey.shade400),
                                  SizedBox(height: 10.h),
                                  Text(
                                    _searchCtrl.text.isNotEmpty
                                        ? context.l10n.groupAdmin_noMatchingContacts
                                        : context.l10n.groupAdmin_noCandidates,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    context.l10n.groupAdmin_candidatesHint,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            itemCount: _filteredCandidates.length,
                            separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                                indent: 56.w),
                            itemBuilder: (context, index) => _candidateTile(
                              _filteredCandidates[index],
                              purple,
                              onTap: () =>
                                  _confirmAdd(_filteredCandidates[index].user),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Shimmer while contacts / group members load: same rows as the real list.
  Widget _buildSkeletonList(Color purple) {
    final placeholder = _CandidateMember(
      user: UserListData(
        name: 'Loading member name',
        mobileNo: '+91 98765 43210',
      ),
      isSavedContact: true,
      isInOtherGroup: false,
    );
    return Skeletonizer(
      key: const ValueKey('add_member_skeleton'),
      enabled: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 8,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100, indent: 56.w),
        itemBuilder: (_, __) => _candidateTile(placeholder, purple),
      ),
    );
  }

  /// One person who can be added: photo, name, phone + where they come from
  /// (saved contact / other group) and an "Add" button. The whole row is
  /// tappable.
  Widget _candidateTile(
    _CandidateMember candidate,
    Color purple, {
    VoidCallback? onTap,
  }) {
    final u = candidate.user;
    final name = (u.name ?? '').trim().isEmpty ? "Member" : u.name!.trim();
    final phone = u.mobileNo ?? "";
    final rawImg = u.profileImage ?? "";
    final imgUrl = rawImg.isNotEmpty
        ? (rawImg.startsWith("http://") || rawImg.startsWith("https://")
            ? rawImg
            : "${ConstRes.aImageBaseUrl}$rawImg")
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
              child: imgUrl == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        color: purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Right side: where the person comes from, then the Add button.
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (candidate.tag.isNotEmpty) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        candidate.isSavedContact
                            ? Icons.contacts_rounded
                            : Icons.groups_rounded,
                        size: 11.sp,
                        color: candidate.isSavedContact
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF5E35B1),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        candidate.shortTag,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: candidate.isSavedContact
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF5E35B1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                ],
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        context.l10n.common_add,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
