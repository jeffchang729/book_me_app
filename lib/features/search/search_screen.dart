// lib/features/search/search_screen.dart
// [體驗重構 V5.7]
// 功能：
// 1. 根據結果類型，提供差異化的加入按鈕。
// 2. 新聞類別：只在頂部顯示「全部加入」按鈕。
// 3. 其他類別：只在每個項目上顯示獨立的「+」按鈕。
// 4. 所有加入操作完成後，都會立即跳轉回主頁。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/home/home_controller.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/features/search/search_models.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchController searchController = Get.find<SearchController>();
    final HomeController homeController = Get.find<HomeController>();
    final TextEditingController textEditingController = TextEditingController();
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.clearSearch();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            _buildSearchBar(context, textEditingController, searchController),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (searchController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (searchController.searchResults.isEmpty) {
          return _buildSuggestionsView(
              searchController, textEditingController, context);
        } else {
          return _buildResultsView(searchController, homeController, context);
        }
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context, TextEditingController controller,
      SearchController searchController) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 24),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '搜尋「所有股票」或「台北天氣」...',
          border: InputBorder.none,
          hintStyle: theme.textTheme.bodyMedium,
        ),
        style: theme.textTheme.bodyLarge,
        onSubmitted: (value) => searchController.performSearch(value),
      ),
    );
  }

  Widget _buildResultsView(SearchController searchController,
      HomeController homeController, BuildContext context) {
    final groupKeys = searchController.searchResults.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final groupTitle = groupKeys[index];
        final items = searchController.searchResults[groupTitle]!;
        return _buildResultGroup(context, groupTitle, items, homeController);
      },
    );
  }

  // [重大修改] 根據結果類型，決定是否顯示「全部加入」按鈕
  Widget _buildResultGroup(BuildContext context, String title,
      List<UniversalSearchResult> items, HomeController homeController) {
    // 檢查這個群組是否為新聞類型
    final bool isNewsGroup =
        items.isNotEmpty && items.first.type == SearchResultType.news;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 標題
                Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis)),
                // [修改] 只在新聞群組顯示「全部加入」按鈕
                if (isNewsGroup)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon:
                        const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: const Text('全部加入'),
                    onPressed: () {
                      homeController.addTrackedItems(items);
                      homeController.changeTabIndex(0);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...items
              .map((item) => _buildResultCard(context, item, homeController))
              .toList(),
        ],
      ),
    );
  }

  // [修改] 根據結果類型，決定是否顯示「+」按鈕
  Widget _buildResultCard(BuildContext context, UniversalSearchResult item,
      HomeController homeController) {
    return _SearchResultItemCard(
      item: item,
      // [修改] 只有非新聞項目才需要獨立的加入按鈕
      showAddButton: item.type != SearchResultType.news,
      onAdd: () {
        homeController.addTrackedItems([item]);
        homeController.changeTabIndex(0);
      },
    );
  }

  Widget _buildSuggestionsView(SearchController controller,
      TextEditingController textController, BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text('熱門搜尋', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: controller.searchSuggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                textController.text = suggestion;
                textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: textController.text.length));
                controller.performSearch(suggestion);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: AppTheme.smartHomeNeumorphic(radius: 20),
                child: Text(suggestion, style: theme.textTheme.labelLarge),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SearchResultItemCard extends StatelessWidget {
  final UniversalSearchResult item;
  final VoidCallback onAdd;
  final bool showAddButton; // [新增]

  const _SearchResultItemCard({
    Key? key,
    required this.item,
    required this.onAdd,
    this.showAddButton = true, // [新增] 預設顯示
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.smartHomeNeumorphic(radius: 15),
        child: Row(
          children: [
            Icon(
              _getIconForType(item.type),
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
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // [修改] 根據 showAddButton 決定是否渲染「+」按鈕
            if (showAddButton) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.smartHomeNeumorphic(radius: 20),
                  child: Icon(
                    Icons.add_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return Icons.wb_cloudy_outlined;
      case SearchResultType.stock:
        return Icons.show_chart_rounded;
      case SearchResultType.news:
        return Icons.article_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
