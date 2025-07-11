// lib/features/search/search_controller.dart
// 功能：管理搜尋邏輯，透過 SearchService 獲取 AI 推薦與搜尋結果。

import 'package:get/get.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/search/search_service.dart';

/// `SearchController` 負責處理應用程式中的搜尋功能。
/// 它透過注入的 `SearchService` 來執行 AI 推薦與傳統搜尋，並管理相關的 UI 狀態。
class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, List<UniversalSearchResult>> searchResults = <String, List<UniversalSearchResult>>{}.obs;

  // [修改] 更新搜尋建議列表，使其更貼近「我想成為的人」這個核心概念
  final RxList<String> searchSuggestions = <String>[
    '我想成為像伊隆·馬斯克一樣的創業家',
    '我想成為一名有影響力的大律師',
    '我想成為一位能溫暖病人的醫師',
    '我想成為更有創造力的產品經理',
    '我想學習如何有效溝通',
    '我想擁有更強的領導力',
  ].obs;

  /// 清空當前的搜尋結果。
  void clearSearch() {
    searchResults.clear();
  }
  
  /// 執行搜尋操作。
  /// @param query - 用戶輸入的搜尋關鍵字或自然語言查詢。
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    isLoading.value = true;
    searchResults.clear();
    
    try {
      final List<BookSearchResultItem> bookResults = await _searchService.getAiBookRecommendations(query);
      
      final Map<String, List<UniversalSearchResult>> results = {};

      if (bookResults.isNotEmpty) {
        results['AI 為您推薦的書籍'] = bookResults;
      } else {
        results['無符合的 AI 推薦'] = [];
      }
      
      searchResults.assignAll(results);
    } catch (e) {
      Get.snackbar('搜尋失敗', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
