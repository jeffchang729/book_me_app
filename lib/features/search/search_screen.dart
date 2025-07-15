// lib/features/search/search_screen.dart
// [修正完成] 功能：AI書籍推薦搜尋頁面，補上缺失的方法實作。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/search/book_detail_screen.dart';
import 'package:book_me_app/features/search/search_models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController searchController = Get.find<SearchController>();
  final AppController appController = Get.find<AppController>();
  final TextEditingController textEditingController = TextEditingController();

  final ValueNotifier<bool> _isInputEmpty = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      _isInputEmpty.value = textEditingController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _isInputEmpty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 120),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(theme, context),
                Expanded(
                  child: Obx(() {
                    if (searchController.isLoading.value) {
                      return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
                    }
                    if (searchController.isInitialState.value) {
                      return _buildSearchSuggestions(theme);
                    }
                    if (searchController.errorMessage.value.isNotEmpty && searchController.searchResults.isEmpty) {
                      return _buildStatusIndicator(theme, Icons.error_outline_rounded, '發生錯誤', searchController.errorMessage.value);
                    }
                    if (searchController.searchResults.isEmpty) {
                      return _buildStatusIndicator(theme, Icons.search_off_rounded, '無結果', '找不到相關的書籍推薦，試試換個問法？');
                    }
                    return _buildResultsList(theme);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(IAppTheme theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: theme.neumorphicBoxDecoration(
          isConcave: true, radius: 30, color: theme.primaryBackgroundColor,
        ),
        child: Center(
          child: TextField(
            controller: textEditingController,
            style: theme.themeData.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: '想成為什麼樣的人？',
              hintStyle: theme.themeData.textTheme.bodyMedium,
              border: InputBorder.none,
              icon: Icon(Icons.search, color: theme.themeData.iconTheme.color),
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: _isInputEmpty,
                builder: (context, isEmpty, child) {
                  if (isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: Icon(Icons.clear, color: theme.themeData.iconTheme.color),
                    onPressed: () {
                      textEditingController.clear();
                      searchController.clearSearch();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                searchController.performSearch(value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(IAppTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('試試看...', style: theme.themeData.textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: searchController.searchSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  textEditingController.text = suggestion;
                  searchController.performSearch(suggestion);
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: theme.neumorphicBoxDecoration(
                    radius: 15,
                    color: theme.secondaryBackgroundColor,
                  ),
                  child: Text(suggestion, style: theme.themeData.textTheme.bodyLarge),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
  
  // [補上實作] 搜尋結果列表 Widget
  Widget _buildResultsList(IAppTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: searchController.searchResults.length,
      itemBuilder: (context, index) {
        final result = searchController.searchResults[index];
        return GestureDetector(
          onTap: () {
            Get.to(() => BookDetailScreen(bookId: result.id));
          },
          child: _SearchResultCard(result: result, theme: theme),
        );
      },
    );
  }

  // [補上實作] 狀態指示器 Widget (用於空狀態、錯誤等)
  Widget _buildStatusIndicator(IAppTheme theme, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: theme.themeData.iconTheme.color?.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(title, style: theme.themeData.textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: theme.themeData.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.theme,
  });

  final BookSearchResultItem result;
  final IAppTheme theme;

  @override
  Widget build(BuildContext context) {
    final coverUrl = (result.data['volumeInfo'] as Map<String, dynamic>?)?['imageLinks']
            as Map<String, dynamic>? ?? {};
    final thumbnailUrl = coverUrl['thumbnail'] ?? coverUrl['smallThumbnail'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: theme.neumorphicBoxDecoration(
        radius: 20,
        color: theme.secondaryBackgroundColor,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnailUrl ?? '',
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 120,
                decoration: theme.neumorphicBoxDecoration(
                  radius: 12,
                  isConcave: true,
                  color: theme.secondaryBackgroundColor
                ),
                child: Icon(Icons.book_outlined, color: theme.themeData.iconTheme.color),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: theme.themeData.textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  result.subtitle,
                  style: theme.themeData.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (result.recommendationReason != null && result.recommendationReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'AI 推薦理由：${result.recommendationReason}',
                    style: theme.themeData.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.themeData.primaryColor.withOpacity(0.9)
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}