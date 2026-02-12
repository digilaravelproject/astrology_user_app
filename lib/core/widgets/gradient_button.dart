import 'package:flutter/material.dart';

/// Reusable gradient button widget used throughout the app
/// Follows the Bhagwa & Red theme from login screen
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final double borderRadius;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.width,
    this.height = 52,
    this.borderRadius = 27,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF8F00), // Bhagwa
              Color(0xFFFF6D00), // Bhagwa
              Color(0xFFD32F2F), // Red (30%)
            ],
            stops: [0.0, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8F00).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
