import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_theme.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.poppins().fontFamily,
  primaryColor: AppColors.darkPrimaryColor,
  scaffoldBackgroundColor: AppColors.darkScaffoldBackgroundColor,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimaryColor,
    secondary: AppColors.secondaryColor,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    surface: AppColors.darkCardColor,
    error: AppColors.errorColor,
  ),
  cardColor: AppColors.darkCardColor,
  dividerColor: AppColors.darkDividerColor,
  textTheme: AppTextTheme.darkTextTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
    color: AppColors.darkPrimaryColor,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkCardColor,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.darkBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.darkBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.darkPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorColor),
    ),
    hintStyle: TextStyle(color: AppColors.darkTextColorHint),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.darkPrimaryColor,
      side: const BorderSide(color: AppColors.darkPrimaryColor, width: 2.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.darkPrimaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkPrimaryColor,
      side: const BorderSide(color: AppColors.darkPrimaryColor, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
