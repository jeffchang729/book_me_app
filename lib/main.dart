// lib/main.dart
// 功能：應用程式的進入點，設定 Firebase、GetX 依賴注入、主題和路由。

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:book_me_app/firebase_options.dart'; // 自動生成的 Firebase 設定檔
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入認證控制器
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/screens/main_screen.dart'; // 引入應用程式主畫面
import 'package:book_me_app/core/dependency_injection.dart'; // 引入依賴注入設定
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController

/// 應用程式的進入點。
/// 負責初始化 Flutter 引擎、Firebase 服務，並設定應用程式的依賴注入。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 確保 Flutter 引擎已初始化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 使用自動生成的 Firebase 設定
  );

  await DependencyInjection.init(); // 初始化所有核心服務和控制器

  runApp(const MyApp()); // 啟動 Flutter 應用程式
}

/// `MyApp` 是應用程式的根 Widget。
/// 它設定了應用程式的標題、主題，並預設進入主畫面。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 獲取 AppController 實例，用於主題管理。
    final AppController appController = Get.find<AppController>();

    return GetMaterialApp(
      title: 'BookMe App', // 應用程式標題
      theme: AppTheme.lightTheme, // 應用淺色主題
      darkTheme: AppTheme.darkTheme, // 應用深色主題 (雖然定義了，但 ThemeMode.light 會優先)
      themeMode: ThemeMode.light, // [修正] 強制使用淺色主題，以確保 Neumorphism 風格正確顯示
      debugShowCheckedModeBanner: false, // 隱藏 debug 標誌

      // 直接返回 MainScreen，不再進行登入狀態判斷，實現訪客模式
      home: const MainScreen(),
    );
  }
}
