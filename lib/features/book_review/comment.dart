// lib/features/book_review/comment.dart
// 功能：定義讀書心得留言的資料模型。

import 'package:cloud_firestore/cloud_firestore.dart';

/// `Comment` 代表一則讀書心得的留言資料結構。
/// 它包含了留言者的資訊、留言內容和時間戳。
class Comment {
  final String id; // 留言的唯一識別碼 (Firestore Document ID)
  final String reviewId; // 留言所屬的讀書心得 ID
  final String userId; // 留言者的用戶 ID
  final String userName; // 留言者的用戶名稱
  final String? userAvatarUrl; // 留言者的用戶頭像 URL (可選)
  final String content; // 留言內容
  final DateTime createdAt; // 留言的創建時間
  final DateTime updatedAt; // 留言的最後更新時間

  /// `Comment` 構造函數。
  const Comment({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 將 `Comment` 物件轉換為 Map 格式，以便儲存到 Firestore。
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 從 Firestore 的 DocumentSnapshot 創建 `Comment` 實例的工廠方法。
  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id, // 使用 Document ID 作為留言 ID
      reviewId: data['reviewId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '匿名用戶',
      userAvatarUrl: data['userAvatarUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 創建一個新的 `Comment` 實例，用於新增時的初始化。
  static Comment createNew({
    required String reviewId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
  }) {
    final now = DateTime.now();
    return Comment(
      id: '', // 新增時 ID 為空，Firestore 會自動生成
      reviewId: reviewId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  // [新增] copyWith 方法
  Comment copyWith({
    String? id,
    String? reviewId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}