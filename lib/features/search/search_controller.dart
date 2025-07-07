// lib/features/search/search_controller.dart
// 功能：管理搜尋邏輯，處理用戶輸入並提供搜尋建議和結果。

import 'package:get/get.dart';
import 'package:book_me_app/features/search/search_models.dart';
// 移除舊的服務引用
// import 'package:book_me_app/core/fake_data_service.dart';
// import 'package:book_me_app/features/stock/stock_service.dart';
// import 'package:book_me_app/features/weather/weather_service.dart';
// import 'package:book_me_app/features/news/news_models.dart';

/// `SearchController` 負責處理應用程式中的搜尋功能。
/// 它管理搜尋的載入狀態、搜尋結果和搜尋建議。
/// 由於 BookMe 專案已移除天氣、股票、新聞功能，此控制器已簡化為通用搜尋。
class SearchController extends GetxController {
  // 移除舊的服務注入
  // final WeatherService _weatherService = Get.find<WeatherService>();
  // final StockService _stockService = Get.find<StockService>();
  // final FakeDataService _fakeDataService = Get.find<FakeDataService>();

  final RxBool isLoading = false.obs; // 搜尋是否正在載入中
  // 搜尋結果，鍵為結果分組標題 (例如 "書籍", "用戶")，值為對應的搜尋結果列表。
  final RxMap<String, List<UniversalSearchResult>> searchResults = <String, List<UniversalSearchResult>>{}.obs;

  // 搜尋建議列表
  final RxList<String> searchSuggestions = <String>[
    '三體', // 書籍建議
    '村上春樹', // 作者/用戶建議
    '軟體工程', // 書籍類別建議
    '讀書心得社群', // 用戶/社群建議
    'AI 與未來', // 書籍主題建議
  ].obs;

  /// 清空當前的搜尋結果。
  void clearSearch() {
    searchResults.clear();
  }
  
  /// 執行搜尋操作。
  /// 根據關鍵字模擬搜尋書籍和用戶。
  /// @param keyword - 用戶輸入的搜尋關鍵字。
  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      clearSearch(); // 如果關鍵字為空，則清空結果
      return;
    }
    isLoading.value = true; // 設定載入狀態為 true
    searchResults.clear(); // 清空之前的搜尋結果
    
    // 故意延遲以改善使用者體驗，避免快速閃爍
    await Future.delayed(const Duration(milliseconds: 300));

    final Map<String, List<UniversalSearchResult>> results = {};
    final String cleanedKeyword = keyword.trim().toLowerCase(); // 轉換為小寫以便比對

    // 模擬書籍搜尋結果
    if (cleanedKeyword.contains('書') || cleanedKeyword.contains('三體') || cleanedKeyword.contains('軟體')) {
      results['書籍'] = _generateFakeBookResults(cleanedKeyword);
    }

    // 模擬用戶搜尋結果
    if (cleanedKeyword.contains('用戶') || cleanedKeyword.contains('村上') || cleanedKeyword.contains('社群')) {
      results['用戶'] = _generateFakeUserResults(cleanedKeyword);
    }

    // 如果沒有特定關鍵字，則顯示一些預設的書籍和用戶結果
    if (results.isEmpty) {
      results['熱門書籍'] = _generateFakeBookResults('熱門');
      results['推薦用戶'] = _generateFakeUserResults('推薦');
    }
    
    searchResults.assignAll(results); // 更新搜尋結果
    isLoading.value = false; // 設定載入狀態為 false
  }

  /// 模擬生成假書籍搜尋結果。
  /// TODO: 未來將替換為呼叫後端 Book Service 獲取真實數據。
  List<UniversalSearchResult> _generateFakeBookResults(String query) {
    return List.generate(3, (index) {
      final bookTitles = ['三體：地球往事', '軟體工程師的成長之路', 'Flutter 實戰指南', '原子習慣', '人類大歷史'];
      final authors = ['劉慈欣', '李明', '陳小華', '詹姆斯·克利爾', '尤瓦爾·諾亞·赫拉利'];
      final title = bookTitles[index % bookTitles.length];
      final author = authors[index % authors.length];
      return UnsupportedSearchResultItem( // 暫時使用 UnsupportedSearchResultItem
        id: 'book_${query.hashCode}_$index',
        title: title,
        subtitle: '作者：$author',
        data: {'book_id': 'book_$index', 'title': title, 'author': author},
        relevance: 100 - index * 5,
      );
    });
  }

  /// 模擬生成假用戶搜尋結果。
  /// TODO: 未來將替換為呼叫後端 User Service 獲取真實數據。
  List<UniversalSearchResult> _generateFakeUserResults(String query) {
    return List.generate(2, (index) {
      final userNames = ['讀書人阿華', '書蟲小明', '知識分享家', '程式碼與書', 'AI 讀書筆記'];
      final bio = ['熱愛閱讀與程式設計', '分享每日讀書心得', '專注於科技與人文', '我的讀書旅程', 'AI 領域的探索者'];
      final userName = userNames[index % userNames.length];
      return UnsupportedSearchResultItem( // 暫時使用 UnsupportedSearchResultItem
        id: 'user_${query.hashCode}_$index',
        title: userName,
        subtitle: bio[index % bio.length],
        data: {'user_id': 'user_$index', 'username': userName, 'bio': bio[index % bio.length]},
        relevance: 90 - index * 5,
      );
    });
  }
}
