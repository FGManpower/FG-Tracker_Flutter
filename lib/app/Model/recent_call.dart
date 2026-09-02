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
    id = json['id'];
    contact = json['contact'] != null
        ? RecentContact.fromJson(json['contact'])
        : null;
    type = json['type'];
    direction = json['direction'];
    status = json['status'];
    calledAt = json['called_at'];
    date = json['date'];
    time = json['time'];
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
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    avatar = json['avatar'];
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
