// lib/features/search/search_service.dart
// 功能：提供與後端搜尋、推薦功能相關的 API 請求服務，並加入詳細日誌。

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert'; // 用於 jsonEncode

import 'package:book_me_app/features/search/search_models.dart';

class SearchService {
  final Dio _dio = Dio();
  
  String get _apiBaseUrl {
    // [重要] 當後端部署到 Cloud Run 後，請將此處替換為您的 Cloud Run 服務網址
    // 例如：'https://recommendation-service-xxxxxxxx-an.a.run.app'
    const String cloudRunUrl = ''; 

    if (cloudRunUrl.isNotEmpty) {
      return cloudRunUrl;
    }

    // ----- 以下為本機開發的備用邏輯 -----
    const String realDeviceIp = '';
    if (kDebugMode && !kIsWeb && realDeviceIp.isNotEmpty) {
      return 'http://$realDeviceIp:3000';
    }
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  /// 向後端發送 AI 書籍推薦請求。
  Future<List<BookSearchResultItem>> getAiBookRecommendations(String query) async {
    final String endpoint = '$_apiBaseUrl/api/recommendations/book';
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

  /// [新增] 獲取單本書籍的詳細資訊
  Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    // 注意：此處直接呼叫 Google Books API，因為 API Key 是公開的，且通常不會有 CORS 問題。
    // 如果未來遇到問題，也可以為此建立一個後端代理。
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
