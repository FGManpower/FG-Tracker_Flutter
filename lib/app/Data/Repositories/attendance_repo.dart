import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class AttendanceRepo {
  /// POST /api/attendance/create (group admin only)
  static Future<Map<String, dynamic>> createAttendance({
    required int groupId,
    required String question,
    required String date,
    required List<String> options,
    required List<int> memberIds,
  }) async {
    final response = await HttpUtil().Authpost(
      "/attendance/create",
      data: {
        "groupId": groupId,
        "question": question,
        "date": date,
        "options": options,
        "memberIds": memberIds,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// POST /api/attendance/mark (multipart, selfie required for "Present")
  static Future<Map<String, dynamic>> markAttendance({
    required int attendanceId,
    required String response,
    double? latitude,
    double? longitude,
    String? locationName,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      "attendanceId": attendanceId,
      "response": response,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (locationName != null && locationName.isNotEmpty)
        "locationName": locationName,
      if (photoPath != null && photoPath.isNotEmpty)
        "attendancePhoto": await MultipartFile.fromFile(
          photoPath,
          filename: p.basename(photoPath),
          contentType: MediaType("image", "jpeg"),
        ),
    });

    final result = await HttpUtil().Authpost(
      "/attendance/mark",
      formdata: formData,
      type: "formdata",
    );

    return Map<String, dynamic>.from(result);
  }

  /// GET /api/attendance/details (admin view: all members)
  static Future<Map<String, dynamic>> getAttendanceDetails(
    int attendanceId,
  ) async {
    final response = await HttpUtil().get(
      "/attendance/details?attendanceId=$attendanceId",
    );

    return Map<String, dynamic>.from(response);
  }

  /// GET /api/attendance/message (chat card summary + current user's response)
  static Future<Map<String, dynamic>> getAttendanceMessage(
    int attendanceId,
  ) async {
    final response = await HttpUtil().get(
      "/attendance/message?attendanceId=$attendanceId",
    );

    return Map<String, dynamic>.from(response);
  }

  /// GET /api/attendance/report (admin only)
  static Future<Map<String, dynamic>> getAttendanceReport(
    int attendanceId,
  ) async {
    final response = await HttpUtil().get(
      "/attendance/report?attendanceId=$attendanceId",
    );

    return Map<String, dynamic>.from(response);
  }
}
