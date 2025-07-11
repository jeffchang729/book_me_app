// lib/features/search/search_models.dart
// 功能：定義應用程式中通用的搜尋結果資料模型，並新增具體的書籍與用戶模型。

import 'package:book_me_app/models/app_user.dart'; // 引入 AppUser 模型
import 'package:book_me_app/features/book_review/book_review.dart'; // 引入 BookReview 模型

/// 定義搜尋結果的類型。
enum SearchResultType {
  book, // 書籍搜尋結果
  user, // 用戶搜尋結果
  unsupported, // 不支援的搜尋結果類型
}

/// 抽象類別 `UniversalSearchResult` 定義了所有搜尋結果的通用介面。
/// 每個具體的搜尋結果類型都必須實現這些屬性。
abstract class UniversalSearchResult {
  String get id; // 唯一識別碼
  SearchResultType get type; // 搜尋結果類型
  String get title; // 標題
  String get subtitle; // 副標題
  dynamic get data; // 原始資料物件
  int get relevance; // 相關性分數

  const UniversalSearchResult();

  /// 將搜尋結果物件轉換為 JSON 格式。
  Map<String, dynamic> toJson();

  /// 從 JSON 格式創建 `UniversalSearchResult` 實例的工廠建構子。
  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = SearchResultType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => SearchResultType.unsupported,
    );

    try {
      switch (type) {
        case SearchResultType.book:
          return BookSearchResultItem.fromJson(json); // [實作] 使用 BookSearchResultItem
        case SearchResultType.user:
          return UserSearchResultItem.fromJson(json); // [實作] 使用 UserSearchResultItem
        default:
          return UnsupportedSearchResultItem.fromJson(json);
      }
    } catch (e, stackTrace) {
      print('==================== DESERIALIZATION ERROR ====================');
      print('== ❌ [錯誤] 無法解析類型為: $type 的 JSON 資料');
      print('== [例外] $e');
      print('== [堆疊追蹤] $stackTrace');
      print('== [問題 JSON] $json');
      print('===============================================================');
      return UnsupportedSearchResultItem.fromJson(json);
    }
  }
}

/// [新增] 書籍搜尋結果項目
class BookSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.book;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final Map<String, dynamic> data; // 可儲存如 bookId, coverUrl 等原始資訊
  @override
  final int relevance;
  final String? recommendationReason; // AI 推薦理由

  const BookSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 100,
    this.recommendationReason,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data,
        'relevance': relevance,
        'recommendationReason': recommendationReason,
      };

  factory BookSearchResultItem.fromJson(Map<String, dynamic> json) {
    return BookSearchResultItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '無標題書籍',
      subtitle: json['subtitle'] ?? '未知作者',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      relevance: json['relevance'] ?? 100,
      recommendationReason: json['recommendationReason'],
    );
  }
}

/// [新增] 用戶搜尋結果項目
class UserSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.user;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final AppUser data; // 直接使用 AppUser 模型
  @override
  final int relevance;

  const UserSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 90,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data.toJson(),
        'relevance': relevance,
      };

  factory UserSearchResultItem.fromJson(Map<String, dynamic> json) {
    return UserSearchResultItem(
      id: json['id'],
      title: json['title'] ?? '匿名用戶',
      subtitle: json['subtitle'] ?? '',
      data: AppUser.fromDocument(json['data']),
      relevance: json['relevance'] ?? 90,
    );
  }
}


/// `UnsupportedSearchResultItem` 代表一個無法識別或不支援的搜尋結果。
class UnsupportedSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.unsupported;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final Map<String, dynamic> data;
  @override
  final int relevance;

  const UnsupportedSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 0,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data,
        'relevance': relevance,
      };

  factory UnsupportedSearchResultItem.fromJson(Map<String, dynamic> json) {
    return UnsupportedSearchResultItem(
      id: json['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '未知項目',
      subtitle: json['subtitle'] ?? '此資料已損毀或不支援。',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}