import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
      String? type}) async {
    try {
      api.sendRequest.options.headers["authorization"] =
          "Bearer ${Global.storageServices.getaccesstoken()!}";
      api.sendRequest.options.headers['accept'] = 'application/json';
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
}
