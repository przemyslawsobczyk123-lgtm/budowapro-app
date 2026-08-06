import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primary = Color(0xFF176B5B);
  static const _secondary = Color(0xFFB15F18);
  static const _surface = Color(0xFFF7F8F5);
  static const _text = Color(0xFF17211D);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surface,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: _text,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF53605A),
          fontSize: 16,
          height: 1.45,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
