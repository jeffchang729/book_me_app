// lib/features/search/search_controller.dart
// [API串接 V6.2 - 更新]
// 功能：改為呼叫真實的 StockService，並移除對股票假資料的依賴。

import 'package:get/get.dart';
import 'package:book_me_app/core/services/fake_data_service.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/stock/stock_service.dart'; // [新增] 導入 StockService
import 'package:book_me_app/features/weather/weather_service.dart';
import 'package:book_me_app/features/news/news_models.dart';

class SearchController extends GetxController {
  // // 透過 Get.find() 獲取已註冊的服務
  final WeatherService _weatherService = Get.find<WeatherService>();
  final StockService _stockService = Get.find<StockService>(); // [新增]
  final FakeDataService _fakeDataService =
      Get.find<FakeDataService>(); // // 暫時保留給新聞

  final RxBool isLoading = false.obs;
  final RxMap<String, List<UniversalSearchResult>> searchResults =
      <String, List<UniversalSearchResult>>{}.obs;

  final RxList<String> searchSuggestions = <String>[
    '今日頭條',
    '所有股票',
    '台北 天氣',
    '2330.TW', // [修改] 使用更精確的代碼
    'NVDA',
    '伊朗',
  ].obs;

  void clearSearch() {
    searchResults.clear();
  }

  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    isLoading.value = true;
    searchResults.clear();

    // // 故意延遲以改善使用者體驗，避免閃爍
    await Future.delayed(const Duration(milliseconds: 300));

    final Map<String, List<UniversalSearchResult>> results = {};
    final String cleanedKeyword = keyword.trim();
    final String upperKeyword = cleanedKeyword.toUpperCase();

    // // 重新設計的搜尋邏輯
    if (cleanedKeyword.contains('天氣')) {
      final locationName = cleanedKeyword.replaceAll('天氣', '').trim();
      final weatherLocations = await _weatherService
          .searchLocations(locationName.isEmpty ? '臺北' : locationName);

      final List<UniversalSearchResult> weatherItems = [];
      for (final loc in weatherLocations) {
        final weatherData = await _weatherService.getCompleteWeatherData(loc);
        if (weatherData != null) {
          weatherItems.add(WeatherSearchResultItem(
            id: weatherData.id,
            title: weatherData.locationName,
            subtitle:
                '${weatherData.currentWeather.temperature.round()}°C，${weatherData.currentWeather.description}',
            data: weatherData,
          ));
        }
      }
      if (weatherItems.isNotEmpty) {
        results['天氣'] = weatherItems;
      }
    }
    // [重大修改] 判斷是否為股票查詢
    else if (cleanedKeyword == '所有股票' ||
        RegExp(r'^[A-Z0-9\.,\s]+$').hasMatch(upperKeyword)) {
      final stockQuotes = await _stockService.searchStocks(cleanedKeyword);
      if (stockQuotes.isNotEmpty) {
        results['股市'] = stockQuotes
            .map((quote) => StockSearchResultItem(
                  id: 'stock_${quote.symbol}',
                  title: quote.shortName,
                  subtitle: quote.symbol,
                  // // 將 quote 物件轉換為 UI 需要的 Map 格式
                  data: quote.toDisplayMap(),
                ))
            .toList();
      }
    } else {
      // // 如果不是天氣或股票，則預設為新聞搜尋 (仍使用假資料)
      final List<PostData> fakeNews =
          _fakeDataService.getFakeNewsListData(cleanedKeyword);
      results['新聞: "$cleanedKeyword"'] = fakeNews
          .map((news) => NewsSearchResultItem(
                id: 'news_${cleanedKeyword.hashCode}_${news.caption.hashCode}',
                title: news.caption,
                subtitle: news.userName,
                data: news,
                topic: cleanedKeyword,
              ))
          .toList();
    }

    searchResults.assignAll(results);
    isLoading.value = false;
  }
}
