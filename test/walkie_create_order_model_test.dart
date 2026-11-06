import 'package:fgtracker/app/Model/walkie_create_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses nested create-order shape (current backend)', () {
    final res = WalkieCreateOrderResponseModel.fromJson({
      'status': true,
      'data': {
        'payment': {'id': 991, 'orderId': 'WT_1'},
        'razorpay': {
          'orderId': 'order_A',
          'amount': 79800,
          'currency': 'INR',
          'keyId': 'rzp_x'
        },
      },
    });
    expect(res.data?.payment?.id, 991);
    expect(res.data?.razorpay?.orderId, 'order_A');
    expect(res.data?.razorpay?.amount, 79800);
  });

  test('parses flat create-order shape (backend v2 doc)', () {
    final res = WalkieCreateOrderResponseModel.fromJson({
      'status': true,
      'data': {
        'paymentId': 89,
        'razorpayOrderId': 'order_NXK',
        'amount': 99.50,
        'currency': 'INR',
        'keyId': 'rzp_live_x',
        'pricing': {'finalAmount': 99.50},
      },
    });
    expect(res.data?.payment?.id, 89);
    expect(res.data?.razorpay?.orderId, 'order_NXK');
    expect(res.data?.razorpay?.amount, 9950); // converted to paise
    expect(res.data?.razorpay?.keyId, 'rzp_live_x');
    expect(res.data?.pricing?.finalAmount, 99.50);
  });
}
