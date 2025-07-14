// lib/core/theme_service.dart
// 功能：管理所有可用的主題，並負責儲存與讀取使用者的選擇。

import 'package:get/get.dart';
import 'package:book_me_app/core/storage_service.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/core/themes/fitness_light_theme.dart';
// import 'package:book_me_app/core/themes/another_cool_theme.dart'; // 未來擴充時，在此引入

/// 定義所有可用主題的類型。
/// 當您新增一個主題時，只需在此處添加一個新成員。
enum AppThemeType {
  fitnessLight,
  // anotherCool, // 未來擴充
}

/// `ThemeService` 是一個 GetxService，作為主題的中央工廠和管理器。
/// 它負責註冊所有可用的主題，並從本地儲存中讀取/寫入用戶的選擇。
class ThemeService extends GetxService {
  final StorageService _storageService = Get.find();
  static const _themeKey = 'app_theme_type';

  // 一個 Map，用於註冊所有可用的主題實例。
  // 新增主題時，只需在此 Map 中新增一個條目。
  final Map<AppThemeType, IAppTheme> _themes = {
    AppThemeType.fitnessLight: FitnessLightTheme(),
    // AppThemeType.anotherCool: AnotherCoolTheme(), // 未來擴充
  };

  /// 從本地儲存中獲取用戶上次保存的主題類型。
  /// 如果沒有儲存過，則返回預設主題。
  AppThemeType getSavedThemeType() {
    final savedThemeName = _storageService.getString(_themeKey);
    return AppThemeType.values.firstWhere(
      (e) => e.name == savedThemeName,
      orElse: () => AppThemeType.fitnessLight, // 預設主題
    );
  }

  /// 根據給定的主題類型，從註冊中心返回對應的主題物件。
  IAppTheme getTheme(AppThemeType type) {
    // 使用 ! 是因為我們確信所有在 AppThemeType 中定義的類型都已在 _themes 中註冊。
    return _themes[type]!;
  }

  /// 將用戶選擇的主題類型保存到本地儲存。
  Future<void> saveThemeType(AppThemeType type) async {
    await _storageService.setString(_themeKey, type.name);
  }
}