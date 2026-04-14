import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.feedback,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                AppText(
                  "How was your experience?",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                const SizedBox(height: 10),
                AppText(
                  "Your feedback helps us improve",
                  fontSize: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Iconsax.star_1_copy : Iconsax.star_1,
                          color: index < _rating ? Colors.amber : Colors.grey.shade300,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Tell us what you liked or how we can improve...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: "Submit Feedback",
                  onTap: () {
                    if (_rating == 0) {
                      Get.snackbar("Error", "Please provide a rating", backgroundColor: Colors.redAccent, colorText: Colors.white);
                      return;
                    }
                    if (_feedbackController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter your feedback", backgroundColor: Colors.redAccent, colorText: Colors.white);
                      return;
                    }
                    _controller.submitFeedback(_rating, _feedbackController.text.trim());
                  },
                ),
              ],
            ),
          ),
          Obx(() => _controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
