import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors - Updated to Pink Theme
  static const Color primaryColor = Color(0xFFE91E63); // Pink Primary
  static const Color secondaryColor = Color(0xFFEC407A); // Pink Secondary
  static const Color accentColor = Color(0xFFF06292); // Pink Accent
  static const Color lightPink = Color(0xFFFCE4EC); // Very Light Pink
  static const Color softPink = Color(0xFFF8BBD0); // Soft Pink
  static const Color deepPink = Color(0xFFC2185B); // Deep Pink
  static const Color goldAccent = Color(0xFFFFD700); // Gold for premium feel
  static const Color fieldBackground = Color(0xFFF9F9F9); // Light off-white for inputs

  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color scaffoldBackgroundColor = Colors.white;

  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Color textColorHint = Color(0xFFBDBDBD);

  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFFEC407A); // Pink for dark mode
  static const Color darkSecondaryColor = Color(0xFFF06292); // Lighter pink
  static const Color darkAccentColor = Color(0xFFFFD54F); // Amber-light for contrast

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkScaffoldBackgroundColor = Color(0xFF121212);

  static const Color darkTextColorPrimary = Color(0xFFFFFFFF);
  static const Color darkTextColorSecondary = Color(0xFFB3B3B3);
  static const Color darkTextColorHint = Color(0xFF888888);

  static const Color darkBorderColor = Color(0xFF333333);
  static const Color darkDividerColor = Color(0xFF333333);

  // Common colors
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color warningColor = Color(0xFFFFA000); // Amber
  static const Color infoColor = Color(0xFF1976D2); // Blue
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Pink Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    stops: [0.0, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient pinkWhiteGradient = LinearGradient(
    colors: [Colors.white, lightPink, primaryColor],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient verticalGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient pinkWhiteMixGradient = LinearGradient(
    colors: [
      primaryColor,
      Colors.white,
    ],
    stops: const [0.8, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
