// lib/core/app_config.dart
// [清理完成] 功能：移除與天氣相關的無用設定，讓設定檔更專注於 BookMe 核心功能。

class AppConfig {
  
  /// API 基礎 URL
  /// 透過 --dart-define 從外部注入，用於切換本地與雲端後端。
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// API 請求超時設定
  static const Duration apiTimeout = Duration(seconds: 10);

}