import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ICE servers for a 1:1 call (BUG-CALL-07).
///
/// 1. Short-lived TURN credentials from the backend for each call:
///    `GET /api/calls/turn-credentials` →
///    `{ "urls": [...], "username": "...", "credential": "...", "ttl": 3600 }`
///    (endpoint requested in the backend handover doc; not live yet).
/// 2. Until it exists (404 / error / timeout): the static list in `Urls`,
///    now with TURN over TLS 443 for networks that block 3478.
///
/// Credentials are never logged.
class TurnCredentialService {
  TurnCredentialService._();
  static final TurnCredentialService instance = TurnCredentialService._();

  static const String _stun = 'stun:stun.l.google.com:19302';

  List<Map<String, dynamic>>? _cached;
  DateTime? _expiresAt;

  @visibleForTesting
  void clearCache() {
    _cached = null;
    _expiresAt = null;
  }

  /// Static fallback (compiled in; to be removed once the endpoint is live).
  static List<Map<String, dynamic>> fallbackServers() => <Map<String, dynamic>>[
        <String, dynamic>{
          'urls': <String>[_stun],
        },
        <String, dynamic>{
          'urls': Urls.rtcUrl,
          'username': Urls.rtcUserName,
          'credential': Urls.rtcCredential,
        },
      ];

  /// Parses the endpoint body. Returns null when it is not usable.
  static ({List<Map<String, dynamic>> servers, Duration ttl})? parse(
    dynamic body,
  ) {
    if (body is! Map) return null;
    final dynamic data = body['data'] is Map ? body['data'] : body;
    if (data is! Map) return null;
    final dynamic rawUrls = data['urls'] ?? data['uris'];
    final List<String> urls = rawUrls is List
        ? rawUrls.map((dynamic e) => e.toString()).toList()
        : (rawUrls is String && rawUrls.isNotEmpty ? <String>[rawUrls] : <String>[]);
    final String user = (data['username'] ?? '').toString();
    final String cred = (data['credential'] ?? data['password'] ?? '').toString();
    if (urls.isEmpty || user.isEmpty || cred.isEmpty) return null;
    final int ttlSec = int.tryParse('${data['ttl'] ?? ''}') ?? 600;
    return (
      servers: <Map<String, dynamic>>[
        <String, dynamic>{
          'urls': <String>[_stun],
        },
        <String, dynamic>{'urls': urls, 'username': user, 'credential': cred},
      ],
      ttl: Duration(seconds: ttlSec),
    );
  }

  Future<List<Map<String, dynamic>>> iceServers({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final DateTime now = DateTime.now();
    final List<Map<String, dynamic>>? cached = _cached;
    if (cached != null && _expiresAt != null && now.isBefore(_expiresAt!)) {
      return cached;
    }
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final Object? token = p.get(PrefConst.STORAGE_USER_TOKEN_KEY);
      if (token != null && token.toString().isNotEmpty) {
        final http.Response r = await http.get(
          Uri.parse('${ConstRes.aBaseUrl}calls/turn-credentials'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(timeout);
        if (r.statusCode == 200) {
          final parsed = parse(jsonDecode(r.body));
          if (parsed != null) {
            _cached = parsed.servers;
            // Refresh a minute before the credentials expire.
            final Duration keep = parsed.ttl > const Duration(minutes: 2)
                ? parsed.ttl - const Duration(minutes: 1)
                : parsed.ttl ~/ 2;
            _expiresAt = now.add(keep);
            if (kDebugMode) log('[CALL] TURN: short-lived credentials in use');
            return parsed.servers;
          }
        }
        if (kDebugMode) log('[CALL] TURN endpoint status=${r.statusCode}, fallback');
      }
    } catch (e) {
      if (kDebugMode) log('[CALL] TURN endpoint unavailable (${e.runtimeType}), fallback');
    }
    return fallbackServers();
  }
}
