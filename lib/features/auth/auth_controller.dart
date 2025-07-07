// lib/features/auth/auth_controller.dart
// 功能：管理認證相關的 UI 狀態和邏輯，處理用戶輸入，並呼叫 AuthService。

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_me_app/features/auth/auth_service.dart';
import 'dart:async';

/// `AuthController` 負責管理應用程式的認證狀態和邏輯。
/// 它處理用戶的註冊、登入、登出操作，並管理相關的 UI 狀態（如載入中、錯誤訊息）。
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>(); // 注入認證服務

  final RxBool isLoading = false.obs; // 是否正在處理認證請求
  final RxString errorMessage = ''.obs; // 認證錯誤訊息

  // 觀察者變數，用於控制 AuthScreen 的模式：false 為登入模式，true 為註冊模式
  final RxBool isRegisterMode = false.obs; 

  final Rx<User?> _currentUser = Rx<User?>(null); 
  StreamSubscription<User?>? _userSubscription; 

  Rx<User?> get currentUser => _currentUser;

  @override
  void onInit() {
    super.onInit();
    // 監聽 Firebase Authentication 的用戶狀態變化
    _userSubscription = _authService.user.listen((user) {
      _currentUser.value = user;
    });
  }

  @override
  void onClose() {
    _userSubscription?.cancel(); // 在控制器關閉時取消訂閱，防止記憶體洩漏
    super.onClose();
  }

  /// 切換登入/註冊模式的方法。
  void toggleAuthMode() {
    isRegisterMode.value = !isRegisterMode.value;
    errorMessage.value = ''; // 切換模式時清空錯誤訊息
  }

  /// 處理新用戶註冊功能。
  Future<void> signUp(String email, String password, String confirmPassword) async {
    isLoading.value = true;
    errorMessage.value = ''; 

    if (password != confirmPassword) {
      errorMessage.value = '密碼與確認密碼不一致。';
      isLoading.value = false;
      return; 
    }

    User? user = await _authService.signUpWithEmail(email, password);
    if (user == null) {
      // 這裡可以根據 AuthService 捕獲的 FirebaseAuthException 訊息，提供更精確的錯誤提示
      errorMessage.value = '註冊失敗，請檢查電子郵件或密碼。'; 
    } else {
      Get.snackbar(
        '註冊成功', 
        '歡迎加入 BookMe！', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Get.theme.primaryColor, 
        colorText: Get.theme.colorScheme.onPrimary
      );
      // 註冊成功後，不需要額外導航，因為 currentUser 的變化會觸發 AuthScreen 的 once 監聽
    }
    isLoading.value = false;
  }

  /// 處理電子郵件登入功能。
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    User? user = await _authService.signInWithEmail(email, password);
    if (user == null) {
      errorMessage.value = '登入失敗，請檢查電子郵件或密碼。';
    } else {
      Get.snackbar(
        '登入成功', 
        '歡迎回來！', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Get.theme.primaryColor, 
        colorText: Get.theme.colorScheme.onPrimary
      );
      // 登入成功後，不需要額外導航，因為 currentUser 的變化會觸發 AuthScreen 的 once 監聽
    }
    isLoading.value = false;
  }

  /// 處理 Google 登入功能。
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    User? user = await _authService.signInWithGoogle();
    if (user == null) {
      errorMessage.value = 'Google 登入失敗，請稍後再試。';
    } else {
      Get.snackbar('Google 登入成功', '歡迎回來！', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.primaryColor, colorText: Get.theme.colorScheme.onPrimary);
      // Google 登入成功後，不需要額外導航，因為 currentUser 的變化會觸發 AuthScreen 的 once 監聽
    }
    isLoading.value = false;
  }

  /// 處理登出功能。
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
