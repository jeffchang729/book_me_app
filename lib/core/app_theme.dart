// lib/core/app_theme.dart
// 功能：定義應用程式的主題，包含顏色、文字樣式和 Neumorphism 效果。
// [風格改造] 全面更新為 Dribbble 設計稿中的冷色調淺色 Neumorphism 風格。

import 'package:flutter/material.dart';

/// `AppTheme` 類別負責定義應用程式的視覺主題。
/// 它包含了顏色定義、文字樣式，以及 Neumorphism 效果的 BoxDecoration。
class AppTheme {
  AppTheme._(); // 私有建構函數，防止實例化

  // --- [風格改造] 新的冷色調顏色定義 (Fitness Neumorphism) ---
  static const Color fitness_bg = Color(0xFFE8EBF0); // 主要背景色 (冷色調灰白)
  static const Color fitness_primary_text = Color(0xFF353F58); // 主要文字顏色 (深藍灰)
  static const Color fitness_secondary_text = Color(0xFF8A99B1); // 次要文字顏色 (中度藍灰)
  static const Color fitness_accent_purple = Color(0xFFA07BFF); // 強調紫色
  static const Color fitness_accent_cyan = Color(0xFF67E0BA); // 強調青色 (與原 smarthome_accent_green 相同)
  static final Color fitness_dark_shadow = const Color(0xFFA6B4C8).withOpacity(0.5); // 深色陰影 (稍微調淡)
  static final Color fitness_light_shadow = const Color(0xFFFFFFFF).withOpacity(0.9); // 淺色陰影 (稍微調亮)

  static const String fontName = 'Roboto'; // 假設使用 Roboto 字體

  // --- [風格改造] 唯一的應用程式主題 ---
  static ThemeData get themeData => _buildTheme(
        brightness: Brightness.light,
        primaryColor: fitness_accent_purple, // 使用紫色作為主要強調色
        scaffoldBackgroundColor: fitness_bg,
        iconColor: fitness_secondary_text,
        textTheme: _buildTextTheme(fitness_primary_text, fitness_secondary_text, fitness_accent_purple),
        accentColor: fitness_accent_cyan, // 使用青色作為次要強調色
      );

  // [移除] 不再需要 darkTheme 和 getThemeData 方法
  // static ThemeData get darkTheme => ...
  // static ThemeData getThemeData(AppThemeStyle style) => ...
  // [移除] 不再需要 AppThemeStyle 列舉
  // enum AppThemeStyle { ... }

  /// 建立通用的 ThemeData 物件。
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color scaffoldBackgroundColor,
    required Color iconColor,
    required TextTheme textTheme,
    required Color accentColor, // 強調色參數
  }) {
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: fontName,
      iconTheme: IconThemeData(color: iconColor, size: 24),
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        background: scaffoldBackgroundColor,
        primary: primaryColor, // 明確設定 primary
        secondary: accentColor, // 明確設定 secondary
        onPrimary: Colors.white, // 主要色上的文字顏色
        onBackground: fitness_primary_text, // 背景上的文字顏色
      ),
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
      hintColor: fitness_secondary_text, // 提示文字顏色
      dividerColor: fitness_secondary_text.withOpacity(0.2), // 分隔線顏色
      // GetX 的 snackbar 可能會用到
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }

  /// 建立通用的 TextTheme 物件。
  static TextTheme _buildTextTheme(Color primary, Color secondary, Color labelColor) {
    return TextTheme(
      headlineLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, fontSize: 32, color: primary),
      headlineMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w700, fontSize: 24, color: primary),
      headlineSmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, fontSize: 20, color: primary),
      titleLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, fontSize: 18, color: primary),
      bodyLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, fontSize: 16, color: primary, height: 1.5),
      bodyMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, fontSize: 14, color: secondary, height: 1.5),
      labelLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, fontSize: 14, color: labelColor),
    );
  }

  /// [風格改造] 產生 Neumorphism 風格的 BoxDecoration (已改名並使用新顏色)。
  static BoxDecoration neumorphicBoxDecoration({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient,
  }) {
    final baseColor = color ?? fitness_bg; // 預設背景色

    // 內凹效果
    if (isConcave) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fitness_dark_shadow.withOpacity(0.4),
            fitness_light_shadow.withOpacity(0.5),
          ],
          stops: const [0.0, 1.0],
        ),
      );
    }

    // 預設的凸起效果
    return BoxDecoration(
      color: baseColor,
      gradient: gradient, // 如果提供了 gradient，就使用它
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: fitness_dark_shadow,
          offset: const Offset(8, 8), // 縮小陰影偏移
          blurRadius: 18, // 縮小模糊半徑
        ),
        BoxShadow(
          color: fitness_light_shadow,
          offset: const Offset(-8, -8), // 縮小陰影偏移
          blurRadius: 18, // 縮小模糊半徑
        ),
      ],
    );
  }
}