// lib/models/app_user.dart
// 功能：定義應用程式用戶的資料模型，包含追蹤關係。

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String email;
  final String userName; // 用戶的顯示名稱
  final String? userAvatarUrl; // 用戶頭像 URL
  final String? bio; // 個人簡介
  final List<String> following; // 追蹤的用戶 ID 列表
  final List<String> followers; // 追蹤此用戶的用戶 ID 列表
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.userId,
    required this.email,
    required this.userName,
    this.userAvatarUrl,
    this.bio,
    this.following = const [],
    this.followers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 將 AppUser 物件轉換為 Map 格式，以便儲存到 Firestore。
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'bio': bio,
      'following': following,
      'followers': followers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 從 Firestore 的 DocumentSnapshot 創建 AppUser 實例的工廠方法。
  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // 使用 null-safe 檢查

    if (data == null) {
      throw Exception("Document data was null for AppUser ${doc.id}");
    }

    return AppUser(
      userId: doc.id, // 使用 Document ID 作為 userId
      email: data['email'] ?? '',
      userName: data['userName'] ?? '匿名用戶',
      userAvatarUrl: data['userAvatarUrl'],
      bio: data['bio'],
      following: (data['following'] as List?)?.map((item) => item as String).toList() ?? [],
      followers: (data['followers'] as List?)?.map((item) => item as String).toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 創建一個新的 AppUser 實例，用於新用戶註冊時的初始化。
  static AppUser createNew({
    required String userId,
    required String email,
    String? userName,
    String? userAvatarUrl,
  }) {
    final now = DateTime.now();
    return AppUser(
      userId: userId,
      email: email,
      userName: userName ?? email.split('@')[0], // 預設使用 email 的前半部分作為用戶名
      userAvatarUrl: userAvatarUrl,
      createdAt: now,
      updatedAt: now,
    );
  }
}