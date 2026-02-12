import 'package:flutter/material.dart';
import '../constants/image_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({Key? key, this.size = 120}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageConstants.logo),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
