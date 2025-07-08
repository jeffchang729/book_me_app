// lib/core/dependency_injection.dart
// 功能：應用程式的依賴注入中心，註冊各種服務與控制器。

import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_service.dart'; // 引入認證服務
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入認證控制器
import 'package:book_me_app/core/storage_service.dart'; // 引入儲存服務的正確路徑
import 'package:book_me_app/features/search/search_controller.dart'; // 引入搜尋控制器
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/features/user/user_service.dart'; // 引入用戶服務
import 'package:book_me_app/features/book_review/book_review_service.dart'; // [新增] 引入讀書心得服務

/// 依賴注入設定
/// 負責初始化應用程式中所有必要的服務與控制器。
class DependencyInjection {
  static Future<void> init() async {
    // 異步初始化本地儲存服務
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });

    // 認證服務與控制器 (確保 AuthService 在 AuthController 之前註冊)
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true); 

    // 用戶服務
    Get.lazyPut<UserService>(() => UserService(), fenix: true);

    // [新增] 讀書心得服務 (在 BookReviewController 之前)
    Get.lazyPut<BookReviewService>(() => BookReviewService(), fenix: true);

    // 讀書心得控制器 (現在會依賴 BookReviewService)
    Get.lazyPut<BookReviewController>(() => BookReviewController(), fenix: true);
    
    // 應用程式通用控制器
    Get.lazyPut<AppController>(() => AppController(), fenix: true); 

    // 搜尋控制器
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有核心依賴注入完成 (包含 BookMe 基礎認證服務及用戶服務)。");
  }
}