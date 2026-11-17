import 'const_res.dart';
export 'const_res.dart';

class Urls {
  ///------------------------ Urls ------------------------///
  static const String sendOtp = '${ConstRes.aBaseUrl}send-otp';
  static const String verifyOtp = '${ConstRes.aBaseUrl}verify-otp';
  static const String logOut = '${ConstRes.aBaseUrl}logOut';
  static const String deleteAccount = '${ConstRes.aBaseUrl}delete-account';
  static const String resendOtp = '${ConstRes.aBaseUrl}resendOtp';

  // v2: send-otp returns nextStep / otpCharge for non-India numbers
  static const String v2SendOtp = '${ConstRes.aBaseUrl}v2/send-otp';
  static const String v2ResendOtp = '${ConstRes.aBaseUrl}v2/resend-otp';
  static const String v2VerifyOtp = '${ConstRes.aBaseUrl}v2/verify-otp';
  static const String otpChargeConfig =
      '${ConstRes.aBaseUrl}v2/otp-charge/config';
  static const String otpChargeCreateOrder =
      '${ConstRes.aBaseUrl}v2/otp-charge/create-order';
  static const String otpChargePaymentSuccess =
      '${ConstRes.aBaseUrl}v2/otp-charge/payment-success';
  static const String otpChargePaymentFailed =
      '${ConstRes.aBaseUrl}v2/otp-charge/payment-failed';
  // Logged in: OTP price for the user's own number (side-menu screen)
  static const String otpChargeMyRate =
      '${ConstRes.aBaseUrl}v2/otp-charge/my-rate';
  static const String updateProfile = '${ConstRes.aBaseUrl}updateProfile';
  static const String banner = '${ConstRes.aBaseUrl}banners';
  static const String getAllGroup = '${ConstRes.aBaseUrl}get-all-group';
  static const String recentCallHistory = '${ConstRes.aBaseUrl}history'
      '';
  static const String allGroupMembers = '${ConstRes.aBaseUrl}all-group-members';
  static const String usersWithinRadius =
      '${ConstRes.aBaseUrl}users-within-radius';
  static const String userWithinRadiusFallback =
      '${ConstRes.aBaseUrl}user-within-radius';
  static const String initialize = '${ConstRes.aBaseUrl}initialize';
  static const String walkiePlans = '${ConstRes.aBaseUrl}walkie/plans';
  static const String walkieEligibleCoupons =
      '${ConstRes.aBaseUrl}walkie/coupons/eligible';
  static const String walkieApplyCoupon =
      '${ConstRes.aBaseUrl}walkie/coupons/apply';

  static const String walkieOverview = '${ConstRes.aBaseUrl}walkie/overview';
  static const String walkieOrderSummary =
      '${ConstRes.aBaseUrl}walkie/orders/summary';
  static const String walkieCreateOrder =
      '${ConstRes.aBaseUrl}walkie/payment/create-order';
  static const String walkieVerifyPayment =
      '${ConstRes.aBaseUrl}walkie/payment/verify';
  static const String callingStatus = '${ConstRes.aBaseUrl}calling-status';
  static const String walkieUpdateMemberSubscription =
      '${ConstRes.aBaseUrl}walkie/update-member-subscription';

  static const String walkieChannels = '${ConstRes.aBaseUrl}walkie/channels';
  static String walkieChannelNotifications(dynamic groupId) =>
      '${ConstRes.aBaseUrl}walkie/channels/$groupId/notifications';
  static const String walkieActiveChannel =
      '${ConstRes.aBaseUrl}walkie/active-channel';

  // Package Pricing (contract: docs/packages/02_backend_requirements.md)
  static const String packages = '${ConstRes.aBaseUrl}packages';

  static const String createStatus = "status/create";
  static const String statusFeed = "status/feed";
  static const String myStatus = "status/my-status";
  static String viewStatus(int id) => "status/$id/view";
  static String replyStatus(int id) => "status/$id/reply";
  static String deleteStatus(int id) => "status/$id";

  ///------------------------ WebRTC TURN / STUN Configuration ------------------------///
  // AWS Production LiveKit TURN Credentials (Mumbai ap-south-1)
  static const String _awsRtcUserName = 'API_fgtracker_sfu_2026';
  static const String _awsRtcCredential =
      'SEC_livekit_prod_7f8a9b2c3d4e5f6a7b8c9d0e1f2a3b4c';
  static const List<String> _awsRtcUrl = [
    'stun:sfu.fgtracker.fgmanpower.co.in:3478',
    'turn:sfu.fgtracker.fgmanpower.co.in:3478?transport=udp',
    'turn:sfu.fgtracker.fgmanpower.co.in:3478?transport=tcp',
  ];

  // Hostinger VPS Coturn Credentials (Testing / Staging)
  static const String _vpsRtcUserName = 'fgtracker';
  static const String _vpsRtcCredential = 'FGM_Tracker@2025';
  static const List<String> _vpsRtcUrl = [
    'turn:89.116.23.2:3478?transport=udp',
    'turn:89.116.23.2:3478?transport=tcp',
    'turns:89.116.23.2:443?transport=tcp',
  ];

  /// Active WebRTC Credentials (selected by ConstRes.isProduction)
  static const String rtcUserName =
      ConstRes.isProduction ? _awsRtcUserName : _vpsRtcUserName;
  static const String rtcCredential =
      ConstRes.isProduction ? _awsRtcCredential : _vpsRtcCredential;
  static const List rtcUrl =
      ConstRes.isProduction ? _awsRtcUrl : _vpsRtcUrl;

  ///------------------------ LiveKit SFU Endpoints ------------------------///
  static const String livekitToken = '${ConstRes.aBaseUrl}calls/livekit-token';
  static const String livekitWsUrl = 'wss://sfu.fgtracker.fgmanpower.co.in';
}
