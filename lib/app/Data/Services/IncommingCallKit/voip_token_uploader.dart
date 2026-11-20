import 'dart:convert';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Uploads the iOS PushKit (VoIP) token whenever it changes (BUG-CALL-11).
///
/// Before, the token was sent only at OTP login (`Voip_Device`). After a
/// token change iOS calls stopped ringing when the app was killed. The login
/// code (`OtpController`, protected) is not touched; this is a separate
/// upload: `POST /api/update-voip-token { voipToken, platform: "ios" }`
/// (endpoint requested in the backend handover doc).
///
/// - Once per new token (the last uploaded token is remembered).
/// - Not remembered on failure, so the next app start tries again.
/// - The token itself is never logged.
class VoipTokenUploader {
  VoipTokenUploader._();
  static final VoipTokenUploader instance = VoipTokenUploader._();

  static const String _lastKey = 'voip_token_uploaded_v1';

  Future<bool> upload(
    String token, {
    bool force = false,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) return false;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.reload();
      final Object? authRaw = p.get(PrefConst.STORAGE_USER_TOKEN_KEY) ??
          p.get('user_token_key') ??
          p.get('token');
      if (authRaw == null || authRaw.toString().trim().isEmpty) return false; // logged out
      final String auth = authRaw.toString().trim().replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');

      if (!force && p.getString(_lastKey) == cleanToken) return true;

      final baseUrl = ConstRes.aBaseUrl.endsWith('/') ? ConstRes.aBaseUrl : '${ConstRes.aBaseUrl}/';
      final http.Response r = await http
          .post(
            Uri.parse('${baseUrl}update-voip-token'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $auth',
            },
            body: jsonEncode(<String, String>{
              'voipToken': cleanToken,
              'platform': 'ios',
            }),
          )
          .timeout(timeout);
      final bool ok = r.statusCode >= 200 && r.statusCode < 300;
      if (ok) await p.setString(_lastKey, cleanToken);
      if (kDebugMode) log('[CALL] VoIP token upload status=${r.statusCode}');
      return ok;
    } catch (e) {
      if (kDebugMode) log('[CALL] VoIP token upload failed (${e.runtimeType})');
      return false;
    }
  }
}
