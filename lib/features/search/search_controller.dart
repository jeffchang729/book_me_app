// lib/features/search/search_controller.dart
// [改造] 功能：管理搜尋邏輯，新增初始狀態判斷。

import 'package:get/get.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/search/search_service.dart';

class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();

  final RxBool isLoading = false.obs;
  final RxList<BookSearchResultItem> searchResults = <BookSearchResultItem>[].obs;
  final RxString errorMessage = ''.obs;

  // [新增] 用於判斷是否是初始狀態（從未執行過搜尋）
  final RxBool isInitialState = true.obs;

  final RxList<String> searchSuggestions = <String>[
    '我想成為更有創造力的產品經理',
    '我想學習如何有效溝通',
    '我想擁有更強的領導力',
    '我想了解最新的AI趨勢',
    '我想探索古典哲學',
    '我想成為更好的投資者',
  ].obs;

  void clearSearch() {
    searchResults.clear();
    errorMessage.value = '';
    isInitialState.value = true; // [新增] 清除時回到初始狀態
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    isLoading.value = true;
    isInitialState.value = false; // [新增] 一旦開始搜尋，就脫離初始狀態
    searchResults.clear();
    errorMessage.value = '';

    try {
      final List<BookSearchResultItem> bookResults = await _searchService.getAiBookRecommendations(query);
      searchResults.assignAll(bookResults);

      if (bookResults.isEmpty) {
        errorMessage.value = '找不到相關的書籍推薦，試試換個問法？';
      }

    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('搜尋失敗', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}