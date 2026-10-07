import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/timezone_helper.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/AppText.dart';
import 'ApiErrorHandler.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();

  factory HttpUtil() {
    return _instance;
  }

  ConstRes api = ConstRes();

  HttpUtil._internal() {
    api.sendRequest.interceptors.add(PrettyDioLogger());
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
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }
      throw AppText.anUnexpectedError;
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
      throw AppText.anUnexpectedError;
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

      throw AppText.anUnexpectedError;
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

      throw AppText.anUnexpectedError;
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";
      api.sendRequest.options.headers['accept'] = 'application/json';
      api.sendRequest.options.headers['content-type'] = 'application/json';
      var response = await api.sendRequest.get(path, queryParameters: data);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw ApiErrorHandler.handleDioError(e);
      }
      throw AppText.anUnexpectedError;
    }
  }

  Future<dynamic> getRecentCall(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final timeZone = await TimeZoneHelper.getTimeZone();

      print("timezone===${timeZone}");

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

      throw AppText.anUnexpectedError;
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
      throw AppText.anUnexpectedError;
    }
  }
}
