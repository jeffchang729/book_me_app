// lib/core/themes/i_app_theme.dart
// [修正完成] 功能：定義所有主題都必須遵守的抽象介面 (合約)。

import 'package:flutter/material.dart';

/// `IAppTheme` 是一個抽象類別，作為所有具體主題實現的介面。
/// 任何想要成為應用程式主題的類別，都必須提供此介面所定義的屬性和方法。
abstract class IAppTheme {
  /// 每個主題都必須提供一個完整的 ThemeData 物件。
  /// ThemeData 包含了應用程式大部分的視覺設定，如顏色、字體、按鈕樣式等。
  ThemeData get themeData;

  /// [新增] 獲取主要背景區域的顏色 (例如頂部區塊)。
  /// 用於實現分離式背景設計，通常是較淺的顏色。
  Color get primaryBackgroundColor;

  /// [新增] 獲取次要背景區域的顏色 (例如底部內容區塊)。
  /// 用於實現分離式背景設計，通常是較深的顏色。
  Color get secondaryBackgroundColor;

  /// 每個主題都必須提供一個實現 Neumorphism 風格的 BoxDecoration 的方法。
  /// 這允許我們在整個應用程式中，以一致的方式創建擬物化風格的容器。
  ///
  /// @param radius - 圓角半徑。
  /// @param color - 容器的背景色 (如果提供，將覆蓋預設的主要或次要背景色)。
  /// @param isConcave - 是否為內凹效果。
  /// @param gradient - 漸層效果。
  BoxDecoration neumorphicBoxDecoration({
    double radius = 20.0,
    Color? color,
    bool isConcave = false,
    Gradient? gradient,
  });
}