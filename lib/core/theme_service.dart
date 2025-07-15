// lib/core/theme_service.dart
// [修正完成] 功能：管理所有可用的主題，並負責儲存與讀取使用者的選擇。

import 'package:get/get.dart';
import 'package:book_me_app/core/storage_service.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/core/themes/split_neumorphism.dart'; // [修正] 引入新主題

/// [修正] 定義所有可用主題的類型。
enum AppThemeType {
  splitNeumorphism,
}

/// `ThemeService` 是一個 GetxService，作為主題的中央工廠和管理器。
class ThemeService extends GetxService {
  final StorageService _storageService = Get.find();
  static const _themeKey = 'app_theme_type';

  // [修正] 註冊新的主題實例。
  final Map<AppThemeType, IAppTheme> _themes = {
    AppThemeType.splitNeumorphism: SplitNeumorphismTheme(),
  };

  /// 從本地儲存中獲取用戶上次保存的主題類型。
  AppThemeType getSavedThemeType() {
    final savedThemeName = _storageService.getString(_themeKey);
    return AppThemeType.values.firstWhere(
      (e) => e.name == savedThemeName,
      orElse: () => AppThemeType.splitNeumorphism, // [修正] 更新預設主題
    );
  }

  /// 根據給定的主題類型，從註冊中心返回對應的主題物件。
  IAppTheme getTheme(AppThemeType type) {
    return _themes[type]!;
  }

  /// 將用戶選擇的主題類型保存到本地儲存。
  Future<void> saveThemeType(AppThemeType type) async {
    await _storageService.setString(_themeKey, type.name);
  }
}