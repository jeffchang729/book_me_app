// lib/main.dart
// [架構改造] 功能：應用程式的進入點，設定 Firebase、GetX 依賴注入和動態主題。

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:book_me_app/firebase_options.dart';
import 'package:book_me_app/screens/main_screen.dart';
import 'package:book_me_app/core/dependency_injection.dart';
import 'package:book_me_app/core/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 初始化所有服務和控制器，包括 ThemeService 和 AppController
  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 獲取 AppController 實例，它在 onInit 中已經設定好了初始主題
    final AppController appController = Get.find<AppController>();

    return GetMaterialApp(
      title: 'BookMe App',
      // [架構改造] 初始主題直接從 AppController 的當前主題物件中獲取
      theme: appController.currentTheme.value.themeData,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}