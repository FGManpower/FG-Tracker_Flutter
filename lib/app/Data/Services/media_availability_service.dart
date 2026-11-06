import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:fgtracker/app/Core/util/app_log.dart';
enum MediaStatus { unknown, available, missing }

/// Tells chat bubbles whether a remote media file (image, video, audio,
/// document) still exists on the server, so a deleted/expired file can be
/// shown as "Media is missing" instead of an empty or broken bubble.
///
/// Each URL is checked once per app session with a lightweight HEAD request
/// and the result is cached. Network failures (offline, timeout) are NOT
/// treated as missing: only a definite "not found" answer from the server is.
class MediaAvailabilityService {
  MediaAvailabilityService._();

  static final RxMap<String, MediaStatus> _status =
      <String, MediaStatus>{}.obs;
  static final Set<String> _inFlight = <String>{};

  /// Status codes that mean the file is gone. S3-style storage answers 403
  /// for a missing object when listing is not allowed.
  static const Set<int> _missingCodes = {403, 404, 410};

  static const Duration _timeout = Duration(seconds: 10);

  /// Re-checks before a "not found" is believed (about 11 s in total).
  static const List<Duration> _confirmDelays = [
    Duration(seconds: 3),
    Duration(seconds: 8),
  ];

  static Future<int> _probe(http.Client client, Uri uri) async {
    var code = (await client.head(uri).timeout(_timeout)).statusCode;
    // Some servers don't implement HEAD; ask for a single byte instead.
    if (code == 405 || code == 501) {
      final request = http.Request('GET', uri)..headers['Range'] = 'bytes=0-0';
      final streamed = await client.send(request).timeout(_timeout);
      code = streamed.statusCode;
    }
    return code;
  }

  /// Reactive: safe to call inside `Obx`.
  static bool isMissing(String url) =>
      _status[url.trim()] == MediaStatus.missing;

  static void markMissing(String url) {
    final key = url.trim();
    if (key.isEmpty) return;
    _status[key] = MediaStatus.missing;
  }

  static bool isMissingStatusCode(int? code) =>
      code != null && _missingCodes.contains(code);

  /// Checks [url] once and caches the answer. Local file paths are
  /// considered available (they are messages still being sent).
  static Future<MediaStatus> check(String url) async {
    final key = url.trim();
    if (key.isEmpty) return MediaStatus.missing;
    if (!key.startsWith('http://') && !key.startsWith('https://')) {
      return MediaStatus.available;
    }

    final cached = _status[key];
    if (cached != null && cached != MediaStatus.unknown) return cached;
    if (!_inFlight.add(key)) return MediaStatus.unknown;

    final client = http.Client();
    try {
      final uri = Uri.parse(key);
      var code = await _probe(client, uri);

      // A file that was JUST uploaded (real-time message) can answer 404/403
      // for a few seconds (storage/CDN propagation, CDN error caching).
      // Confirm before calling it missing, or the bubble shows "Media is
      // missing" for the rest of the session.
      for (final wait in _confirmDelays) {
        if (!_missingCodes.contains(code)) break;
        await Future<void>.delayed(wait);
        code = await _probe(client, uri);
      }

      final MediaStatus status;
      if (_missingCodes.contains(code)) {
        status = MediaStatus.missing;
      } else if (code >= 200 && code < 400) {
        status = MediaStatus.available;
      } else {
        status = MediaStatus.unknown;
      }

      if (status != MediaStatus.unknown) _status[key] = status;
      return status;
    } catch (e) {
      if (kDebugMode) AppLog.d('[MediaAvailability] $key -> $e');
      return MediaStatus.unknown;
    } finally {
      client.close();
      _inFlight.remove(key);
    }
  }
}
