import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Production-ready conditional logger.
/// Emits log messages only in debug mode via `dart:developer.log`.
/// Guaranteed zero log overhead in production release builds.
class AppLog {
  AppLog._();

  /// Master switch for debug logs.
  /// Can be turned off during testing or on when inspecting specific flows.
  /// Even when true, logs only execute when kDebugMode is true.
  static bool isEnabled = true;

  /// Log a debug message
  static void d(Object? message, {String name = 'APP', int? wrapWidth, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode && isEnabled) {
      developer.log('$message', name: name, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an informational message
  static void i(Object? message, {String name = 'APP', int? wrapWidth, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode && isEnabled) {
      developer.log('$message', name: name, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a warning message
  static void w(Object? message, {String name = 'APP', int? wrapWidth, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode && isEnabled) {
      developer.log('⚠️ $message', name: name, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an error message
  static void e(Object? message, {String name = 'APP', int? wrapWidth, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode && isEnabled) {
      developer.log('❌ $message', name: name, error: error, stackTrace: stackTrace);
    }
  }
}

/// Shorthand function for debug-only logging
void appLog(Object? message, {String name = 'APP', int? wrapWidth}) {
  if (kDebugMode && AppLog.isEnabled) {
    AppLog.d(message, name: name, wrapWidth: wrapWidth);
  }
}
