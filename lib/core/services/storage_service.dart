// lib/shared/services/storage_service.dart
// [無需變更] 此檔案結構良好，無需修改，在此呈現以確保完整性。

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  @visibleForTesting
  SharedPreferences? prefs;
  
  @visibleForTesting
  bool isInitialized = false;

  Future<StorageService> init() async {
    if (isInitialized) return this;
    try {
      prefs = await SharedPreferences.getInstance();
      isInitialized = true;
      print('本地儲存服務已初始化');
    } catch (e) {
      print('初始化儲存服務失敗: $e');
      rethrow;
    }
    return this;
  }

  void _ensureInitialized() {
    if (!isInitialized || prefs == null) {
      throw Exception('StorageService 尚未初始化，請先呼叫 init() 方法');
    }
  }

  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await prefs!.setString(key, value);
  }

  String? getString(String key) {
    _ensureInitialized();
    return prefs!.getString(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 失敗 [$key]: $e');
      return false;
    }
  }

  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('讀取 JSON 失敗 [$key]: $e');
      return null;
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('儲存 JSON 列表失敗 [$key]: $e');
      return false;
    }
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('讀取 JSON 列表失敗 [$key]: $e');
      return null;
    }
  }
  
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