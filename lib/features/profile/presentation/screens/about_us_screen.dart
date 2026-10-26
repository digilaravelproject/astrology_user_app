import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  String? _content;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final content = await _controller.fetchAboutUs();
    if (mounted) {
      setState(() {
        _content = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.aboutUs,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _content == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_content == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Failed to load content".tr),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: Text("Retry".tr),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HtmlWidget(
            _content!,
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
