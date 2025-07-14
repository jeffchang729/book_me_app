// lib/core/dependency_injection.dart
// 功能：應用程式的依賴注入中心，註冊各種服務與控制器。

import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_service.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/core/storage_service.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/features/book_review/book_review_controller.dart';
import 'package:book_me_app/features/user/user_service.dart';
import 'package:book_me_app/features/book_review/book_review_service.dart';
import 'package:book_me_app/features/search/search_service.dart';
import 'package:book_me_app/core/theme_service.dart'; // [新增] 引入主題服務

/// 依賴注入設定
class DependencyInjection {
  static Future<void> init() async {
    // 異步初始化本地儲存服務
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });

    // [新增] 主題服務 (需要在 AppController 之前注入)
    Get.lazyPut<ThemeService>(() => ThemeService(), fenix: true);

    // 認證服務與控制器
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // 用戶服務
    Get.lazyPut<UserService>(() => UserService(), fenix: true);

    // 讀書心得服務
    Get.lazyPut<BookReviewService>(() => BookReviewService(), fenix: true);

    // 讀書心得控制器
    Get.lazyPut<BookReviewController>(() => BookReviewController(), fenix: true);

    // 應用程式通用控制器 (現在會依賴 ThemeService)
    Get.lazyPut<AppController>(() => AppController(), fenix: true);

    // 搜尋服務
    Get.lazyPut<SearchService>(() => SearchService(), fenix: true);

    // 搜尋控制器
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);

    print("所有核心依賴注入完成 (包含全新的主題服務)。");
  }
}