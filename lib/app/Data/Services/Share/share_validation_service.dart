import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/Share/share_payload.dart';

enum ShareValidationFailure {
  none,
  empty,
  noInternet,
  notLoggedIn,
  fileMissing,
  fileTooLarge,
  permissionDenied,
}

class ShareFileValidationResult {
  const ShareFileValidationResult({
    required this.isValid,
    this.failure = ShareValidationFailure.none,
    this.fileName,
    this.actualBytes,
    this.limitBytes,
  });

  final bool isValid;
  final ShareValidationFailure failure;
  final String? fileName;
  final int? actualBytes;
  final int? limitBytes;

  static const ShareFileValidationResult ok =
      ShareFileValidationResult(isValid: true);
}

class ShareValidationService {
  ShareValidationService._();

  /// Confirmed product limits: 10 MB for images, videos, audio, and documents.
  static const int maxImageBytes = 10 * 1024 * 1024;
  static const int maxMediaOrFileBytes = 10 * 1024 * 1024;

  static int maxBytesForFile(ShareFileItem file, SharePayloadKind payloadKind) {
    final mime = (file.mimeType ?? '').toLowerCase();
    final lowerName = file.displayName.toLowerCase();
    final isImage = payloadKind == SharePayloadKind.image ||
        mime.startsWith('image/') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.heic');
    return isImage ? maxImageBytes : maxMediaOrFileBytes;
  }

  static String formatSizeMb(int bytes) {
    final mb = bytes / (1024 * 1024);
    return mb >= 10 ? mb.toStringAsFixed(0) : mb.toStringAsFixed(1);
  }

  static bool isUserAuthenticated() {
    try {
      final token = Global.storageServices.getaccesstoken();
      final isRegistered = Global.storageServices.get(PrefConst.isRegistered);
      return Utility.isNotNullEmptyOrFalse(token) && isRegistered == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasInternet({
    Future<List<InternetAddress>> Function(String host)? lookup,
  }) async {
    final resolver = lookup ?? InternetAddress.lookup;
    final backendHost = Uri.tryParse(ConstRes.production)?.host ?? '';
    final candidates = <String>[
      if (backendHost.isNotEmpty) backendHost,
      'google.com',
      'cloudflare.com',
    ];

    for (final host in candidates) {
      try {
        final result =
            await resolver(host).timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  static Future<ShareFileValidationResult> validatePayloadFiles(
    SharePayload payload,
  ) async {
    if (payload.isEmpty) {
      return const ShareFileValidationResult(
        isValid: false,
        failure: ShareValidationFailure.empty,
      );
    }

    for (final item in payload.files) {
      final file = File(item.path);
      bool exists = false;
      int length = item.sizeBytes ?? 0;
      try {
        exists = await file.exists();
        if (exists) {
          length = await file.length();
        }
      } on FileSystemException {
        return ShareFileValidationResult(
          isValid: false,
          failure: ShareValidationFailure.permissionDenied,
          fileName: item.displayName,
        );
      } catch (_) {
        return ShareFileValidationResult(
          isValid: false,
          failure: ShareValidationFailure.fileMissing,
          fileName: item.displayName,
        );
      }

      if (!exists) {
        return ShareFileValidationResult(
          isValid: false,
          failure: ShareValidationFailure.fileMissing,
          fileName: item.displayName,
        );
      }

      final limit = maxBytesForFile(item, payload.kind);
      if (length > limit) {
        return ShareFileValidationResult(
          isValid: false,
          failure: ShareValidationFailure.fileTooLarge,
          fileName: item.displayName,
          actualBytes: length,
          limitBytes: limit,
        );
      }
    }

    return ShareFileValidationResult.ok;
  }
}
