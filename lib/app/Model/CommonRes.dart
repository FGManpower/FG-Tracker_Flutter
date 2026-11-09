class CommonResponse {
  bool? status;
  String? message;
  dynamic data;
  String? rawStatus;

  CommonResponse({
    this.status,
    this.message,
    this.data,
    this.rawStatus,
  });

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final s = value.toLowerCase().trim();
      if (s == 'true' ||
          s == 'yes' ||
          s == '1' ||
          s == 'success' ||
          s == 'ok' ||
          s == 'active' ||
          s == 'deactivated') {
        return true;
      }
      if (s == 'false' ||
          s == 'no' ||
          s == '0' ||
          s == 'failed' ||
          s == 'error' ||
          s == 'inactive') {
        return false;
      }
    }
    return null;
  }

  CommonResponse.fromJson(dynamic input) {
    if (input is! Map) {
      status = input == true;
      message = input?.toString();
      return;
    }
    final json = Map<String, dynamic>.from(input);
    rawStatus = json['status']?.toString();
    status = _parseBool(json['status'] ?? json['success'] ?? json['ok']);
    message = (json['message'] ?? json['msg'] ?? json['error'])?.toString();
    data = json['data'];
  }

  bool get isSuccess => status == true;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['status'] = status;
    out['message'] = message;
    if (data != null) out['data'] = data;
    if (rawStatus != null) out['rawStatus'] = rawStatus;
    return out;
  }
}
