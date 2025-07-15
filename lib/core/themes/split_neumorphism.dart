// lib/core/themes/split_neumorphism.dart
// [新檔案] 功能：實現 IAppTheme 介面，提供符合 Behance 分離式擬物化風格的具體主題。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';

/// `SplitNeumorphismTheme` 類別，具體實現了分離式擬物化 (Split Neumorphism) 的視覺風格。
/// 這種風格的特點是擁有兩種層次的背景色，以及更柔和、精緻的陰影效果。
class SplitNeumorphismTheme implements IAppTheme {
  // --- 色彩定義 ---
  // 遵循 Behance 範例，我們定義一組柔和且層次分明的顏色。
  static const Color _primaryBackground = Color(0xFFE6EBF0); // 頂部較淺的背景色
  static const Color _secondaryBackground = Color(0xFFDDE4EB); // 底部較深的背景色
  static const Color _primaryColor = Color(0xFF5685FF); // 主題色，用於按鈕、圖示等
  static const Color _textColor = Color(0xFF3D4C63); // 主要文字顏色
  static const Color _secondaryTextColor = Color(0xFF8A99B4); // 次要文字顏色
  static const Color _lightShadow = Color(0xFFFFFFFF); // 擬物化效果的亮部陰影
  static const Color _darkShadow = Color(0xFFAAB9CF); // 擬物化效果的暗部陰影

  @override
  Color get primaryBackgroundColor => _primaryBackground;

  @override
  Color get secondaryBackgroundColor => _secondaryBackground;

  @override
  ThemeData get themeData {
    return ThemeData(
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _primaryBackground, // App 主要背景使用頂部較淺的顏色
      fontFamily: 'WorkSans', // 保持現有字體設定
      textTheme: const TextTheme(
        // 定義通用的文字樣式
        headlineLarge: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 36),
        headlineMedium: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 24),
        headlineSmall: TextStyle(color: _textColor, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: TextStyle(color: _textColor, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: _textColor, fontSize: 16),
        bodyMedium: TextStyle(color: _secondaryTextColor, fontSize: 14),
        bodySmall: TextStyle(color: _secondaryTextColor, fontSize: 12),
      ),
      iconTheme: const IconThemeData(
        color: _secondaryTextColor, // 預設圖示顏色
        size: 24,
      ),
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _textColor,
        onPrimary: Colors.white,
        onError: Colors.white,
        error: Colors.redAccent,
        background: _primaryBackground,
        surface: _secondaryBackground, // 將 surface 對應到次要背景色
      ),
    );
  }

  @override
  BoxDecoration neumorphicBoxDecoration({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient,
  }) {
    // 根據 Behance 風格，陰影應該更柔和、更分散
    final shadowOffset = isConcave ? const Offset(-2, -2) : const Offset(5, 5);
    final blurRadius = isConcave ? 4.0 : 10.0;

    // 內凹效果的顏色是反轉的
    final shadows = isConcave
        ? [
            BoxShadow(
              color: _darkShadow,
              offset: -shadowOffset,
              blurRadius: blurRadius,
            ),
            BoxShadow(
              color: _lightShadow,
              offset: shadowOffset,
              blurRadius: blurRadius,
            ),
          ]
        : [
            BoxShadow(
              color: _darkShadow.withOpacity(0.8),
              offset: shadowOffset,
              blurRadius: blurRadius,
            ),
            BoxShadow(
              color: _lightShadow.withOpacity(0.9),
              offset: -shadowOffset,
              blurRadius: blurRadius,
            ),
          ];

    return BoxDecoration(
      color: color ?? _secondaryBackground, // 預設使用較深的背景色
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows,
      gradient: gradient,
    );
  }
}