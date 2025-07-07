// lib/features/auth/auth_service.dart
// 功能：封裝與 Firebase Authentication 的互動邏輯，新增 Google 登入。

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 引入 Google 登入套件

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // 獲取 GoogleSignIn 實例

  // 監聽用戶登入狀態的 Stream。每當用戶登入或登出時，這個 Stream 都會發出一個新的 User 物件 (或 null)。
  // 這對於在 APP 中即時反映登入狀態非常有用。
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // 使用電子郵件和密碼註冊新用戶
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('認證錯誤 (註冊): ${e.code} - ${e.message}');
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
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('認證錯誤 (登入): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('未知錯誤 (登入): ${e.toString()}');
      return null;
    }
  }

  // 使用 Google 帳號登入/註冊
  Future<User?> signInWithGoogle() async {
    try {
      // 觸發 Google 登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 用戶取消了 Google 登入
        return null;
      }

      // 從 Google 帳號中獲取認證資訊
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 建立一個新的 Firebase 憑證
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用 Firebase 憑證登入 Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth 錯誤 (Google 登入): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Google 登入未知錯誤: ${e.toString()}');
      return null;
    }
  }

  // 登出
  Future<void> signOut() async {
    await _auth.signOut();
    // 如果用戶是透過 Google 登入的，也要登出 Google 帳號
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }
}
