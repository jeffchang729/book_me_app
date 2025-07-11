// lib/features/search/search_screen.dart
// 功能：提供通用的搜尋介面，並整合 App 內部書籍詳情頁。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/search/book_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final SearchController controller = Get.find<SearchController>();
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Container(
          height: 48,
          decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 24),
          child: TextField(
            controller: textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '描述您想成為的人...',
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textEditingController.clear();
                  controller.clearSearch();
                },
              ),
            ),
            style: theme.textTheme.bodyLarge,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                controller.performSearch(value);
              }
            },
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.primaryColor),
                const SizedBox(height: 20),
                Text('AI 正在為您客製化書單...', style: theme.textTheme.titleMedium),
              ],
            ),
          );
        } else if (controller.searchResults.isEmpty) {
          return _buildSuggestionsList(controller, textEditingController, theme);
        } else {
          return _buildResultsList(controller);
        }
      }),
    );
  }

  Widget _buildSuggestionsList(SearchController controller, TextEditingController textEditingController, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '或試試這些靈感 ✨',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.searchSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = controller.searchSuggestions[index];
              return ListTile(
                leading: Icon(Icons.auto_awesome_outlined, color: theme.primaryColor),
                title: Text(suggestion, style: theme.textTheme.bodyLarge),
                onTap: () {
                  textEditingController.text = suggestion;
                  controller.performSearch(suggestion);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(SearchController controller) {
    final resultKeys = controller.searchResults.keys.toList();

    return ListView.builder(
      itemCount: resultKeys.length,
      itemBuilder: (context, index) {
        final categoryTitle = resultKeys[index];
        final items = controller.searchResults[categoryTitle]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: Text(
                categoryTitle,
                style: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...items.map((item) {
              if (item is BookSearchResultItem) {
                return _AiRecommendationCard(item: item);
              }
              return const SizedBox.shrink(); 
            }).toList(),
          ],
        );
      },
    );
  }
}


/// [UX 優化] 為 AI 書籍推薦設計的卡片 Widget，整張卡片皆可點擊。
class _AiRecommendationCard extends StatelessWidget {
  final BookSearchResultItem item;

  const _AiRecommendationCard({required this.item});

  String? _getProxiedImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) return null;
    String getApiBaseUrl() {
      const String cloudRunUrl = ''; 
      if (cloudRunUrl.isNotEmpty) return cloudRunUrl;
      if (kIsWeb) return 'http://localhost:3000';
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      return 'http://localhost:3000';
    }
    final baseUrl = getApiBaseUrl();
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '$baseUrl/api/images/proxy?url=$encodedUrl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final coverUrl = item.data['coverUrl'] as String?;
    final String? proxiedCoverUrl = _getProxiedImageUrl(coverUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // [UX 優化] 使用 Material 和 InkWell 來提供點擊時的水波紋回饋效果
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Get.to(() => BookDetailScreen(bookId: item.id));
          },
          child: Container(
            padding: const EdgeInsets.only(bottom: 8), // 為底部留出空間，避免內容太擠
            decoration: AppTheme.smartHomeNeumorphic(radius: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 120,
                      child: (proxiedCoverUrl != null)
                          ? Image.network(
                              proxiedCoverUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: theme.primaryColor.withOpacity(0.05),
                                  child: Icon(Icons.book_outlined, size: 40, color: theme.iconTheme.color?.withOpacity(0.5)),
                                );
                              },
                            )
                          : Container(
                              color: theme.primaryColor.withOpacity(0.05),
                              child: Icon(Icons.book_outlined, size: 40, color: theme.iconTheme.color?.withOpacity(0.5)),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12.0, 12.0, 4.0), // 調整右側和底部邊距
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        const Divider(thickness: 0.5),
                        const SizedBox(height: 8),
                        Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Icon(Icons.auto_awesome, color: theme.primaryColor.withOpacity(0.8), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.recommendationReason ?? 'AI 正在思考...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                           ],
                        ),
                        // [UX 優化] 移除獨立的「查看詳情」按鈕
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
