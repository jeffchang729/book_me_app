// lib/core/themes/fitness_light_theme.dart
// 功能：提供 Fitness 風格的淺色主題具體實現。

import 'package:flutter/material.dart';
import 'i_app_theme.dart';

/// `FitnessLightTheme` 類別實作了 `IAppTheme` 介面，
/// 提供了一套基於 Dribbble 設計稿的冷色調淺色 Neumorphism 風格。
class FitnessLightTheme implements IAppTheme {
  // --- 顏色定義 ---
  static const Color _bg = Color(0xFFE8EBF0);
  static const Color _primaryText = Color(0xFF353F58);
  static const Color _secondaryText = Color(0xFF8A99B1);
  static const Color _accentPurple = Color(0xFFA07BFF);
  static const Color _accentCyan = Color(0xFF67E0BA);
  static final Color _darkShadow = const Color(0xFFA6B4C8).withOpacity(0.5);
  static final Color _lightShadow = const Color(0xFFFFFFFF).withOpacity(0.9);
  static const String _fontName = 'Roboto';

  @override
  ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _accentPurple,
      scaffoldBackgroundColor: _bg,
      fontFamily: _fontName,
      iconTheme: const IconThemeData(color: _secondaryText, size: 24),
      textTheme: _buildTextTheme(_primaryText, _secondaryText, _accentPurple),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentPurple,
        brightness: Brightness.light,
        background: _bg,
        primary: _accentPurple,
        secondary: _accentCyan,
        onPrimary: Colors.white,
        onBackground: _primaryText,
      ),
      splashColor: _accentPurple.withOpacity(0.1),
      highlightColor: Colors.transparent,
      hintColor: _secondaryText,
      dividerColor: _secondaryText.withOpacity(0.2),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _accentPurple,
        contentTextStyle: _buildTextTheme(_primaryText, _secondaryText, _accentPurple).bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }

  TextTheme _buildTextTheme(Color primary, Color secondary, Color labelColor) {
    return TextTheme(
      headlineLarge: const TextStyle(fontFamily: _fontName, fontWeight: FontWeight.bold, fontSize: 32, color: primary),
      headlineMedium: const TextStyle(fontFamily: _fontName, fontWeight: FontWeight.w700, fontSize: 24, color: primary),
      headlineSmall: const TextStyle(fontFamily: _fontName, fontWeight: FontWeight.w600, fontSize: 20, color: primary),
      titleLarge: const TextStyle(fontFamily: _fontName, fontWeight: FontWeight.w600, fontSize: 18, color: primary),
      bodyLarge: TextStyle(fontFamily: _fontName, fontWeight: FontWeight.normal, fontSize: 16, color: primary, height: 1.5),
      bodyMedium: TextStyle(fontFamily: _fontName, fontWeight: FontWeight.normal, fontSize: 14, color: secondary, height: 1.5),
      labelLarge: TextStyle(fontFamily: _fontName, fontWeight: FontWeight.w600, fontSize: 14, color: labelColor),
    );
  }

  @override
  BoxDecoration neumorphicBoxDecoration({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient,
  }) {
    final baseColor = color ?? _bg;

    if (isConcave) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkShadow.withOpacity(0.4),
            _lightShadow.withOpacity(0.5),
          ],
          stops: const [0.0, 1.0],
        ),
      );
    }

    return BoxDecoration(
      color: baseColor,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: _darkShadow,
          offset: const Offset(8, 8),
          blurRadius: 18,
        ),
        BoxShadow(
          color: _lightShadow,
          offset: const Offset(-8, -8),
          blurRadius: 18,
        ),
      ],
    );
  }
}