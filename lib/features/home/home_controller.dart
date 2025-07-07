// lib/features/home/home_controller.dart
// [體驗重構 V5.7]
// 功能：恢復 V5.3 的邏輯，將天氣視為單一類別群組，而非為每個城市建立獨立卡片。

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/core/services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  static const String _trackedItemsKey = 'tracked_items';
  static const String _themeKey = 'app_theme_style';

  final RxInt currentTabIndex = 0.obs;
  final RxList<UniversalSearchResult> trackedItems =
      <UniversalSearchResult>[].obs;

  final Rx<SearchResultType?> selectedType = Rx<SearchResultType?>(null);
  final Rx<String?> selectedNewsTopic = Rx<String?>(null);

  final Rx<AppThemeStyle> currentThemeStyle = AppThemeStyle.SmartHomeLight.obs;

  List<UniversalSearchResult> get trackedWeathers =>
      trackedItems.where((i) => i.type == SearchResultType.weather).toList();
  List<UniversalSearchResult> get trackedStocks =>
      trackedItems.where((i) => i.type == SearchResultType.stock).toList();
  List<UniversalSearchResult> get trackedNews =>
      trackedItems.where((i) => i.type == SearchResultType.news).toList();
  List<String> get trackedNewsTopics => trackedNews
      .map((item) => (item as NewsSearchResultItem).topic)
      .toSet()
      .toList();

  @override
  void onInit() {
    super.onInit();
    _loadTrackedItems();
    _initTheme();
  }

  void _initTheme() {
    final savedThemeName = _storageService.getString(_themeKey);
    final style = AppThemeStyle.values.firstWhere(
      (e) => e.toString() == savedThemeName,
      orElse: () => AppThemeStyle.SmartHomeLight,
    );
    _setTheme(style);
  }

  void _setTheme(AppThemeStyle style) {
    currentThemeStyle.value = style;
    Get.changeTheme(AppTheme.getThemeData(style));
    _storageService.setString(_themeKey, style.toString());
  }

  void cycleTheme() {
    Get.snackbar('主題切換', '目前僅提供 SmartHomeLight 風格。',
        snackPosition: SnackPosition.BOTTOM);
  }

  void selectContent({required SearchResultType type, String? newsTopic}) {
    selectedType.value = type;
    selectedNewsTopic.value =
        (type == SearchResultType.news) ? newsTopic : null;
  }

  void _loadTrackedItems() {
    try {
      final savedData = _storageService.getString(_trackedItemsKey);
      if (savedData != null && savedData.isNotEmpty) {
        final items = (jsonDecode(savedData) as List)
            .map((d) =>
                UniversalSearchResult.fromJson(d as Map<String, dynamic>))
            .toList();
        trackedItems.assignAll(items);

        if (trackedWeathers.isNotEmpty) {
          selectContent(type: SearchResultType.weather);
        } else if (trackedStocks.isNotEmpty) {
          selectContent(type: SearchResultType.stock);
        } else if (trackedNewsTopics.isNotEmpty) {
          selectContent(
              type: SearchResultType.news, newsTopic: trackedNewsTopics.first);
        }
      }
    } catch (e) {
      print('❌ 載入已追蹤項目失敗: $e');
      _storageService.remove(_trackedItemsKey);
    }
  }

  Future<void> addTrackedItems(List<UniversalSearchResult> items) async {
    final newItems = items
        .where((newItem) =>
            !trackedItems.any((oldItem) => oldItem.id == newItem.id))
        .toList();
    if (newItems.isEmpty) {
      showWarningSnackbar('重複項目', '您選擇的項目已經在儀表板上。');
      return;
    }
    trackedItems.insertAll(0, newItems);
    final firstNewItem = newItems.first;

    selectContent(
      type: firstNewItem.type,
      newsTopic: firstNewItem.type == SearchResultType.news
          ? (firstNewItem as NewsSearchResultItem).topic
          : null,
    );

    await _saveTrackedItems();
  }

  Future<void> _saveTrackedItems() async {
    try {
      final dataToSave = trackedItems.map((item) => item.toJson()).toList();
      await _storageService.setString(_trackedItemsKey, jsonEncode(dataToSave));
    } catch (e) {
      print('❌ 儲存追蹤項目失敗: $e');
    }
  }

  void changeTabIndex(int index) {
    if (index == currentTabIndex.value) return;
    currentTabIndex.value = index;
  }

  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
    );
  }

  void showWarningSnackbar(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[700],
        colorText: Colors.white);
  }
}
