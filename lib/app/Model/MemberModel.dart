
class MemberModel {
  final dynamic userId;
  final String name;
  final String team;
  final String location;
  final String distance;
  final int? battery;
  final String avatarUrl;
  final double? latitude;
  final double? longitude;
  final bool isOnline;

  MemberModel({
    this.userId,
    required this.name,
    required this.team,
    required this.location,
    required this.distance,
    this.battery,
    required this.avatarUrl,
    this.latitude,
    this.longitude,
    this.isOnline = true,
  });
}