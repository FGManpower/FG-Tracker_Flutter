import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';

class ApiErrorHandler {
  static String handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw AppText.anErrorOccouredPlsTryAgain;
    } else if (e.type == DioExceptionType.badResponse && e.response != null) {
      final response = e.response!;
      final statusCode = response.statusCode;

      if (statusCode == 401) {
        LogoutUser().logout();
      } else if (statusCode == 503) {
        throw AppText.OopsSomethingWentWrong;
      } else if (e.response!.statusCode == 422 ||
          e.response!.statusCode == 400 ||
          e.response!.statusCode == 500 ||
          e.response!.statusCode == 404 ||
          e.response!.statusCode == 400) {
        if (response.data['status'].toString() == "false") {
          if (response.data != null && response.data['errors'] != null) {
            final errors = response.data['errors'];
            String errorMessage = errors.entries.map((entry) {
              return (entry.value is List)
                  ? entry.value.join("\n")
                  : entry.value.toString();
            }).join("\n");

            throw errorMessage;
          } else {
            throw response.data['message'];
          }
        } else {
          throw response.data['message'];
        }
      }
    }

    throw AppText.OopsSomethingWentWrong;
  }
}
