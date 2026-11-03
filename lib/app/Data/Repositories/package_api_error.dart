import 'dart:io';

import 'package:dio/dio.dart';

/// Why a Package Pricing API call failed. The screens pick an icon and a
/// friendly message from this; the raw server text is only logged.
enum PackageErrorKind {
  offline,
  timeout,
  unauthorized,
  notFound,
  conflict,
  server,

  /// 2xx response with `status: false`
  rejected,

  /// Body was not the JSON object the contract describes
  malformed,
  unknown,
}

class PackageApiException implements Exception {
  final PackageErrorKind kind;
  final int? statusCode;

  /// Server message / Dio detail — for logs only, never shown to the user
  final String? debugMessage;

  const PackageApiException(this.kind, {this.statusCode, this.debugMessage});

  /// Friendly text for the error state / dialogs
  String get userMessage => switch (kind) {
        PackageErrorKind.offline =>
          'No internet connection. Check your network and try again.',
        PackageErrorKind.timeout =>
          'The server is taking too long to respond. Please try again.',
        PackageErrorKind.unauthorized =>
          'Your session has expired. Please log in again.',
        PackageErrorKind.notFound =>
          'Plans are not available right now. Please try again later.',
        PackageErrorKind.conflict =>
          'This plan is already active or a payment is in progress.',
        PackageErrorKind.server ||
        PackageErrorKind.rejected ||
        PackageErrorKind.malformed ||
        PackageErrorKind.unknown =>
          'Something went wrong. Please try again.',
      };

  bool get isOffline => kind == PackageErrorKind.offline;

  static PackageApiException fromDio(DioException e) {
    final code = e.response?.statusCode;
    final serverMessage = _serverMessage(e.response?.data);
    final detail = [
      if (code != null) 'HTTP $code',
      e.requestOptions.method,
      e.requestOptions.uri.toString(),
      if (serverMessage != null) serverMessage,
    ].join(' · ');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return PackageApiException(PackageErrorKind.timeout,
            debugMessage: detail);
      case DioExceptionType.connectionError:
        return PackageApiException(PackageErrorKind.offline,
            debugMessage: detail);
      case DioExceptionType.badResponse:
        return PackageApiException(_kindForStatus(code),
            statusCode: code, debugMessage: detail);
      default:
        if (e.error is SocketException) {
          return PackageApiException(PackageErrorKind.offline,
              debugMessage: detail);
        }
        return PackageApiException(PackageErrorKind.unknown,
            statusCode: code, debugMessage: detail);
    }
  }

  static PackageErrorKind _kindForStatus(int? code) {
    if (code == 401 || code == 403) return PackageErrorKind.unauthorized;
    if (code == 404) return PackageErrorKind.notFound;
    if (code == 409) return PackageErrorKind.conflict;
    if (code != null && code >= 500) return PackageErrorKind.server;
    return PackageErrorKind.unknown;
  }

  static String? _serverMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.length > 200 ? data.substring(0, 200) : data;
    }
    return null;
  }

  @override
  String toString() =>
      'PackageApiException($kind${statusCode != null ? ', $statusCode' : ''}'
      '${debugMessage != null ? ': $debugMessage' : ''})';
}
