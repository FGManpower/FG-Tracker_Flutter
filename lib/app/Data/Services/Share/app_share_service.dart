import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/util/media_url.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Services/Share/share_payload.dart';
import 'package:fgtracker/app/Data/Services/Share/share_validation_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Model/ForwardMessageModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShareService {
  AppShareService._();

  static final AppShareService instance = AppShareService._();

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.fg.fgtracker';
  static const String appStoreUrl =
      'https://apps.apple.com/app/fg-tracker/id6738914614';

  static const String _pendingPrefsKey = 'pending_external_share_payload';
  static const Duration _pendingMaxAge = Duration(hours: 24);

  static const MethodChannel _intakeChannel =
      MethodChannel('com.fgtracker/share_intake');
  static const EventChannel _intakeEvents =
      EventChannel('com.fgtracker/share_intake_events');

  StreamSubscription<dynamic>? _intakeSub;
  bool _intakeInitialized = false;
  bool _isConsumingPending = false;
  String? _lastHandledKey;
  DateTime? _lastHandledAt;

  // ---------------------------------------------------------------------------
  // Outgoing OS Share Sheet (WhatsApp, Instagram, Telegram, Gmail, Drive, etc.)
  // ---------------------------------------------------------------------------

  Rect _safeShareOrigin(BuildContext? context) {
    final effectiveContext = context ?? ContextUtility.context ?? Get.context;
    Size screenSize = const Size(390, 844);
    if (effectiveContext != null) {
      final mediaSize = MediaQuery.maybeSizeOf(effectiveContext);
      if (mediaSize != null && mediaSize.width > 1 && mediaSize.height > 1) {
        screenSize = mediaSize;
      }
    } else {
      final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
      if (view != null && view.devicePixelRatio > 0) {
        final logical = view.physicalSize / view.devicePixelRatio;
        if (logical.width > 1 && logical.height > 1) {
          screenSize = logical;
        }
      }
    }

    final screenBounds = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final fallbackOrigin = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: 1,
      height: 1,
    );

    if (effectiveContext == null) return fallbackOrigin;

    try {
      final renderObj = effectiveContext.findRenderObject();
      if (renderObj is RenderBox && renderObj.attached && renderObj.hasSize) {
        final rect = renderObj.localToGlobal(Offset.zero) & renderObj.size;
        final intersected = rect.intersect(screenBounds);
        if (!intersected.isEmpty && intersected.width >= 1 && intersected.height >= 1) {
          return intersected;
        }
      }
    } catch (_) {}

    return fallbackOrigin;
  }

  Future<void> shareAppLink({BuildContext? context}) async {
    final text = appL10n.share_appMessage(playStoreUrl, appStoreUrl);
    await _shareViaOsSheet(
      text: text,
      subject: 'FG Tracker',
      context: context,
    );
  }

  Future<bool> openSystemShareSheet(
    SharePayload payload, {
    BuildContext? context,
  }) async {
    final shareOrigin = _safeShareOrigin(context);
    if (payload.isEmpty) {
      Utils().fluttertoast(appL10n.share_nothingToShare);
      return false;
    }

    if (payload.files.isNotEmpty) {
      final existingFiles = <XFile>[];
      for (final item in payload.files) {
        try {
          if (await File(item.path).exists()) {
            existingFiles.add(
              XFile(
                item.path,
                mimeType: item.mimeType,
                name: item.displayName,
              ),
            );
          }
        } catch (_) {}
      }

      if (existingFiles.isEmpty) {
        Utils().fluttertoast(appL10n.share_fileNotAvailable);
        return false;
      }

      return _shareViaOsSheet(
        files: existingFiles,
        text: payload.combinedText.isNotEmpty ? payload.combinedText : null,
        sharePositionOrigin: shareOrigin,
      );
    }

    final text = payload.combinedText;
    if (text.isEmpty) {
      Utils().fluttertoast(appL10n.share_nothingToShare);
      return false;
    }

    return _shareViaOsSheet(
      text: text,
      sharePositionOrigin: shareOrigin,
    );
  }

  Future<bool> shareRemoteFile({
    required String url,
    String? fileName,
    String? text,
    BuildContext? context,
  }) async {
    final shareOrigin = _safeShareOrigin(context);
    final resolvedUrl = _resolveMediaPathOrUrl(url);
    if (resolvedUrl.isEmpty) {
      Utils().fluttertoast(appL10n.share_fileNotAvailable);
      return false;
    }

    final cleanCaption = (text ?? '').trim();

    // If the file is already local on disk, share directly without network.
    final localPath = resolvedUrl.startsWith('file://')
        ? Uri.tryParse(resolvedUrl)?.toFilePath() ?? resolvedUrl
        : resolvedUrl;
    if (!localPath.startsWith('http://') && !localPath.startsWith('https://')) {
      final localFile = File(localPath);
      if (await localFile.exists()) {
        final size = await localFile.length();
        if (size > ShareValidationService.maxMediaOrFileBytes) {
          _showError(
            appL10n.share_fileTooLarge(
              fileName ?? localPath.split('/').last,
              ShareValidationService.formatSizeMb(
                ShareValidationService.maxMediaOrFileBytes,
              ),
            ),
          );
          return false;
        }
        return _shareViaOsSheet(
          files: [XFile(localPath, name: fileName)],
          text: cleanCaption.isNotEmpty ? cleanCaption : null,
          sharePositionOrigin: shareOrigin,
        );
      }
      _showError(appL10n.share_fileNotAvailable);
      return false;
    }

    if (!await ShareValidationService.hasInternet()) {
      _showError(appL10n.share_noInternet);
      return false;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final cleanName = _sanitizeFileName(
        fileName ?? Uri.tryParse(resolvedUrl)?.pathSegments.lastOrNull ?? 'file',
      );
      final targetPath =
          '${tempDir.path}${Platform.pathSeparator}share_${DateTime.now().millisecondsSinceEpoch}_$cleanName';

      final token = Global.storageServices.getaccesstoken();
      await Dio().download(
        resolvedUrl,
        targetPath,
        options: (token != null && token.isNotEmpty)
            ? Options(headers: {'authorization': 'Bearer $token'})
            : null,
      );
      final downloaded = File(targetPath);
      if (!await downloaded.exists()) {
        _showError(appL10n.share_fileNotAvailable);
        return false;
      }

      final size = await downloaded.length();
      if (size > ShareValidationService.maxMediaOrFileBytes) {
        _showError(
          appL10n.share_fileTooLarge(
            cleanName,
            ShareValidationService.formatSizeMb(
              ShareValidationService.maxMediaOrFileBytes,
            ),
          ),
        );
        return false;
      }

      return await _shareViaOsSheet(
        files: [XFile(targetPath, name: cleanName)],
        text: cleanCaption.isNotEmpty ? cleanCaption : null,
        sharePositionOrigin: shareOrigin,
      );
    } on DioException catch (e) {
      AppLog.e('shareRemoteFile DioException: $e');
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _showError(appL10n.share_noInternet);
      } else if (e.response?.statusCode == 404 || e.response?.statusCode == 410) {
        _showError(appL10n.share_fileNotAvailable);
      } else {
        _showError(appL10n.share_failed);
      }
      return false;
    } catch (e) {
      AppLog.e('shareRemoteFile error: $e');
      _showError(appL10n.share_failed);
      return false;
    }
  }

  Future<bool> shareChatMessageOut(
    MessageData message, {
    BuildContext? context,
  }) async {
    final type = (message.messageType ?? 'text').toString().toLowerCase().trim();

    if (type == 'image' || (type == 'media' && (message.images?.isNotEmpty ?? false))) {
      final urls = (message.images != null && message.images!.isNotEmpty)
          ? message.images!
          : [message.content?.toString() ?? ''];
      final firstUrl = urls.where((u) => u.trim().isNotEmpty).firstOrNull ?? '';
      if (firstUrl.isNotEmpty) {
        return shareRemoteFile(
          url: firstUrl,
          text: message.caption?.toString(),
          context: context,
        );
      }
    }

    if (type == 'video' || (type == 'media' && (message.videos?.isNotEmpty ?? false))) {
      String videoUrl = '';
      if (message.videos != null && message.videos!.isNotEmpty) {
        videoUrl = message.videos!.first.videoUrl ?? '';
      } else {
        final raw = message.content?.toString() ?? '';
        videoUrl = raw.split('||').first;
      }
      if (videoUrl.trim().isNotEmpty) {
        return shareRemoteFile(
          url: videoUrl,
          fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
          text: message.caption?.toString(),
          context: context,
        );
      }
    }

    if (type == 'audio') {
      final audio = (message.audioUrl ?? '').trim().isNotEmpty
          ? message.audioUrl!.trim()
          : (message.content?.toString() ?? '').trim();
      if (audio.isNotEmpty) {
        return shareRemoteFile(
          url: audio,
          fileName: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          context: context,
        );
      }
    }

    if (type == 'document') {
      final raw = message.content?.toString() ?? '';
      final parts = raw.split('||');
      final url = parts.isNotEmpty ? parts[0].trim() : '';
      final name = parts.length > 1 ? parts[1].trim() : 'document';
      if (url.isNotEmpty) {
        return shareRemoteFile(
          url: url,
          fileName: name,
          text: message.caption?.toString(),
          context: context,
        );
      }
    }

    if (type == 'location' || type == 'live_location') {
      final raw = message.content?.toString() ?? '';
      final parsed = LocationMessage.fromContent(raw);
      final meta = message.locationMeta;
      final lat = parsed.latitude != 0.0
          ? parsed.latitude
          : (meta?['latitude'] as num?)?.toDouble();
      final lng = parsed.longitude != 0.0
          ? parsed.longitude
          : (meta?['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final addr = parsed.address?.trim() ?? '';
        final locText = [
          if (parsed.locationName.isNotEmpty) parsed.locationName,
          if (addr.isNotEmpty) addr,
          'https://maps.google.com/?q=$lat,$lng',
        ].join('\n');
        return _shareViaOsSheet(text: locText, context: context);
      }
    }

    final text = message.content?.toString().trim() ?? '';
    if (text.isEmpty) {
      Utils().fluttertoast(appL10n.share_nothingToShare);
      return false;
    }
    return _shareViaOsSheet(text: text, context: context);
  }

  Future<bool> _shareViaOsSheet({
    String? text,
    String? subject,
    List<XFile>? files,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final origin = sharePositionOrigin ?? _safeShareOrigin(context);
    final normalizedText =
        (text != null && text.trim().isNotEmpty) ? text.trim() : null;
    final normalizedSubject =
        (subject != null && subject.trim().isNotEmpty) ? subject.trim() : null;
    final hasFiles = files != null && files.isNotEmpty;
    if (normalizedText == null && !hasFiles) {
      Utils().fluttertoast(appL10n.share_nothingToShare);
      return false;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: normalizedText,
          subject: normalizedSubject,
          files: hasFiles ? files : null,
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } catch (e) {
      AppLog.e('SharePlus error (origin=$origin): $e');
      _showError(appL10n.share_failed);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Incoming Share Intake (Android Intent + iOS Share Extension)
  // ---------------------------------------------------------------------------

  Future<void> initIntake() async {
    if (_intakeInitialized) return;
    _intakeInitialized = true;

    _intakeSub = _intakeEvents.receiveBroadcastStream().listen(
      (dynamic event) {
        _processNativeEvent(event);
      },
      onError: (Object err) {
        AppLog.e('Share intake stream error: $err');
      },
    );

    try {
      final initial =
          await _intakeChannel.invokeMethod<dynamic>('getInitialSharedPayload');
      if (initial != null) {
        await _processNativeEvent(initial);
      }
    } catch (e) {
      AppLog.d('getInitialSharedPayload skipped: $e');
    }
  }

  Future<void> _processNativeEvent(dynamic event) async {
    if (event is! Map) return;

    final errorCode = event['error']?.toString();
    if (errorCode == 'permission_denied') {
      _showError(appL10n.share_permissionDenied);
      return;
    }
    if (errorCode == 'read_failed') {
      _showError(appL10n.share_fileNotAvailable);
      return;
    }

    final payload = SharePayload.fromNativeMap(event);
    if (payload.isEmpty) return;

    // Guard against duplicate cold-start + stream delivery within 1.5s.
    final dedupeKey = payload.toJsonString();
    final now = DateTime.now();
    if (_lastHandledKey == dedupeKey &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(milliseconds: 1500)) {
      return;
    }
    _lastHandledKey = dedupeKey;
    _lastHandledAt = now;

    await handleIncomingPayload(payload);
  }

  Future<void> handleIncomingPayload(SharePayload payload) async {
    final validation = await ShareValidationService.validatePayloadFiles(payload);
    if (!validation.isValid) {
      _showValidationError(validation);
      return;
    }

    if (!ShareValidationService.isUserAuthenticated()) {
      await savePendingShare(payload);
      Utils().fluttertoast(appL10n.share_loginRequiredToComplete);
      return;
    }

    final currentRoute = Get.currentRoute;
    final bool isBootstrapping = currentRoute.isEmpty ||
        currentRoute == Routes.Splash ||
        currentRoute == Routes.Login ||
        currentRoute == Routes.OTPScreen ||
        currentRoute == Routes.OTP_CHARGES ||
        currentRoute == Routes.Register ||
        currentRoute == Routes.Intro ||
        currentRoute == Routes.permissionSetup ||
        currentRoute == Routes.permissionGate;

    if (isBootstrapping) {
      await savePendingShare(payload);
      return;
    }

    await openForwardForPayload(payload);
  }

  Future<void> savePendingShare(SharePayload payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingPrefsKey, payload.toJsonString());
    } catch (e) {
      AppLog.e('savePendingShare error: $e');
    }
  }

  Future<SharePayload?> loadPendingShare() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingPrefsKey);
      if (raw == null || raw.isEmpty) return null;
      final payload = SharePayload.fromJsonString(raw);
      final ageMs = DateTime.now().millisecondsSinceEpoch -
          (payload.createdAtMs ?? DateTime.now().millisecondsSinceEpoch);
      if (ageMs > _pendingMaxAge.inMilliseconds) {
        await clearPendingShare();
        return null;
      }
      return payload;
    } catch (e) {
      AppLog.e('loadPendingShare error: $e');
      await clearPendingShare();
      return null;
    }
  }

  Future<void> clearPendingShare() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingPrefsKey);
    } catch (_) {}
  }

  Future<void> consumePendingOnHomeReady() async {
    if (_isConsumingPending) return;
    if (!ShareValidationService.isUserAuthenticated()) return;
    _isConsumingPending = true;
    try {
      final pending = await loadPendingShare();
      if (pending == null || pending.isEmpty) return;

      final validation =
          await ShareValidationService.validatePayloadFiles(pending);
      await clearPendingShare();
      if (!validation.isValid) {
        _showValidationError(validation);
        return;
      }

      // Let HomeScreen & sockets finish settling one frame before pushing.
      await Future.delayed(const Duration(milliseconds: 350));
      if (!ShareValidationService.isUserAuthenticated()) return;
      await openForwardForPayload(pending);
    } finally {
      _isConsumingPending = false;
    }
  }

  Future<void> openForwardForPayload(SharePayload payload) async {
    if (!ShareValidationService.isUserAuthenticated()) {
      await savePendingShare(payload);
      Utils().fluttertoast(appL10n.share_loginRequiredToComplete);
      return;
    }

    final validation = await ShareValidationService.validatePayloadFiles(payload);
    if (!validation.isValid) {
      _showValidationError(validation);
      return;
    }

    Get.toNamed(
      Routes.forwardMessageScreen,
      arguments: {
        'sharePayload': payload,
        'sourceType': payload.source,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dispatch Shared Payload to Selected Chats / Groups via Forward Screen
  // ---------------------------------------------------------------------------

  Future<bool> dispatchShareToDestinations({
    required SharePayload payload,
    required List<ForwardDestination> destinations,
  }) async {
    if (destinations.isEmpty) {
      Get.snackbar(
        appL10n.chatList_selectDestination,
        appL10n.chatList_selectDestinationMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!ShareValidationService.isUserAuthenticated()) {
      await savePendingShare(payload);
      _showError(appL10n.share_loginRequiredToComplete);
      return false;
    }

    if (!await ShareValidationService.hasInternet()) {
      _showError(appL10n.share_noInternet);
      return false;
    }

    final validation = await ShareValidationService.validatePayloadFiles(payload);
    if (!validation.isValid) {
      _showValidationError(validation);
      return false;
    }

    final socketService = SocketMessageService.instance;
    if (destinations.any((d) => !d.isGroup) &&
        !socketService.isPrivateChatSocketConnected) {
      socketService.connectPrivateChat();
    }

    try {
      final captionText = (payload.text ?? '').trim();

      if (payload.kind == SharePayloadKind.location && payload.location != null) {
        final locMsg = payload.location!.toLocationMessage();
        final locMeta = {
          'latitude': locMsg.latitude,
          'longitude': locMsg.longitude,
          'locationName': locMsg.locationName,
          'address': locMsg.address,
          'isLive': false,
          if (locMsg.comment != null) 'comment': locMsg.comment,
        };
        await _sendToAllDestinations(
          destinations: destinations,
          messageType: 'location',
          content: locMsg.toContent(),
          locationMeta: locMeta,
        );
        return true;
      }

      if (payload.files.isEmpty) {
        final textContent = payload.combinedText;
        if (textContent.isEmpty) {
          _showError(appL10n.share_nothingToShare);
          return false;
        }
        await _sendToAllDestinations(
          destinations: destinations,
          messageType: 'text',
          content: textContent,
        );
        return true;
      }

      // Partition files by type so mixed media or single media uploads once.
      final imageFiles = <ShareFileItem>[];
      final videoFiles = <ShareFileItem>[];
      final audioFiles = <ShareFileItem>[];
      final docFiles = <ShareFileItem>[];

      for (final f in payload.files) {
        final mime = (f.mimeType ?? '').toLowerCase();
        final name = f.displayName.toLowerCase();
        if (payload.kind == SharePayloadKind.image ||
            mime.startsWith('image/') ||
            name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.webp') ||
            name.endsWith('.gif') ||
            name.endsWith('.heic')) {
          imageFiles.add(f);
        } else if (payload.kind == SharePayloadKind.video ||
            mime.startsWith('video/') ||
            name.endsWith('.mp4') ||
            name.endsWith('.mov') ||
            name.endsWith('.mkv') ||
            name.endsWith('.avi')) {
          videoFiles.add(f);
        } else if (payload.kind == SharePayloadKind.audio ||
            mime.startsWith('audio/') ||
            name.endsWith('.mp3') ||
            name.endsWith('.m4a') ||
            name.endsWith('.wav') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg')) {
          audioFiles.add(f);
        } else {
          docFiles.add(f);
        }
      }

      final uploadedImages = <String>[];
      final uploadedVideos = <Map<String, dynamic>>[];

      for (final img in imageFiles) {
        final res = await MessageRepo.uploadChatImage(File(img.path));
        if (res.status == true && (res.filename ?? '').isNotEmpty) {
          uploadedImages.add(res.filename!);
        } else {
          _showError(appL10n.chat_uploadFileFailed(img.displayName));
          return false;
        }
      }

      for (final vid in videoFiles) {
        final thumb = await generateThumbnailFile(vid.path);
        if (thumb == null || thumb.isEmpty) {
          _showError(appL10n.chat_videoThumbnailFailed);
          return false;
        }
        final res = await MessageRepo.uploadChatVideo(
          videoPath: vid.path,
          thumbnailPath: thumb,
        );
        if (res.status == true && (res.videoUrl?.toString() ?? '').isNotEmpty) {
          uploadedVideos.add({
            'videoUrl': res.videoUrl,
            'thumbnail': res.thumbnail,
            'duration': res.duration,
          });
        } else {
          _showError(appL10n.chat_videoUploadFailed);
          return false;
        }
      }

      if (uploadedImages.isNotEmpty && uploadedVideos.isEmpty && videoFiles.isEmpty) {
        await _sendToAllDestinations(
          destinations: destinations,
          messageType: 'image',
          content: uploadedImages.first,
          images: uploadedImages,
          caption: captionText,
        );
      } else if (uploadedVideos.length == 1 && uploadedImages.isEmpty) {
        final v = uploadedVideos.first;
        await _sendToAllDestinations(
          destinations: destinations,
          messageType: 'video',
          content: '${v['videoUrl']}||${v['thumbnail']}||${v['duration']}',
          caption: captionText,
          duration: v['duration'],
        );
      } else if (uploadedImages.isNotEmpty || uploadedVideos.isNotEmpty) {
        await _sendToAllDestinations(
          destinations: destinations,
          messageType: 'media',
          content: '',
          images: uploadedImages,
          videos: uploadedVideos,
          caption: captionText,
        );
      }

      for (final aud in audioFiles) {
        final res = await MessageRepo.uploadChatAudio(aud.path);
        final filename = res.filename?.toString() ?? '';
        if (res.status == true && filename.isNotEmpty) {
          await _sendToAllDestinations(
            destinations: destinations,
            messageType: 'audio',
            content: filename,
            duration: res.duration,
          );
        } else {
          _showError(appL10n.chat_uploadFileFailed(aud.displayName));
          return false;
        }
      }

      for (final doc in docFiles) {
        final res = await MessageRepo.uploadChatDocument(doc.path);
        final filename = res.filename?.toString() ?? '';
        if (res.status == true && filename.isNotEmpty) {
          final originalName = res.originalName ?? doc.displayName;
          await _sendToAllDestinations(
            destinations: destinations,
            messageType: 'document',
            content: '$filename||$originalName',
            caption: captionText,
          );
        } else {
          _showError(appL10n.chat_uploadFileFailed(doc.displayName));
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLog.e('dispatchShareToDestinations error: $e');
      _showError(appL10n.share_failed);
      return false;
    }
  }

  Future<void> _sendToAllDestinations({
    required List<ForwardDestination> destinations,
    required String messageType,
    required String content,
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    String? caption,
    Map<String, dynamic>? locationMeta,
    dynamic duration,
  }) async {
    final socketService = SocketMessageService.instance;
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    final hasGroupTargets = destinations.any((d) => d.isGroup && d.targetId != null);
    final hasPrivateTargets =
        destinations.any((d) => !d.isGroup && d.targetId != null);

    if (hasGroupTargets && !socketService.isSocketConnected && currentUserId.isNotEmpty) {
      final firstGroupId =
          destinations.firstWhere((d) => d.isGroup && d.targetId != null).targetId;
      await socketService.init(
        ConstRes.socketUrl,
        userId: currentUserId,
        groupId: firstGroupId,
      );
      for (int i = 0; i < 40 && !socketService.isSocketConnected; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (!socketService.isSocketConnected) {
        throw StateError('Group chat socket did not connect in time');
      }
    }

    if (hasPrivateTargets &&
        !socketService.isPrivateChatSocketConnected &&
        currentUserId.isNotEmpty) {
      final firstPrivateId =
          destinations.firstWhere((d) => !d.isGroup && d.targetId != null).targetId!;
      await socketService.initPrivateChat(
        ConstRes.socketUrl,
        userId: currentUserId,
        receiverId: firstPrivateId.toString(),
      );
      for (int i = 0; i < 40 && !socketService.isPrivateChatSocketConnected; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    for (final dest in destinations) {
      final targetId = dest.targetId;
      if (targetId == null) continue;
      if (dest.isGroup) {
        socketService.sendGroupMessage(
          groupId: targetId,
          content: content,
          messageType: messageType,
          images: images,
          videos: videos,
          caption: caption,
          locationMeta: locationMeta,
          duration: duration,
        );
      } else {
        socketService.sendPrivateMessage(
          receiverId: targetId.toString(),
          content: content,
          messageType: messageType,
          images: images,
          videos: videos,
          caption: caption,
        );
      }
    }
  }

  void _showValidationError(ShareFileValidationResult res) {
    switch (res.failure) {
      case ShareValidationFailure.fileTooLarge:
        final limitMb = ShareValidationService.formatSizeMb(
          res.limitBytes ?? ShareValidationService.maxMediaOrFileBytes,
        );
        _showError(appL10n.share_fileTooLarge(res.fileName ?? 'File', limitMb));
        break;
      case ShareValidationFailure.permissionDenied:
        _showError(appL10n.share_permissionDenied);
        break;
      case ShareValidationFailure.fileMissing:
        _showError(appL10n.share_fileNotAvailable);
        break;
      case ShareValidationFailure.noInternet:
        _showError(appL10n.share_noInternet);
        break;
      case ShareValidationFailure.notLoggedIn:
        _showError(appL10n.share_loginRequiredToComplete);
        break;
      case ShareValidationFailure.empty:
      case ShareValidationFailure.none:
        _showError(appL10n.share_nothingToShare);
        break;
    }
  }

  void _showError(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      appL10n.common_error,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _resolveMediaPathOrUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    return resolveMediaUrl(trimmed);
  }

  String _sanitizeFileName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return cleaned.isEmpty ? 'file' : cleaned;
  }

  void dispose() {
    _intakeSub?.cancel();
    _intakeSub = null;
    _intakeInitialized = false;
  }
}
