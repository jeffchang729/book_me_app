// lib/core/theme/app_theme.dart
// [錯誤修正 V5.1]
// 功能：為 smartHomeNeumorphic 方法新增 gradient 參數，以支援天氣卡片的動態漸層背景。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppThemeStyle {
  SmartHomeLight,
  ClaymorphismDark,
  MorningSilverGray,
}

class AppTheme {
  AppTheme._();

  // --- 顏色定義 (維持不變) ---
  static const Color smarthome_bg = Color(0xFFEEF0F5);
  static const Color smarthome_primary_text = Color(0xFF3D5068);
  static const Color smarthome_secondary_text = Color(0xFF98A6B9);
  static const Color smarthome_primary_blue = Color(0xFF5685FF);
  static const Color smarthome_accent_pink = Color(0xFFEF64D9);
  static const Color smarthome_accent_green = Color(0xFF67E0BA);
  static final Color smarthome_dark_shadow = const Color(0xFFA6B4C8).withOpacity(0.7);
  static final Color smarthome_light_shadow = const Color(0xFFFFFFFF).withOpacity(0.8);

  static const String fontName = 'Roboto';

  // --- 主題獲取 (維持不變) ---
  static ThemeData getThemeData(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.SmartHomeLight:
      default:
        return _buildTheme(
          brightness: Brightness.light,
          primaryColor: smarthome_primary_blue,
          scaffoldBackgroundColor: smarthome_bg,
          iconColor: smarthome_secondary_text,
          textTheme: _buildTextTheme(smarthome_primary_text, smarthome_secondary_text, smarthome_primary_blue)
        );
    }
  }

  static ThemeData _buildTheme({ required Brightness brightness, required Color primaryColor, required Color scaffoldBackgroundColor, required Color iconColor, required TextTheme textTheme}) {
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: fontName,
      iconTheme: IconThemeData(color: iconColor, size: 24),
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: brightness, background: scaffoldBackgroundColor),
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
    );
  }

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

  // [重大修改] 新增 gradient 參數
  static BoxDecoration smartHomeNeumorphic({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient, // [新增] 可選的漸層參數
  }) {
    final baseColor = color ?? smarthome_bg;

    if (isConcave) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            smarthome_dark_shadow.withOpacity(0.4),
            smarthome_light_shadow.withOpacity(0.5),
          ],
          stops: const [0.0, 1.0],
        ),
      );
    }

    return BoxDecoration(
      color: baseColor,
      // [新增] 如果提供了 gradient，就使用它
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: smarthome_dark_shadow,
          offset: const Offset(10, 10),
          blurRadius: 24,
        ),
        BoxShadow(
          color: smarthome_light_shadow,
          offset: const Offset(-12, -12),
          blurRadius: 20,
        ),
      ],
    );
  }
}
