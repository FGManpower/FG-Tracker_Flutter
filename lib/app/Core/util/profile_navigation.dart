import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../gen/fonts.gen.dart';
import '../../Data/Services/call_service.dart';
import '../../Data/Services/group_call_service.dart';
import '../../Model/MemberDataRes.dart';
import '../../Model/PrivateChatModel.dart';
import '../../modules/Messages/Controller/MessageController.dart';
import '../../modules/Messages/Controller/chat_list_controller.dart';
import '../../modules/Messages/Views/Chat_Screen.dart';
import '../../modules/Messages/Views/UserProfileScreen.dart';
import '../../modules/call/Controller/contact_controller.dart';
import '../../modules/call/widget/call_widget.dart';
import '../../modules/Group/controller/Group_Controller.dart';
import '../../routes/app_pages.dart';
import '../constant/const_res.dart';
import '../constant/pref_res.dart';
import '../values/Utils.dart';
import '../values/global.dart';

String _myId() =>
    Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

/// True when [userId] is the logged-in user.
bool isMyUserId(dynamic userId) => userId?.toString().trim() == _myId();

/// Returns a cleaned user id, or '' when it is missing / invalid.
String _cleanId(dynamic userId) {
  final String uid = userId?.toString().trim() ?? '';
  if (uid.isEmpty || uid == 'null' || uid == '0') return '';
  return uid;
}

/// Full image url from a raw profile image value ('' when there is none).
String profileImageUrl(String? raw) {
  final String v = raw?.trim() ?? '';
  final String lower = v.toLowerCase();
  if (v.isEmpty ||
      lower == 'null' ||
      lower == 'undefined' ||
      lower.endsWith('/null') ||
      lower.contains('default')) {
    return '';
  }
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  final base = ConstRes.aImageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
  return '$base/${v.replaceFirst(RegExp(r'^/+'), '')}';
}

/// Common entry point to open another user's profile (UserProfileScreen).
///
/// UserProfileScreen loads its data by the private chatId, so this resolves
/// the chatId for [userId] when it is not passed. If none is found it passes 0
/// so the screen shows the given details instead of falling back to whatever
/// chat the MessageController currently holds (which could be another user).
void openUserProfile({
  required dynamic userId,
  String? name,
  String? profileImage,
  String? mobileNo,
  int? chatId,
}) {
  final String uid = _cleanId(userId);
  // Own profile is not shown via UserProfileScreen.
  if (uid.isEmpty || uid == _myId()) return;

  final int? resolvedChatId =
      (chatId != null && chatId != 0) ? chatId : resolvePrivateChatId(uid);

  Get.to(() => UserProfileScreen(
        userData: MemberData(
          userId: int.tryParse(uid),
          name: name,
          profileImage: profileImage,
          mobileNo: mobileNo,
          chatId: resolvedChatId,
          groupId: 0,
        ),
        chatId: resolvedChatId ?? 0,
      ));
}

/// Finds the private chatId with [userId] from already loaded data.
int? resolvePrivateChatId(String userId) {
  if (Get.isRegistered<ChatListController>()) {
    final c = Get.find<ChatListController>();
    for (final list in [c.privateChats, c.archivedChats]) {
      final PrivateChatModel? chat = list.firstWhereOrNull(
        (ch) => ch.isGroup != true && ch.userId?.toString() == userId,
      );
      final int? id = chat?.chatId ?? chat?.conversationId ?? chat?.id;
      if (id != null && id != 0) return id;
    }
  }
  if (Get.isRegistered<ContactController>()) {
    final id = Get.find<ContactController>().chatIdFor(int.tryParse(userId));
    if (id != null && id != 0) return id;
  }
  return null;
}

