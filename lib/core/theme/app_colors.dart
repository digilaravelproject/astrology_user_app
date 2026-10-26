import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Light theme colors - Updated to Peach/Coral/Burgundy Theme from image
  //static const Color primaryColor = Color(0xFFB51F49); // Deep Burgundy/Magenta
  static const Color primaryColor = Color(0xFF8B0D31); // Deep Burgundy/Magenta
  static const Color secondaryColor = Color(0xFFEF6A55); // Coral/Peach
  static const Color accentColor = Color(0xFFF78B75); // Lighter Coral/Peach
  static const Color lightPink = Color(0xFFFFEAE6); // Very Light Peach/Pink
  static const Color softPink = Color(0xFFFCD2C8); // Soft Peach/Pink
  static const Color deepPink = Color(0xFF8B0D31); // Deep Burgundy/Magenta
  static const Color goldAccent = Color(0xFFFFD700); // Gold for premium feel
  static const Color fieldBackground = Color(0xFFFFF9F9); // Warm light input background

  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color scaffoldBackgroundColor = Color(0xFFFFF5F4); // Very soft peach-white page background

  static const Color textColorPrimary = Color(0xFF2C1E1B); // Dark warm brown/charcoal
  static const Color textColorSecondary = Color(0xFF7D6763); // Muted warm grey
  static const Color textColorHint = Color(0xFFBCAAA4); // Light warm hint text

  static const Color borderColor = Color(0xFFFFDFD9); // Peach border
  static const Color dividerColor = Color(0xFFFFDFD9); // Peach divider

  // Dark theme colors - Matching Warm/Burgundy palette
  static const Color darkPrimaryColor = Color(0xFFEF6A55); // Coral/Peach for dark mode contrast
  static const Color darkSecondaryColor = Color(0xFFF78B75); // Lighter Coral/Peach
  static const Color darkAccentColor = Color(0xFFB51F49); // Deep Burgundy/Magenta

  static const Color darkBackgroundColor = Color(0xFF221614); // Dark warm charcoal
  static const Color darkCardColor = Color(0xFF2F201E); // Slightly lighter warm dark color for cards
  static const Color darkScaffoldBackgroundColor = Color(0xFF1E1210); // Dark background

  static const Color darkTextColorPrimary = Color(0xFFFFEAE6); // Light peach text
  static const Color darkTextColorSecondary = Color(0xFFD2BCAE); // Muted warm text
  static const Color darkTextColorHint = Color(0xFF9E8B83);

  static const Color darkBorderColor = Color(0xFF4C302B);
  static const Color darkDividerColor = Color(0xFF4C302B);

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
    colors: [secondaryColor, primaryColor],
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

  static const LinearGradient cardGradient = LinearGradient(
    colors: [primaryColor, accentColor,softPink],
    stops: [0.0, 1.0,1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );


}
