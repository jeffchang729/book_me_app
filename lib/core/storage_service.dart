// lib/core/storage_service.dart
// 功能：提供本地儲存服務，用於持久化應用程式數據。

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `StorageService` 提供了基於 `shared_preferences` 的本地數據儲存功能。
/// 採用單例模式，確保整個應用程式只有一個實例，並在首次使用前進行初始化。
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  @visibleForTesting
  SharedPreferences? prefs; // 用於測試的 SharedPreferences 實例
  
  @visibleForTesting
  bool isInitialized = false; // 標記服務是否已初始化

  /// 初始化儲存服務。
  /// 在應用程式啟動時呼叫一次，以確保 `SharedPreferences` 實例可用。
  Future<StorageService> init() async {
    if (isInitialized) return this; // 如果已初始化，則直接返回
    try {
      prefs = await SharedPreferences.getInstance(); // 獲取 SharedPreferences 實例
      isInitialized = true; // 設定初始化標誌
      print('本地儲存服務已初始化');
    } catch (e) {
      print('初始化儲存服務失敗: $e'); // 錯誤處理
      rethrow; // 重新拋出錯誤
    }
    return this;
  }

  /// 確保儲存服務已初始化，否則拋出異常。
  void _ensureInitialized() {
    if (!isInitialized || prefs == null) {
      throw Exception('StorageService 尚未初始化，請先呼叫 init() 方法');
    }
  }

  /// 儲存字串數據。
  /// @param key - 儲存的鍵。
  /// @param value - 要儲存的字串值。
  /// @returns 是否儲存成功。
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await prefs!.setString(key, value);
  }

  /// 讀取字串數據。
  /// @param key - 要讀取的鍵。
  /// @returns 儲存的字串值，如果不存在則為 null。
  String? getString(String key) {
    _ensureInitialized();
    return prefs!.getString(key);
  }

  /// 儲存 JSON (Map) 數據。
  /// @param key - 儲存的鍵。
  /// @param value - 要儲存的 Map 值。
  /// @returns 是否儲存成功。
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value); // 將 Map 轉換為 JSON 字串
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取 JSON (Map) 數據。
  /// @param key - 要讀取的鍵。
  /// @returns 儲存的 Map 值，如果不存在或解析失敗則為 null。
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>; // 將 JSON 字串解析為 Map
    } catch (e) {
      print('讀取 JSON 失敗 [$key]: $e');
      return null;
    }
  }

  /// 儲存 JSON 列表數據。
  /// @param key - 儲存的鍵。
  /// @param value - 要儲存的 List<Map> 值。
  /// @returns 是否儲存成功。
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value); // 將 List<Map> 轉換為 JSON 字串
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 列表失敗 [$key]: $e');
      return false;
    }
  }

  /// 讀取 JSON 列表數據。
  /// @param key - 要讀取的鍵。
  /// @returns 儲存的 List<Map> 值，如果不存在或解析失敗則為 null。
  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final List<dynamic> decoded = jsonDecode(jsonString); // 將 JSON 字串解析為 List
      return decoded.cast<Map<String, dynamic>>(); // 轉換為 List<Map<String, dynamic>>
    } catch (e) {
      print('讀取 JSON 列表失敗 [$key]: $e');
      return null;
    }
  }
  
  /// 移除指定鍵的數據。
  /// @param key - 要移除的鍵。
  /// @returns 是否移除成功。
  Future<bool> remove(String key) async {
    _ensureInitialized();
    try {
      return await prefs!.remove(key);
    } catch (e) {
      print('移除資料失敗 [$key]: $e');
      return false;
    }
  }
}