/// Opens the private chat with a user (same flow as the chat list).
Future<void> openPrivateChatWith({
  required dynamic userId,
  String? name,
  String? profileImage,
  int? chatId,
}) async {
  final String uid = _cleanId(userId);
  if (uid.isEmpty || uid == _myId()) return;

  final int? resolvedChatId =
      (chatId != null && chatId != 0) ? chatId : resolvePrivateChatId(uid);

  await Get.to(
    () => ChatScreen(),
    arguments: {
      "userData": MemberData(
        userId: int.tryParse(uid),
        name: name,
        profileImage: profileImage,
        groupId: 0,
      ),
      "chatId": resolvedChatId?.toString(),
    },
    binding: BindingsBuilder(() {
      Get.put(MessageController());
    }),
  );
}

/// Opens a group chat (same flow as the chat list group row).
Future<void> openGroupChat({
  required dynamic groupId,
  String? groupName,
  String? groupProfile,
}) async {
  final String gId = _cleanId(groupId);
  if (gId.isEmpty) return;

  String groupCode = '';
  String isCreator = 'false';
  String isActive = 'true';
  String profileImg = groupProfile ?? '';

  if (Get.isRegistered<GroupController>()) {
    final matched = Get.find<GroupController>()
        .groupData
        .firstWhereOrNull((g) => g.id?.toString() == gId);
    if (matched != null) {
      groupCode = matched.groupCode ?? '';
      isCreator = (matched.isCreator ?? false).toString();
      isActive = (matched.isActive ?? true).toString();
      if (profileImageUrl(profileImg).isEmpty &&
          matched.groupProfile != null) {
        profileImg = matched.groupProfile!;
      }
    }
  }

  await Get.toNamed(
    Routes.groupChatScreen,
    arguments: {
      "groupId": gId,
      "groupName": groupName ?? "Group Chat",
      "groupProfile": profileImg,
      "groupImage": profileImg,
      "groupCode": groupCode,
      "isCreator": isCreator,
      "isActive": isActive,
    },
  );
}

/// Starts an audio / video call with a user (same flow as New Chat).
void startUserCall({
  required dynamic userId,
  String? name,
  String? profileImage,
  String? mobileNo,
  required bool isVideo,
}) {
  final String uid = _cleanId(userId);
  if (!CallValidation.validateCall(
    destinationPhone: mobileNo ?? '',
    destinationUserId: uid,
  )) {
    return;
  }
  final ctx = Get.context;
  if (uid.isEmpty || ctx == null) {
    Utils().fluttertoast("Unable to call this contact");
    return;
  }
  CallService().startOutGoingCall(
    ctx,
    callerId: _myId(),
    remoteUserId: uid,
    is_video: isVideo,
    callerName: name ?? 'User',
    callerProfile: profileImage,
  );
}

/// Tap on any user's photo: big photo + Message / Call / Video / Info.
/// Pass [showMessage] false when already inside that user's chat.
void showUserQuickProfile({
  required dynamic userId,
  String? name,
  String? profileImage,
  String? mobileNo,
  int? chatId,
  bool showMessage = true,
}) {
  final String uid = _cleanId(userId);
  if (uid.isEmpty || uid == _myId()) return;

  final String displayName = (name != null &&
          name.trim().isNotEmpty &&
          name.trim().toLowerCase() != 'null')
      ? name.trim()
      : (mobileNo ?? 'User');

  showProfilePhotoPreview(
    name: displayName,
    imageUrl: profileImageUrl(profileImage),
    onMessage: showMessage
        ? () => openPrivateChatWith(
              userId: uid,
              name: displayName,
              profileImage: profileImage,
              chatId: chatId,
            )
        : null,
    onAudioCall: () => startUserCall(
      userId: uid,
      name: displayName,
      profileImage: profileImage,
      mobileNo: mobileNo,
      isVideo: false,
    ),
    onVideoCall: () => startUserCall(
      userId: uid,
      name: displayName,
      profileImage: profileImage,
      mobileNo: mobileNo,
      isVideo: true,
    ),
    onInfo: () => openUserProfile(
      userId: uid,
      name: displayName,
      profileImage: profileImage,
      mobileNo: mobileNo,
      chatId: chatId,
    ),
  );
}

