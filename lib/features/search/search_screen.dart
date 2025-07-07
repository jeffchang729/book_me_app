// lib/features/search/search_screen.dart
// 功能：提供通用的搜尋介面，用於搜尋書籍和用戶。

import 'package:flutter/material.dart' hide SearchController; // [修正] 隱藏 Flutter Material 中的 SearchController
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/search/search_controller.dart';
// import 'package:book_me_app/core/home/home_controller.dart'; // [移除] 不再需要 HomeController

/// `SearchScreen` 提供了應用程式的搜尋功能介面。
/// 用戶可以在這裡輸入關鍵字搜尋書籍或用戶，並查看搜尋結果。
/// 介面設計簡潔，符合 Neumorphism 風格。
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchController searchController = Get.find<SearchController>(); // 獲取搜尋控制器
    // final HomeController homeController = Get.find<HomeController>(); // [移除] 不再需要 HomeController
    final TextEditingController textEditingController = TextEditingController(); // 搜尋輸入框控制器
    final theme = context.theme; // 獲取當前主題

    // 在畫面首次渲染後清空搜尋結果，確保每次進入都是乾淨的狀態
    WidgetsBinding.instance.addPostFrameCallback((_) {
        searchController.clearSearch();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // 設定背景色
      appBar: AppBar(
        title: _buildSearchBar(context, textEditingController, searchController), // 搜尋欄
        backgroundColor: theme.scaffoldBackgroundColor, // AppBar 背景色
        elevation: 0, // 無陰影
        automaticallyImplyLeading: false, // 不自動顯示返回按鈕
      ),
      body: Obx(() {
        // 根據載入狀態顯示不同的 UI
        if (searchController.isLoading.value) {
          return const Center(child: CircularProgressIndicator()); // 顯示載入指示器
        } else if (searchController.searchResults.isEmpty) {
          return _buildSuggestionsView(searchController, textEditingController, context); // 顯示搜尋建議
        } else {
          return _buildResultsView(searchController, context); // [修正] 移除 homeController 參數
        }
      }),
    );
  }

  /// 建立搜尋欄位。
  /// @param context - BuildContext。
  /// @param controller - TextEditingController，用於控制輸入框文字。
  /// @param searchController - SearchController，用於觸發搜尋。
  /// @returns 搜尋欄位的 Widget。
  Widget _buildSearchBar(BuildContext context, TextEditingController controller, SearchController searchController) {
    final theme = context.theme;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 24), // 搜尋欄的 Neumorphism 樣式
      child: TextField(
        controller: controller,
        autofocus: true, // 自動獲取焦點
        decoration: InputDecoration(
          hintText: '搜尋書籍或用戶...', // 提示文字
          border: InputBorder.none, // 無邊框
          hintStyle: theme.textTheme.bodyMedium, // 提示文字樣式
        ),
        style: theme.textTheme.bodyLarge, // 輸入文字樣式
        onSubmitted: (value) => searchController.performSearch(value), // 提交時執行搜尋
      ),
    );
  }

  /// 建立搜尋結果視圖。
  /// @param searchController - SearchController，包含搜尋結果資料。
  /// @param context - BuildContext。
  /// @returns 搜尋結果列表的 Widget。
  Widget _buildResultsView(SearchController searchController, BuildContext context) { // [修正] 移除 homeController 參數
    final groupKeys = searchController.searchResults.keys.toList(); // 獲取所有結果分組的鍵
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80), // 列表內邊距
      itemCount: groupKeys.length, // 項目數量為分組數量
      itemBuilder: (context, index) {
        final groupTitle = groupKeys[index]; // 當前分組的標題
        final items = searchController.searchResults[groupTitle]!; // 當前分組的項目列表
        return _buildResultGroup(context, groupTitle, items); // 建立結果分組
      },
    );
  }

  /// 建立單一搜尋結果分組。
  /// @param context - BuildContext。
  /// @param title - 分組標題。
  /// @param items - 該分組下的搜尋結果項目列表。
  /// @returns 搜尋結果分組的 Widget。
  Widget _buildResultGroup(BuildContext context, String title, List<UniversalSearchResult> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall, // 標題樣式
                    overflow: TextOverflow.ellipsis, // 文字溢出時顯示省略號
                  ),
                ),
                // TODO: 未來可以添加「全部加入」或「查看更多」按鈕
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 遍歷並顯示每個搜尋結果卡片
          ...items.map((item) => _buildResultCard(context, item)).toList(),
        ],
      ),
    );
  }

  /// 建立單一搜尋結果卡片。
  /// @param context - BuildContext。
  /// @param item - 搜尋結果項目。
  /// @returns 搜尋結果卡片的 Widget。
  Widget _buildResultCard(BuildContext context, UniversalSearchResult item) {
    // [修正] 移除 homeController 參數，因為不再需要將項目添加到主頁
    return _SearchResultItemCard(
      item: item,
      showAddButton: false, // 暫時不顯示加入按鈕
      onAdd: () {
        // 這裡可以處理將書籍或用戶添加到個人追蹤列表的邏輯
        Get.snackbar('功能待開發', '加入功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
      },
    );
  }
  
  /// 建立搜尋建議視圖。
  /// @param controller - SearchController，包含搜尋建議資料。
  /// @param textController - TextEditingController，用於更新搜尋欄文字。
  /// @param context - BuildContext。
  /// @returns 搜尋建議列表的 Widget。
  Widget _buildSuggestionsView(SearchController controller, TextEditingController textController, BuildContext context) { 
    final theme = context.theme; 
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text('熱門搜尋', style: theme.textTheme.titleLarge), // 熱門搜尋標題
        const SizedBox(height: 16), 
        Wrap( // 使用 Wrap 讓建議標籤自動換行
          spacing: 12.0, // 水平間距
          runSpacing: 12.0, // 垂直間距
          children: controller.searchSuggestions.map((suggestion) { 
            return GestureDetector( 
              onTap: () { 
                textController.text = suggestion; // 點擊建議後更新搜尋欄文字
                // 將游標移動到文字末尾
                textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length)); 
                controller.performSearch(suggestion); // 執行搜尋
              }, 
              child: Container( 
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                decoration: AppTheme.smartHomeNeumorphic(radius: 20), // 建議標籤的 Neumorphism 樣式
                child: Text(suggestion, style: theme.textTheme.labelLarge), // 建議文字樣式
              ), 
            ); 
          }).toList(), 
        ), 
      ],
    ); 
  }
}

