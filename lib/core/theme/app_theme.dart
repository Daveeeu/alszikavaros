import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const scaffold = Color(0xFF0E1116);
    const surface = Color(0xFF171C23);
    const accent = Color(0xFF6EE7B7);

    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF34D399),
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: scaffold,
        elevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          height: 1.35,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
