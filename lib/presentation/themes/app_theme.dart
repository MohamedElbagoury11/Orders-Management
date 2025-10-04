import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class AppTheme {
  // Common gradient backgrounds used across the app
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 1, 88, 249),
      Color.fromARGB(255, 2, 188, 245),
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 1, 88, 249),
      Color.fromARGB(255, 2, 188, 245),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(26, 1, 88, 249), // 0.1 opacity
      Color.fromARGB(13, 2, 188, 245), // 0.05 opacity
      Color(0xFFFFFFFF), // white
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(26, 1, 88, 249), // 0.1 opacity
      Color.fromARGB(13, 2, 188, 245), // 0.05 opacity
      Color(0xFF121212), // dark background
    ],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 1, 88, 249),
      secondary: Color.fromARGB(255, 2, 188, 245),
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.black,
      background: AppColors.white,
      onBackground: AppColors.black,
    ),
    scaffoldBackgroundColor: AppColors.white,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.black,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.black,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 1, 88, 249),
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
    ),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 1, 88, 249),
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 1, 88, 249),
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 1, 88, 249), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
      ),
    ),
    // Custom theme extensions for consistent styling
    extensions: [
      CustomThemeExtension(
        primaryGradient: primaryGradient,
        surfaceGradient: surfaceGradient,
        backgroundGradient: backgroundGradient,
        cardBorderRadius: 16.0,
        cardElevation: 2.0,
        cardMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        iconContainerPadding: 12.0,
        iconContainerBorderRadius: 12.0,
        navigationCardAspectRatio: 1.1,
        navigationCardSpacing: 16.0,
        statCardPadding: 16.0,
        statCardBorderRadius: 16.0,
        welcomeSectionPadding: 24.0,
        welcomeSectionBorderRadius: 20.0,
        appBarPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        appBarIconContainerPadding: 12.0,
        appBarIconContainerBorderRadius: 12.0,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 1, 88, 249),
      secondary: Color.fromARGB(255, 2, 188, 245),
      surface: AppColors.darkSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkText,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 1, 88, 249),
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
          color: AppColors.white,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 1, 88, 249),
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 1, 88, 249),
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 1, 88, 249), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
      ),
    ),
    // Custom theme extensions for consistent styling
    extensions: [
      CustomThemeExtension(
        primaryGradient: primaryGradient,
        surfaceGradient: surfaceGradient,
        backgroundGradient: darkBackgroundGradient,
        cardBorderRadius: 16.0,
        cardElevation: 2.0,
        cardMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        iconContainerPadding: 12.0,
        iconContainerBorderRadius: 12.0,
        navigationCardAspectRatio: 1.1,
        navigationCardSpacing: 16.0,
        statCardPadding: 16.0,
        statCardBorderRadius: 16.0,
        welcomeSectionPadding: 24.0,
        welcomeSectionBorderRadius: 20.0,
        appBarPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        appBarIconContainerPadding: 12.0,
        appBarIconContainerBorderRadius: 12.0,
      ),
    ],
  );
}

// Custom theme extension to provide consistent styling values
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final LinearGradient primaryGradient;
  final LinearGradient surfaceGradient;
  final LinearGradient backgroundGradient;
  final double cardBorderRadius;
  final double cardElevation;
  final EdgeInsets cardMargin;
  final double iconContainerPadding;
  final double iconContainerBorderRadius;
  final double navigationCardAspectRatio;
  final double navigationCardSpacing;
  final double statCardPadding;
  final double statCardBorderRadius;
  final double welcomeSectionPadding;
  final double welcomeSectionBorderRadius;
  final EdgeInsets appBarPadding;
  final double appBarIconContainerPadding;
  final double appBarIconContainerBorderRadius;

  const CustomThemeExtension({
    required this.primaryGradient,
    required this.surfaceGradient,
    required this.backgroundGradient,
    required this.cardBorderRadius,
    required this.cardElevation,
    required this.cardMargin,
    required this.iconContainerPadding,
    required this.iconContainerBorderRadius,
    required this.navigationCardAspectRatio,
    required this.navigationCardSpacing,
    required this.statCardPadding,
    required this.statCardBorderRadius,
    required this.welcomeSectionPadding,
    required this.welcomeSectionBorderRadius,
    required this.appBarPadding,
    required this.appBarIconContainerPadding,
    required this.appBarIconContainerBorderRadius,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? surfaceGradient,
    LinearGradient? backgroundGradient,
    double? cardBorderRadius,
    double? cardElevation,
    EdgeInsets? cardMargin,
    double? iconContainerPadding,
    double? iconContainerBorderRadius,
    double? navigationCardAspectRatio,
    double? navigationCardSpacing,
    double? statCardPadding,
    double? statCardBorderRadius,
    double? welcomeSectionPadding,
    double? welcomeSectionBorderRadius,
    EdgeInsets? appBarPadding,
    double? appBarIconContainerPadding,
    double? appBarIconContainerBorderRadius,
  }) {
    return CustomThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardMargin: cardMargin ?? this.cardMargin,
      iconContainerPadding: iconContainerPadding ?? this.iconContainerPadding,
      iconContainerBorderRadius: iconContainerBorderRadius ?? this.iconContainerBorderRadius,
      navigationCardAspectRatio: navigationCardAspectRatio ?? this.navigationCardAspectRatio,
      navigationCardSpacing: navigationCardSpacing ?? this.navigationCardSpacing,
      statCardPadding: statCardPadding ?? this.statCardPadding,
      statCardBorderRadius: statCardBorderRadius ?? this.statCardBorderRadius,
      welcomeSectionPadding: welcomeSectionPadding ?? this.welcomeSectionPadding,
      welcomeSectionBorderRadius: welcomeSectionBorderRadius ?? this.welcomeSectionBorderRadius,
      appBarPadding: appBarPadding ?? this.appBarPadding,
      appBarIconContainerPadding: appBarIconContainerPadding ?? this.appBarIconContainerPadding,
      appBarIconContainerBorderRadius: appBarIconContainerBorderRadius ?? this.appBarIconContainerBorderRadius,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      primaryGradient: primaryGradient,
      surfaceGradient: surfaceGradient,
      backgroundGradient: backgroundGradient,
      cardBorderRadius: cardBorderRadius,
      cardElevation: cardElevation,
      cardMargin: cardMargin,
      iconContainerPadding: iconContainerPadding,
      iconContainerBorderRadius: iconContainerBorderRadius,
      navigationCardAspectRatio: navigationCardAspectRatio,
      navigationCardSpacing: navigationCardSpacing,
      statCardPadding: statCardPadding,
      statCardBorderRadius: statCardBorderRadius,
      welcomeSectionPadding: welcomeSectionPadding,
      welcomeSectionBorderRadius: welcomeSectionBorderRadius,
      appBarPadding: appBarPadding,
      appBarIconContainerPadding: appBarIconContainerPadding,
      appBarIconContainerBorderRadius: appBarIconContainerBorderRadius,
    );
  }
} 