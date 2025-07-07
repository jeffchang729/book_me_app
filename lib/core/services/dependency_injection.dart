// lib/core/services/dependency_injection.dart
// 功能：應用程式的依賴注入中心，註冊各種服務與控制器。

import 'package:get/get.dart';
import 'package:book_me_app/core/services/fake_data_service.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/features/home/home_controller.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/features/search/search_controller.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/core/services/storage_service.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/features/stock/stock_service.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/features/weather/weather_service.dart'; // [修改] 引用新的套件路徑

// [新增] 導入您新建立的認證服務與控制器
import 'package:book_me_app/features/auth/auth_service.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    
    // // 異步初始化本地儲存服務
    await Get.putAsync<StorageService>(() async {
      final storageService = StorageService();
      await storageService.init();
      return storageService;
    });

    // // 使用 lazyPut 延遲加載服務，在第一次使用時才建立實例
    Get.lazyPut<FakeDataService>(() => FakeDataService(), fenix: true);
    Get.lazyPut<WeatherService>(() => WeatherService(), fenix: true);
    Get.lazyPut<StockService>(() => StockService(), fenix: true);
    
    // [新增] 註冊認證服務與控制器 (確保 AuthService 在 AuthController 之前註冊)
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true); 

    // // 延遲加載核心的 Controllers
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    
    print("所有核心依賴注入完成 (包含 BookMe 基礎認證服務)。"); // [修改]
  }
}