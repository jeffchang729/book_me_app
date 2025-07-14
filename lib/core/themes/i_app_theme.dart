// lib/core/themes/i_app_theme.dart
// 功能：定義所有主題都必須遵守的抽象介面 (合約)。

import 'package:flutter/material.dart';

/// `IAppTheme` 是一個抽象類別，作為所有具體主題實現的介面。
/// 任何想要成為應用程式主題的類別，都必須提供此介面所定義的屬性和方法。
abstract class IAppTheme {
  /// 每個主題都必須提供一個完整的 ThemeData 物件。
  /// ThemeData 包含了應用程式大部分的視覺設定，如顏色、字體、按鈕樣式等。
  ThemeData get themeData;

  /// 每個主題都必須提供一個實現 Neumorphism 風格的 BoxDecoration 的方法。
  /// 這允許我們在整個應用程式中，以一致的方式創建擬物化風格的容器。
  ///
  /// @param radius - 圓角半徑。
  /// @param color - 容器的背景色。
  /// @param isConcave - 是否為內凹效果。
  /// @param gradient - 漸層效果。
  BoxDecoration neumorphicBoxDecoration({
    double radius,
    Color? color,
    bool isConcave,
    Gradient? gradient,
  });

  // 未來可以輕鬆擴充其他所有主題都必須具備的自定義樣式，例如：
  // Color get specialCardColor;
  // TextStyle get subtitleStyle;
}