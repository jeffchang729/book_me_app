// lib/main.dart
// [命名重構 V4.4]
// 功能：更新 import 路徑與類別引用。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/services/dependency_injection.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/app/app_container.dart';
import 'package:book_me_app/features/home/home_controller.dart';
// [新增] 引入 Firebase 核心套件
import 'package:firebase_core/firebase_core.dart'; 
// [新增] 引入自動生成的 Firebase 設定檔 (確保路徑正確，取決於您的專案名稱)
import 'package:book_me_app/firebase_options.dart'; 

// [新增] 引入 Firebase Authentication 套件，用於監聽用戶狀態
import 'package:firebase_auth/firebase_auth.dart'; 
// [新增] 引入您將要創建的認證頁面
import 'package:book_me_app/features/auth/auth_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 確保 Flutter 引擎初始化完畢
  // [新增] 初始化 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DependencyInjection.init(); // 初始化其他服務 (包括後面會創建的 AuthController)
  runApp(const MyApp()); // 運行您的 APP
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // HomeController 可能會在認證完成後才用到，但 GetX 會確保它在第一次調用時被初始化。
    // 在此處直接查找，如果 homeController 在非登入狀態下不需要立即初始化，可以考慮調整。
    // 但為簡化起見，暫時保持現有模式。
    final HomeController homeController = Get.find<HomeController>(); 
    return Obx(() => GetMaterialApp(
          title: 'BookMe', // [修改] APP 名稱改為 BookMe
          theme: AppTheme.getThemeData(homeController.currentThemeStyle.value),
          debugShowCheckedModeBanner: false,
          // [修改] 應用程式的根頁面改為 AuthWrapper
          // AuthWrapper 將根據用戶的登入狀態，決定顯示登入頁面還是 AppContainer (主內容)
          home: const AuthWrapper(),
        ));
  }
}
// [新增] AuthWrapper 類別：用於根據用戶登入狀態，動態切換顯示頁面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 StreamBuilder 監聽 FirebaseAuth 的登入狀態變化
    return StreamBuilder<User?>( // 'User?' 來自 firebase_auth
      stream: FirebaseAuth.instance.authStateChanges(), // Firebase 提供的認證狀態變更 Stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 如果連接狀態是等待中，表示 Firebase 正在檢查用戶登入狀態，顯示載入指示器
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          // 如果 snapshot.hasData 為 true，表示有用戶已登入 (snapshot.data 就是 User 物件)
          // 導向應用程式的主內容，例如您現有的 AppContainer
          return const AppContainer(); // 將您現有的 AppContainer 作為登入後的首頁
        } else {
          // 如果 snapshot.hasData 為 false，表示沒有用戶登入
          // 顯示認證頁面 (登入/註冊)
          return const AuthScreen(); // 您將創建的登入/註冊頁面
        }
      },
    );
  }
}
