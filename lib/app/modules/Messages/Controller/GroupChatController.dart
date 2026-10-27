import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';

import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/global.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

import '../../../Model/GetMessage.dart';

import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import '../../../Data/Services/chat_translation_service.dart';
import '../../Attendance/models/attendance_poll_model.dart';

class GroupMessageController extends GetxController with WidgetsBindingObserver {
  final socketService = SocketMessageService.instance;

  final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final List<MessageData> _messages = [];

  late final TextEditingController textEditingController = TextEditingController();
  final RxBool showScrollToBottom = false.obs;
  final RxInt unreadBelowCount = 0.obs;
  bool _wasKeyboardOpen = false;
  bool _wasAtBottom = true;

  final StreamController<List<MessageData>> _messageStreamController =
      StreamController<List<MessageData>>.broadcast();

  Stream<List<MessageData>> get messageStream =>
      _messageStreamController.stream;

  List<MessageData> get messageData => _messages;

  void updateMessageStream() {
    if (_messageStreamController.isClosed) return;

    _messageStreamController.add(
      List.unmodifiable(_messages),
    );
  }

  RxList<String> videoPaths = <String>[].obs;
  RxList<Uint8List?> videoThumbnails = <Uint8List?>[].obs;
  RxList<LocationData> groupMembers = <LocationData>[].obs;
  final Rxn<MessageData> editingMessage = Rxn<MessageData>();
  final RxString groupName = ''.obs;
  final RxString groupDesc = ''.obs;
  late String groupImage;
  RxBool isLoadingMembers = false.obs;
  final RxBool isUploadingVideo = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  RxList<File> imagePaths = <File>[].obs;
  RxList<String> videoDurations = <String>[].obs;
  RxString documentPath = "".obs;
  RxBool isSending = false.obs;
  RxBool isLoading = true.obs;
  RxString messageText = "".obs;
  final RxBool showEmoji = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = "".obs;
  final RxList<int> searchResultIds = <int>[].obs;
  final RxInt currentSearchIndex = (-1).obs;
  RxBool isCreator = true.obs;
  final Rxn<MessageData> pinnedMessage = Rxn<MessageData>();
  final RxBool showPinnedBanner = true.obs;
  Rx<MessageData?> replyMessage = Rx<MessageData?>(null);
  RxInt highlightedMessageId = (-1).obs;
  final RxSet<int> uploadingVideoIndexes = <int>{}.obs;
  final RxMap<int, double> videoUploadProgress = <int, double>{}.obs;
  final RxString floatingDate = "".obs;
  final RxBool showFloatingDate = false.obs;
  Timer? _floatingDateTimer;

