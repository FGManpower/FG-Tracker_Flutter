import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

/// Attendance Voting API (backend v1.0.0). Every request carries the
/// `x-attendance-supported: 1` header via the shared Dio options.
class AttendanceRepo {
  static Map<String, dynamic> _map(dynamic response) =>
      response is Map ? Map<String, dynamic>.from(response) : {};

  /// 5.1 POST /groups/:groupId/attendance (group admin)
  static Future<Map<String, dynamic>> createPoll({
    required int groupId,
    required String title,
    String? description,
    required String eventDate,
    String? eventTime,
    String? location,
    required List<Map<String, dynamic>> options,
    String? photoRequiredOptionLabel,
    bool allowVoteChange = true,
    String voterVisibility = "admin",
    DateTime? deadlineAt,
  }) async {
    final response = await HttpUtil().Authpost(
      "/groups/$groupId/attendance",
      data: {
        "title": title,
        if (description != null && description.isNotEmpty)
          "description": description,
        "eventDate": eventDate,
        if (eventTime != null) "eventTime": eventTime,
        if (location != null && location.isNotEmpty) "location": location,
        "options": options,
        if (photoRequiredOptionLabel != null)
          "photoRequiredOptionLabel": photoRequiredOptionLabel,
        "allowVoteChange": allowVoteChange,
        "voterVisibility": voterVisibility,
        if (deadlineAt != null)
          "deadlineAt": deadlineAt.toUtc().toIso8601String(),
      },
    );
    return _map(response);
  }

  /// 5.2 GET /attendance/:pollId → { poll, myVote }
  static Future<Map<String, dynamic>> getPoll(int pollId) async {
    return _map(await HttpUtil().get("/attendance/$pollId"));
  }

  /// 5.3 POST /attendance/:pollId/vote (multipart)
  static Future<Map<String, dynamic>> vote({
    required int pollId,
    required String optionId,
    required String clientRequestId,
    double? latitude,
    double? longitude,
    String? locationName,
    double? locationAccuracy,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      "optionId": optionId,
      "clientRequestId": clientRequestId,
      if (latitude != null) "latitude": latitude.toString(),
      if (longitude != null) "longitude": longitude.toString(),
      if (locationName != null && locationName.isNotEmpty)
        "locationName": locationName,
      if (locationAccuracy != null)
        "locationAccuracy": locationAccuracy.toString(),
      if (photoPath != null && photoPath.isNotEmpty)
        "attendancePhoto": await MultipartFile.fromFile(
          photoPath,
          filename: p.basename(photoPath),
          contentType: MediaType("image", "jpeg"),
        ),
    });

    final response = await HttpUtil().Authpost(
      "/attendance/$pollId/vote",
      formdata: formData,
      type: "formdata",
    );
    return _map(response);
  }

  /// 5.4 DELETE /attendance/:pollId/vote
  static Future<Map<String, dynamic>> removeVote(int pollId) async {
    return _map(await HttpUtil().Authdelete("/attendance/$pollId/vote"));
  }

  /// 5.5 GET /attendance/:pollId/voters
  /// Pass [notVoted] to list members who haven't voted.
  static Future<Map<String, dynamic>> getVoters({
    required int pollId,
    String? optionId,
    bool notVoted = false,
    int page = 1,
    int limit = 50,
    String? search,
    String sort = "votedAt",
  }) async {
    final query = <String, String>{
      if (optionId != null) "optionId": optionId,
      if (notVoted) "status": "notVoted",
      "page": "$page",
      "limit": "$limit",
      if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      "sort": sort,
    };
    final qs = Uri(queryParameters: query).query;
    return _map(await HttpUtil().get("/attendance/$pollId/voters?$qs"));
  }

  /// 5.6 PUT /attendance/:pollId (group admin)
  static Future<Map<String, dynamic>> editPoll(
    int pollId,
    Map<String, dynamic> changes,
  ) async {
    return _map(await HttpUtil().Authput("/attendance/$pollId", data: changes));
  }

  /// 5.7 POST /attendance/:pollId/close (group admin)
  static Future<Map<String, dynamic>> closePoll(int pollId) async {
    return _map(await HttpUtil().Authpost("/attendance/$pollId/close"));
  }

  /// 5.8 DELETE /attendance/:pollId (group admin)
  static Future<Map<String, dynamic>> deletePoll(int pollId) async {
    return _map(await HttpUtil().Authdelete("/attendance/$pollId"));
  }

  /// 5.9 GET /groups/:groupId/attendance
  static Future<Map<String, dynamic>> getGroupPolls({
    required int groupId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final statusParam = status != null ? "&status=$status" : "";
    return _map(await HttpUtil().get(
      "/groups/$groupId/attendance?page=$page&limit=$limit$statusParam",
    ));
  }

  /// 5.10 GET /attendance/:pollId/export → CSV text (group admin)
  static Future<String> exportCsv(int pollId) async {
    final response = await HttpUtil().get("/attendance/$pollId/export");
    return response?.toString() ?? "";
  }
}
