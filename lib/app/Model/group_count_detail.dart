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

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  factory GroupCountDetail.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return const GroupCountDetail();
    }

    final dynamic rawData = (json.containsKey('data') && json['data'] is Map)
        ? json['data']
        : json;

    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);

    return GroupCountDetail(
      totalGroups: _parseInt(
        data['totalGroups'] ??
            data['total_groups'] ??
            data['groupsCount'] ??
            data['groups'],
      ),
      totalMembers: _parseInt(
        data['totalMembers'] ??
            data['total_members'] ??
            data['membersCount'] ??
            data['members'],
      ),
      activeMembers: _parseInt(
        data['activeMembers'] ??
            data['active_members'] ??
            data['totalOnlineMembers'] ??
            data['onlineMembers'] ??
            data['online'],
      ),
      locationDisabledMembers: _parseInt(
        data['locationDisabledMembers'] ??
            data['totalPrivateMembers'] ??
            data['privateMembers'] ??
            data['ghostMembers'] ??
            data['ghostModeMembers'] ??
            data['ghostCount'] ??
            data['location_disabled_members'] ??
            data['locationDisabled'] ??
            data['private'],
      ),
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
