import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Steam blue + Valorant red, the same look as the PrelimExam shop,
/// applied to every screen (light and dark).
class AppTheme {
  // Steam Blue
  static const Color steamBlue = Color(0xFF00ADFF);

  // Valorant Red
  static const Color valorantRed = Color(0xFFFF4654);

  // Steam Dark
  static const Color steamDark = Color(0xFF171A21);

  // Valorant Dark Maroon
  static const Color valorantDark = Color(0xFFBA3A46);

  static const Color success = Color(0xFF2EBD6B);

  static ThemeData lightTheme = _build(Brightness.light);
  static ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: steamBlue,
      brightness: brightness,
    ).copyWith(secondary: valorantRed, error: valorantRed);

    final base = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.rajdhaniTextTheme(base),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0xFF22252F)
            : Colors.white.withValues(alpha: .94),
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: valorantRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade500,
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: buttonShape,
          textStyle: GoogleFonts.rajdhani(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: buttonShape,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: valorantRed,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? const Color(0xFF2B2F3A) : Colors.white,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? steamDark : Colors.white,
        indicatorColor: steamBlue.withValues(alpha: .25),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static LinearGradient lightGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [steamBlue, valorantRed],
  );

  static LinearGradient darkGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [steamDark, valorantDark],
  );

  static LinearGradient gradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkGradient
          : lightGradient;

  /// Steam products get blue accents, Valorant products red.
  static Color accentFor(String? categoryName) =>
      (categoryName ?? '').toLowerCase().contains('valorant')
          ? valorantRed
          : steamBlue;
}
