

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
}