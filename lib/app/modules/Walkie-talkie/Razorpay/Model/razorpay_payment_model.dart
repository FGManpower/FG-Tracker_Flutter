import 'package:fgtracker/app/Core/constant/const_res.dart';

class RazorpayPaymentOptions {
  final String key;
  final num amount; // In INR (will be converted to paise: amount * 100)
  final String name;
  final String description;
  final String? orderId;
  final String? prefillContact;
  final String? prefillEmail;
  final String? prefillName;
  final String currency;
  final String themeColor;
  final Map<String, dynamic>? notes;

  const RazorpayPaymentOptions({
    this.key = ConstRes.activePaymentKey, // Dev key active from ConstRes
    required this.amount,
    this.name = 'FG Tracker',
    required this.description,
    this.orderId,
    this.prefillContact,
    this.prefillEmail,
    this.prefillName,
    this.currency = 'INR',
    this.themeColor = '#5B4DF5',
    this.notes,
  });

  /// Convert to Razorpay SDK Map format
  Map<String, dynamic> toMap() {
    final int amountInPaise = (amount * 100).round();
    final Map<String, dynamic> map = {
      'key': key,
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'currency': currency,
      'theme': {
        'color': themeColor,
      },
      'prefill': {
        if (prefillContact != null && prefillContact!.isNotEmpty)
          'contact': prefillContact,
        if (prefillEmail != null && prefillEmail!.isNotEmpty)
          'email': prefillEmail,
        if (prefillName != null && prefillName!.isNotEmpty)
          'name': prefillName,
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      'send_sms_hash': true,
    };

    if (orderId != null && orderId!.isNotEmpty) {
      map['order_id'] = orderId;
    }

    if (notes != null && notes!.isNotEmpty) {
      map['notes'] = notes;
    }

    return map;
  }
}

enum PaymentProcessStatus {
  initial,
  ready,
  processing,
  success,
  failed,
  cancelled,
}

class RazorpayPaymentResult {
  final PaymentProcessStatus status;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;
  final dynamic rawData;

  const RazorpayPaymentResult({
    required this.status,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
    this.rawData,
  });

  bool get isSuccess => status == PaymentProcessStatus.success;
  bool get isFailed => status == PaymentProcessStatus.failed;
  bool get isCancelled => status == PaymentProcessStatus.cancelled;
}
