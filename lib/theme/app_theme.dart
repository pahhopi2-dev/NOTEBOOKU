import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color ink = Color(0xFF0F1A18);
  static const Color mutedInk = Color(0xFF5C6B67);
  static const Color paper = Color(0xFFF4F8F6);
  static const Color paperAlt = Color(0xFFE8F0EC);
  static const Color darkInk = Color(0xFFEAF2EF);
  static const Color darkMuted = Color(0xFF9AADA7);
  static const Color darkPaper = Color(0xFF0C1210);
  static const Color darkPaperAlt = Color(0xFF161F1C);
  static const Color teal = Color(0xFF1F7A70);
  static const Color tealLight = Color(0xFF6FC9BE);
  static const Color coral = Color(0xFFE56B5D);
  static const Color gold = Color(0xFFD4A017);
  static const Color plum = Color(0xFF7359A6);

  static TextTheme _textTheme(ColorScheme scheme, bool isDark) {
    final base = isDark
        ? GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
        : GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      primary: teal,
      secondary: coral,
      tertiary: gold,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return _base(scheme, isDark: false).copyWith(
      scaffoldBackgroundColor: paper,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withAlpha(40)),
        ),
      ),
      inputDecorationTheme: _inputDecoration(
        fill: Colors.white,
        border: const Color(0xFFD5E3DD),
        hint: mutedInk,
      ),
      navigationBarTheme: _navigationBar(
        background: Colors.white,
        indicator: teal.withAlpha(40),
        label: ink,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: tealLight,
      primary: tealLight,
      secondary: const Color(0xFFFF9A8E),
      tertiary: const Color(0xFFE2B95F),
      surface: darkPaperAlt,
      brightness: Brightness.dark,
    );

    return _base(scheme, isDark: true).copyWith(
      scaffoldBackgroundColor: darkPaper,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: darkInk,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkInk,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkPaperAlt,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2B3935)),
        ),
      ),
      inputDecorationTheme: _inputDecoration(
        fill: darkPaperAlt,
        border: const Color(0xFF30423D),
        hint: darkMuted,
      ),
      navigationBarTheme: _navigationBar(
        background: const Color(0xFF161F1C),
        indicator: const Color(0xFF214D47),
        label: darkInk,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: tealLight,
        foregroundColor: darkPaper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme, {required bool isDark}) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      textTheme: _textTheme(scheme, isDark),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withAlpha(40),
        thickness: 1,
      ),
    );
  }

  static InputDecorationTheme _inputDecoration({
    required Color fill,
    required Color border,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: teal, width: 2),
      ),
    );
  }

  static NavigationBarThemeData _navigationBar({
    required Color background,
    required Color indicator,
    required Color label,
  }) {
    return NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: indicator,
      elevation: 0,
      height: 70,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(
          color: label,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
