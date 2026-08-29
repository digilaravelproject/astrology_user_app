import 'dart:async';
import 'package:astro_user/core/constants/app_urls.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<ResponseModel> sendOtp(String phone) async {
    return await _apiClient.post(AppUrls.sendOtp, data: {"phone": phone});
  }

  @override
  Future<ResponseModel> resendOtp(String phone) async {
    return await _apiClient.post(AppUrls.resendOtp, data: {"phone": phone});
  }

  @override
  Future<ResponseModel> updateProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.put(AppUrls.updateProfile(userId), data: data);
  }

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub signup success');
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    return const ResponseModel(isSuccess: true, message: 'Stub login success');
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    return await _apiClient.post(
      AppUrls.verifyOtp,
      data: {"phone": mobile, "otp": otp},
    );
  }

  @override
  Future<ResponseModel> logout() async {
    return await _apiClient.post(AppUrls.logout);
  }

  @override
  Future<ResponseModel> deleteAccount() async {
    return await _apiClient.delete(AppUrls.deleteAccount);
  }
}
