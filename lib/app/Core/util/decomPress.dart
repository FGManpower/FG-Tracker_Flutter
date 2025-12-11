import 'dart:convert';
import 'dart:developer';

import 'package:archive/archive.dart';

class decomPress{
  Map<String, dynamic>? decompressSDPOffer(String? compressed) {
    if (compressed == null) return null;
    try {
      final decoded = base64Decode(compressed);
      final unzipped = GZipDecoder().decodeBytes(decoded);
      return jsonDecode(utf8.decode(unzipped));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> extractExtra(Map body) {
    final rawExtra = body['extra'];

    if (rawExtra == null) {
      return {};
    }

    if (rawExtra is Map) {
      return rawExtra.cast<String, dynamic>();
    }

    if (rawExtra is String) {
      try {
        final decoded = jsonDecode(rawExtra);
        if (decoded is Map) {
          return decoded.cast<String, dynamic>();
        }
      } catch (e) {
        log("[CallKit] Failed to parse extra JSON → $e");
      }
    }

    return {};
  }
}