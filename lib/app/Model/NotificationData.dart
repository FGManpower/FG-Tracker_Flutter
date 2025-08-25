class NotificationRes {
  bool status;
  String message;
  Map<String, List<NotificationData>> response;

  NotificationRes(
      {required this.status, required this.message, required this.response});

  factory NotificationRes.fromJson(Map<String, dynamic> json) {
    var responseMap = Map<String, dynamic>.from(json['response']);
    var response = responseMap.map((key, value) {
      List<NotificationData> items = List<NotificationData>.from(
          value.map((item) => NotificationData.fromJson(item)));
      return MapEntry(key, items);
    });

    return NotificationRes(
      status: json['status'],
      message: json['message'],
      response: response,
    );
  }
}

class NotificationData {
  int? messageId;
  String? date;
  String? time;
  String? title;
  String? body;
  int? parameterIndexId;
  int? parameterLabourId;
  int? parameterEmployerId;
  int? parameterChildJobId;
  int? parameterParentJobId;
  String? parameterDate;
  String? parameterTime;
  String? parameterDateTime;
  String? parameterOfferType;
  String? parameterJobType;
  String? parameterRole;
  String? parameterScreenName;

  NotificationData(
      {this.messageId,
      this.date,
      this.time,
      this.title,
      this.body,
      this.parameterIndexId,
      this.parameterLabourId,
      this.parameterEmployerId,
      this.parameterChildJobId,
      this.parameterParentJobId,
      this.parameterDate,
      this.parameterTime,
      this.parameterDateTime,
      this.parameterOfferType,
      this.parameterJobType,
      this.parameterRole,
      this.parameterScreenName});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      messageId: json['message_id'],
      date: json['date'],
      time: json['time'],
      title: json['title'],
      body: json['body'],
      parameterIndexId: json['parameter_index_id'],
      parameterLabourId: json['parameter_labour_id'],
      parameterEmployerId: json['parameter_employer_id'],
      parameterChildJobId: json['parameter_child_job_id'],
      parameterParentJobId: json['parameter_parent_job_id'],
      parameterDate: json['parameter_date'],
      parameterTime: json['parameter_time'],
      parameterDateTime: json['parameter_date_time'],
      parameterOfferType: json['parameter_offer_type'],
      parameterJobType: json['parameter_job_type'],
      parameterRole: json['parameter_role'],
      parameterScreenName: json['parameter_screen_name'],
    );
  }
}