  Future<void> scrollToMessage(int messageId) async {
    final index = _messages.indexWhere((e) => e.id == messageId);

    if (index != -1) {
      debugPrint("Message at Index: ${_messages[index].id}");
    }

    if (index == -1) return;

    highlightedMessageId.value = messageId;

    if (itemScrollController.isAttached) {
      await itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    highlightedMessageId.value = -1;
  }

  void setReply(MessageData message) {
    replyMessage.value = message;
  }

  void clearReply() {
    replyMessage.value = null;
  }

  Map<String, dynamic>? arguments = Get.arguments;

  late int groupId;

  @override
  void onInit() {
    super.onInit();
    ChatTranslationService.instance.resetVisibility();

    groupId = arguments?["groupId"] is int
        ? (arguments!["groupId"] as int)
        : (int.tryParse(arguments?["groupId"]?.toString() ?? '0') ?? 0);

    groupName.value = arguments?["groupName"]?.toString() ?? "";
    groupDesc.value = arguments?["groupDesc"]?.toString() ?? "";
    groupImage = arguments?["groupImage"] ?? arguments?["groupProfile"] ?? "";
    print("isCreator = ${isCreator.value}");

    WidgetsBinding.instance.addObserver(this);
    initializeGroupChat();
    itemPositionsListener.itemPositions.addListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.addListener(_updateScrollBottomState);
  }

  void toggleEmoji() {
    showEmoji.toggle();
  }

  void hideEmoji() {
    showEmoji.value = false;
  }

  void initializeGroupChat() {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    socketService.init(
      ConstRes.socketUrl,
      userId: currentUserId,
      groupId: groupId,
    );

    socketService.joinGroupChat(
      groupId: groupId,
      userId: currentUserId,
    );

    socketService.receiveGroupMessage(
      callback: (message) {
        debugPrint("GROUP RECEIVE EVENT => $message");

        final incomingMessage = MessageData.fromJson(message);
        debugPrint("RECEIVED MESSAGE ID => ${incomingMessage.id}");

        final incomingId = incomingMessage.id;

        if (incomingId != null &&
            _messages.any((item) => item.id == incomingId)) {
          debugPrint("DUPLICATE MESSAGE IGNORED => $incomingId");
          return;
        }

        final currentUserId =
            Global.storageServices.get(PrefConst.userId)?.toString();
        final isMyMessage = incomingMessage.senderId?.toString() == currentUserId;
        final wasAtBottom = isUserAtBottom();

        _messages.add(incomingMessage);
        updateMessageStream();

        if (isMyMessage || wasAtBottom) {
          scrollToBottom();
        } else {
          unreadBelowCount.value++;
          showScrollToBottom.value = true;
        }
      },
    );
    socketService.listenMessageEdited(
      callback: (data) {
        final messageId = int.tryParse(
          data["messageId"].toString(),
        );

        if (messageId == null) return;

        final index = _messages.indexWhere(
          (message) => message.id == messageId,
        );

        if (index == -1) return;

        _messages[index].content = data["content"];

        _messages[index].isEdited = data["isEdited"] ?? true;

        _messages[index].editedAt = data["editedAt"];

        updateMessageStream();

        log("GROUP MESSAGE EDITED => $messageId");
      },
    );

    socketService.listenMessageDeleted(
      callback: (data) {
        debugPrint("RAW DELETE EVENT: $data");

        if (data is! Map) return;

        final messageId = int.tryParse(
          (data["messageId"] ?? data["message_id"] ?? data["id"] ?? "")
              .toString(),
        );

        final eventGroupId = int.tryParse(
          (data["groupId"] ?? data["group_id"] ?? "").toString(),
        );

        if (messageId == null) return;
        if (eventGroupId != null && eventGroupId != groupId) return;

        final deleteType =
        (data["deleteType"] ?? data["delete_type"] ?? "for_everyone")
            .toString();

        final index = _messages.indexWhere((m) => m.id == messageId);

        debugPrint(
          "DELETE TYPE => $deleteType | INDEX => $index | MSG ID => $messageId",
        );

        if (index != -1) {
          if (deleteType == "for_me") {
            _messages.removeAt(index);
          } else {
            final msg = _messages[index];
            msg.messageType = "text";
            msg.content = "This message was deleted";
            msg.caption = null;
            msg.images = [];
            msg.videos = [];
            msg.replyId = null;
            msg.isDeleted = true;
          }
        }

        if (pinnedMessage.value?.id == messageId) {
          pinnedMessage.value = null;
          showPinnedBanner.value = false;
        }

        updateMessageStream();


      },
    );

    socketService.listenPinMessage(
      callback: (data) {
        final eventGroupId = int.tryParse(
          (data["groupId"] ?? data["group_id"] ?? "").toString(),
        );

        final messageId = int.tryParse(
          (data["messageId"] ?? data["message_id"] ?? "").toString(),
        );

        if (data["chatType"] != "group") return;
        if (eventGroupId != groupId || messageId == null) return;

        final msg = _messages.firstWhereOrNull(
          (e) => e.id == messageId,
        );

        if (msg != null) {
          pinnedMessage.value = msg;
          showPinnedBanner.value = true;
          updateMessageStream();
        }
      },
    );

    socketService.listenUnpinMessage(
      callback: (data) {
        print("📌 GROUP MESSAGE UNPINNED =====> $data");

        if (data["chatType"] != "group") return;

        final dataGroupId = int.tryParse(data["groupId"].toString());

        if (dataGroupId != groupId) return;

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();
      },
    );

    getGroupMessages();

    getGroupMembers();
  }

  Future<void> addVideos(List<String> paths) async {
    for (final path in paths) {
      await addVideo(path);
    }
  }

  Future<void> addVideo(String path) async {
    videoPaths.add(path);
    videoThumbnails.add(null);
    videoDurations.add('');

    final index = videoPaths.length - 1;

    try {
      final thumb = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 80,
      );

      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final duration = controller.value.duration;
      final durationStr = formatDuration(duration);
      await controller.dispose();

      if (index < videoThumbnails.length) {
        videoThumbnails[index] = thumb;
        videoDurations[index] = durationStr;
        videoThumbnails.refresh();
        videoDurations.refresh();
      }
    } catch (e) {
      debugPrint("Video preview error: $e");
    }
  }

