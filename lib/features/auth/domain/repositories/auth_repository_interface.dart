import '../../../../core/services/network/response_model.dart';

abstract class AuthRepositoryInterface {
  Future<ResponseModel> sendOtp(String phone);
  Future<ResponseModel> resendOtp(String phone);
  Future<ResponseModel> updateProfile(int userId, Map<String, dynamic> data);
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
}