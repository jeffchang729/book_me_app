// lib/features/stock/stock_service.dart
// [API串接 V6.5 - 最終修正]
// 功能：
// 1. 引入更完整的兩階段認證：先訪問首頁獲取 Cookie，再憑 Cookie 獲取 Crumb。
// 2. 新增 _initializeSession 方法來封裝此認證流程，並確保只執行一次。
// 3. 徹底解決 Yahoo Finance API 的 "Invalid Cookie" 401 錯誤。

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:book_me_app/features/stock/stock_models.dart';

class StockService {
  late final Dio _dio;
  final CookieJar _cookieJar = CookieJar();
  String? _crumb;
  bool _isSessionInitialized = false; // 標記 Session 是否已初始化

  // // 單例模式
  static final StockService _instance = StockService._internal();
  factory StockService() => _instance;

  // // 預設追蹤的股票清單 (台股需加上 .TW 後綴)
  static const List<String> _defaultStockSymbols = [
    '2330.TW',
    '2317.TW',
    '2454.TW',
    'NVDA',
    'AAPL',
    'GOOG',
  ];

  StockService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    ));
    // // 將 Cookie 管理器作為攔截器加入，它會自動處理所有請求的 Cookie
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  // [重大修改] 初始化 Session，包含獲取 Cookie 和 Crumb
  Future<void> _initializeSession() async {
    // // 如果已初始化，則直接返回，避免重複執行
    if (_isSessionInitialized) return;

    // // 步驟一：訪問 Yahoo 首頁以獲取初始 Session Cookie
    try {
      if (kDebugMode)
        print('ℹ️ 步驟 1/2: 正在初始化 Yahoo Finance Session (獲取 Cookie)...');
      // // 我們不在乎這個請求的回應內容，只為了觸發 CookieJar 儲存 Cookie
      await _dio.get('https://finance.yahoo.com');
      if (kDebugMode) print('✅ Cookie 應該已成功設定。');
    } catch (e) {
      // // 即便這一步失敗，我們還是嘗試下一步，因為 CookieJar 可能存有舊的有效 Cookie
      if (kDebugMode) print('⚠️ 初始化 Session 失敗 (步驟1: 獲取 Cookie): $e');
    }

    // // 步驟二：憑藉上一步取得的 Cookie，去獲取 Crumb
    try {
      if (kDebugMode) print('ℹ️ 步驟 2/2: 正在獲取 Yahoo Finance Crumb...');
      const crumbUrl = 'https://query1.finance.yahoo.com/v1/test/getcrumb';
      final response = await _dio.get(crumbUrl);

      if (response.statusCode == 200 &&
          response.data != null &&
          (response.data as String).isNotEmpty) {
        _crumb = response.data as String;
        // // 只有成功獲取 Crumb，才算整個 Session 初始化成功
        _isSessionInitialized = true;
        if (kDebugMode) print('✅ Crumb 獲取成功: $_crumb');
      } else {
        if (kDebugMode) print('⚠️ Crumb 獲取失敗，回應為空或狀態碼不正確。');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ 獲取 Crumb 時發生 Dio 錯誤: $e');
        if (e.response != null) print('Crumb 請求失敗，回應: ${e.response?.data}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ 獲取 Crumb 時發生未知錯誤: $e');
    }
  }

  // // 主要的搜尋方法
  Future<List<StockQuote>> searchStocks(String query) async {
    final cleanQuery = query.trim();
    List<String> symbolsToFetch;

    if (cleanQuery == '所有股票') {
      symbolsToFetch = _defaultStockSymbols;
    } else {
      symbolsToFetch = cleanQuery
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.isNotEmpty)
          .toList();
      symbolsToFetch = symbolsToFetch.map((s) {
        if (RegExp(r'^\d{4,6}$').hasMatch(s)) return '$s.TW';
        return s.toUpperCase();
      }).toList();
    }

    if (symbolsToFetch.isEmpty) return [];

    return await _fetchQuotes(symbolsToFetch);
  }

  // // 根據股票代碼列表，獲取報價資料
  Future<List<StockQuote>> _fetchQuotes(List<String> symbols) async {
    // // 步驟一：確保 Session 已被初始化
    await _initializeSession();

    // // 如果 Session 初始化失敗 (拿不到 Crumb)，則直接返回空列表
    if (!_isSessionInitialized || _crumb == null || _crumb!.isEmpty) {
      if (kDebugMode) print('❌ 因 Session 初始化失敗，已中斷 _fetchQuotes 操作。');
      return [];
    }

    try {
      if (kDebugMode) print('ℹ️ 正在獲取股票報價...');
      const quoteUrl = 'https://query1.finance.yahoo.com/v7/finance/quote';
      // // 步驟二：帶上 Crumb 參數發起最終請求
      final response = await _dio.get(quoteUrl, queryParameters: {
        'symbols': symbols.join(','),
        'crumb': _crumb,
      });

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['quoteResponse']?['result'] as List?;
        if (results != null) {
          if (kDebugMode) print('✅ 成功獲取 ${results.length} 支股票報價。');
          return results.map((json) => StockQuote.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ _fetchQuotes 失敗: $e');
      }
      return [];
    }
  }
}
