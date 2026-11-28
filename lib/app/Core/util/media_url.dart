import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';

/// Builds a playable URL for a voice message path from the server or a local file.
String resolveMediaUrl(String path) {
  final value = path.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  if (value.startsWith('file:')) return value;
  // Absolute path that exists on the phone = local file; otherwise a server path like "/uploads/..."
  if (value.startsWith('/') && File(value).existsSync()) return value;
  return '${ConstRes.aImageBaseUrl}${value.replaceFirst(RegExp(r'^/+'), '')}';
}
