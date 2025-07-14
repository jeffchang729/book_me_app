// lib/features/search/search_screen.dart
// [架構改造] 使用 AppController 來獲取動態主題樣式。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/core/app_controller.dart'; // [新增]
import 'package:book_me_app/core/themes/i_app_theme.dart'; // [新增]
import 'package:book_me_app/features/search/book_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController searchController = Get.find<SearchController>();
    final AppController appController = Get.find<AppController>(); // [新增]
    final TextEditingController textEditingController = TextEditingController();

    return Obx(() { // [新增] 用 Obx 包裹
      final IAppTheme theme = appController.currentTheme.value;
      final ThemeData themeData = theme.themeData;

      return Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // 搜尋框
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // [修正]
                  decoration: theme.neumorphicBoxDecoration(isConcave: true, radius: 24),
                  child: TextField(
                    controller: textEditingController,
                    style: themeData.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '想成為什麼樣的人？例如：有創意的領導者',
                      hintStyle: themeData.textTheme.bodyMedium,
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: themeData.iconTheme.color),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: themeData.primaryColor),
                        onPressed: () {
                          if (textEditingController.text.isNotEmpty) {
                            searchController.searchBooks(textEditingController.text);
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        searchController.searchBooks(value);
                      }
                    },
                  ),
                ),
              ),

              // 狀態顯示
              Expanded(
                child: Obx(() {
                  if (searchController.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: themeData.primaryColor));
                  } else if (searchController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          searchController.errorMessage.value,
                          style: themeData.textTheme.bodyLarge?.copyWith(color: themeData.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (searchController.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_outlined, size: 80, color: themeData.iconTheme.color?.withOpacity(0.5)),
                          const SizedBox(height: 20),
                          Text('探索，從一個問題開始', style: themeData.textTheme.headlineSmall),
                          const SizedBox(height: 10),
                          Text(
                            '輸入您的目標或感興趣的領域，\n讓 AI 為您推薦最適合的書籍。',
                            style: themeData.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    // 搜尋結果列表
                    return ListView.builder(
                      itemCount: searchController.searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchController.searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => BookDetailScreen(searchResult: result));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            padding: const EdgeInsets.all(12.0),
                            // [修正]
                            decoration: theme.neumorphicBoxDecoration(radius: 15),
                            child: Row(
                              children: [
                                // 書籍封面
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    result.thumbnailLink,
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 120,
                                      color: themeData.primaryColor.withOpacity(0.1),
                                      child: Icon(Icons.book_outlined, color: themeData.iconTheme.color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 書籍資訊
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.title,
                                        style: themeData.textTheme.titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result.authors.join(', '),
                                        style: themeData.textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        result.recommendationReason,
                                        style: themeData.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: themeData.primaryColor),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}