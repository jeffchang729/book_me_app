// lib/features/auth/auth_service.dart
// 功能：封裝與 Firebase Authentication 的互動邏輯

import 'package:firebase_auth/firebase_auth.dart'; // 引入 Firebase Authentication

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // 獲取 FirebaseAuth 實例

  // 監聽用戶登入狀態的 Stream。每當用戶登入或登出時，這個 Stream 都會發出一個新的 User 物件 (或 null)。
  // 這對於在 APP 中即時反映登入狀態非常有用。
  Stream<User?> get user {
    return _auth.authStateChanges(); // Firebase 提供監聽認證狀態變化的 Stream
  }

  // 使用電子郵件和密碼註冊新用戶
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // 返回註冊成功的用戶資訊
    } on FirebaseAuthException catch (e) {
      // 處理 Firebase 認證錯誤，例如：電子郵件格式無效、密碼過弱、電子郵件已被使用
      print('認證錯誤 (註冊): ${e.code} - ${e.message}');
      // 您可以在這裡拋出更具體的應用程式級別錯誤或返回 null
      return null;
    } catch (e) {
      print('未知錯誤 (註冊): ${e.toString()}');
      return null;
    }
  }

  // 使用電子郵件和密碼登入
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // 返回登入成功的用戶資訊
    } on FirebaseAuthException catch (e) {
      print('認證錯誤 (登入): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('未知錯誤 (登入): ${e.toString()}');
      return null;
    }
  }

  // 用戶登出
  Future<void> signOut() async {
    await _auth.signOut();
  }
}