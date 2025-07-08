// lib/features/book_review/book_review_detail_screen.dart
// 功能：顯示單一讀書心得的完整內容，並整合按讚與留言功能。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/book_review/book_review.dart'; // 引入讀書心得模型
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/features/book_review/comment.dart'; // 引入留言模型
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入 AuthController

/// `BookReviewDetailScreen` 用於顯示單一讀書心得的詳細內容。
/// 它接收一個 `BookReview` 物件作為參數，並將其所有資訊呈現給使用者。
/// 新增了按讚功能和留言區塊。
class BookReviewDetailScreen extends StatefulWidget {
  final BookReview review; // 接收一個讀書心得物件
  final int initialTabIndex; // 初始選中的 Tab 索引 (0: 詳情, 1: 留言)

  const BookReviewDetailScreen({
    super.key,
    required this.review,
    this.initialTabIndex = 0,
  });

  @override
  State<BookReviewDetailScreen> createState() => _BookReviewDetailScreenState();
}

class _BookReviewDetailScreenState extends State<BookReviewDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController(); // 留言輸入框控制器

  final BookReviewController bookReviewController = Get.find<BookReviewController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    
    // [優化] 開始監聽當前心得的留言
    // 無論哪個 Tab，只要進入詳情頁，就開始監聽留言。
    // 因為 Tab 頁面可能被緩存，確保每次顯示都是最新。
    bookReviewController.startCommentsListener(widget.review.id);
    
    // 監聽 Tab 變化，如果切換到留言 Tab 頁面被初次載入時，確保監聽已經啟動。
    // 這個 addListener 主要是為了確保當用戶手動切換到留言Tab時，
    // 如果之前因為某些原因監聽沒有啟動，能夠再次啟動。
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        // 確保監聽已啟動，如果已啟動則不會重複訂閱
        bookReviewController.startCommentsListener(widget.review.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    // [優化] 在頁面銷毀時停止監聽留言並清空列表，防止 setState() called after dispose() 錯誤
    bookReviewController.stopCommentsListener();
    super.dispose();
  }

  /// 處理發送留言
  Future<void> _sendComment() async {
    final String commentContent = _commentController.text.trim();
    if (commentContent.isEmpty) {
      Get.snackbar('提示', '留言內容不能為空。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      return;
    }
    
    await bookReviewController.addComment(widget.review.id, commentContent);

    // 只有在沒有錯誤訊息時才清空輸入框
    if (bookReviewController.errorMessage.isEmpty) {
      _commentController.clear(); // 清空輸入框
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final currentUserUid = authController.currentUser.value?.uid;

    // [優化] 使用 Obx 監聽 BookReviewController 中對應的心得物件的最新狀態
    // 這樣確保 likesCount 和 commentsCount 是即時更新的
    return Obx(() {
      // 嘗試從公開心得列表獲取最新狀態，如果找不到則從用戶心得列表，最後使用傳入的 review
      final BookReview displayReview = bookReviewController.publicBookReviews.firstWhereOrNull((r) => r.id == widget.review.id)
          ?? bookReviewController.userBookReviews.firstWhereOrNull((r) => r.id == widget.review.id)
          ?? widget.review; // Fallback to original if not found

      final bool isLiked = displayReview.likedBy.contains(currentUserUid);

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            '讀書心得詳情',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            labelStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: theme.textTheme.titleMedium,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(text: '詳情'),
              Tab(text: '留言'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 第一個 Tab: 心得詳情
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用戶資訊區塊
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        backgroundImage: displayReview.userAvatarUrl != null && displayReview.userAvatarUrl!.isNotEmpty
                            ? NetworkImage(displayReview.userAvatarUrl!) as ImageProvider
                            : null,
                        child: displayReview.userAvatarUrl == null || displayReview.userAvatarUrl!.isEmpty
                            ? Icon(Icons.person, size: 30, color: theme.primaryColor)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayReview.userName,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              displayReview.bookAuthor, // 顯示作者作為副標題
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 書籍封面圖片
                  if (displayReview.bookCoverUrl != null && displayReview.bookCoverUrl!.isNotEmpty)
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: AppTheme.smartHomeNeumorphic(radius: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          displayReview.bookCoverUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: theme.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.primaryColor.withOpacity(0.1),
                              child: Center(
                                child: Icon(Icons.image_not_supported_outlined, size: 50, color: theme.iconTheme.color?.withOpacity(0.5)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (displayReview.bookCoverUrl != null && displayReview.bookCoverUrl!.isNotEmpty)
                    const SizedBox(height: 20),

                  // 書籍標題
                  Text(
                    displayReview.bookTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 心得內容
                  Text(
                    displayReview.reviewContent,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),

                  // 金句摘錄 (如果存在)
                  if (displayReview.quotes != null && displayReview.quotes!.isNotEmpty) ...[
                    Text('金句摘錄', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: displayReview.quotes!
                          .map((quote) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text('「$quote」', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 標籤 (如果存在)
                  if (displayReview.tags != null && displayReview.tags!.isNotEmpty) ...[
                    Text('標籤', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: displayReview.tags!
                          .map((tag) => Chip(
                                label: Text('#$tag', style: theme.textTheme.labelLarge),
                                backgroundColor: theme.primaryColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 互動數據 (按讚、留言數)
                  Row(
                    children: [
                      // 按讚按鈕
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : theme.iconTheme.color,
                          size: 24,
                        ),
                        onPressed: () {
                          if (currentUserUid != null) {
                            bookReviewController.toggleLike(displayReview, currentUserUid);
                          } else {
                            Get.snackbar('提示', '請先登入才能按讚。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
                          }
                        },
                      ),
                      // 這裡直接使用 displayReview.likesCount 是 OK 的，因為 displayReview 已經是 Obx 監聽到的最新狀態
                      Text(
                        '${displayReview.likesCount} 個讚',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 24, color: theme.iconTheme.color),
                      const SizedBox(width: 4),
                      // 這裡直接使用 displayReview.commentsCount 是 OK 的
                      Text('${displayReview.commentsCount} 則留言', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 創建時間
                  Text(
                    '發布於：${displayReview.createdAt.toLocal().toString().split(' ')[0]}', // 顯示日期
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            // 第二個 Tab: 留言區
            _buildCommentsSection(theme), // 不再需要傳入 review，因為 controller 已管理
          ],
        ),
      );
    });
  }

  /// 構建留言區塊。
  Widget _buildCommentsSection(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          // Obx 監聽 currentReviewComments
          child: Obx(() {
            if (bookReviewController.isLoading.value && bookReviewController.currentReviewComments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (bookReviewController.currentReviewComments.isEmpty) {
              return Center(
                child: Text('目前沒有留言，快來發表第一則留言吧！', style: theme.textTheme.bodyMedium),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: bookReviewController.currentReviewComments.length,
                itemBuilder: (context, index) {
                  final comment = bookReviewController.currentReviewComments[index];
                  return _CommentCard(comment: comment);
                },
              );
            }
          }),
        ),
        // 留言輸入框
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 8.0, // 考慮安全區域
            left: 16.0,
            right: 16.0,
            top: 8.0,
          ),
          child: Container(
            decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 25), // 留言輸入框的 Neumorphism 樣式
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '新增留言...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: theme.textTheme.bodyLarge,
                    maxLines: 3, // 允許多行輸入
                    minLines: 1,
                  ),
                ),
                // [優化] 使用 Builder 包裹 IconButton，將 isLoading 狀態讀取從直接的 Obx 移到 Builder 範圍內
                Builder(
                  builder: (context) {
                    final isSending = bookReviewController.isLoading.value; // 從 controller 獲取狀態
                    return IconButton(
                      icon: isSending
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) // 小型的載入指示器
                          : Icon(Icons.send_rounded, color: theme.primaryColor),
                      onPressed: isSending ? null : _sendComment,
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// `_CommentCard` 顯示單一留言的卡片。
class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            backgroundImage: comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty
                ? NetworkImage(comment.userAvatarUrl!) as ImageProvider
                : null,
            child: comment.userAvatarUrl == null || comment.userAvatarUrl!.isEmpty
                ? Icon(Icons.person, size: 22, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded( // 使用 Expanded 包裹留言內容，防止文字溢出
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: AppTheme.smartHomeNeumorphic(radius: 12), // 留言氣泡的 Neumorphism 樣式
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.userName,
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // 格式化留言時間
                    '${comment.createdAt.toLocal().toString().split(' ')[0]} ${comment.createdAt.toLocal().hour}:${comment.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}