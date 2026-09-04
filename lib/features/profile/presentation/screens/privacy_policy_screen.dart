import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/support/presentation/controllers/support_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();
    
    // Fetch privacy policy when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPrivacyPolicy();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.privacyPolicyProfile,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isPrivacyLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }

        final policyData = controller.privacyPolicyData.value;
        if (policyData == null || policyData.content.isEmpty) {
          return const Center(
            child: AppText("Privacy Policy is not available at the moment.".tr,
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HtmlWidget(
            policyData.content,
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        );
      }),
    );
  }
}
