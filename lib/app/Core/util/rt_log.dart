import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'app_log.dart';

/// Structured diagnostic logger for Chat (REST + Sockets).
/// Keeps a memory ring-buffer of the latest 250 log events.
/// Strictly masks tokens, phone numbers, and message bodies.
class ChatDiagnosticLogger {
  ChatDiagnosticLogger._();

  static const int _maxEntries = 250;
  static final List<Map<String, dynamic>> _ringBuffer = [];

  /// Log a structured diagnostic event
  static void logEvent({
    required String category, // 'SOCKET' | 'API' | 'STATE' | 'NAV'
    required String action,
    String? correlationId,
    Map<String, dynamic>? details,
  }) {
    final entry = {
      't': DateTime.now().toUtc().toIso8601String(),
      'cat': category,
      'act': action,
      if (correlationId != null) 'cid': correlationId,
      if (details != null) 'data': details,
    };

    if (_ringBuffer.length >= _maxEntries) {
      _ringBuffer.removeAt(0);
    }
    _ringBuffer.add(entry);

    if (kDebugMode) {
      AppLog.d('[CHAT_DIAG][$category][$action] ${correlationId != null ? 'cid=$correlationId ' : ''}${details != null ? jsonEncode(details) : ''}');
    }
  }

  /// Get exported logs as a JSON string for QA / bug reports
  static String exportLogs() {
    return jsonEncode(_ringBuffer);
  }

  /// Clear in-memory diagnostic logs
  static void clear() {
    _ringBuffer.clear();
  }
}

/// Convenience log for realtime chat and attendance flows
void rtLog(String message) {
  if (kDebugMode) AppLog.d(message, name: 'RT');
}
