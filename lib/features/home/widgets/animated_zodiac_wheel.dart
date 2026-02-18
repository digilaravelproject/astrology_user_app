import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';

class AnimatedZodiacWheel extends StatefulWidget {
  const AnimatedZodiacWheel({super.key});

  @override
  State<AnimatedZodiacWheel> createState() => _AnimatedZodiacWheelState();
}

class _AnimatedZodiacWheelState extends State<AnimatedZodiacWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -100,
      right: -120,
      child: RotationTransition(
        turns: _controller,
        child: Opacity(
          opacity: 0.1,
          child: CustomImageWidget(
            imagePath: 'assets/images/zodiac_wheel.png',
            width: 420,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
