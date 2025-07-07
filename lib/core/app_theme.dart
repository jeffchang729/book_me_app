// lib/core/app_theme.dart
// 功能：定義應用程式的主題，包含顏色、文字樣式和 Neumorphism 效果。

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 為了使用 Get.theme

/// 定義應用程式的主題風格。
enum AppThemeStyle {
  SmartHomeLight, // 智慧家庭淺色風格
  // ClaymorphismDark, // 其他風格 (目前未使用)
  // MorningSilverGray, // 其他風格 (目前未使用)
}

/// `AppTheme` 類別負責定義應用程式的視覺主題。
/// 它包含了顏色定義、文字樣式，以及 Neumorphism 效果的 BoxDecoration。
class AppTheme {
  AppTheme._(); // 私有建構函數，防止實例化

  // --- 顏色定義 ---
  static const Color smarthome_bg = Color(0xFFEEF0F5); // 背景色
  static const Color smarthome_primary_text = Color(0xFF3D5068); // 主要文字顏色
  static const Color smarthome_secondary_text = Color(0xFF98A6B9); // 次要文字顏色
  static const Color smarthome_primary_blue = Color(0xFF5685FF); // 主要藍色
  static const Color smarthome_accent_pink = Color(0xFFEF64D9); // 強調粉色
  static const Color smarthome_accent_green = Color(0xFF67E0BA); // 強調綠色
  static final Color smarthome_dark_shadow = const Color(0xFFA6B4C8).withOpacity(0.7); // 深色陰影
  static final Color smarthome_light_shadow = const Color(0xFFFFFFFF).withOpacity(0.8); // 淺色陰影

  static const String fontName = 'Roboto'; // 假設使用 Roboto 字體

  // --- 主題獲取 (為 GetMaterialApp 提供 lightTheme 和 darkTheme) ---
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primaryColor: smarthome_primary_blue,
        scaffoldBackgroundColor: smarthome_bg,
        iconColor: smarthome_secondary_text,
        textTheme: _buildTextTheme(smarthome_primary_text, smarthome_secondary_text, smarthome_primary_blue),
        accentColor: smarthome_accent_pink, // 新增 accentColor
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[700]!, // 深色模式的主色
        scaffoldBackgroundColor: const Color(0xFF2C2C2C), // 深色模式背景
        iconColor: Colors.blueGrey[300]!,
        textTheme: _buildTextTheme(Colors.white, Colors.blueGrey[300]!, Colors.blueGrey[100]!),
        accentColor: Colors.purpleAccent, // 深色模式的 accentColor
      );

  /// 根據指定的主題風格獲取對應的 ThemeData。
  /// [修正] 此方法用於解決 `AppController` 中 `Get.changeTheme` 的呼叫問題。
  static ThemeData getThemeData(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.SmartHomeLight:
        return lightTheme;
      // TODO: 未來可在此處添加其他主題風格的返回邏輯
      // case AppThemeStyle.ClaymorphismDark:
      //   return darkTheme;
      // case AppThemeStyle.MorningSilverGray:
      //   return lightTheme; // 假設此風格也使用 lightTheme
      default:
        return lightTheme; // 預設返回淺色主題
    }
  }

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
        onPrimary: brightness == Brightness.light ? Colors.white : Colors.black, // 主要色上的文字顏色
        onBackground: brightness == Brightness.light ? smarthome_primary_text : Colors.white, // 背景上的文字顏色
      ),
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
      hintColor: smarthome_secondary_text, // 提示文字顏色
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

  /// 產生 Neumorphism 風格的 BoxDecoration。
  static BoxDecoration smartHomeNeumorphic({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient,
  }) {
    final baseColor = color ?? smarthome_bg; // 預設背景色

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
      gradient: gradient, // 如果提供了 gradient，就使用它
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
