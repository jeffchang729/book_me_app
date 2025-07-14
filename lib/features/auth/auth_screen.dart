// lib/features/auth/auth_screen.dart
// [架構改造] 使用 AppController 來獲取動態主題樣式。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/core/app_controller.dart'; // [修改] 引入 AppController
import 'package:book_me_app/core/themes/i_app_theme.dart'; // [新增] 引入主題介面
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess;
  final bool initialRegisterMode;

  const AuthScreen({
    super.key,
    this.onLoginSuccess,
    this.initialRegisterMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    // [新增] 獲取 AppController
    final AppController appController = Get.find<AppController>();

    if (!authController.hasBeenInitialized) {
      authController.isRegisterMode.value = initialRegisterMode;
      authController.hasBeenInitialized = true;
    }

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    once(authController.currentUser, (user) {
      if (user != null && onLoginSuccess != null) {
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        if (Get.currentRoute.contains('AuthScreen')) Get.back();
        onLoginSuccess!();
      }
    });

    // 使用 Obx 包裹整個 Scaffold 的 body，以便在主題切換時能重建
    return Obx(() {
      // 從 AppController 獲取當前主題
      final IAppTheme theme = appController.currentTheme.value;
      final ThemeData themeData = theme.themeData;

      return Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('BookMe', style: themeData.textTheme.headlineLarge),
                const SizedBox(height: 10),
                Text('讀書，分享，連結', style: themeData.textTheme.headlineSmall?.copyWith(color: themeData.textTheme.bodyMedium?.color)),
                const SizedBox(height: 48),

                // Email 輸入框
                _buildAuthInputField(
                  theme: theme, // 傳遞主題物件
                  controller: emailController,
                  hintText: '電子郵件',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // 密碼輸入框
                _buildAuthInputField(
                  theme: theme,
                  controller: passwordController,
                  hintText: '密碼',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // 確認密碼輸入框
                Obx(() => authController.isRegisterMode.value
                    ? _buildAuthInputField(
                        theme: theme,
                        controller: confirmPasswordController,
                        hintText: '確認密碼',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      )
                    : const SizedBox.shrink()),
                
                Obx(() => authController.isRegisterMode.value ? const SizedBox(height: 32) : const SizedBox.shrink()),

                Obx(() => Text(
                      authController.errorMessage.value,
                      style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.error),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 16),

                // 主要按鈕
                Obx(() => _buildAuthButton(
                      themeData: themeData,
                      label: authController.isRegisterMode.value ? '註冊' : '登入',
                      isLoading: authController.isLoading.value,
                      onPressed: () {
                        if (authController.isRegisterMode.value) {
                          authController.signUp(emailController.text.trim(), passwordController.text.trim(), confirmPasswordController.text.trim());
                        } else {
                          authController.signIn(emailController.text.trim(), passwordController.text.trim());
                        }
                      },
                      backgroundColor: themeData.primaryColor,
                    )),
                const SizedBox(height: 20),

                // 模式切換
                Obx(() => GestureDetector(
                      onTap: authController.toggleAuthMode,
                      child: Text.rich(
                        TextSpan(
                          text: authController.isRegisterMode.value ? '已經有帳號了？' : '還沒有帳號？',
                          style: themeData.textTheme.bodyMedium,
                          children: <TextSpan>[
                            TextSpan(
                              text: authController.isRegisterMode.value ? '立即登入' : '立即註冊',
                              style: themeData.textTheme.bodyMedium?.copyWith(
                                color: themeData.primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                const SizedBox(height: 48),
                Text('或使用社群帳號登入', style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.textTheme.bodyMedium?.color)),
                const SizedBox(height: 24),

                // 社群登入按鈕
                _buildSocialAuthButton(
                  themeData: themeData,
                  label: '使用 Google 帳號登入',
                  icon: FontAwesomeIcons.google,
                  color: Colors.white,
                  textColor: themeData.textTheme.bodyLarge?.color,
                  onPressed: authController.isLoading.value ? null : authController.signInWithGoogle,
                ),
                const SizedBox(height: 16),
                // ... 其他社群按鈕 ...
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAuthInputField({
    required IAppTheme theme, // [修改] 接收 IAppTheme
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final themeData = theme.themeData;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // [修正] 使用從主題物件來的方法
      decoration: theme.neumorphicBoxDecoration(isConcave: true, radius: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          icon: Icon(icon, color: themeData.iconTheme.color),
        ),
        style: themeData.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildAuthButton({
    required ThemeData themeData, // [修改] 接收 ThemeData
    required String label,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: themeData.textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildSocialAuthButton({
    required ThemeData themeData, // [修改] 接收 ThemeData
    required String label,
    required IconData icon,
    required Color color,
    required Color? textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        icon: FaIcon(icon, color: textColor ?? themeData.textTheme.bodyLarge?.color),
        label: Text(label, style: themeData.textTheme.titleLarge?.copyWith(color: textColor ?? themeData.textTheme.bodyLarge?.color)),
      ),
    );
  }
}