// lib/core/app_utils.dart
// 功能：應用程式通用工具函數類別。

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 十六進位顏色轉換工具類別
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

/// 應用程式工具函數類別
class AppUtils {
  AppUtils._(); // 私有建構函數，防止實例化

  // ==================== 日期時間工具方法 ====================
  
  static String formatDate(DateTime date, {String format = 'dd MMM'}) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // ==================== 數字格式化工具方法 ====================
  
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}');
    return formatter.format(number);
  }

  // ==================== 字串工具方法 ====================
  
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }
  
  // ==================== 設備資訊工具方法 ====================
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}
