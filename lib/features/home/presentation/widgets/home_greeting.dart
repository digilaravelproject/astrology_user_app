import 'package:flutter/material.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:get/get.dart';

class HomeGreeting extends StatelessWidget {
  final String? name;
  final String? greeting;

  const HomeGreeting({
    Key? key,
    this.name,
    this.greeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              greeting ?? AppStrings.hello,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E1A47).withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            const WavingEmoji(),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppText(
              name ?? AppStrings.guest,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF800000),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ],
        ),
      ],
    );
  }
}

class WavingEmoji extends StatefulWidget {
  const WavingEmoji({Key? key}) : super(key: key);

  @override
  State<WavingEmoji> createState() => _WavingEmojiState();
}

class _WavingEmojiState extends State<WavingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: (_controller.value - 0.5) * 0.4,
          child: AppText("👋".tr, fontSize: 20),
        );
      },
    );
  }
}
