import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';
import '../domain/models/user_model.dart';
import '../../../routes/route_helper.dart';
import '../../language/controllers/localization_controller.dart';
import '../domain/services/auth_service.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/services/network/websocket_service.dart';
import '../../../core/services/fcm_notification_service.dart';
import '../../../core/services/foreground_task_service.dart';


class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;


  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required GetUserInfoUseCase getUserInfoUseCase,
    required SendOtpUseCase sendOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _getUserInfoUseCase = getUserInfoUseCase,
        _sendOtpUseCase = sendOtpUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteAccountUseCase = deleteAccountUseCase;


  final isLoading = false.obs;
  final currentMobile = ''.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  final selectedGender = ''.obs;

  Timer? _resendTimer;
  final resendTimerSeconds = 30.obs;
  final canResendOtp = false.obs;

  void startResendTimer() {
    _resendTimer?.cancel();
    resendTimerSeconds.value = 30;
    canResendOtp.value = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimerSeconds.value > 0) {
        resendTimerSeconds.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  void cancelResendTimer() {
    _resendTimer?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _checkLoginStatusUseCase.execute();
    if (isLoggedIn) {
      final user = await _getUserInfoUseCase.execute();
      if (user != null) currentUser.value = user;
    }
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final user = await _registerUseCase.execute(
        nameController.text.trim(),
        mobileController.text.trim(),
      );

      if (user != null) {
        currentUser.value = user;
        currentMobile.value = mobileController.text.trim();
        startResendTimer();
        Get.toNamed(RouteHelper.getOtpRoute());
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('OTP sent to your mobile number');
        });
      } else {
        CustomSnackbar.showError('Signup failed. Please try again.');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'Signup failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    print('Login called for Send OTP');
    
    try {
      isLoading.value = true;
      
      final mobile = mobileController.text.trim();
      final responseModel = await _sendOtpUseCase.execute(mobile);

      if (responseModel != null) {
        currentMobile.value = mobile;
        startResendTimer();
        print('Navigating to OTP Screen');
        Get.toNamed(RouteHelper.getOtpRoute());
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('OTP sent successfully');
        });
      } else {
        CustomSnackbar.showError('Failed to send OTP. Please try again.');
      }
      
    } catch (e) {
      print('Login error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value && resendTimerSeconds.value > 0) return;
    print('Resend OTP called');
    
    try {
      isLoading.value = true;
      
      final responseModel = await _resendOtpUseCase.execute(currentMobile.value);

      if (responseModel != null) {
        CustomSnackbar.showSuccess('OTP resent successfully');
        startResendTimer();
      } else {
        CustomSnackbar.showError('Failed to resend OTP. Please try again.');
      }
      
    } catch (e) {
      print('Resend OTP error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      CustomSnackbar.showError('Please enter OTP');
      return;
    }

    try {
      isLoading.value = true;
      
      final user = await _verifyOtpUseCase.execute(
        currentMobile.value, // populated from login() or signup()
        otpController.text.trim(),
      );

      if (user != null) {
        currentUser.value = user;
        otpController.clear();

        CustomSnackbar.showSuccess('OTP Verified!');
        //Get.offAllNamed(RouteHelper.getRegistrationSuccessRoute());
        
        if (user.profileCompleted == true) {
          Get.find<WebSocketService>().connect();
          FCMNotificationService.registerDeviceToken(null);
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        } else {
          // Still connect if they successfully logged in, even if profile is pending
          Get.find<WebSocketService>().connect();
          FCMNotificationService.registerDeviceToken(null);
          Get.offAllNamed(RouteHelper.getRegistrationSuccessRoute());
        }
      } else {
        CustomSnackbar.showError('Invalid OTP or Verification Failed.');
      }
    } catch (e) {
      print('OTP Verification error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'An error occurred during verification.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required DateTime dob,
    required TimeOfDay tob,
    required String placeOfBirth,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;
      if (userId == null) {
        CustomSnackbar.showError('User session invalid');
        return;
      }

      final dobString = "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
      final tobString = "${tob.hour.toString().padLeft(2, '0')}:${tob.minute.toString().padLeft(2, '0')}";
      
      final localizationController = Get.find<LocalizationController>();
      final String selectedLang = localizationController.languages[localizationController.selectedIndex].languageName;

      final Map<String, dynamic> data = {
        "name": nameController.text.trim(),
        "gender": selectedGender.value,
        "date_of_birth": dobString,
        "time_of_birth": tobString,
        "place_of_birth": placeOfBirth,
        "languages": [selectedLang],
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      };

      final updatedUser = await _updateProfileUseCase.execute(userId, data);
      
      if (updatedUser != null) {
        currentUser.value = updatedUser;
        await Get.find<AuthService>().saveUserInfo(updatedUser);
        CustomSnackbar.showSuccess('Profile updated successfully');
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        CustomSnackbar.showError('Failed to update profile');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'Failed to update profile');
    } finally {
       isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      print('AuthController.logout() called');
      try {
        await FCMNotificationService.removeDeviceToken();
      } catch (_) {}
      final response = await _logoutUseCase.execute();
      
      currentUser.value = null;
      currentMobile.value = '';
      mobileController.clear();
      otpController.clear();
      nameController.clear();
      
      try {
        Get.find<WebSocketService>().disconnect();
        ForegroundTaskService.stopService();
      } catch (_) {}
      await Get.find<AuthService>().clearUserInfo();

      Get.offAllNamed(RouteHelper.getLoginRoute());
      
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess('Logged out successfully');
      });
    } catch (e) {
      print('Logout error: $e');
      currentUser.value = null;
      try {
        await Get.find<AuthService>().clearUserInfo();
      } catch (_) {}
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> deleteAccount() async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              const AppText(
                'Delete Account',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E1A47),
              ),
              const SizedBox(height: 12),
              AppText(
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: AppText('Cancel', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        try {
                          isLoading.value = true;
                          final response = await _deleteAccountUseCase.execute();
                          
                          if (response.isSuccess) {
                            currentUser.value = null;
                            currentMobile.value = '';
                            mobileController.clear();
                            otpController.clear();
                            nameController.clear();
                            
                            Get.find<WebSocketService>().disconnect();
                            ForegroundTaskService.stopService();
                            
                            Get.offAllNamed(RouteHelper.getLoginRoute());
                            
                            Future.delayed(const Duration(milliseconds: 300), () {
                              CustomSnackbar.showSuccess(response.message ?? 'Account deleted successfully');
                            });
                          } else {
                            CustomSnackbar.showError(response.message ?? 'Failed to delete account');
                          }
                        } catch (e) {
                          print('Delete account error: $e');
                          CustomSnackbar.showError('An error occurred during account deletion');
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Delete', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? validateName(String? value) {

    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }
}


class LoginUseCase {
  final AuthService _authService;

  LoginUseCase(this._authService);

  Future<UserModel?> execute(String mobile) async {
    final response = await _authService.login(mobile);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    } else {
      throw Exception(response.message);
    }
  }
}


class VerifyOtpUseCase {
  final AuthService _authService;

  VerifyOtpUseCase(this._authService);

  Future<UserModel?> execute(String mobile, String otp) async {
    final response = await _authService.verifyOtp(mobile, otp);
    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        final Map<String, dynamic> userJson = bodyMap['user'] ?? bodyMap;
        final token = response.token ?? '';
        
        final userModel = UserModel.fromJson(userJson);
        
        if (token.isNotEmpty) {
          await _authService.saveUserToken(token);
        }
        
        if (userModel.profileCompleted == true) {
          await _authService.saveUserInfo(userModel);
        }
        
        return userModel;
      } catch (e) {
        print('Error parsing VerifyOtpResponse: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception(response.message);
    }
  }
}



class LogoutUseCase {
  final AuthService _authService;

  LogoutUseCase(this._authService);

  Future<ResponseModel> execute() async {
    return await _authService.logout();
  }
}



class CheckLoginStatusUseCase {
  final AuthService _authService;

  CheckLoginStatusUseCase(this._authService);

  Future<bool> execute() async {
    return await _authService.isLoggedIn();
  }
}



class GetUserInfoUseCase {
  final AuthService _authService;

  GetUserInfoUseCase(this._authService);

  Future<UserModel?> execute() async {
    return await _authService.getUserInfo();
  }
}

class RegisterUseCase {
  final AuthService _authService;

  RegisterUseCase(this._authService);

  Future<UserModel?> execute(String name, String mobile) async {
    final response = await _authService.signup(name, mobile);

    if (response.isSuccess && response.body != null) {
      try {
        return UserModel.fromJson(response.body);
      } catch (e) {
        print('Error parsing user data: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception(response.message);
    }
  }
}

class SendOtpUseCase {
  final AuthService _authService;

  SendOtpUseCase(this._authService);

  Future<SendOtpModel?> execute(String mobile) async {
    final response = await _authService.sendOtp(mobile);

    // Some APIs might wrap body in {"data": ...} while others return just the data.
    // Assuming response.body corresponds to the "data" field from standard ResponseModel handling
    if (response.isSuccess && response.body != null) {
      try {
        return SendOtpModel.fromJson(response.body);
      } catch (e) {
        print('Error parsing SendOtpModel data: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception(response.message);
    }
  }
}

class ResendOtpUseCase {
  final AuthService _authService;

  ResendOtpUseCase(this._authService);

  Future<SendOtpModel?> execute(String mobile) async {
    final response = await _authService.resendOtp(mobile);

    // Some APIs might wrap body in {"data": ...} while others return just the data.
    // Assuming response.body corresponds to the "data" field from standard ResponseModel handling
    if (response.isSuccess && response.body != null) {
      try {
        return SendOtpModel.fromJson(response.body);
      } catch (e) {
        print('Error parsing SendOtpModel data: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception(response.message);
    }
  }
}

class UpdateProfileUseCase {
  final AuthService _authService;

  UpdateProfileUseCase(this._authService);

  Future<UserModel?> execute(int userId, Map<String, dynamic> data) async {
    final response = await _authService.updateProfile(userId, data);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        final Map<String, dynamic> userJson = bodyMap['user'] ?? bodyMap;
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing UpdateProfile data: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception(response.message);
    }
  }
}

class DeleteAccountUseCase {
  final AuthService _authService;

  DeleteAccountUseCase(this._authService);

  Future<ResponseModel> execute() async {
    return await _authService.deleteAccount();
  }
}




