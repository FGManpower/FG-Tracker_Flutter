class WalkieVerifyPaymentResponseModel {
  final bool? status;
  final String? message;
  final dynamic data;

  const WalkieVerifyPaymentResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieVerifyPaymentResponseModel.fromJson(dynamic json) {
    if (json is! Map) return const WalkieVerifyPaymentResponseModel();
    final map = Map<String, dynamic>.from(json);
    return WalkieVerifyPaymentResponseModel(
      status: map['status'] as bool?,
      message: map['message']?.toString(),
      data: map['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data,
      };
}
