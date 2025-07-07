// lib/features/search/search_models.dart
// 功能：定義應用程式中通用的搜尋結果資料模型。

/// 定義搜尋結果的類型。
/// 由於 BookMe 專案已移除天氣、股票、新聞功能，此處僅保留通用類型。
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
  dynamic get data; // 原始資料物件 (可以是任何類型，具體由子類別決定)
  int get relevance; // 相關性分數 (數字越大表示越相關)

  const UniversalSearchResult();

  /// 將搜尋結果物件轉換為 JSON 格式。
  Map<String, dynamic> toJson();

  /// 從 JSON 格式創建 `UniversalSearchResult` 實例的工廠建構子。
  /// 根據 `type` 欄位來判斷並創建對應的子類別實例。
  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = SearchResultType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => SearchResultType.unsupported, // 如果類型不支援，則使用 unsupported
    );

    try {
      switch (type) {
        case SearchResultType.book:
          // TODO: 未來實作 BookSearchResultItem.fromJson(json)
          // return BookSearchResultItem.fromJson(json);
          return UnsupportedSearchResultItem.fromJson(json); // 暫時回傳不支援類型
        case SearchResultType.user:
          // TODO: 未來實作 UserSearchResultItem.fromJson(json)
          // return UserSearchResultItem.fromJson(json);
          return UnsupportedSearchResultItem.fromJson(json); // 暫時回傳不支援類型
        default:
          return UnsupportedSearchResultItem.fromJson(json); // 預設為不支援類型
      }
    } catch (e, stackTrace) {
      // 捕獲反序列化錯誤，並印出詳細資訊以供偵錯
      print('==================== DESERIALIZATION ERROR ====================');
      print('== ❌ [錯誤] 無法解析類型為: $type 的 JSON 資料');
      print('== [例外] $e');
      print('== [堆疊追蹤] $stackTrace');
      print('== [問題 JSON] $json');
      print('===============================================================');
      return UnsupportedSearchResultItem.fromJson(json); // 錯誤時回傳不支援類型
    }
  }
}

/// `UnsupportedSearchResultItem` 代表一個無法識別或不支援的搜尋結果。
/// 用於處理未知或錯誤的資料類型，避免應用程式崩潰。
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
  final Map<String, dynamic> data; // 儲存原始的 JSON 資料
  @override
  final int relevance;

  const UnsupportedSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 0, // 不支援的項目相關性為 0
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

  /// 從 JSON 格式創建 `UnsupportedSearchResultItem` 實例的工廠建構子。
  factory UnsupportedSearchResultItem.fromJson(Map<String, dynamic> json) {
    return UnsupportedSearchResultItem(
      id: json['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}', // 如果沒有 ID，則生成一個時間戳 ID
      title: json['title'] ?? '未知項目', // 預設標題
      subtitle: json['subtitle'] ?? '此資料已損毀或不支援。', // 預設副標題
      data: const {}, // 預設為空資料
    );
  }
}

// TODO: 未來新增 BookSearchResultItem 和 UserSearchResultItem
/*
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
  final BookData data; // 假設 BookData 是您定義的書籍資料模型
  @override
  final int relevance;

  const BookSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.relevance = 100,
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

  factory BookSearchResultItem.fromJson(Map<String, dynamic> json) {
    return BookSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: BookData.fromJson(json['data']), // 假設您有 BookData.fromJson
      relevance: json['relevance'] ?? 100,
    );
  }
}

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
  final UserProfileData data; // 假設 UserProfileData 是您定義的用戶資料模型
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
      title: json['title'],
      subtitle: json['subtitle'],
      data: UserProfileData.fromJson(json['data']), // 假設您有 UserProfileData.fromJson
      relevance: json['relevance'] ?? 90,
    );
  }
}
*/
