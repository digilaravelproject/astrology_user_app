import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/auth/data/models/user_model.dart';

abstract class AuthServiceInterface {
  Future<ResponseModel> sendOtp(String phone);
  Future<ResponseModel> resendOtp(String phone);
  Future<ResponseModel> updateProfile(int userId, Map<String, dynamic> data);
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
  Future<ResponseModel> logout();
  Future<ResponseModel> deleteAccount();
  Future<void> saveUserToken(String userToken);

  Future<void> saveUserInfo(UserModel user);
  Future<void> clearUserInfo();
  Future<bool> isLoggedIn();
  Future<UserModel?> getUserInfo();
}
