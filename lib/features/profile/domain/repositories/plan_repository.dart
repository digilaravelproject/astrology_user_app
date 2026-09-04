import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/core/constants/app_urls.dart';

class PlanRepository {
  final ApiClient apiClient;

  PlanRepository(this.apiClient);

  Future<ResponseModel> getPlans() async {
    return await apiClient.get(AppUrls.plans);
  }

  Future<ResponseModel> getPlanById(int id) async {
    return await apiClient.get('${AppUrls.plans}/$id');
  }

  Future<ResponseModel> upgradePlan(int id) async {
    return await apiClient.post(AppUrls.upgradePlans, data: {'plan_id': id});
  }

  Future<ResponseModel> verifyUpgrade({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    return await apiClient.post(AppUrls.upgradePlansVerify, data: {
      'razorpay_order_id': providerOrderId,
      'razorpay_payment_id': providerPaymentId,
      'razorpay_signature': signature,
    });
  }
}
