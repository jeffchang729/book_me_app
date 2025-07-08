// lib/screens/activity_screen.dart
// 功能：顯示用戶的活動和通知 (Instagram 活動風格)。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入 AuthController
import 'package:book_me_app/features/auth/auth_screen.dart'; // 引入 AuthScreen
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController

/// `ActivityScreen` 用於顯示用戶在 BookMe 應用程式中的所有活動和通知，
/// 例如誰按讚了您的讀書心得、誰留言、誰追蹤了您等。
/// 其設計靈感來自 Instagram 的活動頁面。
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme; // 獲取當前主題
    final AuthController authController = Get.find<AuthController>(); // 獲取 AuthController
    final AppController appController = Get.find<AppController>(); // 獲取 AppController

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // AppBar 背景色
        elevation: 0, // 無陰影
        title: Text(
          '活動', // 頁面標題
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false, // 標題左對齊
      ),
      body: Obx(() {
        if (authController.currentUser.value == null) {
          // 如果用戶未登入，顯示登入提示頁面
          return _buildLoginPromptPage(context, authController, appController); // [修正] 傳遞 appController
        } else {
          // 如果用戶已登入，顯示實際的活動列表
          // TODO: 未來這裡會替換為實際的活動通知列表，從後端獲取數據
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '您的活動通知',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  '這裡將顯示您的讚、留言和新追蹤者',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // 示例活動數量
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 10), 
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.primaryColor.withOpacity(0.2),
                                child: Icon(Icons.person, size: 25, color: theme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '用戶 ${index + 1} 喜歡了您的讀書心得', // 示例活動訊息
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              Text(
                                '${index + 1} 小時前', // 示例時間
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  /// 建立未登入時顯示的登入提示頁面。
  Widget _buildLoginPromptPage(BuildContext context, AuthController authController, AppController appController) { // [修正] 接收 appController
    final theme = context.theme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.5)),
        const SizedBox(height: 20),
        Text(
          '登入以查看您的活動',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '按讚、留言、追蹤等互動將在這裡顯示。',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              authController.toggleAuthMode(); // 切換到登入模式
              // [修正] 導航到 AuthScreen，並傳遞回調函數以返回當前頁面
              Get.to(() => AuthScreen(onLoginSuccess: () {
                appController.changeTabIndex(3); // 返回到活動頁面 (索引 3)
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              '登入或註冊',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}