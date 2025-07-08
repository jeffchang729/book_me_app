// lib/features/auth/auth_screen.dart
// 功能：提供使用者註冊、登入與社群登入的 UI 介面 (現代化動態切換版)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入新的主題路徑
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// `AuthScreen` 提供了應用程式的認證介面，包括註冊、登入和社群帳號登入。
/// 介面支援登入/註冊模式的動態切換，並顯示載入狀態和錯誤訊息。
class AuthScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess; // 登入成功後要執行的回調函數
  final bool initialRegisterMode; // [新增] 控制器初始是否為註冊模式

  const AuthScreen({
    super.key,
    this.onLoginSuccess,
    this.initialRegisterMode = false, // [新增] 預設為登入模式
  });

  @override
  Widget build(BuildContext context) {
    // [修正] 使用 Get.put 創建或查找 AuthController
    // 並在創建時，根據 initialRegisterMode 設定其初始狀態
    final AuthController authController = Get.put(AuthController());
    // [修正] 避免每次 build 都重設 initialRegisterMode
    // 這裡使用 authController 的生命週期來確保只設定一次
    if (!authController.hasBeenInitialized) { // 自定義一個標誌來判斷是否已初始化
      authController.isRegisterMode.value = initialRegisterMode;
      authController.hasBeenInitialized = true; // 設定為已初始化
    }

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController(); 
    final theme = context.theme; // 使用 context.theme 更簡潔

    // 監聽登入成功，然後執行回調並關閉此畫面
    // 使用 once 而非 ever，確保只執行一次
    once(authController.currentUser, (user) { 
      if (user != null && onLoginSuccess != null) {
        // 使用 Get.until 確保回到正確的路由層級，例如 MainScreen
        // 判斷是否需要 Pop 當前 AuthScreen
        if (Get.currentRoute.contains('AuthScreen')) { // 判斷當前路由是否為 AuthScreen
          Get.back(); // Pop AuthScreen
        }
        onLoginSuccess!(); // 執行登入成功回調
      }
    });

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
              _buildAuthInputField(
                context: context,
                controller: emailController,
                hintText: '電子郵件',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // 密碼輸入框
              _buildAuthInputField(
                context: context,
                controller: passwordController,
                hintText: '密碼',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // 確認密碼輸入框：根據模式動態顯示
              Obx(() => authController.isRegisterMode.value
                  ? _buildAuthInputField(
                      context: context,
                      controller: confirmPasswordController,
                      hintText: '確認密碼',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    )
                  : const SizedBox.shrink()), // 如果是登入模式，則隱藏

              // 如果是註冊模式，則多加一個間距
              Obx(() => authController.isRegisterMode.value
                  ? const SizedBox(height: 32) 
                  : const SizedBox.shrink()), 
              
              // 錯誤訊息顯示
              Obx(() => Text(
                    authController.errorMessage.value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error), // 使用主題錯誤色
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 16),

              // 主要的登入/註冊按鈕：根據模式動態切換文字和動作
              Obx(() => _buildAuthButton(
                    context: context,
                    label: authController.isRegisterMode.value ? '註冊' : '登入', // 動態標籤
                    isLoading: authController.isLoading.value,
                    onPressed: () {
                      if (authController.isRegisterMode.value) {
                        authController.signUp(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          confirmPasswordController.text.trim(),
                        );
                      } else {
                        authController.signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                    backgroundColor: theme.primaryColor, // 使用主題主要色
                  )),
              const SizedBox(height: 20),

              // 模式切換連結
              Obx(() => GestureDetector(
                    onTap: authController.toggleAuthMode,
                    child: Text.rich(
                      TextSpan(
                        text: authController.isRegisterMode.value ? '已經有帳號了？' : '還沒有帳號？',
                        style: theme.textTheme.bodyMedium,
                        children: <TextSpan>[
                          TextSpan(
                            text: authController.isRegisterMode.value ? '立即登入' : '立即註冊',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 48), 
              Text('或使用社群帳號登入', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 24),

              // Google 登入按鈕
              _buildSocialAuthButton(
                context: context,
                label: '使用 Google 帳號登入',
                icon: FontAwesomeIcons.google,
                color: Colors.white,
                textColor: theme.textTheme.bodyLarge?.color,
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        authController.signInWithGoogle();
                      },
              ),
              const SizedBox(height: 16),

              // Facebook 登入按鈕
              _buildSocialAuthButton(
                context: context,
                label: '使用 Facebook 帳號登入',
                icon: FontAwesomeIcons.facebookF,
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                onPressed: () {
                  Get.snackbar('功能待開發', 'Facebook 登入功能仍在開發中。', snackPosition: SnackPosition.BOTTOM, backgroundColor: theme.colorScheme.secondary, colorText: theme.colorScheme.onSecondary);
                },
              ),
              const SizedBox(height: 16),

              // LINE 登入按鈕
              _buildSocialAuthButton(
                context: context,
                label: '使用 LINE 帳號登入',
                icon: FontAwesomeIcons.line,
                color: const Color(0xFF06FE06), 
                textColor: Colors.black,
                onPressed: () {
                  Get.snackbar('功能待開發', 'LINE 登入功能仍在開發中，需要後端配合。', snackPosition: SnackPosition.BOTTOM, backgroundColor: theme.colorScheme.secondary, colorText: theme.colorScheme.onSecondary);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 輔助函數：通用的輸入框
  Widget _buildAuthInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          icon: Icon(icon, color: theme.iconTheme.color),
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  // 輔助函數：通用認證按鈕
  Widget _buildAuthButton({
    required BuildContext context,
    required String label,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
    );
  }

  // 輔助函數：社群登入按鈕
  Widget _buildSocialAuthButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color? textColor,
    required VoidCallback? onPressed,
  }) {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: FaIcon(icon, color: textColor ?? theme.textTheme.bodyLarge?.color),
        label: Text(label, style: theme.textTheme.titleLarge?.copyWith(color: textColor ?? theme.textTheme.bodyLarge?.color)),
      ),
    );
  }
}