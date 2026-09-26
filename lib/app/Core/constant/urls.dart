import 'const_res.dart';
export 'const_res.dart';

class Urls {
  ///------------------------ Urls ------------------------///
  static const String sendOtp = '${ConstRes.aBaseUrl}send-otp';
  static const String verifyOtp = '${ConstRes.aBaseUrl}verify-otp';
  static const String logOut = '${ConstRes.aBaseUrl}logOut';
  static const String resendOtp = '${ConstRes.aBaseUrl}resendOtp';
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

  ///------------------------ Params ------------------------///
  static const String rtcUserName = 'fgtracker';
  static const String rtcCredential = 'FGM_Tracker@2025';
  static const List rtcUrl = [
    'turn:89.116.23.2:3478?transport=udp',
    'turn:89.116.23.2:3478?transport=tcp',
    'turns:89.116.23.2:443?transport=tcp',
  ];
}
