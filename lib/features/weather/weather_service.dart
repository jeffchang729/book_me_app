// lib/features/weather/weather_service.dart
// [API串接 V6.3 - 錯誤修正]
// 功能：修正 import 'dart:io' 的語法錯誤，解決編譯失敗問題。

import 'dart:io'; // [修正] 正確的 dart:io 導入方式
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:book_me_app/core/config/app_config.dart';
import 'package:book_me_app/features/weather/weather_models.dart';

class WeatherService {
  late final Dio _dio;

  // // 單例模式，確保整個 App 共用一個 WeatherService 實例
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;

  // // 私有建構子，用於初始化 Dio
  WeatherService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://opendata.cwa.gov.tw/api/v1/rest/datastore',
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
      ),
    );

    // // 在非 Web 的偵錯模式下，忽略憑證錯誤，方便本機開發測試
    if (kDebugMode && !kIsWeb) {
      final adapter = _dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  // // 簡單的記憶體快取，避免頻繁請求 API
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // // 根據關鍵字搜尋台灣城市
  Future<List<WeatherSearchResult>> searchLocations(String query) async {
    final cleanQuery = query.trim().replaceAll('台', '臺');
    if (cleanQuery.isEmpty) return [];

    // // 從 AppConfig 的靜態列表中進行過濾
    return AppConfig.taiwanCities
        .where((city) => city['name']!.contains(cleanQuery))
        .map((city) => WeatherSearchResult(
              locationName: city['name']!,
              fullLocationName: city['name']!,
              locationCode: city['code']!,
            ))
        .toList();
  }

  // // 組合當前天氣與天氣預報，回傳一個完整的資料模型
  Future<WeatherCardData?> getCompleteWeatherData(
      WeatherSearchResult searchResult) async {
    try {
      final futures = await Future.wait([
        getCurrentWeather(searchResult.locationName),
        getWeatherForecast(searchResult.locationName),
      ]);
      final currentWeather = futures[0] as CurrentWeather?;
      final forecast = futures[1] as WeatherForecast?;

      if (currentWeather != null) {
        return WeatherCardData(
          id: _generateCardId(searchResult.locationCode),
          locationName: searchResult.locationName,
          currentWeather: currentWeather,
          forecast: forecast,
          createdAt: DateTime.now(),
        );
      }
      // // 如果連當前天氣都獲取失敗，則回傳 null
      return null;
    } catch (e) {
      // // 捕獲 Future.wait 可能的錯誤
      if (kDebugMode) {
        print('❌ getCompleteWeatherData 失敗: $e');
      }
      return null;
    }
  }

  // // 獲取指定地點的當前天氣觀測資料 (API: O-A0003-001)
  Future<CurrentWeather?> getCurrentWeather(String locationName) async {
    final cacheKey = 'current_$locationName';
    if (_isValidCache(cacheKey)) {
      return CurrentWeather.fromJson(_cache[cacheKey]);
    }

    try {
      final response = await _dio.get('/O-A0003-001', queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'TEMP,HUMD,Weather',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // // 如果 API 回應中沒有地點資料，視為查詢失敗
        if ((data['records']?['location'] as List?)?.isEmpty ?? true) {
          if (kDebugMode) {
            print('ℹ️ API O-A0003-001 回應成功，但找不到地點 "$locationName" 的資料。');
          }
          return null;
        }

        final currentWeather = _parseCurrentWeatherResponse(data, locationName);
        if (currentWeather != null) {
          _cache[cacheKey] = currentWeather.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          return currentWeather;
        }
      }
      // // 若狀態碼不為 200 或 data 為空，拋出錯誤
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'API 請求失敗，狀態碼: ${response.statusCode}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ getCurrentWeather for "$locationName" 失敗: $e');
      }
      return null;
    }
  }

  // // 獲取指定地點的未來一週天氣預報 (API: F-C0032-001)
  Future<WeatherForecast?> getWeatherForecast(String locationName) async {
    final cacheKey = 'forecast_$locationName';
    if (_isValidCache(cacheKey)) {
      return WeatherForecast.fromJson(_cache[cacheKey]);
    }

    try {
      final response = await _dio.get('/F-C0032-001', queryParameters: {
        'Authorization': AppConfig.cwaApiKey,
        'locationName': locationName,
        'elementName': 'Wx,PoP,MinT,MaxT',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // // 如果 API 回應中沒有地點資料，視為查詢失敗
        if ((data['records']?['location'] as List?)?.isEmpty ?? true) {
          if (kDebugMode) {
            print('ℹ️ API F-C0032-001 回應成功，但找不到地點 "$locationName" 的資料。');
          }
          return null;
        }

        final forecast = _parseForecastResponse(data, locationName);
        if (forecast != null) {
          _cache[cacheKey] = forecast.toJson();
          _cacheTimestamps[cacheKey] = DateTime.now();
          return forecast;
        }
      }
      // // 若狀態碼不為 200 或 data 為空，拋出錯誤
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'API 請求失敗，狀態碼: ${response.statusCode}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ getWeatherForecast for "$locationName" 失敗: $e');
      }
      return null;
    }
  }

  // // 解析來自 O-A0003-001 的 JSON 回應
  CurrentWeather? _parseCurrentWeatherResponse(
      Map<String, dynamic> data, String locationName) {
    try {
      final records = data['records']['location'] as List;
      if (records.isEmpty) {
        return null;
      }
      final locationData = records.first;
      final elements = locationData['weatherElement'] as List;
      double getElementValue(String name, {double defaultValue = -99.0}) {
        final element = elements.firstWhere((e) => e['elementName'] == name,
            orElse: () => null);
        // // CWA API 有時會回傳 -99，代表無效值，我們需將其過濾
        final value =
            double.tryParse(element?['elementValue'] ?? '$defaultValue') ??
                defaultValue;
        return value <= -90.0 ? defaultValue : value;
      }

      String getWeatherDesc() {
        final element = elements.firstWhere(
            (e) => e['elementName'] == 'Weather',
            orElse: () => null);
        return element?['elementValue'] ?? '無資料';
      }

      final temp = getElementValue('TEMP');
      final humidity = getElementValue('HUMD');
      if (temp == -99.0) return null; // // 如果沒有溫度，資料無效

      return CurrentWeather(
        temperature: temp,
        description: getWeatherDesc(),
        humidity: (humidity * 100).toInt(),
        pressure: 1013.25,
        updateTime: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ _parseCurrentWeatherResponse 解析失敗: $e');
      }
      return null;
    }
  }

  // // 解析來自 F-C0032-001 的 JSON 回應
  WeatherForecast? _parseForecastResponse(
      Map<String, dynamic> data, String locationName) {
    try {
      final locationData = (data['records']['location'] as List).first;
      final weatherElements = locationData['weatherElement'] as List;

      final wx = weatherElements
          .firstWhere((e) => e['elementName'] == 'Wx')['time'] as List;
      final pop = weatherElements
          .firstWhere((e) => e['elementName'] == 'PoP')['time'] as List;
      final minT = weatherElements
          .firstWhere((e) => e['elementName'] == 'MinT')['time'] as List;
      final maxT = weatherElements
          .firstWhere((e) => e['elementName'] == 'MaxT')['time'] as List;

      final dailyForecasts = <DailyForecast>[];
      for (int i = 0; i < wx.length && dailyForecasts.length < 7; i++) {
        final forecastTime = DateTime.parse(wx[i]['startTime']);
        if (dailyForecasts.any((df) =>
            df.date.day == forecastTime.day &&
            df.date.month == forecastTime.month)) {
          continue;
        }

        dailyForecasts.add(DailyForecast(
          date: forecastTime,
          maxTemperature: double.parse(maxT[i]['parameter']['parameterName']),
          minTemperature: double.parse(minT[i]['parameter']['parameterName']),
          description: wx[i]['parameter']['parameterName'],
          rainProbability: int.parse(pop[i]['parameter']['parameterName']),
          weatherIconCode: wx[i]['parameter']['parameterValue'],
        ));
      }
      return WeatherForecast(
          dailyForecasts: dailyForecasts, updateTime: DateTime.now());
    } catch (e) {
      if (kDebugMode) {
        print('❌ _parseForecastResponse 解析失敗: $e');
      }
      return null;
    }
  }

  // // 檢查快取是否有效
  bool _isValidCache(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    final cacheTime = _cacheTimestamps[key]!;
    return DateTime.now().difference(cacheTime) < AppConfig.weatherCacheExpiry;
  }

  // // 產生唯一的卡片 ID
  String _generateCardId(String locationCode) {
    return 'weather_${locationCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // // 清理快取
  void dispose() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