/// `_SearchResultItemCard` 是用於顯示單一搜尋結果項目的卡片。
class _SearchResultItemCard extends StatelessWidget {
  final UniversalSearchResult item; // 搜尋結果項目
  final VoidCallback onAdd; // 點擊「加入」按鈕的回調
  final bool showAddButton; // 是否顯示「加入」按鈕

  const _SearchResultItemCard({
    Key? key,
    required this.item,
    required this.onAdd,
    this.showAddButton = true, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.smartHomeNeumorphic(radius: 15), // 卡片的 Neumorphism 樣式
        child: Row(
          children: [
            Icon(
              _getIconForType(item.type), // 根據類型獲取圖示
              color: theme.iconTheme.color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600), // 標題樣式
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium, // 副標題樣式
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 文字溢出時顯示省略號
                  ),
                ],
              ),
            ),
            // 根據 showAddButton 決定是否渲染「+」按鈕
            if (showAddButton) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.smartHomeNeumorphic(radius: 20), // 按鈕的 Neumorphism 樣式
                  child: Icon(
                    Icons.add_rounded,
                    color: theme.primaryColor, // 按鈕圖示顏色
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根據搜尋結果類型獲取對應的圖示。
  /// @param type - 搜尋結果類型。
  /// @returns 對應的 IconData。
  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.book:
        return Icons.book_outlined; // 書籍圖示
      case SearchResultType.user:
        return Icons.person_outline; // 用戶圖示
      default:
        return Icons.help_outline_rounded; // 預設圖示
    }
  }
}
