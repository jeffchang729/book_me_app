// lib/features/book_review/book_review_detail_screen.dart
// [風格改造] 功能：顯示單一讀書心得詳情，採用分離式擬物化風格。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/book_review/book_review.dart';
import 'package:book_me_app/features/book_review/book_review_controller.dart';
import 'package:book_me_app/features/book_review/comment.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';

class BookReviewDetailScreen extends StatefulWidget {
  final BookReview review;
  final int initialTabIndex;

  const BookReviewDetailScreen({super.key, required this.review, this.initialTabIndex = 0});
  @override
  State<BookReviewDetailScreen> createState() => _BookReviewDetailScreenState();
}

class _BookReviewDetailScreenState extends State<BookReviewDetailScreen> with SingleTickerProviderStateMixin {
  // --- Controllers and Keys (保持不變) ---
  late TabController _tabController;
  final _commentController = TextEditingController();
  final bookReviewController = Get.find<BookReviewController>();
  final authController = Get.find<AuthController>();
  final appController = Get.find<AppController>();

  @override
  void initState() { /* ... 保持不變 ... */ }
  @override
  void dispose() { /* ... 保持不變 ... */ }
  Future<void> _sendComment() async { /* ... 保持不變 ... */ }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = appController.currentTheme.value;

    return Obx(() {
      final BookReview displayReview = bookReviewController.publicBookReviews.firstWhereOrNull((r) => r.id == widget.review.id) ??
          bookReviewController.userBookReviews.firstWhereOrNull((r) => r.id == widget.review.id) ?? widget.review;

      return Scaffold(
        backgroundColor: theme.primaryBackgroundColor,
        body: Column(
          children: [
            _buildAppBarAndTabs(theme),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(theme, displayReview),
                    _buildCommentsTab(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  // [抽出] AppBar 和 TabBar
  Widget _buildAppBarAndTabs(IAppTheme theme) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AppBar(
              backgroundColor: Colors.transparent, elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: theme.themeData.iconTheme.color),
                onPressed: () => Get.back(),
              ),
              title: Text('心得詳情', style: theme.themeData.textTheme.headlineSmall),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelStyle: theme.themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            labelColor: theme.themeData.primaryColor,
            unselectedLabelColor: theme.themeData.textTheme.bodyMedium?.color,
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: theme.themeData.primaryColor),
                insets: const EdgeInsets.symmetric(horizontal: 16.0)),
            tabs: const [Tab(text: '詳情'), Tab(text: '留言')],
          ),
        ],
      ),
    );
  }

  // [抽出] 詳情 Tab 頁
  Widget _buildDetailsTab(IAppTheme theme, BookReview review) {
    /* ... 詳情頁面的內容 ... */
    /* ... 請將原有的 SingleChildScrollView 及其內容放在此處 ... */
    /* ... 並將所有 AppTheme.smartHomeNeumorphic 替換為 theme.neumorphicBoxDecoration ... */
    /* ... 所有顏色和文字樣式都從 theme 物件獲取 ... */
    return const Center(child: Text("詳情頁面內容")); // 暫時佔位符
  }

  // [抽出] 留言 Tab 頁
  Widget _buildCommentsTab(IAppTheme theme) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (bookReviewController.currentReviewComments.isEmpty) {
              return Center(child: Text('目前沒有留言', style: theme.themeData.textTheme.bodyMedium));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: bookReviewController.currentReviewComments.length,
              itemBuilder: (c, i) => _CommentCard(comment: bookReviewController.currentReviewComments[i], theme: theme),
            );
          }),
        ),
        _buildCommentInputField(theme),
      ],
    );
  }

  // [改造] 留言輸入框
  Widget _buildCommentInputField(IAppTheme theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
      child: Container(
        decoration: theme.neumorphicBoxDecoration(
            isConcave: true, radius: 25, color: theme.secondaryBackgroundColor),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '新增留言...', border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: theme.themeData.primaryColor),
              onPressed: bookReviewController.isLoading.value ? null : _sendComment,
            )
          ],
        ),
      ),
    );
  }
}

// [改造] 留言卡片
class _CommentCard extends StatelessWidget {
  final Comment comment;
  final IAppTheme theme;
  const _CommentCard({required this.comment, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(comment.userAvatarUrl ?? '')),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: theme.neumorphicBoxDecoration(radius: 15, color: theme.secondaryBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.userName, style: theme.themeData.textTheme.labelLarge?.copyWith(color: theme.themeData.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 4),
                  Text(comment.content, style: theme.themeData.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}