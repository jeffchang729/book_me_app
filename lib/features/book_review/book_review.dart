// lib/features/book_review/book_review.dart
// 功能：定義讀書心得的資料模型。

import 'package:cloud_firestore/cloud_firestore.dart';

/// `BookReview` 代表一個讀書心得的資料結構。
/// 它包含了書籍和心得的詳細資訊，以及用戶和時間相關的屬性。
class BookReview {
  final String id; // 讀書心得的唯一識別碼 (通常是 Firestore Document ID)
  final String userId; // 發布此心得的用戶 ID
  final String userName; // 發布此心得的用戶名稱 (快取用，方便顯示)
  final String? userAvatarUrl; // 用戶頭像 URL (可選，方便顯示)
  
  final String bookTitle; // 書籍標題
  final String bookAuthor; // 書籍作者
  final String? bookCoverUrl; // 書籍封面圖片 URL (可選)
  
  final String reviewContent; // 讀書心得的內容
  final List<String>? quotes; // 心得中的金句摘錄列表 (可選)
  final List<String>? tags; // 心得的標籤列表 (可選)
  
  final bool isPublic; // 心得是否公開 (true: 公開, false: 私有)
  final int likesCount; // 按讚數
  final List<String> likedBy; // 按讚用戶的 ID 列表
  final int commentsCount; // 留言數
  
  final DateTime createdAt; // 心得的創建時間
  final DateTime updatedAt; // 心得的最後更新時間

  /// `BookReview` 構造函數。
  const BookReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    required this.reviewContent,
    this.quotes,
    this.tags,
    this.isPublic = true, // 預設為公開
    this.likesCount = 0,
    this.likedBy = const [], // 預設為空列表
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 將 `BookReview` 物件轉換為 Map 格式，以便儲存到 Firestore。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'reviewContent': reviewContent,
      'quotes': quotes,
      'tags': tags,
      'isPublic': isPublic,
      'likesCount': likesCount,
      'likedBy': likedBy, // 確保 likedBy 被正確儲存
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt), // 將 DateTime 轉換為 Firestore Timestamp
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 從 Firestore 的 DocumentSnapshot 創建 `BookReview` 實例的工廠方法。
  factory BookReview.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookReview(
      id: doc.id, // 使用 Document ID 作為心得 ID
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '未知用戶',
      userAvatarUrl: data['userAvatarUrl'],
      bookTitle: data['bookTitle'] ?? '無標題書籍',
      bookAuthor: data['bookAuthor'] ?? '未知作者',
      bookCoverUrl: data['bookCoverUrl'],
      reviewContent: data['reviewContent'] ?? '',
      quotes: (data['quotes'] as List?)?.map((item) => item as String).toList(),
      tags: (data['tags'] as List?)?.map((item) => item as String).toList(),
      isPublic: data['isPublic'] ?? true,
      likesCount: data['likesCount'] ?? 0,
      likedBy: (data['likedBy'] as List?)?.map((item) => item as String).toList() ?? [], // 確保 likedBy 被正確讀取
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 創建一個新的 `BookReview` 實例，用於新增時的初始化。
  /// @param userId - 用戶 ID。
  /// @param userName - 用戶名稱。
  /// @param bookTitle - 書籍標題。
  /// @param bookAuthor - 書籍作者。
  /// @param reviewContent - 心得內容。
  /// @returns 新的 `BookReview` 實例。
  static BookReview createNew({
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String bookTitle,
    required String bookAuthor,
    String? bookCoverUrl,
    required String reviewContent,
    List<String>? quotes,
    List<String>? tags,
    bool isPublic = true,
  }) {
    final now = DateTime.now();
    return BookReview(
      id: '', // 新增時 ID 為空，Firestore 會自動生成
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      bookCoverUrl: bookCoverUrl,
      reviewContent: reviewContent,
      quotes: quotes,
      tags: tags,
      isPublic: isPublic,
      // 新增時，likesCount, likedBy, commentsCount 預設為 0 或空
      likesCount: 0,
      likedBy: const [],
      commentsCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  // 複製構造函數，用於更新不可變物件的特定屬性
  BookReview copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    String? reviewContent,
    List<String>? quotes,
    List<String>? tags,
    bool? isPublic,
    int? likesCount,
    List<String>? likedBy,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      reviewContent: reviewContent ?? this.reviewContent,
      quotes: quotes ?? this.quotes,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}