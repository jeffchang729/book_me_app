// lib/core/app_controller.dart
// 功能：管理應用程式的通用狀態，例如底部導覽列索引、主題切換和通用提示。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/core/storage_service.dart'; // [修正] 引入儲存服務的正確路徑

/// `AppController` 負責管理應用程式級別的通用狀態，
/// 包括底部導覽列的當前索引、應用程式主題的切換，以及顯示成功/警告訊息的 Snackbar。
///
/// 此控制器已從原來的 `HomeController` 簡化並重新命名，
/// 以更準確地反映其作為應用程式通用控制器的職責。
class AppController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>(); // 注入儲存服務
  static const String _themeKey = 'app_theme_style'; // 主題儲存的鍵值

  final RxInt currentTabIndex = 0.obs; // 當前選中的底部導覽列索引
  final Rx<AppThemeStyle> currentThemeStyle = AppThemeStyle.SmartHomeLight.obs; // 當前應用程式主題風格

  @override
  void onInit() {
    super.onInit();
    _initTheme(); // 初始化時載入並設定主題
  }

  /// 初始化應用程式主題。
  /// 從本地儲存中載入之前設定的主題，如果沒有則使用預設主題。
  void _initTheme() {
    final savedThemeName = _storageService.getString(_themeKey);
    final style = AppThemeStyle.values.firstWhere(
      (e) => e.toString() == savedThemeName,
      orElse: () => AppThemeStyle.SmartHomeLight, // 預設為 SmartHomeLight 風格
    );
    _setTheme(style); // 設定主題
  }
  
  /// 設定應用程式主題。
  /// 根據指定的主題風格切換應用程式主題，並將其儲存到本地。
  /// @param style - 要設定的主題風格。
  void _setTheme(AppThemeStyle style) {
    currentThemeStyle.value = style;
    // [修正] 直接使用 AppTheme.lightTheme 或 AppTheme.darkTheme
    Get.changeTheme(style == AppThemeStyle.SmartHomeLight ? AppTheme.lightTheme : AppTheme.darkTheme); 
    _storageService.setString(_themeKey, style.toString()); // 將主題風格儲存到本地
  }

  /// 循環切換應用程式主題。
  /// 目前僅提供 SmartHomeLight 風格，此方法為未來擴展預留。
  void cycleTheme() {
    // 由於目前只有一種主題風格，此方法僅顯示提示。
    Get.snackbar('主題切換', '目前僅提供 SmartHomeLight 風格。', snackPosition: SnackPosition.BOTTOM);
  }

  /// 改變底部導覽列的當前索引。
  /// @param index - 要切換到的新索引。
  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return; // 如果索引未改變，則不執行任何操作
    currentTabIndex.value = index; // 更新當前索引
  }

  /// 顯示成功訊息的 Snackbar。
  /// @param title - Snackbar 的標題。
  /// @param message - Snackbar 的內容訊息。
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor, // 使用主題的主要顏色作為背景
      colorText: Colors.white, // 文字顏色為白色
    );
  }

  /// 顯示警告訊息的 Snackbar。
  /// @param title - Snackbar 的標題。
  /// @param message - Snackbar 的內容訊息。
  void showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[700], // 使用橙色作為背景
      colorText: Colors.white, // 文字顏色為白色
    );
  }
}
