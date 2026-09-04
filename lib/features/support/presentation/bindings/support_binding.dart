import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/support/domain/repositories/support_repository.dart';
import 'package:astro_user/features/support/domain/usecases/get_faq_usecase.dart';
import 'package:astro_user/features/support/domain/usecases/get_payment_policy_usecase.dart';
import 'package:astro_user/features/support/domain/usecases/get_privacy_policy_usecase.dart';
import 'package:astro_user/features/support/domain/usecases/get_terms_and_conditions_usecase.dart';
import 'package:astro_user/features/support/presentation/controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupportRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => GetFAQUseCase(repository: Get.find<SupportRepository>()));
    Get.lazyPut(() => GetPrivacyPolicyUseCase(repository: Get.find<SupportRepository>()));
    Get.lazyPut(() => GetPaymentPolicyUseCase(repository: Get.find<SupportRepository>()));
    Get.lazyPut(() => GetTermsAndConditionsUseCase(repository: Get.find<SupportRepository>()));
    Get.lazyPut(() => SupportController(
          getFAQUseCase: Get.find<GetFAQUseCase>(),
          getPrivacyPolicyUseCase: Get.find<GetPrivacyPolicyUseCase>(),
          getPaymentPolicyUseCase: Get.find<GetPaymentPolicyUseCase>(),
          getTermsAndConditionsUseCase: Get.find<GetTermsAndConditionsUseCase>(),
        ));
  }
}
