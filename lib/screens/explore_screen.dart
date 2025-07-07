// lib/screens/explore_screen.dart
// 功能：探索新的讀書心得或用戶 (Instagram 探索風格)。

import 'package:flutter/material.dart' hide SearchController; // [修正] 隱藏 Flutter Material 中的 SearchController
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/search/search_controller.dart'; // 引入搜尋控制器
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController

/// `ExploreScreen` 提供了 BookMe 應用程式的探索功能。
/// 用戶可以在此處發現新的書籍、讀書心得和用戶。
/// 介面設計靈感來自 Instagram 的探索頁面，包含搜尋欄和內容網格。
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme; // 獲取當前主題
    final SearchController searchController = Get.find<SearchController>(); // 獲取搜尋控制器
    final AppController appController = Get.find<AppController>(); // 獲取 AppController

    // 搜尋欄的 TextEditingController，用於控制搜尋輸入框的文字。
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // 設定背景色
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // AppBar 背景色
        elevation: 0, // 無陰影
        title: Container(
          height: 40,
          // 搜尋框的 Neumorphism 風格裝飾
          decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 10), 
          child: TextField(
            controller: textEditingController, // 綁定控制器
            decoration: InputDecoration(
              hintText: '搜尋書籍、作者或用戶...', // 提示文字
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color), // 搜尋圖示
              border: InputBorder.none, // 無邊框
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // 內容內邊距
            ),
            style: theme.textTheme.bodyLarge, // 輸入文字樣式
            onTap: () {
              // 點擊搜尋框時，切換到 SearchScreen (因為 SearchScreen 現在是獨立的頁面)
              appController.changeTabIndex(1); // 呼叫 AppController 來切換到索引為 1 的搜尋分頁
            },
            readOnly: true, // 設定為只讀，因為實際搜尋邏輯在 SearchScreen 中
          ),
        ),
      ),
      body: Center(
        // 暫時的佔位符內容，未來將替換為實際的探索內容網格
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '探索讀書心得',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '發現更多有趣的書籍和讀者！',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            // TODO: 未來在此處載入並顯示探索內容網格 (例如 GridView.builder)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 每行3個項目
                  crossAxisSpacing: 4.0, // 水平間距
                  mainAxisSpacing: 4.0, // 垂直間距
                ),
                itemCount: 12, // 示例探索內容數量
                itemBuilder: (context, index) {
                  return Container(
                    color: theme.colorScheme.secondary.withOpacity(0.1), // 示例顏色
                    child: Center(
                      child: Text(
                        '內容 ${index + 1}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
