// lib/features/auth/auth_screen.dart
// 功能：提供使用者註冊與登入的 UI 介面

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_controller.dart'; // [修改] 引用新的套件路徑
import 'package:book_me_app/core/theme/app_theme.dart'; // [修改] 引用新的套件路徑

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController()); // 獲取或創建 AuthController
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('BookMe', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text('讀書，分享，連結', style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 48),

              // Email 輸入框
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '電子郵件',
                    border: InputBorder.none,
                    icon: Icon(Icons.email_outlined, color: theme.iconTheme.color),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),

              // 密碼輸入框
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '密碼',
                    border: InputBorder.none,
                    icon: Icon(Icons.lock_outline, color: theme.iconTheme.color),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),

              // 錯誤訊息顯示
              Obx(() => Text(
                    authController.errorMessage.value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 16),

              // 註冊按鈕
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null // 載入中禁用按鈕
                          : () {
                              authController.signUp(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.smarthome_primary_blue, // 使用您定義的主題色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('註冊', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    ),
                  )),
              const SizedBox(height: 20),

              // 登入按鈕
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          authController.signIn(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.smarthome_accent_green, // 使用您定義的主題色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('登入', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}