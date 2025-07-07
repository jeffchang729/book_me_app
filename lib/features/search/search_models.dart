// lib/features/search/search_models.dart
// [體驗重構 V4.8]
// 功能：為新聞搜尋結果新增 topic 欄位，以支援主題式分組。

import 'package:book_me_app/features/news/news_models.dart';
import 'package:book_me_app/features/weather/weather_models.dart';

enum SearchResultType {
  weather,
  stock,
  news,
  event,
  unsupported,
}

abstract class UniversalSearchResult {
  String get id;
  SearchResultType get type;
  String get title;
  String get subtitle;
  dynamic get data;
  int get relevance;

  const UniversalSearchResult();

  Map<String, dynamic> toJson();

  factory UniversalSearchResult.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = SearchResultType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => SearchResultType.unsupported,
    );

    try {
      switch (type) {
        case SearchResultType.weather:
          return WeatherSearchResultItem.fromJson(json);
        case SearchResultType.stock:
          return StockSearchResultItem.fromJson(json);
        case SearchResultType.news:
          return NewsSearchResultItem.fromJson(json);
        default:
          return UnsupportedSearchResultItem.fromJson(json);
      }
    } catch (e, stackTrace) {
      print('==================== DESERIALIZATION ERROR ====================');
      print('== ❌ [Error] Failed to parse JSON for type: $type');
      print('== [Exception] $e');
      print('== [StackTrace] $stackTrace');
      print('== [Problematic JSON] $json');
      print('===============================================================');
      return UnsupportedSearchResultItem.fromJson(json);
    }
  }
}

class NewsSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.news;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final PostData data;
  @override
  final int relevance;

  // [新增] 用於標記此新聞條目所屬的主題（來自哪個搜尋關鍵字）
  final String topic;

  const NewsSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.topic, // [新增]
    this.relevance = 80,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'subtitle': subtitle,
        'data': data.toJson(),
        'topic': topic, // [新增]
        'relevance': relevance,
      };

  factory NewsSearchResultItem.fromJson(Map<String, dynamic> json) {
    return NewsSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: PostData.fromJson(json['data']),
      // [新增] 從 JSON 中讀取 topic，如果不存在則給一個預設值
      topic: json['topic'] ?? '未知主題',
      relevance: json['relevance'] ?? 80,
    );
  }
}

// ... 其餘模型 (Unsupported, Weather, Stock) 保持不變 ...
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
      title: json['title'] ?? '未知卡片',
      subtitle: json['subtitle'] ?? '此資料已損毀或不支援。',
      data: const {},
    );
  }
}

class WeatherSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.weather;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final WeatherCardData data;
  @override
  final int relevance;

  const WeatherSearchResultItem({
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

  factory WeatherSearchResultItem.fromJson(Map<String, dynamic> json) {
    return WeatherSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: WeatherCardData.fromJson(json['data']),
      relevance: json['relevance'] ?? 90,
    );
  }
}

class StockSearchResultItem extends UniversalSearchResult {
  @override
  final String id;
  @override
  final SearchResultType type = SearchResultType.stock;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final Map<String, dynamic> data;
  @override
  final int relevance;

  const StockSearchResultItem({
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
        'data': data,
        'relevance': relevance,
      };

  factory StockSearchResultItem.fromJson(Map<String, dynamic> json) {
    return StockSearchResultItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      data: Map<String, dynamic>.from(json['data']),
      relevance: json['relevance'] ?? 100,
    );
  }
}
