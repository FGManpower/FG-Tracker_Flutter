class GroupCountDetail {
  final int totalGroups;
  final int totalMembers;
  final int activeMembers;
  final int locationDisabledMembers;

  const GroupCountDetail({
    this.totalGroups = 0,
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.locationDisabledMembers = 0,
  });

  factory GroupCountDetail.fromJson(dynamic json) {
    final Map<String, dynamic> data =
    json is Map<String, dynamic> && json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json as Map<String, dynamic>;

    return GroupCountDetail(
      totalGroups: (data['totalGroups'] as num?)?.toInt() ?? 0,
      totalMembers: (data['totalMembers'] as num?)?.toInt() ?? 0,
      activeMembers: (data['activeMembers'] as num?)?.toInt() ?? 0,
      locationDisabledMembers:
      (data['locationDisabledMembers'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGroups': totalGroups,
    'totalMembers': totalMembers,
    'activeMembers': activeMembers,
    'locationDisabledMembers': locationDisabledMembers,
  };

  GroupCountDetail copyWith({
    int? totalGroups,
    int? totalMembers,
    int? activeMembers,
    int? locationDisabledMembers,
  }) {
    return GroupCountDetail(
      totalGroups: totalGroups ?? this.totalGroups,
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      locationDisabledMembers:
      locationDisabledMembers ?? this.locationDisabledMembers,
    );
  }

  @override
  String toString() =>
      'GroupCountDetail(totalGroups: $totalGroups, totalMembers: $totalMembers, '
          'activeMembers: $activeMembers, locationDisabledMembers: $locationDisabledMembers)';
}
