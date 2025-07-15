// lib/features/navigation/activity_screen.dart
// [最終修正] 功能：顯示用戶的活動和通知，採用分離式擬物化風格。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/features/auth/auth_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryBackgroundColor,
        elevation: 0,
        title: Text('活動', style: theme.themeData.textTheme.headlineSmall),
        centerTitle: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Obx(() {
          if (authController.currentUser.value == null) {
            return _buildLoginPromptPage(theme, authController, appController);
          } else {
            return _buildActivityList(theme);
          }
        }),
      ),
    );
  }

  Widget _buildLoginPromptPage(IAppTheme theme, AuthController authController, AppController appController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 80, color: theme.themeData.iconTheme.color?.withOpacity(0.5)),
        const SizedBox(height: 20),
        Text('登入以查看您的活動', style: theme.themeData.textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text('按讚、留言、追蹤等互動將在這裡顯示。', style: theme.themeData.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => AuthScreen(onLoginSuccess: () => appController.changeTabIndex(3)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Ink(
              decoration: theme.neumorphicBoxDecoration(
                  radius: 15,
                  color: theme.themeData.primaryColor,
                  gradient: LinearGradient(
                    colors: [theme.themeData.primaryColor, const Color(0xFF6A95FF)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  )),
              child: Center(
                child: Text('登入或註冊', style: theme.themeData.textTheme.titleLarge?.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(IAppTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: 10, // 示例活動數量
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: theme.neumorphicBoxDecoration(
              radius: 20, color: theme.secondaryBackgroundColor),
          child: Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: theme.primaryBackgroundColor),
              const SizedBox(width: 16),
              Expanded(
                // [修正] 加上 .textTheme
                child: Text('用戶 ${index + 1} 喜歡了您的讀書心得', style: theme.themeData.textTheme.bodyLarge),
              ),
              // [修正] 加上 .textTheme
              Text('${index + 1}h', style: theme.themeData.textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}