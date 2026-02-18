import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_theme.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.poppins().fontFamily,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    surface: AppColors.cardColor,
    error: AppColors.errorColor,
  ),
  cardColor: AppColors.cardColor,
  dividerColor: AppColors.dividerColor,
  textTheme: AppTextTheme.lightTextTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    iconTheme: const IconThemeData(color: AppColors.primaryColor),
    actionsIconTheme: const IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: const TextStyle(
      color: AppColors.primaryColor,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.softPink.withOpacity(0.1),
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorColor),
    ),
    hintStyle: TextStyle(color: AppColors.textColorHint),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        fontSize: 16,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      side: const BorderSide(color: AppColors.primaryColor, width: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
