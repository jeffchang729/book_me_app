// lib/core/app_controller.dart
// 功能：管理應用程式的通用狀態，例如底部導覽列索引、主題切換和通用提示。
// [架構改造] 使用 ThemeService 來管理主題狀態。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/theme_service.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';

/// `AppController` 負責管理應用程式級別的通用狀態。
/// 它持有當前主題的狀態，並提供切換主題的方法。
class AppController extends GetxController {
  final ThemeService _themeService = Get.find();

  // 持有當前主題物件的響應式變數。UI 層將監聽此變數的變化。
  late final Rx<IAppTheme> currentTheme;

  final RxInt currentTabIndex = 0.obs; // 當前選中的底部導覽列索引

  @override
  void onInit() {
    super.onInit();
    // 初始化時，從 ThemeService 獲取儲存的主題類型，並設定為當前主題。
    final savedType = _themeService.getSavedThemeType();
    currentTheme = _themeService.getTheme(savedType).obs;
  }

  /// 切換應用程式的主題。
  /// @param newType - 要切換到的新主題類型。
  void changeTheme(AppThemeType newType) {
    // 檢查是否為同一個主題，避免不必要的操作
    // 我們比較主題物件的運行時類型，這比比較枚舉更可靠
    if (currentTheme.value.runtimeType == _themeService.getTheme(newType).runtimeType) {
      return;
    }

    // 1. 從 ThemeService 獲取新的主題物件
    final newTheme = _themeService.getTheme(newType);

    // 2. 更新 AppController 中的狀態，這將觸發所有監聽此狀態的 UI (Obx) 重建
    currentTheme.value = newTheme;

    // 3. 呼叫 GetX 的核心方法來真正改變 Flutter 的 ThemeData
    Get.changeTheme(newTheme.themeData);

    // 4. 將用戶的選擇保存到本地，以便下次啟動時使用
    _themeService.saveThemeType(newType);

    Get.snackbar('主題已切換', '新的視覺風格已套用！', snackPosition: SnackPosition.BOTTOM);
  }

  /// 改變底部導覽列的當前索引。
  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return;
    currentTabIndex.value = index;
  }

  /// 顯示成功訊息的 Snackbar。
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: currentTheme.value.themeData.primaryColor, // 使用當前主題的顏色
      colorText: Colors.white,
    );
  }

  /// 顯示警告訊息的 Snackbar。
  void showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[700],
      colorText: Colors.white,
    );
  }
}