/// Starts a group audio / video call (same flow as Recent Calls).
void startGroupCallWith({
  required dynamic groupId,
  String? groupName,
  String? groupProfile,
  int? memberCount,
  required bool isVideo,
}) {
  final String gId = _cleanId(groupId);
  final ctx = Get.context;
  if (gId.isEmpty || ctx == null) {
    Utils().fluttertoast("Unable to start group call");
    return;
  }
  GroupCallService.instance.startGroupCall(
    ctx,
    groupId: gId,
    groupName: groupName ?? "Group Call",
    groupProfile: groupProfile,
    isVideo: isVideo,
    memberCount: memberCount ?? 0,
  );
}

/// Tap on any group's photo: big photo + Message / Call / Video (+ Info).
/// [onMessage] overrides the default "open group chat" (e.g. to mark read);
/// [onInfo] is shown only when the caller has a group info screen to open.
void showGroupQuickProfile({
  required dynamic groupId,
  String? groupName,
  String? groupProfile,
  int? memberCount,
  VoidCallback? onMessage,
  VoidCallback? onInfo,
}) {
  final String gId = _cleanId(groupId);
  if (gId.isEmpty) return;

  final String name = (groupName != null &&
          groupName.trim().isNotEmpty &&
          groupName.trim().toLowerCase() != 'null')
      ? groupName.trim()
      : 'Group';

  showProfilePhotoPreview(
    name: name,
    imageUrl: profileImageUrl(groupProfile),
    isGroup: true,
    onMessage: onMessage ??
        () => openGroupChat(
              groupId: gId,
              groupName: name,
              groupProfile: groupProfile,
            ),
    onAudioCall: () => startGroupCallWith(
      groupId: gId,
      groupName: name,
      groupProfile: groupProfile,
      memberCount: memberCount,
      isVideo: false,
    ),
    onVideoCall: () => startGroupCallWith(
      groupId: gId,
      groupName: name,
      groupProfile: groupProfile,
      memberCount: memberCount,
      isVideo: true,
    ),
    onInfo: onInfo,
  );
}

/// WhatsApp-style profile photo popup: name on top, big photo,
/// actions (message / call / video / info) at the bottom.
/// Tapping the photo opens a full-screen zoomable view.
void showProfilePhotoPreview({
  required String name,
  required String imageUrl,
  bool isGroup = false,
  VoidCallback? onMessage,
  VoidCallback? onAudioCall,
  VoidCallback? onVideoCall,
  VoidCallback? onInfo,
}) {
  final bool hasImage = imageUrl.isNotEmpty;
  final double size = (Get.width * 0.72).clamp(220.0, 320.0);

  Widget fallback() => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(
          isGroup ? Icons.groups_rounded : Icons.person,
          color: Colors.grey.shade500,
          size: 90.sp,
        ),
      );

  Widget action(IconData icon, VoidCallback onTap) => IconButton(
        onPressed: () {
          Get.back();
          onTap();
        },
        icon: Icon(icon, size: 22.sp, color: const Color(0xFF6B4DFF)),
      );

  final actions = <Widget>[
    if (onMessage != null) action(Icons.chat_bubble_outline, onMessage),
    if (onAudioCall != null) action(Icons.call_outlined, onAudioCall),
    if (onVideoCall != null) action(Icons.videocam_outlined, onVideoCall),
    if (onInfo != null) action(Icons.info_outline_rounded, onInfo),
  ];

  Get.dialog(
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    Center(
      child: Container(
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: hasImage
                        ? () {
                            Get.back();
                            showFullScreenPhoto(
                                name: name, imageUrl: imageUrl);
                          }
                        : null,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6B4DFF),
                                ),
                              ),
                              errorWidget: (context, url, error) => fallback(),
                            )
                          : fallback(),
                    ),
                  ),
                  // Name strip on top of the photo
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 18.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontFamily: FontFamily.interSemiBold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (actions.isNotEmpty)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFEFEBFD), width: 1),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// WhatsApp-style full-screen photo: black background, back arrow + name
/// on top, image fitted to the full screen, pinch to zoom.
void showFullScreenPhoto({required String name, required String imageUrl}) {
  Get.to(
    () => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SizedBox.expand(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
