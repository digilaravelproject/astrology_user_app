

class AppUrls {
  static String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com";
  static const String baseImageUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/storage/app/public/";
  static String sendOtp = "/api/v1/user/send-otp";
  static String verifyOtp = "/api/v1/user/verify-otp";
  static String resendOtp = "/api/v1/user/resend-otp";
  static String updateProfile(int id) => "/api/v1/user/profile/$id";
  static String updateProfilePhoto = "/api/v1/user/profile/photo";
  static String getProfile(int id) => "/api/v1/user/profile/$id";
  static String updateProfileInApp = "/api/v1/user/profileInAppUpdate";
  static String remedies = "/api/v1/user/remedies";
  static const String blogs = '/api/v1/user/blogs';
  static const String astrologers = '/api/v1/user/astrologers';
  static String getAstrologerDetails(int id) => '/api/v1/user/astrologers/$id';
  static const String wallet = '/api/v1/user/wallet';
  static const String walletTopup = '/api/v1/user/wallet/topup';
  static const String walletTopupVerify = '/api/v1/user/wallet/topup/verify';
  static const String walletTransactions = '/api/v1/user/wallet/transactions';
  static const String matrimonyProfile = '/api/v1/user/matrimony/profile';
  static const String getMatrimonyProfile = '/api/v1/user/matrimony/profiles';
  static String getMatrimonyProfileDetails(int id) => '/api/v1/user/matrimony/profiles/$id';
  static String matrimonySearch(String query) => '/api/v1/user/matrimony/search?q=$query';


  static const String deleteAccount = '/api/v1/user/delete-account';
  static const String logout = '/api/v1/user/logout';

  static const String following = '/api/v1/user/following';
  static const String plans = '/api/v1/user/plans';
  static const String upgradePlans = '/api/v1/user/plans/upgrade';
  static const String upgradePlansVerify = '/api/v1/user/plans/upgrade/verify';
}