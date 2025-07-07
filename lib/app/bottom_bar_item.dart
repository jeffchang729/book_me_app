// lib/app/bottom_bar_item.dart
// 底部導覽列項目資料模型

import 'package:flutter/material.dart';

/// 代表底部導覽列中的單一項目。
class ElegantBottomBarItem {
  ElegantBottomBarItem({
    required this.icon,
    required this.label,
  });

  /// 圖示 (使用 IconData 以獲得最大靈活性)
  final IconData icon;
  
  /// 顯示在圖示下方的標籤文字
  final String label;
}