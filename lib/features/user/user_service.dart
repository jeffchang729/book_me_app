// lib/features/user/user_service.dart
// 功能：處理與 Firestore 'users' 集合相關的數據操作，包括用戶資料和追蹤關係。

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_me_app/models/app_user.dart'; // 引入 AppUser 模型

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 獲取單一用戶的資料
  Future<AppUser?> fetchUser(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return AppUser.fromDocument(docSnapshot);
      }
      return null;
    } catch (e) {
      print('錯誤：獲取用戶 $userId 資料失敗: $e');
      return null;
    }
  }

  // 創建新用戶資料 (在用戶首次登入或註冊時呼叫)
  Future<void> createUserProfile(User firebaseUser) async {
    final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDocRef.get();

    if (!docSnapshot.exists) {
      // 如果用戶資料不存在，則創建一個新的
      final newUser = AppUser.createNew(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        userName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0],
        userAvatarUrl: firebaseUser.photoURL,
      );
      await userDocRef.set(newUser.toJson());
      print('為新用戶 ${firebaseUser.uid} 創建了個人檔案。');
    } else {
      // 如果資料已存在，可以選擇更新部分欄位，例如 userName 或 userAvatarUrl
      // 這裡簡單示範更新 updatedAt
      await userDocRef.update({'updatedAt': Timestamp.now()});
      print('用戶 ${firebaseUser.uid} 的個人檔案已存在，更新了時間戳。');
    }
  }

  // 獲取所有用戶的資料 (用於首頁朋友列表、探索頁面等)
  Future<List<AppUser>> fetchAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => AppUser.fromDocument(doc)).toList();
    } catch (e) {
      print('錯誤：獲取所有用戶資料失敗: $e');
      return [];
    }
  }

  // 追蹤/取消追蹤用戶
  Future<bool> toggleFollow(String currentUserId, String targetUserId, bool isFollowing) async {
    if (currentUserId == targetUserId) {
      print('不能追蹤自己');
      return false;
    }

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserDoc = await transaction.get(currentUserRef);
        final targetUserDoc = await transaction.get(targetUserRef);

        if (!currentUserDoc.exists || !targetUserDoc.exists) {
          throw Exception("用戶資料不存在。");
        }

        AppUser currentUser = AppUser.fromDocument(currentUserDoc);
        AppUser targetUser = AppUser.fromDocument(targetUserDoc);

        if (isFollowing) {
          // 如果當前是追蹤狀態，則執行取消追蹤
          currentUser.following.remove(targetUserId);
          targetUser.followers.remove(currentUserId);
          print('用戶 $currentUserId 取消追蹤 $targetUserId');
        } else {
          // 如果當前是未追蹤狀態，則執行追蹤
          if (!currentUser.following.contains(targetUserId)) {
            currentUser.following.add(targetUserId);
          }
          if (!targetUser.followers.contains(currentUserId)) {
            targetUser.followers.add(currentUserId);
          }
          print('用戶 $currentUserId 追蹤了 $targetUserId');
        }

        transaction.update(currentUserRef, {
          'following': currentUser.following,
          'updatedAt': Timestamp.now(),
        });
        transaction.update(targetUserRef, {
          'followers': targetUser.followers,
          'updatedAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      print('追蹤/取消追蹤失敗: $e');
      return false;
    }
  }
}
