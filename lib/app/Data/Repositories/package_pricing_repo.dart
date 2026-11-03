import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/ApiErrorHandler.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/package_api_error.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:flutter/foundation.dart';

/// Packages & Pricing endpoint (GET /api/packages).
/// Contract: docs/packages/02_backend_requirements.md
///
/// All data comes from the backend — there is no sample / fallback data.
/// Every failure is thrown as [PackageApiException] so the screens can show
/// a friendly message; the raw server text is only logged in debug.
class PackagePricingRepo {
  PackagePricingRepo._();

  /// Own Dio so the auth token is never written to the debug log
  /// (the shared HttpUtil logger prints request headers).
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'accept': 'application/json'},
  ));

  @visibleForTesting
  static Dio get dio => _dio;

  static Future<PackageListResponse> getPackages() async {
    final json = await _send('GET', Urls.packages);
    return PackageListResponse.fromJson(json);
  }

  // ---------------------------------------------------------------------------

  /// Sends the request and returns the decoded JSON object.
  /// Throws [PackageApiException] for transport errors, non-2xx responses,
  /// a body that is not a JSON object, and `status: false`.
  static Future<Map<String, dynamic>> _send(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    if (kDebugMode) {
      // Method + URL + body only — never the Authorization header
      debugPrint('📦 [PackageAPI] $method $url'
          '${body != null ? ' body=$body' : ''}');
    }

    final Response<dynamic> response;
    try {
      final token = Global.storageServices.getaccesstoken();
      response = await _dio.request<dynamic>(
        url,
        data: body,
        options: Options(
          method: method,
          contentType: 'application/json',
          headers: {
            if (token != null && token.isNotEmpty)
              'authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final error = PackageApiException.fromDio(e);
      if (error.kind == PackageErrorKind.unauthorized &&
          e.response?.statusCode == 401) {
        // Same session-expired handling (force logout) as every other API
        ApiErrorHandler.handleDioError(e);
      }
      if (kDebugMode) debugPrint('❌ [PackageAPI] $error');
      throw error;
    }

    final data = response.data;
    if (kDebugMode) {
      debugPrint('✅ [PackageAPI] ${response.statusCode} $method $url');
    }
    if (data is! Map) {
      throw PackageApiException(PackageErrorKind.malformed,
          statusCode: response.statusCode,
          debugMessage: 'Expected a JSON object, got ${data.runtimeType}');
    }
    final map = Map<String, dynamic>.from(data);
    final status = map['status'];
    if (status != true && status != 'true' && status != 1) {
      throw PackageApiException(PackageErrorKind.rejected,
          statusCode: response.statusCode,
          debugMessage: map['message']?.toString());
    }
    return map;
  }
}
