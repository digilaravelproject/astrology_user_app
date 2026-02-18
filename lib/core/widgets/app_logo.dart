import 'package:flutter/material.dart';
import '../constants/image_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageConstants.logo,
      height: size,
      width: size,
      fit: BoxFit.contain,
    );
  }
}
