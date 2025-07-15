// lib/features/auth/auth_screen.dart
// [修正完成] 功能：使用者認證畫面，採用分離式擬物化風格並修正 API 呼叫。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';

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
        if (Get.currentRoute.contains('AuthScreen')) { // [修正]
          Get.back();
        }
        onLoginSuccess!();
      }
    });

    return Obx(() {
      final IAppTheme theme = appController.currentTheme.value;

      return Scaffold(
        backgroundColor: theme.primaryBackgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Obx(() => _buildAuthForm(
                    theme: theme, 
                    authController: authController, 
                    emailController: emailController, 
                    passwordController: passwordController, 
                    confirmPasswordController: confirmPasswordController
                  )),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAuthForm({
    required IAppTheme theme,
    required AuthController authController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
  }) {
    final bool isRegister = authController.isRegisterMode.value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('BookMe', style: theme.themeData.textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          isRegister ? '創建您的知識帳戶' : '歡迎回來',
          style: theme.themeData.textTheme.headlineSmall?.copyWith(color: theme.themeData.textTheme.bodyMedium?.color),
        ),
        const SizedBox(height: 48),

        _buildAuthInputField(
          theme: theme,
          controller: emailController,
          hintText: '電子郵件',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildAuthInputField(
          theme: theme,
          controller: passwordController,
          hintText: '密碼',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isRegister ? 88 : 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildAuthInputField(
                  theme: theme,
                  controller: confirmPasswordController,
                  hintText: '確認密碼',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 20,
          child: Text(
            authController.errorMessage.value,
            style: theme.themeData.textTheme.bodyMedium?.copyWith(color: theme.themeData.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        _buildAuthButton(
          theme: theme,
          label: isRegister ? '註冊' : '登入',
          isLoading: authController.isLoading.value,
          onPressed: () {
            if (isRegister) {
              authController.signUp(emailController.text.trim(), passwordController.text.trim(), confirmPasswordController.text.trim());
            } else {
              authController.signIn(emailController.text.trim(), passwordController.text.trim());
            }
          },
        ),
        const SizedBox(height: 24),
        
        _buildToggleModeText(authController, theme),
        const SizedBox(height: 32),

        Text('或使用社群帳號登入', style: theme.themeData.textTheme.bodyMedium),
        const SizedBox(height: 24),

        _buildSocialAuthButton(
          theme: theme,
          label: '使用 Google 帳號',
          icon: FontAwesomeIcons.google,
          onPressed: authController.isLoading.value ? null : authController.signInWithGoogle,
        ),
      ],
    );
  }

  Widget _buildAuthInputField({
    required IAppTheme theme,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: theme.neumorphicBoxDecoration(
        isConcave: true,
        radius: 20,
        color: theme.secondaryBackgroundColor,
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            icon: Icon(icon, color: theme.themeData.iconTheme.color),
            hintStyle: theme.themeData.textTheme.bodyMedium,
          ),
          style: theme.themeData.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IAppTheme theme,
    required String label,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Ink(
          decoration: theme.neumorphicBoxDecoration(
            radius: 20,
            color: theme.themeData.primaryColor,
            gradient: LinearGradient(
              colors: [theme.themeData.primaryColor, const Color(0xFF6A95FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(label, style: theme.themeData.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialAuthButton({
    required IAppTheme theme,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
         onPressed: onPressed,
         style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
         child: Ink(
          decoration: theme.neumorphicBoxDecoration(
            radius: 20,
            color: theme.secondaryBackgroundColor,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: theme.themeData.textTheme.bodyLarge?.color, size: 20),
                const SizedBox(width: 12),
                Text(label, style: theme.themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleModeText(AuthController authController, IAppTheme theme) {
    return GestureDetector(
      onTap: authController.toggleAuthMode,
      child: Text.rich(
        TextSpan(
          text: authController.isRegisterMode.value ? '已經有帳號了？ ' : '還沒有帳號？ ',
          style: theme.themeData.textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(
              text: authController.isRegisterMode.value ? '立即登入' : '立即註冊',
              style: theme.themeData.textTheme.bodyMedium?.copyWith(
                color: theme.themeData.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}