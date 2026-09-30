import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ConstRes {
  ///------------------------ Backend urls and key ------------------------///

  // static const String development = 'http://192.168.1.21:4000/'; // Development
  static const String production = 'http://fgtracker.in:3000/'; //Prod
  static const String aBaseUrl = '${production}api/';
  static const String aImageBaseUrl = production;
  static String socketUrl = "http://fgtracker.in:3000"; //pro
  // static const String socketUrl = "http://192.168.1.21:4000"; //dev
  static String DeepLink_Url = "https://fgtracker.in";
  static String gMapApiKey = "AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q";

  ///------------------------ Payment Gateway Credentials ------------------------///
  // Razorpay Test & Production Keys
  static const String razorpayTestKey = 'rzp_test_ThoFEwOj0pMgTH';
  static const String razorpaySecretKey = '';
  static const String razorpayLiveKey = '';

  // Cashfree Credentials (for reference)
  static const String paymentAppIdProd = 'rzp_test_ThoFEwOj0pMgTH';
  static const String paymentSecretKeyProd = 'E0GZbrpaTrM37FAIJk8NXrKR';
  static const String paymentAppIdDev = 'rzp_test_ThoFEwOj0pMgTH';
  static const String paymentSecretKeyDev = 'E0GZbrpaTrM37FAIJk8NXrKR';

  // Active Key for Razorpay Package
  static const String activePaymentKey = razorpayTestKey;
  static const String activePaymentSecret = razorpaySecretKey;
  static const bool isPaymentLive = false;

  static BaseOptions networkOptions = BaseOptions(
    baseUrl: aBaseUrl,
  );

  final Dio _dio = Dio();
  ConstRes() {
    BaseOptions options = BaseOptions(
      baseUrl: aBaseUrl,
    );
    _dio.options = options;
    _dio.interceptors.add(PrettyDioLogger());
  }
  Dio get sendRequest => _dio;
}
