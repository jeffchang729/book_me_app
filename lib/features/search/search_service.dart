// lib/features/search/search_service.dart
// [改造完成] 功能：移除本地的 URL 判斷邏輯，改為從 AppConfig 讀取統一的 API Base URL。

import 'package:dio/dio.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/core/app_config.dart'; // [新增] 引入我們新的設定檔

class SearchService {
  final Dio _dio = Dio();
  
  // [移除] 不再需要 _apiBaseUrl 這個 getter
  /*
  String get _apiBaseUrl {
    // ... 複雜的 if/else 判斷 ...
  }
  */

  /// 向後端發送 AI 書籍推薦請求。
  Future<List<BookSearchResultItem>> getAiBookRecommendations(String query) async {
    // [改造] 直接使用 AppConfig.apiBaseUrl
    final String endpoint = '${AppConfig.apiBaseUrl}/api/recommendations/book';
    print('--- [SearchService] 發起 AI 推薦請求 ---');
    print('請求 URL: $endpoint');
    print('請求內容 (Query): "$query"');
    
    try {
      final response = await _dio.post(
        endpoint,
        data: {'query': query},
        options: Options(
          receiveTimeout: const Duration(seconds: 45), 
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data is List) {
        final List<dynamic> responseData = response.data;
        return responseData
            .map((item) => BookSearchResultItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('從伺服器獲取 AI 推薦失敗，狀態碼: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[SearchService] AI 推薦請求失敗 (Dio): ${e.message}');
      if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
          throw Exception('AI 思考時間過長或網路連線不穩定，請稍後再試一次。');
      }
      throw Exception('網路請求失敗，請稍後再試。');
    } catch (e) {
      print('[SearchService] AI 推薦請求失敗 (未知錯誤): $e');
      throw Exception('處理推薦時發生未知錯誤。');
    }
  }

  /// 獲取單本書籍的詳細資訊
  Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    // Google Books API 的 URL 保持不變，因為它不是我們的後端服務
    final String endpoint = 'https://www.googleapis.com/books/v1/volumes/$bookId';
    print('--- [SearchService] 獲取書籍詳情 ---');
    print('請求 URL: $endpoint');

    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('獲取書籍詳情失敗，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('[SearchService] 獲取書籍詳情失敗: $e');
      throw Exception('無法獲取書籍詳細資訊。');
    }
  }
}