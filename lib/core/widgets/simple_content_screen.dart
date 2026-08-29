import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import 'custom_app_bar.dart';

class SimpleContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const SimpleContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: title, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AppText(
          content,
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
