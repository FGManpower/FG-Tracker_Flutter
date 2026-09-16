class recent_Call_Res {
  bool? status;
  String? message;
  AppliedFilters? appliedFilters;
  Pagination? pagination;
  CallData? data;

  recent_Call_Res(
      {this.status,
      this.message,
      this.appliedFilters,
      this.pagination,
      this.data});

  recent_Call_Res.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    appliedFilters = json['appliedFilters'] != null
        ? AppliedFilters.fromJson(json['appliedFilters'])
        : null;
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    data = json['data'] != null ? CallData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (appliedFilters != null) {
      data['appliedFilters'] = appliedFilters!.toJson();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AppliedFilters {
  String? filter;
  String? type;

  AppliedFilters({this.filter, this.type});

  AppliedFilters.fromJson(Map<String, dynamic> json) {
    filter = json['filter'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter'] = filter;
    data['type'] = type;
    return data;
  }
}

class Pagination {
  int? totalRecords;
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination(
      {this.totalRecords,
      this.currentPage,
      this.perPage,
      this.totalPages,
      this.hasNextPage,
      this.hasPreviousPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalRecords = json['totalRecords'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalPages = json['totalPages'];
    hasNextPage = json['hasNextPage'];
    hasPreviousPage = json['hasPreviousPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalRecords'] = totalRecords;
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    data['totalPages'] = totalPages;
    data['hasNextPage'] = hasNextPage;
    data['hasPreviousPage'] = hasPreviousPage;
    return data;
  }
}

class CallData {
  List<CallingDetail>? today;
  List<CallingDetail>? yesterday;
  List<CallingDetail>? older;

  CallData({this.today, this.yesterday, this.older});

  CallData.fromJson(Map<String, dynamic> json) {
    if (json['today'] != null) {
      today = <CallingDetail>[];
      json['today'].forEach((v) {
        today!.add(CallingDetail.fromJson(v));
      });
    }
    if (json['yesterday'] != null) {
      yesterday = <CallingDetail>[];
      json['yesterday'].forEach((v) {
        yesterday!.add(CallingDetail.fromJson(v));
      });
    }
    if (json['older'] != null) {
      older = <CallingDetail>[];
      json['older'].forEach((v) {
        older!.add(CallingDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (today != null) {
      data['today'] = today!.map((v) => v.toJson()).toList();
    }
    if (yesterday != null) {
      data['yesterday'] = yesterday!.map((v) => v.toJson()).toList();
    }
    if (older != null) {
      data['older'] = older!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CallingDetail {
  String? id;
  RecentContact? contact;
  String? type;
  String? direction;
  String? status;
  String? calledAt;
  String? date;
  String? time;

  CallingDetail(
      {this.id,
      this.contact,
      this.type,
      this.direction,
      this.status,
      this.calledAt,
      this.date,
      this.time});

  CallingDetail.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    if (json['contact'] != null && json['contact'] is Map<String, dynamic>) {
      contact = RecentContact.fromJson(json['contact']);
    } else {
      contact = RecentContact(
        id: json['caller_id']?.toString() ??
            json['receiver_id']?.toString() ??
            json['callerId']?.toString() ??
            json['receiverId']?.toString() ??
            json['userId']?.toString() ??
            json['user_id']?.toString() ??
            json['id']?.toString(),
        firstName: json['caller_name'] ??
            json['callerName'] ??
            json['receiver_name'] ??
            json['receiverName'] ??
            json['name'] ??
            json['first_name'] ??
            '',
        lastName: json['last_name'] ?? '',
        avatar: json['caller_profile_image'] ??
            json['callerProfileImage'] ??
            json['receiver_profile_image'] ??
            json['receiverProfileImage'] ??
            json['profile_image'] ??
            json['profileImage'] ??
            json['avatar'] ??
            '',
      );
    }
    type = json['type']?.toString();
    direction = json['direction']?.toString();
    status = json['status']?.toString();
    calledAt = json['called_at']?.toString() ?? json['calledAt']?.toString();
    date = json['date']?.toString();
    time = json['time']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (contact != null) {
      data['contact'] = contact!.toJson();
    }
    data['type'] = type;
    data['direction'] = direction;
    data['status'] = status;
    data['called_at'] = calledAt;
    data['date'] = date;
    data['time'] = time;
    return data;
  }
}

class RecentContact {
  String? id;
  String? firstName;
  String? lastName;
  String? avatar;

  RecentContact({this.id, this.firstName, this.lastName, this.avatar});

  RecentContact.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ??
        json['userId']?.toString() ??
        json['user_id']?.toString() ??
        json['caller_id']?.toString() ??
        json['callerId']?.toString() ??
        json['receiver_id']?.toString() ??
        json['receiverId']?.toString();
    firstName = json['first_name'] ??
        json['firstName'] ??
        json['caller_name'] ??
        json['callerName'] ??
        json['receiver_name'] ??
        json['receiverName'] ??
        json['name'];
    lastName = json['last_name'] ?? json['lastName'] ?? '';
    avatar = json['avatar'] ??
        json['profile_image'] ??
        json['profileImage'] ??
        json['caller_profile_image'] ??
        json['callerProfileImage'] ??
        json['receiver_profile_image'] ??
        json['receiverProfileImage'] ??
        '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar'] = avatar;
    return data;
  }
}
