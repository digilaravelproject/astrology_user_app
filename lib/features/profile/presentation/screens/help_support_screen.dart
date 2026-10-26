import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  String? _rawContent;
  List<String> _phones = [];
  List<String> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final content = await _controller.fetchCustomerSupport();
    if (content != null && mounted) {
      setState(() {
        _rawContent = content;
        _parseContent(content);
      });
    }
  }

  void _parseContent(String content) {
    // Basic regex to find emails and phone numbers
    final emailRegExp = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final phoneRegExp = RegExp(r'\+?[0-9][0-9\s-]{8,15}');

    _emails = emailRegExp.allMatches(content).map((m) => m.group(0)!).toList();
    _phones = phoneRegExp.allMatches(content).map((m) => m.group(0)!).toList();
    
    // De-duplicate
    _emails = _emails.toSet().toList();
    _phones = _phones.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.customerSupport,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _rawContent == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_rawContent == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText("Failed to load contact info".tr, color: Colors.grey),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepPink),
                  child: AppText("Retry".tr, color: Colors.white),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_emails.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText("Email Support".tr, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  ..._emails.map((email) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSupportOption(
                      icon: Iconsax.sms_copy,
                      title: "Email".tr,
                      subtitle: email,
                      onTap: () => _launchEmail(email),
                    ),
                  )),
                ],

                if (_phones.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText("Call Support".tr, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  ..._phones.map((phone) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSupportOption(
                      icon: Iconsax.call_copy,
                      title: "Call".tr,
                      subtitle: phone,
                      onTap: () => _launchPhone(phone),
                    ),
                  )),
                ],
                
                const SizedBox(height: 40),
                Center(
                  child: AppText("Available 24/7 for your help".tr,
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (!await launchUrl(url)) {
      Get.snackbar("Error", "Could not launch email app");
    }
  }

  void _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (!await launchUrl(url)) {
      Get.snackbar("Error", "Could not launch dialer");
    }
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.deepPink, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    subtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600]!,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
