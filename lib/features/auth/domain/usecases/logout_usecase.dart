import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/auth/data/datasources/auth_service_interface.dart';

class LogoutUseCase {
  final AuthServiceInterface service;

  LogoutUseCase({required this.service});

  Future<void> execute() async {
    print('LogoutUseCase.execute() called');
    await service.logout();
    print('LogoutUseCase.execute() completed');
  }
}
