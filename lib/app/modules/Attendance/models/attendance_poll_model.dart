import 'dart:convert';

class AttendanceMemberResponse {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String status; // "Present" or "Absent"
  final String? photoUrl;
  final String time;
  final String? location;
  final String? locationDistance;

  AttendanceMemberResponse({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.status,
    this.photoUrl,
    required this.time,
    this.location,
    this.locationDistance,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userName": userName,
    "userAvatar": userAvatar,
    "status": status,
    "photoUrl": photoUrl,
    "time": time,
    "location": location,
    "locationDistance": locationDistance,
  };

  factory AttendanceMemberResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceMemberResponse(
        userId: json["userId"]?.toString() ?? "",
        userName: json["userName"]?.toString() ?? "Member",
        userAvatar: json["userAvatar"]?.toString(),
        status: json["status"]?.toString() ?? "Present",
        photoUrl: json["photoUrl"]?.toString(),
        time: json["time"]?.toString() ?? "",
        location: json["location"]?.toString(),
        locationDistance: json["locationDistance"]?.toString(),
      );
}

class AttendancePollData {
  final String id;
  final String question;
  final String date;
  final String creatorName;
  final String creatorAvatar;
  final int totalMembers;
  int presentCount;
  int absentCount;
  int respondedCount;
  final List<AttendanceMemberResponse> responses;

  AttendancePollData({
    required this.id,
    required this.question,
    required this.date,
    this.creatorName = "Rahul Verma",
    this.creatorAvatar = "",
    this.totalMembers = 12,
    this.presentCount = 2,
    this.absentCount = 1,
    this.respondedCount = 3,
    List<AttendanceMemberResponse>? responses,
  }) : responses = responses ?? [];

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "date": date,
    "creatorName": creatorName,
    "creatorAvatar": creatorAvatar,
    "totalMembers": totalMembers,
    "presentCount": presentCount,
    "absentCount": absentCount,
    "respondedCount": respondedCount,
    "responses": responses.map((r) => r.toJson()).toList(),
  };

  factory AttendancePollData.fromJson(Map<String, dynamic> json) {
    List<AttendanceMemberResponse> resList = [];
    if (json["responses"] != null && json["responses"] is List) {
      for (var r in json["responses"]) {
        if (r is Map<String, dynamic>) {
          resList.add(AttendanceMemberResponse.fromJson(r));
        }
      }
    }

    return AttendancePollData(
      id: json["id"]?.toString() ?? "att_${DateTime.now().millisecondsSinceEpoch}",
      question: json["question"]?.toString() ?? "Will you be available today?",
      date: json["date"]?.toString() ?? "11 Sep 2026",
      creatorName: json["creatorName"]?.toString() ?? "Rahul Verma",
      creatorAvatar: json["creatorAvatar"]?.toString() ?? "",
      totalMembers: json["totalMembers"] is int
          ? json["totalMembers"]
          : int.tryParse(json["totalMembers"]?.toString() ?? "12") ?? 12,
      presentCount: json["presentCount"] is int
          ? json["presentCount"]
          : int.tryParse(json["presentCount"]?.toString() ?? "2") ?? 2,
      absentCount: json["absentCount"] is int
          ? json["absentCount"]
          : int.tryParse(json["absentCount"]?.toString() ?? "1") ?? 1,
      respondedCount: json["respondedCount"] is int
          ? json["respondedCount"]
          : int.tryParse(json["respondedCount"]?.toString() ?? "3") ?? 3,
      responses: resList,
    );
  }

  static AttendancePollData fromRawJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AttendancePollData.fromJson(decoded);
      }
    } catch (_) {}
    return AttendancePollData(
      id: "att_1",
      question: "Team, please mark your attendance for today.",
      date: "11 Sep",
      totalMembers: 12,
      presentCount: 2,
      absentCount: 1,
      respondedCount: 3,
      responses: [
        AttendanceMemberResponse(
          userId: "1",
          userName: "Rahul",
          status: "Present",
          time: "09:12 AM",
          location: "Ghatkopar, Mumbai",
          locationDistance: "Just now • Within 50 m",
          photoUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
        ),
        AttendanceMemberResponse(
          userId: "2",
          userName: "Sameer",
          status: "Present",
          time: "09:20 AM",
          location: "Pune, Maharashtra",
          locationDistance: "2 mins ago • 1.2 km away",
          photoUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150",
        ),
        AttendanceMemberResponse(
          userId: "3",
          userName: "Imran",
          status: "Absent",
          time: "09:50 AM",
          location: "- \nNo location available",
          locationDistance: "",
        ),
      ],
    );
  }
}
