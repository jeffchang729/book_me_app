// lib/features/auth/auth_controller.dart
// 功能：管理認證相關的 UI 狀態和邏輯，處理用戶輸入，並呼叫 AuthService。

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 引入 Firebase User 類型
import 'package:book_me_app/features/auth/auth_service.dart'; // 引入我們剛剛建立的服務
import 'dart:async'; // [新增] 引入 dart:async 以使用 StreamSubscription

class AuthController extends GetxController {
  // 透過 Get.find() 獲取 AuthService 的實例
  final AuthService _authService = Get.find<AuthService>();

  // 觀察者變數，用於管理 UI 狀態
  final RxBool isLoading = false.obs; // 是否正在處理認證請求
  final RxString errorMessage = ''.obs; // 認證錯誤訊息

  // [修正 1] 使用 Rx<User?> 來持有 Stream 的最新值，並初始化為 null。
  // 這個變數將響應式地更新當前登入用戶的狀態。
  final Rx<User?> _currentUser = Rx<User?>(null); 
  // 用於管理 Stream 的訂閱，確保在控制器銷毀時取消訂閱，防止內存洩漏。
  StreamSubscription<User?>? _userSubscription; 

  // [修正 1] 提供一個公開的 Getter，讓 UI 或其他控制器可以監聽當前用戶的變化。
  Rx<User?> get currentUser => _currentUser;

  @override
  void onInit() {
    super.onInit();
    // [修正 1] 訂閱 _authService.user Stream，並將 Stream 發出的最新值賦值給 _currentUser.value。
    _userSubscription = _authService.user.listen((user) {
      _currentUser.value = user;
    });
  }

  @override
  void onClose() {
    _userSubscription?.cancel(); // 在控制器銷毀時取消訂閱，防止內存洩漏
    super.onClose();
  }

  // 註冊功能
  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = ''; // 清空之前的錯誤訊息
    User? user = await _authService.signUpWithEmail(email, password);
    if (user == null) {
      // 這裡可以根據 AuthService 捕獲的 FirebaseAuthException 訊息，提供更精確的錯誤提示
      errorMessage.value = '註冊失敗，請檢查電子郵件或密碼。'; 
    } else {
      // [修正 2] 移除對 Colors.white 的直接引用，改為使用 Get.theme.colorScheme.onPrimary
      // 或直接使用 Get.snackbar 預設的文字顏色（通常是白色或黑色，與背景色對比）
      Get.snackbar(
        '註冊成功', 
        '歡迎加入 BookMe！', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Get.theme.primaryColor, 
        colorText: Get.theme.colorScheme.onPrimary // 這是 GetX 獲取主題文字顏色的標準方式
      );
    }
    isLoading.value = false;
  }

  // 登入功能
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    User? user = await _authService.signInWithEmail(email, password);
    if (user == null) {
      errorMessage.value = '登入失敗，請檢查電子郵件或密碼。';
    } else {
      // [修正 2] 同樣地，移除對 Colors.white 的直接引用
      Get.snackbar(
        '登入成功', 
        '歡迎回來！', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Get.theme.primaryColor, 
        colorText: Get.theme.colorScheme.onPrimary // 這是 GetX 獲取主題文字顏色的標準方式
      );
    }
    isLoading.value = false;
  }

  // 登出功能
  Future<void> signOut() async {
    await _authService.signOut();
  }
}