import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/attendance_repo.dart';
import '../models/attendance_poll_model.dart';

/// Shared store for attendance cards. Cards read from [polls] by
/// attendanceId so REST refreshes and socket events update them in place.
class AttendanceController extends GetxController {
  static AttendanceController get instance =>
      Get.isRegistered<AttendanceController>()
          ? Get.find<AttendanceController>()
          : Get.put(AttendanceController(), permanent: true);

  final RxMap<int, AttendancePollData> polls = <int, AttendancePollData>{}.obs;
  final Set<int> _loading = {};

  String get _currentUserId =>
      Global.storageServices.get(PrefConst.userId)?.toString() ?? "";

  /// Fetches the chat-card summary (counts + current user's response).
  Future<void> loadMessageData(int attendanceId, {bool force = false}) async {
    if (attendanceId <= 0 || _loading.contains(attendanceId)) return;
    if (!force && polls.containsKey(attendanceId)) return;

    _loading.add(attendanceId);
    try {
      final res = await AttendanceRepo.getAttendanceMessage(attendanceId);
      if (res["status"] == true && res["data"] is Map) {
        _upsert(AttendancePollData.fromJson(
          Map<String, dynamic>.from(res["data"]),
        ));
      }
    } catch (e) {
      log("ATTENDANCE MESSAGE ERROR => $e");
    } finally {
      _loading.remove(attendanceId);
    }
  }

  /// Full member list for the admin detail screen.
  Future<AttendancePollData> fetchDetails(int attendanceId) async {
    final res = await AttendanceRepo.getAttendanceDetails(attendanceId);
    if (res["status"] != true || res["data"] is! Map) {
      throw res["message"]?.toString() ?? "Unable to load attendance";
    }
    final data = AttendancePollData.fromJson(
      Map<String, dynamic>.from(res["data"]),
    );
    _upsert(data);
    return polls[attendanceId] ?? data;
  }

  Future<Map<String, dynamic>> fetchReport(int attendanceId) async {
    final res = await AttendanceRepo.getAttendanceReport(attendanceId);
    if (res["status"] != true || res["data"] is! Map) {
      throw res["message"]?.toString() ?? "Unable to load report";
    }
    return Map<String, dynamic>.from(res["data"]);
  }

  /// Creates an attendance. Returns the created data (includes messageId).
  Future<Map<String, dynamic>> createAttendance({
    required int groupId,
    required String question,
    required DateTime date,
    required List<String> options,
    required List<int> memberIds,
  }) async {
    final isoDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final res = await AttendanceRepo.createAttendance(
      groupId: groupId,
      question: question,
      date: isoDate,
      options: options,
      memberIds: memberIds,
    );

    if (res["status"] != true || res["data"] is! Map) {
      throw res["message"]?.toString() ?? "Unable to create attendance";
    }

    final data = Map<String, dynamic>.from(res["data"]);
    _upsert(AttendancePollData.fromJson({
      ...data,
      "totalMembers": data["totalMembers"] ?? memberIds.length,
    }));
    return data;
  }

  /// Marks the current user's attendance with GPS + optional selfie.
  Future<void> markAttendance({
    required int attendanceId,
    required String response,
    String? photoPath,
  }) async {
    final position = await _currentPosition();
    final locationName = position != null
        ? await _placeName(position.latitude, position.longitude)
        : null;

    final res = await AttendanceRepo.markAttendance(
      attendanceId: attendanceId,
      response: response,
      latitude: position?.latitude,
      longitude: position?.longitude,
      locationName: locationName,
      photoPath: photoPath,
    );

    if (res["status"] != true) {
      throw res["message"]?.toString() ?? "Unable to mark attendance";
    }

    final data = res["data"] is Map
        ? Map<String, dynamic>.from(res["data"])
        : <String, dynamic>{};
    final current = polls[attendanceId];
    if (current != null) {
      final alreadyResponded = current.userResponse != null;
      final isPresent = response.toLowerCase() == "present";
      polls[attendanceId] = current.copyWith(
        userResponse: data["response"]?.toString() ?? response,
        userPhotoUrl: data["photoUrl"]?.toString() ?? photoPath,
        presentCount: alreadyResponded || !isPresent
            ? current.presentCount
            : current.presentCount + 1,
        absentCount: alreadyResponded || isPresent
            ? current.absentCount
            : current.absentCount + 1,
        respondedCount: alreadyResponded
            ? current.respondedCount
            : current.respondedCount + 1,
      );
    }

    // Re-sync counts with the server; the socket event may also arrive.
    loadMessageData(attendanceId, force: true);
  }

  /// `attendance_created` socket event.
  void handleCreated(dynamic data) {
    if (data is! Map) return;
    final poll = AttendancePollData.fromJson(Map<String, dynamic>.from(data));
    if (poll.attendanceId > 0) _upsert(poll);
  }

  /// `attendance_updated` socket event: updates counts in place.
  void handleUpdated(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final update = AttendancePollData.fromJson(map);
    final id = update.attendanceId;
    if (id <= 0) return;

    final current = polls[id];
    if (current == null) {
      loadMessageData(id, force: true);
      return;
    }

    String? myResponse;
    String? myPhoto;
    final latest = map["latestResponse"];
    if (latest is Map && latest["userId"]?.toString() == _currentUserId) {
      myResponse = latest["response"]?.toString();
      myPhoto = latest["photoUrl"]?.toString();
    }

    polls[id] = current.copyWith(
      presentCount: update.presentCount,
      absentCount: update.absentCount,
      totalMembers: update.totalMembers > 0 ? update.totalMembers : null,
      respondedCount: update.respondedCount,
      userResponse: myResponse,
      userPhotoUrl: myPhoto,
    );
  }

  void _upsert(AttendancePollData data) {
    final existing = polls[data.attendanceId];
    polls[data.attendanceId] =
        existing == null ? data : existing.mergeFrom(data);
  }

  Future<Position?> _currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      log("ATTENDANCE LOCATION ERROR => $e");
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> _placeName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 4));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = [
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e.trim().isNotEmpty).toSet().toList();
      return parts.isEmpty ? null : parts.take(2).join(", ");
    } catch (e) {
      log("ATTENDANCE GEOCODE ERROR => $e");
      return null;
    }
  }
}
