// lib/features/search/book_detail_screen.dart
// [風格改造] 功能：顯示單本書籍的詳細資訊，採用分離式擬物化風格。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
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
  final AppController _appController = Get.find<AppController>();
  late Future<Map<String, dynamic>> _bookDetailsFuture;

  @override
  void initState() {
    super.initState();
    _bookDetailsFuture = _searchService.getBookDetails(widget.bookId);
  }

  // 圖片代理服務 URL 邏輯 (保持不變)
  String? _getProxiedImageUrl(String? originalUrl) { /* ... 保持原樣 ... */ }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = _appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor, // [改造] 使用頂部淺色背景
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState(theme);
          }

          final book = snapshot.data!;
          final volumeInfo = book['volumeInfo'] as Map<String, dynamic>? ?? {};
          
          return Stack( // [改造] 使用 Stack 實現分離式背景
            children: [
              // --- 背景層 ---
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4), // 預留頂部淺色區域
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
              // --- 內容層 ---
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTopSection(theme, volumeInfo),
                    _buildBottomSection(theme, volumeInfo),
                  ],
                ),
              ),
              // --- 返回按鈕 ---
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: theme.themeData.iconTheme.color),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // [抽出] 頂部區塊 (封面、標題、作者)
  Widget _buildTopSection(IAppTheme theme, Map<String, dynamic> volumeInfo) {
    final title = volumeInfo['title'] ?? '無標題';
    final authors = (volumeInfo['authors'] as List<dynamic>? ?? ['未知作者']).join(', ');
    final coverUrl = (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['thumbnail'] ??
                     (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['smallThumbnail'];
    final proxiedCoverUrl = _getProxiedImageUrl(coverUrl);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0).copyWith(top: 60),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: theme.neumorphicBoxDecoration(
                radius: 15,
                color: theme.primaryBackgroundColor,
              ).copyWith(
                boxShadow: [ // [優化] 加強封面陰影
                  BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 200,
                  height: 300,
                  child: proxiedCoverUrl != null
                      ? Image.network(proxiedCoverUrl, fit: BoxFit.cover)
                      : Container(
                          color: theme.secondaryBackgroundColor,
                          child: Icon(Icons.book_outlined, size: 80, color: theme.themeData.iconTheme.color?.withOpacity(0.5)),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: theme.themeData.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(authors, textAlign: TextAlign.center, style: theme.themeData.textTheme.titleMedium?.copyWith(color: theme.themeData.textTheme.bodyMedium?.color)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // [抽出] 底部區塊 (簡介、按鈕)
  Widget _buildBottomSection(IAppTheme theme, Map<String, dynamic> volumeInfo) {
    final description = (volumeInfo['description'] ?? '暫無簡介。').replaceAll(RegExp(r'<[^>]*>'), '');
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('內容簡介', style: theme.themeData.textTheme.titleLarge),
          const Divider(height: 24),
          Text(description, style: theme.themeData.textTheme.bodyLarge?.copyWith(height: 1.6)),
          const SizedBox(height: 40),
          // [改造] 按鈕風格統一
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => Get.snackbar('功能待開發', '從這裡開始撰寫讀書心得的功能正在規劃中！'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Ink(
                decoration: theme.neumorphicBoxDecoration(
                  radius: 20,
                  color: theme.themeData.primaryColor,
                  gradient: LinearGradient(
                    colors: [theme.themeData.primaryColor, const Color(0xFF6A95FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text('我讀完了，撰寫心得', style: theme.themeData.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  // [抽出] 錯誤狀態 Widget
  Widget _buildErrorState(IAppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: theme.themeData.colorScheme.error),
          const SizedBox(height: 20),
          Text('無法載入書籍資訊', style: theme.themeData.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('請檢查您的網路連線或稍後再試。', style: theme.themeData.textTheme.bodyMedium),
        ],
      ),
    );
  }
}