import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/support/presentation/controllers/support_controller.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();
    
    // Fetch terms and conditions when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTermsAndConditions();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.termsAndConditions,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isTermsLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }

        final termsData = controller.termsAndConditionsData.value;
        if (termsData == null || termsData.content.isEmpty) {
          return const Center(
            child: AppText(
              "Terms and Conditions are not available at the moment.",
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HtmlWidget(
            termsData.content,
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
