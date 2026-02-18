import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BackgroundType { zodiac, icons }

class CosmicBackground extends StatelessWidget {
  final BackgroundType type;
  final Color? color;
  final double opacity;

  const CosmicBackground({
    Key? key,
    this.type = BackgroundType.zodiac,
    this.color,
    this.opacity = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = AppColors.softPink.withOpacity(opacity);
    final iconColor = AppColors.softPink.withOpacity(opacity * 1.5);
    
    return Stack(
      children: [
        // 1. Primary atmospheric soft glows for "Wow" factor foundation
        Positioned(
          top: -150,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.softPink.withOpacity(0.12),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.softPink.withOpacity(0.08),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // 2. Layered celestial iconography with depth (varied opacity and scale)
        ...List.generate(12, (index) {
          final icons = [
            Icons.star_rounded,
            Icons.auto_awesome_rounded,
            Icons.brightness_4_rounded,
            Icons.flare_rounded,
            Icons.circle,
          ];
          
          // Deterministic "randomness" for performance
          final top = (index * 173.0) % 800;
          final left = (index * 137.0) % 400;
          final size = 12.0 + (index % 5) * 6;
          final opacity = 0.04 + (index % 3) * 0.03;
          final rotation = (index * 15.0) * (3.14 / 180);

          return Positioned(
            top: top,
            left: left,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  icons[index % icons.length],
                  size: size,
                  color: AppColors.softPink,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDecorativeIcon(IconData icon, double iconSize, Color iconColor, Color bubbleColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bubbleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}
