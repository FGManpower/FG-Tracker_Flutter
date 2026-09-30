import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';

class ApiErrorHandler {
  static String handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return AppText.anErrorOccouredPlsTryAgain;
    } else if (e.type == DioExceptionType.badResponse && e.response != null) {
      final response = e.response!;
      final statusCode = response.statusCode;

      if (statusCode == 401) {
        LogoutUser().logout();
        return "Session expired. Please log in again.";
      } else if (statusCode == 503) {
        return AppText.OopsSomethingWentWrong;
      }

      if (response.data != null) {
        final data = response.data;
        if (data is Map) {
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map) {
              final String errorMessage = errors.entries.map((entry) {
                return (entry.value is List)
                    ? entry.value.join("\n")
                    : entry.value.toString();
              }).join("\n");
              if (errorMessage.trim().isNotEmpty) {
                return errorMessage.trim();
              }
            } else if (errors is List) {
              return errors.join("\n");
            }
            return errors.toString();
          } else if (data['message'] != null &&
              data['message'].toString().trim().isNotEmpty) {
            return data['message'].toString().trim();
          } else if (data['error'] != null &&
              data['error'].toString().trim().isNotEmpty) {
            return data['error'].toString().trim();
          }
        } else if (data is String && data.trim().isNotEmpty) {
          return data.trim();
        }
      }
    }

    return AppText.OopsSomethingWentWrong;
  }
}
