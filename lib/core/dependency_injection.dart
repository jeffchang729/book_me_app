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
import 'package:book_me_app/features/search/search_service.dart'; // [新增] 引入搜尋服務

/// 依賴注入設定
class DependencyInjection {
  static Future<void> init() async {
    // 異步初始化本地儲存服務
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });

    // 認證服務與控制器
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true); 

    // 用戶服務
    Get.lazyPut<UserService>(() => UserService(), fenix: true);

    // 讀書心得服務
    Get.lazyPut<BookReviewService>(() => BookReviewService(), fenix: true);

    // 讀書心得控制器
    Get.lazyPut<BookReviewController>(() => BookReviewController(), fenix: true);
    
    // 應用程式通用控制器
    Get.lazyPut<AppController>(() => AppController(), fenix: true); 

    // [新增] 搜尋服務 (在 SearchController 之前)
    Get.lazyPut<SearchService>(() => SearchService(), fenix: true);

    // 搜尋控制器 (現在會依賴 SearchService)
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有核心依賴注入完成 (包含 BookMe 基礎認證服務及用戶服務)。");
  }
}