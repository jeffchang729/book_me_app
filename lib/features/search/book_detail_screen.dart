// lib/features/search/book_detail_screen.dart
// 功能：在應用程式內部顯示單本書籍的詳細資訊。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart';
import 'package:book_me_app/features/search/search_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final SearchService _searchService = Get.find<SearchService>();
  late Future<Map<String, dynamic>> _bookDetailsFuture;

  @override
  void initState() {
    super.initState();
    // 在頁面初始化時，開始獲取書籍詳細資料
    _bookDetailsFuture = _searchService.getBookDetails(widget.bookId);
  }

  /// 建立指向後端圖片代理服務的 URL
  String? _getProxiedImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return null;
    }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text('書籍詳情', style: theme.textTheme.headlineSmall),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookDetailsFuture,
        builder: (context, snapshot) {
          // --- 處理載入中狀態 ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          // --- 處理錯誤狀態 ---
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text('無法載入書籍資訊', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('請檢查您的網路連線或稍後再試。', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          // --- 處理成功狀態 ---
          final book = snapshot.data!;
          final volumeInfo = book['volumeInfo'] as Map<String, dynamic>? ?? {};
          final title = volumeInfo['title'] ?? '無標題';
          final authors = (volumeInfo['authors'] as List<dynamic>? ?? ['未知作者']).join(', ');
          final description = volumeInfo['description'] ?? '暫無簡介。';
          final coverUrl = (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['thumbnail'] ?? 
                           (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['smallThumbnail'];
          
          final proxiedCoverUrl = _getProxiedImageUrl(coverUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 書籍封面
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 200,
                      height: 300,
                      child: proxiedCoverUrl != null
                          ? Image.network(proxiedCoverUrl, fit: BoxFit.cover)
                          : Container(
                              color: theme.primaryColor.withOpacity(0.1),
                              child: Icon(Icons.book_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.5)),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 書名
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // 作者
                Text(
                  authors,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                // 內容簡介標題
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '內容簡介',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // 內容簡介
                Text(
                  description.replaceAll(RegExp(r'<[^>]*>'), ''), // 移除 HTML 標籤
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 40),
                // 未來可加入「撰寫心得」按鈕
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text('我讀完了，撰寫心得'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                  onPressed: () {
                    Get.snackbar('功能待開發', '從這裡開始撰寫讀書心得的功能正在規劃中！');
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