  void removeVideo(int index) {
    if (index < videoPaths.length) videoPaths.removeAt(index);
    if (index < videoThumbnails.length) videoThumbnails.removeAt(index);
    if (index < videoDurations.length) videoDurations.removeAt(index);
  }

  void clearVideos() {
    videoPaths.clear();
    videoThumbnails.clear();
    videoDurations.clear();
  }

  Future<bool> uploadVideoAtIndex(
    String path,
    String caption,
    int index,
  ) async {
    try {
      final thumbnailPath = await generateThumbnailFile(path);

      if (thumbnailPath == null) {
        return false;
      }

      var result = await MessageRepo.uploadChatVideo(
        videoPath: path,
        thumbnailPath: thumbnailPath,
        onSendProgress: (sent, total) {
          if (total > 0) {
            videoUploadProgress[index] = sent / total;
            videoUploadProgress.refresh();
          }
        },
      );

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          messageType: "video",
          content:
              "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
        return true;
      }
      return false;
    } catch (e) {
      log("Group upload error: $e");
      return false;
    }
  }

  Future<void> sendMessage({
    required TextEditingController textController,
  }) async {
    if (isSending.value) return;
    isSending.value = true;

    try {
      final text = textController.text.trim();

      final bool hasImages = imagePaths.isNotEmpty;
      final bool hasVideos = videoPaths.isNotEmpty;
      final bool hasDocument = documentPath.value.isNotEmpty;
      final bool hasMedia = hasImages || hasVideos || hasDocument;

      final bool shouldSendMixedMedia =
          (hasImages && hasVideos) || videoPaths.length > 1;

      if (shouldSendMixedMedia) {
        final imagesCopy = List<File>.from(imagePaths);
        final videosCopy = List<String>.from(videoPaths);
        final uploadedImages = <String>[];
        final uploadedVideos = <Map<String, dynamic>>[];
        final successfulVideoIndexes = <int>[];

        for (final image in imagesCopy) {
          try {
            final result = await MessageRepo.uploadChatImage(image);

            if (result.status == true && result.filename != null) {
              uploadedImages.add(result.filename!);
            } else {
              CommonDialog.errorMessage(
                "Failed to upload ${image.path}",
              );
            }
          } catch (e) {
            log("GROUP IMAGE UPLOAD ERROR => $e");
            CommonDialog.errorMessage(
              "Failed to upload ${image.path}",
            );
          }
        }

        for (int i = 0; i < videosCopy.length; i++) {
          final path = videosCopy[i];
          final currentIndex = videoPaths.indexOf(path);

          if (currentIndex == -1) continue;

          uploadingVideoIndexes.add(currentIndex);
          uploadingVideoIndexes.refresh();

          try {
            final thumbnailPath = await generateThumbnailFile(path);

            if (thumbnailPath == null) continue;

            final result = await MessageRepo.uploadChatVideo(
              videoPath: path,
              thumbnailPath: thumbnailPath,
              onSendProgress: (sent, total) {
                if (total > 0) {
                  videoUploadProgress[currentIndex] = sent / total;
                  videoUploadProgress.refresh();
                }
              },
            );

            if (result.status == true &&
                result.videoUrl != null &&
                result.videoUrl.toString().isNotEmpty) {
              uploadedVideos.add({
                "videoUrl": result.videoUrl,
                "thumbnail": result.thumbnail,
                "duration": result.duration,
              });

              successfulVideoIndexes.add(currentIndex);
            } else {
              CommonDialog.errorMessage(
                "Failed to upload video",
              );
            }
          } catch (e) {
            log("GROUP VIDEO UPLOAD ERROR => $e");
            CommonDialog.errorMessage(
              "Failed to upload video",
            );
          } finally {
            uploadingVideoIndexes.remove(currentIndex);
            videoUploadProgress.remove(currentIndex);
          }
        }

        if (uploadedImages.isNotEmpty || uploadedVideos.isNotEmpty) {
          socketService.sendGroupMessage(
            groupId: groupId,
            content: "",
            messageType: "media",
            images: uploadedImages,
            videos: uploadedVideos,
            caption: text,
            replyId: replyMessage.value?.id,
            replyMessage: replyMessage.value?.content,
            replyType: replyMessage.value?.messageType,
            replySender: replyMessage.value?.senderName,
          );

          clearReply();

          imagePaths.clear();

          successfulVideoIndexes.sort((a, b) => b.compareTo(a));

          for (final index in successfulVideoIndexes) {
            if (index < videoPaths.length) {
              removeVideo(index);
            }
          }
        }
      } else {
        if (imagePaths.isNotEmpty) {
          final imagesCopy = List<File>.from(imagePaths);
          final uploadedImages = <String>[];

          for (final image in imagesCopy) {
            try {
              final result = await MessageRepo.uploadChatImage(image);

              if (result.status == true && result.filename != null) {
                uploadedImages.add(result.filename!);
              } else {
                CommonDialog.errorMessage(
                  "Failed to upload ${image.path}",
                );
              }
            } catch (e) {
              log("GROUP IMAGE UPLOAD ERROR => $e");
              CommonDialog.errorMessage(
                "Failed to upload ${image.path}",
              );
            }
          }

          if (uploadedImages.isNotEmpty) {
            socketService.sendGroupMessage(
              groupId: groupId,
              content: "",
              messageType: "image",
              images: uploadedImages,
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );

            clearReply();
          }

          imagePaths.clear();
        }

        if (videoPaths.isNotEmpty) {
          final videoPath = videoPaths.first;
          final currentIndex = videoPaths.indexOf(videoPath);

          if (currentIndex != -1) {
            uploadingVideoIndexes.add(currentIndex);
            uploadingVideoIndexes.refresh();

            try {
              final success = await uploadVideoAtIndex(
                videoPath,
                text,
                currentIndex,
              );

              if (success) {
                final index = videoPaths.indexOf(videoPath);

                if (index != -1) {
                  removeVideo(index);
                }

                clearReply();
              }
            } finally {
              uploadingVideoIndexes.remove(currentIndex);
              videoUploadProgress.remove(currentIndex);
            }
          }
        }
      }

      if (documentPath.value.isNotEmpty) {
        await uploadDocument(documentPath.value, text);
        documentPath.value = "";
      }

      if (!hasMedia && text.isNotEmpty) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: text,
          messageType: "text",
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }

      textController.clear();
      messageText.value = "";
      clearReply();
      scrollToBottom();
    } catch (e) {
      log("GROUP SEND ERROR => $e");
    } finally {
      isSending.value = false;
    }
  }

  void sendAttendanceMessage({
    required String question,
    required String date,
    required int totalMembers,
  }) {
    try {
      final currentUserName =
          Global.storageServices.get(PrefConst.userName)?.toString() ??
              "Rahul Verma";

      final pollData = AttendancePollData(
        id: "att_${DateTime.now().millisecondsSinceEpoch}",
        question: question,
        date: date,
        creatorName: currentUserName,
        totalMembers: totalMembers,
        presentCount: 0,
        absentCount: 0,
        respondedCount: 0,
        responses: [],
      );

      final content = jsonEncode(pollData.toJson());

      final newMsg = MessageData(
        id: DateTime.now().millisecondsSinceEpoch,
        content: content,
        messageType: "attendance",
        senderName: currentUserName,
        timestamp: DateTime.now().toIso8601String(),
      );

      _messages.add(newMsg);
      updateMessageStream();

      socketService.sendGroupMessage(
        groupId: groupId,
        content: content,
        messageType: "attendance",
      );

      scrollToBottom();
    } catch (e) {
      log("SEND ATTENDANCE ERROR: $e");
    }
  }

  void updateAttendanceResponse({
    required int messageId,
    required AttendanceMemberResponse response,
  }) {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index == -1) return;

      final currentMsg = _messages[index];
      final pollData = AttendancePollData.fromRawJson(
        currentMsg.content?.toString() ?? "",
      );

      final existingIndex =
          pollData.responses.indexWhere((r) => r.userId == response.userId);
      if (existingIndex != -1) {
        final oldStatus = pollData.responses[existingIndex].status;
        if (oldStatus == "Present" && response.status == "Absent") {
          pollData.presentCount = (pollData.presentCount - 1).clamp(0, 9999);
          pollData.absentCount++;
        } else if (oldStatus == "Absent" && response.status == "Present") {
          pollData.absentCount = (pollData.absentCount - 1).clamp(0, 9999);
          pollData.presentCount++;
        }
        pollData.responses[existingIndex] = response;
      } else {
        if (response.status == "Present") {
          pollData.presentCount++;
        } else {
          pollData.absentCount++;
        }
        pollData.respondedCount++;
        pollData.responses.add(response);
      }

      final updatedContent = jsonEncode(pollData.toJson());
      _messages[index].content = updatedContent;
      updateMessageStream();

      final currentUserId =
          Global.storageServices.get(PrefConst.userId)?.toString() ?? "";

      socketService.editMessage(
        messageId: messageId,
        content: updatedContent,
        userId: currentUserId,
      );
    } catch (e) {
      log("UPDATE ATTENDANCE RESPONSE ERROR: $e");
    }
  }

  Future<void> uploadAudio(String path) async {
    try {
      var result = await MessageRepo.uploadChatAudio(path);

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: result.filename!,
          messageType: "audio",
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        clearReply();
      }
    } catch (e) {
      log(
        "GROUP AUDIO ERROR => $e",
      );
    }
  }

  Future<void> uploadVideo(String path, String caption) async {
    try {
      isUploadingVideo.value = true;

      final thumbnailPath = await generateThumbnailFile(path);

      if (thumbnailPath == null) {
        return;
      }

      var result = await MessageRepo.uploadChatVideo(
        videoPath: path,
        thumbnailPath: thumbnailPath,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          messageType: "video",
          content:
              "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }
    } catch (e) {
      log("GROUP AUDIO ERROR => $e");
    } finally {
      isUploadingVideo.value = false;
      clearReply();
    }
  }

  Future<void> uploadDocument(
    String path,
    String caption,
  ) async {
    try {
      var result = await MessageRepo.uploadChatDocument(path);

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: "${result.filename}||${result.originalName!}",
          messageType: "document",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        clearReply();
      }
    } catch (e) {
      log(
        "GROUP Video ERROR => $e",
      );
    }
  }

  Future<void> sendLocation({
    required LocationMessage location,
  }) async {
    try {
      socketService.sendGroupMessage(
        groupId: groupId,
        content: location.toContent(),
        messageType: "location",
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      clearReply();

      scrollToBottom();
    } catch (e) {
      log("LOCATION SEND ERROR => $e");
    }
  }

  Future<void> sendContact({
    required ContactMessage contact,
  }) async {
    try {
      socketService.sendGroupMessage(
        groupId: groupId,
        content: contact.toContent(),
        messageType: "contact",
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      clearReply();

      scrollToBottom();
    } catch (e) {
      log("CONTACT SEND ERROR => $e");
    }
  }

  Future<void> deleteMessage({
    required int messageId,
    required String deleteType,
  }) async {
    final userId =
    Global.storageServices.get(PrefConst.userId).toString();

    debugPrint("========== DELETE MESSAGE START ==========");
    debugPrint("DELETE messageId: $messageId");
    debugPrint("DELETE userId: $userId");
    debugPrint("DELETE deleteType: $deleteType");
    debugPrint("DELETE groupId: $groupId");

    debugPrint(
      "DELETE SOCKET CONNECTED: ${socketService.isSocketConnected}",
    );

    socketService.deleteMessage(
      messageId: messageId,
      userId: userId,
      deleteType: deleteType,
    );

    debugPrint("DELETE MESSAGE EMIT CALLED");
    debugPrint("==========================================");
  }

  Future<void> getGroupMessages() async {
    isLoading.value = true;

    _messages
      ..clear()
      ..addAll(
        List.generate(
          8,
          (index) => MessageData(
            senderId: index.isEven ? 1 : 2,
            senderName: "",
            messageType: "text",
            content: "                     ",
            timestamp: DateTime.now().toIso8601String(),
            seenCount: 0,
            senderImage: "",
          ),
        ),
      );

    updateMessageStream();

    try {
      final result = await MessageRepo.groupMessageHistory(
        groupId: groupId,
      );

      if (result.status == true) {
        final messages = List<MessageData>.from(
          result.messageData ?? [],
        );

        messages.sort((a, b) {
          final aTime = DateTime.tryParse(a.timestamp ?? '');
          final bTime = DateTime.tryParse(b.timestamp ?? '');

          if (aTime == null || bTime == null) {
            return 0;
          }

          return aTime.compareTo(bTime);
        });

        _messages
          ..clear()
          ..addAll(messages);

        final pinnedId = result.pinnedMessageId;

        if (pinnedId != null) {
          final pinned = _messages.firstWhereOrNull(
            (message) => message.id == pinnedId,
          );

          if (pinned != null) {
            pinnedMessage.value = pinned;
            showPinnedBanner.value = true;
          } else {
            pinnedMessage.value = null;
            showPinnedBanner.value = false;
          }
        } else {
          pinnedMessage.value = null;
          showPinnedBanner.value = false;
        }

        updateMessageStream();

        scrollToBottom(instant: true); // Instantly jumps to the latest message
      } else {
        CommonDialog.errorMessage(result.message);

        _messages.clear();
        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();
      }
    } catch (e) {
      log("GROUP HISTORY ERROR => $e");

      _messages.clear();
      pinnedMessage.value = null;
      showPinnedBanner.value = false;

      updateMessageStream();
    } finally {
      isLoading.value = false;
    }
  }

  Future getGroupMembers() async {
    print(
      "MY USER ID => ${Global.storageServices.get(PrefConst.userId)}",
    );

    try {
      isLoadingMembers.value = true;

      var result = await MessageRepo.getGroupMembers(
        groupId: groupId,
      );

      print(
        "GROUP MEMBERS => ${result.locations?.length}",
      );

      if (result.status == true) {
        groupMembers.value = result.locations ?? [];

        final currentUserId =
            Global.storageServices.get(PrefConst.userId).toString();

        // Default
        isCreator.value = false;

        // Check current logged-in user
        for (final member in groupMembers) {
          if (member.userId.toString() == currentUserId) {
            isCreator.value = member.isCreator == true;
            break;
          }
        }

        print("Current User ID => $currentUserId");
        print("Is Creator => ${isCreator.value}");
      }
    } catch (e) {
      log(
        "GROUP MEMBERS ERROR => $e",
      );
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void scrollToBottom({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomExecution(instant: instant);
    });
  }

  void _scrollToBottomExecution({bool instant = false, int retryCount = 0}) {
    if (_messages.isEmpty) return;

    if (itemScrollController.isAttached) {
      try {
        final targetIndex = _messages.length - 1;
        if (targetIndex < 0) return;

        if (instant) {
          itemScrollController.jumpTo(
            index: targetIndex,
          );
        } else {
          itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      } catch (e) {
        log("Scroll execution error: $e");
        if (retryCount < 6) {
          Future.delayed(const Duration(milliseconds: 60), () {
            _scrollToBottomExecution(instant: instant, retryCount: retryCount + 1);
          });
        }
      }
    } else if (retryCount < 10) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToBottomExecution(instant: instant, retryCount: retryCount + 1);
      });
    }
  }

  bool isUserAtBottom() {
    if (_messages.isEmpty) return true;

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return true;

    final visible = positions
        .where((e) => e.itemTrailingEdge > 0 && e.itemLeadingEdge < 1.0)
        .toList();

    if (visible.isEmpty) return true;

    final maxVisible =
        visible.map((e) => e.index).reduce((a, b) => a > b ? a : b);

    return maxVisible >= _messages.length - 2;
  }

  void _updateScrollBottomState() {
    if (_messages.isEmpty) {
      if (showScrollToBottom.value) showScrollToBottom.value = false;
      if (unreadBelowCount.value != 0) unreadBelowCount.value = 0;
      _wasAtBottom = true;
      return;
    }

    final atBottom = isUserAtBottom();
    _wasAtBottom = atBottom;

    if (atBottom) {
      if (showScrollToBottom.value) showScrollToBottom.value = false;
      if (unreadBelowCount.value != 0) unreadBelowCount.value = 0;
    } else {
      if (!showScrollToBottom.value) showScrollToBottom.value = true;
    }
  }

  void handleBackPressed(BuildContext context) {
    // socketService.disconnectSocket();

    _messages.clear();

    messageText.value = "";

    imagePaths.clear();
    clearVideos();
    isSending.value = false;
    pinnedMessage.value = null;
    showPinnedBanner.value = false;

    Navigator.of(context).pop();
  }

  final FocusNode focusNode = FocusNode();

  final RxList<LocationData> filteredMembers = <LocationData>[].obs;
  final RxBool showMentionList = false.obs;
  RxInt? mentionStartIndex = RxInt(-1);

  void onTextChanged({
    required TextEditingController textController,
  }) {
    messageText.value = textController.text;
    print("==========MessageText${messageText.value}");
    handleMentionDetection(textController: textController);
  }

  void handleMentionDetection({
    required TextEditingController textController,
  }) {
    final text = textController.text;
    final cursorPos = textController.selection.baseOffset;

    if (cursorPos <= 0) {
      hideMentionList();
      return;
    }

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex == -1) {
      hideMentionList();
      return;
    }

    final wordAfterAt = textBeforeCursor.substring(lastAtIndex);
    if (wordAfterAt.contains(' ')) {
      hideMentionList();
      return;
    }

    mentionStartIndex!.value = lastAtIndex;
    final query = wordAfterAt.substring(1).toLowerCase().trim();

    filteredMembers.value = groupMembers
        .where((member) =>
            (member.name?.toLowerCase().contains(query) ?? false) ||
            (member.name?.toLowerCase().contains(query) ?? false))
        .toList();

    showMentionList.value = filteredMembers.isNotEmpty;
  }

  void insertMention({
    required dynamic member,
    required TextEditingController textController,
  }) {
    if (mentionStartIndex!.value < 0) return;

    final text = textController.text;
    final cursorPos = textController.selection.baseOffset;

    final displayName = (member.name ?? member.username ?? "User").toString();

    final start = mentionStartIndex!.value; // int
    final replacement = "@$displayName ";

    final newText = text.replaceRange(
      start,
      cursorPos,
      replacement,
    );

    textController.text = newText;

    final newCursorOffset = start + replacement.length;

    textController.selection = TextSelection.collapsed(
      offset: newCursorOffset,
    );

    hideMentionList();
    messageText.value = newText;
  }

  void hideMentionList() {
    showMentionList.value = false;
    filteredMembers.clear();
    mentionStartIndex!.value = -1;
  }

  void startSearch() {
    isSearching.value = true;
    searchQuery.value = "";
    searchResultIds.clear();
    currentSearchIndex.value = -1;
  }

  void stopSearch() {
    isSearching.value = false;
    searchQuery.value = "";
    searchResultIds.clear();
    currentSearchIndex.value = -1;
    highlightedMessageId.value = -1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim();
    searchResultIds.clear();
    currentSearchIndex.value = -1;
    highlightedMessageId.value = -1;

    if (searchQuery.value.isEmpty) return;

    final results = _messages
        .where((msg) =>
            msg.messageType == "text" &&
            (msg.content?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                false))
        .map((msg) => msg.id!)
        .toList();

    searchResultIds.value = results;

    if (results.isNotEmpty) {
      currentSearchIndex.value = results.length - 1;
      _scrollToSearchResult();
    }
  }

  void nextSearchResult() {
    if (searchResultIds.isEmpty) return;
    if (currentSearchIndex.value > 0) {
      currentSearchIndex.value--;
      _scrollToSearchResult();
    }
  }

  void previousSearchResult() {
    if (searchResultIds.isEmpty) return;
    if (currentSearchIndex.value < searchResultIds.length - 1) {
      currentSearchIndex.value++;
      _scrollToSearchResult();
    }
  }

  void _scrollToSearchResult() {
    final id = searchResultIds[currentSearchIndex.value];
    final index = _messages.indexWhere((e) => e.id == id);
    highlightedMessageId.value = id;
    if (index == -1) return;
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void pinMessage(MessageData message) {
    socketService.pinMessage(
      chatType: "group",
      groupId: groupId,
      messageId: message.id!,
      pinnedByName: Global.storageServices.get(PrefConst.userName) ?? "User",
    );
  }

  void unpinMessage() {
    socketService.unpinMessageEvent(
      chatType: "group",
      groupId: groupId,
    );
  }

  void scrollToPinnedMessage() {
    if (pinnedMessage.value == null) return;
    final msgId = pinnedMessage.value!.id;
    if (msgId == null) return;

    final index = _messages.indexWhere((e) => e.id == msgId);
    if (index == -1) return;

    highlightedMessageId.value = msgId;

    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageId.value = -1;
    });
  }

  void _onScrollDateChanged() {
    if (messageData.isEmpty) return;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return;

    final visible = positions.where((e) => e.itemTrailingEdge > 0).toList();

    if (visible.isEmpty) return;

    visible.sort((a, b) => a.index.compareTo(b.index));

    final firstVisibleIndex = visible.first.index;

    if (firstVisibleIndex >= messageData.length) return;

    final newDate = formatDateHeader(
      messageData[firstVisibleIndex].timestamp ?? "",
    );

    if (floatingDate.value != newDate) {
      floatingDate.value = newDate;
    }

    if (!showFloatingDate.value) {
      showFloatingDate.value = true;
    }

    _floatingDateTimer?.cancel();

    _floatingDateTimer = Timer(
      const Duration(milliseconds: 800),
      () {
        showFloatingDate.value = false;
      },
    );
  }

  void startEditingMessage(MessageData message) {
    if (message.messageType?.toString() != "text") {
      return;
    }

    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    if (message.senderId.toString() != currentUserId) {
      return;
    }

    editingMessage.value = message;
  }

  void cancelEditingMessage() {
    editingMessage.value = null;
  }

  void updateEditedMessage({
    required String newText,
  }) {
    final message = editingMessage.value;

    if (message == null) return;

    final text = newText.trim();

    if (text.isEmpty) return;

    socketService.editMessage(
      messageId: message.id!,
      content: text,
      userId: Global.storageServices.get(PrefConst.userId).toString(),
    );

    editingMessage.value = null;
  }

  Future<void> clearGroupChat() async {
    try {
      final response = await MessageRepo.clearGroupChat(
        groupId: groupId,
      );

      if (response['status'] == true) {
        _messages.clear();

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();

        Utils().fluttertoast(
          response['message']?.toString() ??
              'Group chat cleared successfully',
        );
      } else {
        Utils().fluttertoast(
          response['message']?.toString() ??
              'Failed to clear group chat',
        );
      }
    } catch (e) {
      log('Clear group chat error: $e');

      Utils().fluttertoast('Failed to clear group chat');
    }
  }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        final bottomInset = views.first.viewInsets.bottom;
        final isKeyboardOpen = bottomInset > 0;
        if (isKeyboardOpen != _wasKeyboardOpen) {
          _wasKeyboardOpen = isKeyboardOpen;
          if (isKeyboardOpen) {
            // Keep latest messages visible if user was at the bottom
            if (_wasAtBottom) {
              scrollToBottom(instant: false);
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    ChatTranslationService.instance.resetVisibility();
    ChatTranslationService.instance.stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions.removeListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.removeListener(_updateScrollBottomState);
    textEditingController.dispose();
    focusNode.dispose();
    _messageStreamController.close();
    _floatingDateTimer?.cancel();
    super.onClose();
  }
}

typedef GroupChatController = GroupMessageController;
