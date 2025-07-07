// lib/core/fake_data_service.dart
// 功能：提供應用程式的假資料，用於開發和測試。

import 'dart:math';
import 'package:book_me_app/features/news/news_models.dart';
import 'package:book_me_app/features/weather/weather_models.dart';

class FakeDataService {
  static final FakeDataService _instance = FakeDataService._internal();
  factory FakeDataService() => _instance;
  FakeDataService._internal();

  final Random _random = Random();

  static const List<Map<String, String>> _stockList = [
    {'symbol': '2330', 'name': '台積電'},
    {'symbol': 'NVDA', 'name': '輝達'},
    {'symbol': '2317', 'name': '鴻海'},
    {'symbol': '2454', 'name': '聯發科'},
    {'symbol': 'AAPL', 'name': '蘋果'},
    {'symbol': 'GOOG', 'name': '谷歌'},
  ];

  // 擴充天氣假資料的生成邏輯
  WeatherCardData getFakeWeatherData(String locationName) {
    double baseTemp;
    List<String> weatherDescriptions;

    // 根據地點名稱設定不同的基礎溫度和天氣描述
    if (locationName.contains('南')) {
      baseTemp = 31.0; // 南部基礎溫度較高
      weatherDescriptions = ['晴朗', '晴時多雲', '午後短暫雷陣雨'];
    } else if (locationName.contains('中')) {
      baseTemp = 29.0; // 中部次之
      weatherDescriptions = ['多雲時晴', '晴天', '山區午後雷陣雨'];
    } else if (locationName.contains('北') || locationName.contains('基隆')) {
      baseTemp = 27.0; // 北部
      weatherDescriptions = ['多雲', '陰時多雲', '短暫陣雨'];
    } else {
      baseTemp = 28.0; // 預設
      weatherDescriptions = ['晴時多雲', '多雲', '午後雷陣雨', '陰'];
    }

    return WeatherCardData(
      id: 'weather_${locationName.hashCode}',
      locationName: locationName,
      currentWeather: CurrentWeather(
        temperature: baseTemp + _random.nextDouble() * 4, // 隨機範圍縮小，讓溫度更穩定
        description: weatherDescriptions[_random.nextInt(weatherDescriptions.length)],
        humidity: 65 + _random.nextInt(20),
        pressure: 1008.0 + _random.nextDouble() * 8,
        windSpeed: 1.5 + _random.nextDouble() * 5,
        updateTime: DateTime.now(),
      ),
      forecast: WeatherForecast(dailyForecasts: [], updateTime: DateTime.now()),
      createdAt: DateTime.now(),
    );
  }

  List<Map<String, dynamic>> getFakeStockListData() {
    return _stockList.map((stock) {
      return {
        'symbol': stock['symbol']!,
        'name': stock['name']!,
        'price': 300.0 + _random.nextDouble() * 700,
        'change': (-20 + _random.nextDouble() * 40),
        'changePercent': (-5.0 + _random.nextDouble() * 10),
        'volume': '${(10000 + _random.nextInt(50000))}張',
        'marketCap': '${_random.nextInt(20) + 1}.${_random.nextInt(9)}兆',
      };
    }).toList();
  }

  List<PostData> getFakeNewsListData(String query) {
    final topics = ['AI晶片', '電動車市場', '半導體庫存', '元宇宙趨勢', '量子計算突破'];
    return List.generate(5, (index) {
      final topic = topics[index % topics.length];
      return PostData(
        userName: ['TechNews 科技新報', 'Digitimes', 'Anue鉅亨網', '工商時報', '經濟日報'][index % 5],
        cardTitle: '$topic 最新動態',
        cardSubtitle: '深入分析報導',
        cardGradientStart: '',
        cardGradientEnd: '',
        caption: '關於 "$query" 的最新產業動態分析，深入探討其市場影響與未來趨勢。這是摘要預覽。',
        likesCount: 1250 + _random.nextInt(2000),
        comments: [],
        timeAgo: '${1 + _random.nextInt(12)}小時前',
        location: '台灣',
      );
    });
  }
}
