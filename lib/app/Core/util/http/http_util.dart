import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/timezone_helper.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

import 'package:fgtracker/l10n/l10n.dart';
import '../app_log.dart';
import 'ApiErrorHandler.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();

  factory HttpUtil() {
    return _instance;
  }

  ConstRes api = ConstRes();

  /// Toggle for HTTP network payload logging.
  /// Set to false for production ready builds; flip to true when needed for local API testing.
  static const bool enablePrettyLogger = false;

  HttpUtil._internal() {
    if (enablePrettyLogger && kDebugMode) {
      api.sendRequest.interceptors.add(PrettyDioLogger(
        // false: request headers carry the Bearer token — never log it
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
      ));
    }
  }

  Future<dynamic> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameteres,
      FormData? formdata,
      String? type}) async {
    try {
      var response = await api.sendRequest.post(path,
          data: type == "formdata" ? formdata : data,
          queryParameters: queryParameteres);

      return response.data;
    } catch (e, stack) {
      AppLog.e("HttpUtil post error ($path): $e", error: e, stackTrace: stack);
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }
      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> Authpost(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameteres,
      FormData? formdata,
      ProgressCallback? onSendProgress,
      String? type}) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";
      api.sendRequest.options.headers['accept'] = 'application/json';
      var response = await api.sendRequest.post(path,
          data: type == "formdata" ? formdata : data,
          onSendProgress: onSendProgress,
          queryParameters: queryParameteres);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }
      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> Authput(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameteres,
    FormData? formdata,
    String? type,
  }) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";

      api.sendRequest.options.headers['accept'] = 'application/json';

      var response = await api.sendRequest.put(
        path,
        data: type == "formdata" ? formdata : data,
        queryParameters: queryParameteres,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }

      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> Authpatch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameteres,
    FormData? formdata,
    String? type,
  }) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";

      api.sendRequest.options.headers['accept'] = 'application/json';

      var response = await api.sendRequest.patch(
        path,
        data: type == "formdata" ? formdata : data,
        queryParameters: queryParameteres,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }

      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> Authdelete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameteres,
    FormData? formdata,
    String? type,
  }) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";

      api.sendRequest.options.headers['accept'] = 'application/json';

      var response = await api.sendRequest.delete(
        path,
        data: type == "formdata" ? formdata : data,
        queryParameters: queryParameteres,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }

      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final watch = Stopwatch()..start();
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";
      api.sendRequest.options.headers['accept'] = 'application/json';
      api.sendRequest.options.headers['content-type'] = 'application/json';
      var response = await api.sendRequest.get(path, queryParameters: data);
      return response.data;
    } catch (e) {
      // Which error it really was (timeout / connection / 4xx / 5xx / other)
      // was lost in the translated string. Debug only; no token, no body.
      if (kDebugMode) {
        final q = path.indexOf('?');
        debugPrint('[HTTP-GET] ${q == -1 ? path : path.substring(0, q)} '
            'failed after ${watch.elapsedMilliseconds}ms: '
            '${e is DioException ? 'dio=${e.type.name} status=${e.response?.statusCode}' : 'error=${e.runtimeType}'}');
      }
      // Same message as before (toString), plus what kind of failure it was,
      // so a screen can tell "offline / server down" from a 4xx.
      if (e is DioException) {
        throw HttpGetException(ApiErrorHandler.handleDioError(e),
            dioType: e.type, statusCode: e.response?.statusCode);
      }
      throw HttpGetException(sharedL10n.http_unexpectedError);
    }
  }

  Future<dynamic> getRecentCall(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final timeZone = await TimeZoneHelper.getTimeZone();

      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";
      api.sendRequest.options.headers['accept'] = 'application/json';
      api.sendRequest.options.headers['content-type'] = 'application/json';

      if (timeZone != null) {
        api.sendRequest.options.headers['x-timezone'] = timeZone;
      }

      final response = await api.sendRequest.get(
        path,
        queryParameters: data,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }

      throw sharedL10n.http_unexpectedError;
    }
  }

  Future<dynamic> updateCallingStatusPost(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameteres,
      FormData? formdata,
      ProgressCallback? onSendProgress,
      String? type}) async {
    try {
      var pref = await SharedPreferences.getInstance();
      var token = pref.get(PrefConst.STORAGE_USER_TOKEN_KEY);
      api.sendRequest.options.headers["authorization"] = "Bearer $token";
      api.sendRequest.options.headers['accept'] = 'application/json';
      var response = await api.sendRequest.post(path,
          data: type == "formdata" ? formdata : data,
          onSendProgress: onSendProgress,
          queryParameters: queryParameteres);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }
      throw sharedL10n.http_unexpectedError;
    }
  }
}

/// Thrown by [HttpUtil.get]. [toString] is the same translated message that
/// was thrown before (so every existing `e.toString()` shows the same text);
/// [dioType] / [statusCode] tell what really failed.
class HttpGetException implements Exception {
  HttpGetException(this.message, {this.dioType, this.statusCode});

  final String message;
  final DioExceptionType? dioType;
  final int? statusCode;

  /// Offline, timed out or the server is down (5xx): the data on screen may
  /// be stale. A 4xx (not found, forbidden, session) is not.
  bool get isNetworkOrServer {
    switch (dioType) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return (statusCode ?? 0) >= 500;
      case DioExceptionType.unknown:
        return statusCode == null; // e.g. SocketException / HandshakeException
      default:
        return false;
    }
  }

  @override
  String toString() => message;
}
