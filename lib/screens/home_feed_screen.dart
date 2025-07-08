// lib/screens/home_feed_screen.dart
// 功能：顯示用戶關注的讀書心得動態 (Instagram 首頁風格)，並在上方顯示朋友的小圖案。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/features/book_review/book_review.dart'; // 引入讀書心得模型
import 'package:book_me_app/features/book_review/book_review_detail_screen.dart'; // 引入讀書心得詳情頁面
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入 AuthController
import 'package:book_me_app/features/user/user_service.dart'; // 引入 UserService
import 'package:book_me_app/models/app_user.dart'; // 引入 AppUser 模型
import 'package:book_me_app/screens/profile_screen.dart'; // 引入 ProfileScreen

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final BookReviewController bookReviewController = Get.find<BookReviewController>();
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = Get.find<UserService>();

  final RxList<AppUser> _followingUsers = <AppUser>[].obs; // 追蹤的用戶列表

  @override
  void initState() {
    super.initState();
    // [修正] 在頁面初始化時，開始監聽公開的讀書心得
    bookReviewController.startPublicReviewsListener();
    // 監聽當前用戶的追蹤列表變化
    // 當 currentAppUser 改變時（例如登入/登出，或追蹤/取消追蹤成功導致其更新），重新獲取追蹤列表
    ever(authController.currentAppUser, (_) {
      _fetchFollowingUsers();
    });
    _fetchFollowingUsers(); // 初次載入追蹤列表
  }

  // 獲取當前用戶追蹤的用戶資料
  Future<void> _fetchFollowingUsers() async {
    // 如果用戶未登入或 currentAppUser 為空，則清空追蹤列表
    if (authController.currentUser.value == null || authController.currentAppUser.value == null) {
      _followingUsers.clear();
      return;
    }
    
    final List<String> followingIds = authController.currentAppUser.value!.following;
    List<AppUser> users = [];
    for (String userId in followingIds) {
      final user = await userService.fetchUser(userId);
      if (user != null) {
        users.add(user);
      }
    }
    _followingUsers.assignAll(users); // 更新追蹤用戶列表
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0, // 無陰影
        title: Text(
          'BookMe',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false, // 標題左對齊
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: theme.iconTheme.color),
            onPressed: () {
              Get.snackbar('提示', '請點擊底部中間的「發布」按鈕。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          IconButton(
            icon: Icon(Icons.message_outlined, color: theme.iconTheme.color),
            onPressed: () {
              Get.snackbar('功能待開發', '訊息功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: Column( // 使用 Column 包裹，以便在頂部添加朋友列表
        children: [
          // 朋友小圖案列表 (類似 Instagram 限時動態)
          Obx(() => _followingUsers.isEmpty && authController.currentUser.value != null // 只有在登入狀態下才判斷是否為空
              ? Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '還沒有追蹤的朋友，快去探索吧！',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : _buildFollowingUsersList(theme)),
          const Divider(height: 1, thickness: 0.5), // 分隔線
          
          Expanded( // Expanded 包裹原來的 body 內容
            child: Obx(() {
              if (bookReviewController.isLoading.value && bookReviewController.publicBookReviews.isEmpty) {
                return Center(child: CircularProgressIndicator(color: theme.primaryColor)); // 顯示載入指示器
              } else if (bookReviewController.publicBookReviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.5)),
                      const SizedBox(height: 20),
                      Text(
                        '目前沒有讀書心得動態',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '快去發布您的第一篇心得吧！',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                // 顯示讀書心得列表 (動態牆)
                return RefreshIndicator(
                  // [修正] 下拉刷新時，重新啟動監聽，以強制刷新數據
                  onRefresh: () async {
                    // bookReviewController.stopPublicReviewsListener(); // 這個方法現在已經存在於 controller
                    await bookReviewController.startPublicReviewsListener();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: bookReviewController.publicBookReviews.length,
                    itemBuilder: (context, index) {
                      final review = bookReviewController.publicBookReviews[index];
                      // _BookReviewPostCard 變回 StatelessWidget
                      return _BookReviewPostCard(review: review);
                    },
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // 構建追蹤用戶的水平列表
  Widget _buildFollowingUsersList(ThemeData theme) {
    return Container(
      height: 100, // 固定高度
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _followingUsers.length,
        itemBuilder: (context, index) {
          final AppUser user = _followingUsers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // 點擊頭像導航到朋友的個人檔案頁面
                    Get.to(() => ProfileScreen(userId: user.userId));
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                    backgroundImage: user.userAvatarUrl != null && user.userAvatarUrl!.isNotEmpty
                        ? NetworkImage(user.userAvatarUrl!) as ImageProvider
                        : null,
                    child: user.userAvatarUrl == null || user.userAvatarUrl!.isEmpty
                        ? Icon(Icons.person, size: 35, color: theme.primaryColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.userName.length > 8 ? '${user.userName.substring(0, 7)}...' : user.userName, // 超過長度截斷
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// `_BookReviewPostCard` 顯示單個讀書心得貼文卡片，模仿 Instagram 的貼文樣式。
/// 再次變回 StatelessWidget，依賴控制器中 RxList 的更新來觸發重建。
class _BookReviewPostCard extends StatelessWidget {
  final BookReview review; // 接收一個讀書心得物件

  const _BookReviewPostCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final AuthController authController = Get.find<AuthController>();
    final BookReviewController bookReviewController = Get.find<BookReviewController>();

    // 將整個卡片包裹在 Obx 中，以響應 publicBookReviews 列表內部的變化
    // 這樣當 controller 中的 review 物件被替換時，這裡的 UI 會自動重建
    return Obx(() {
      // 從 controller 的公開心得列表 (或用戶心得列表) 中獲取最新狀態的 review
      // 這樣確保 UI 總是顯示最新的 likesCount 和 commentsCount
      final BookReview? displayReview = bookReviewController.publicBookReviews.firstWhereOrNull((r) => r.id == review.id)
          ?? bookReviewController.userBookReviews.firstWhereOrNull((r) => r.id == review.id);
      
      // 如果找不到對應的 review (可能已被刪除或尚未載入)，則顯示一個空的 Container 或載入指示器
      if (displayReview == null) {
        return const SizedBox.shrink(); // 或 CircularProgressIndicator();
      }

      final bool isLiked = displayReview.likedBy.contains(authController.currentUser.value?.uid);

      return GestureDetector(
        onTap: () {
          // 點擊貼文導航到詳情頁面
          Get.to(() => BookReviewDetailScreen(review: displayReview));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: AppTheme.smartHomeNeumorphic(radius: 15), // 卡片整體 Neumorphism 效果
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用戶頭像與名稱
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    GestureDetector( // 點擊貼文的用戶頭像和名稱也可以導航到其個人檔案
                      onTap: () {
                        Get.to(() => ProfileScreen(userId: displayReview.userId));
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        backgroundImage: displayReview.userAvatarUrl != null && displayReview.userAvatarUrl!.isNotEmpty
                            ? NetworkImage(displayReview.userAvatarUrl!) as ImageProvider
                            : null,
                        child: displayReview.userAvatarUrl == null || displayReview.userAvatarUrl!.isEmpty
                            ? Icon(Icons.person, size: 25, color: theme.primaryColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ProfileScreen(userId: displayReview.userId));
                      },
                      child: Text(
                        displayReview.userName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    // TODO: 未來可添加更多選項按鈕
                    Icon(Icons.more_horiz, color: theme.iconTheme.color),
                  ],
                ),
              ),

              // 書籍封面圖片
              if (displayReview.bookCoverUrl != null && displayReview.bookCoverUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(0)), // 圖片不需要圓角，讓卡片本身有圓角
                  child: Image.network(
                    displayReview.bookCoverUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250, // 固定高度
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: theme.primaryColor.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: theme.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: theme.primaryColor.withOpacity(0.1),
                        child: Center(
                          child: Icon(Icons.image_not_supported_outlined, size: 50, color: theme.iconTheme.color?.withOpacity(0.5)),
                        ),
                      );
                    },
                  ),
                ),
              
              // 書名和作者
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
                child: Text(
                  displayReview.bookTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
                child: Text(
                  '作者：${displayReview.bookAuthor}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              // 心得內容摘要
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                child: Text(
                  displayReview.reviewContent,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 3, // 顯示摘要
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 互動按鈕區塊 (按讚、留言、分享)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    // 按讚按鈕
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : theme.iconTheme.color,
                      ),
                      onPressed: () {
                        if (authController.currentUser.value?.uid != null) {
                          bookReviewController.toggleLike(displayReview, authController.currentUser.value!.uid);
                        } else {
                          // [修正] 使用 theme 的顏色
                          Get.snackbar('提示', '請先登入才能按讚。', snackPosition: SnackPosition.BOTTOM, backgroundColor: theme.colorScheme.secondary, colorText: theme.colorScheme.onSecondary);
                        }
                      },
                    ),
                    // 留言按鈕
                    IconButton(
                      icon: Icon(Icons.chat_bubble_outline, color: theme.iconTheme.color),
                      onPressed: () {
                        // 點擊留言按鈕直接導航到詳情頁並滾動到留言區
                        Get.to(() => BookReviewDetailScreen(review: displayReview, initialTabIndex: 1));
                      },
                    ),
                    // 分享按鈕
                    IconButton(
                      icon: Icon(Icons.send_outlined, color: theme.iconTheme.color),
                      onPressed: () {
                        // [修正] 使用 theme 的顏色
                        Get.snackbar('功能待開發', '分享功能仍在開發中。', snackPosition: SnackPosition.BOTTOM, backgroundColor: theme.colorScheme.secondary, colorText: theme.colorScheme.onSecondary);
                      },
                    ),
                    const Spacer(),
                    // 收藏按鈕
                    IconButton(
                      icon: Icon(Icons.bookmark_border, color: theme.iconTheme.color),
                      onPressed: () {
                        // [修正] 使用 theme 的顏色
                        Get.snackbar('功能待開發', '收藏功能仍在開發中。', snackPosition: SnackPosition.BOTTOM, backgroundColor: theme.colorScheme.secondary, colorText: theme.colorScheme.onSecondary);
                      },
                    ),
                  ],
                ),
              ),

              // 按讚數和留言連結
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顯示按讚數
                    Text(
                      '${displayReview.likesCount} 個讚',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // 顯示留言數連結
                    if (displayReview.commentsCount > 0)
                      GestureDetector(
                        onTap: () {
                          Get.to(() => BookReviewDetailScreen(review: displayReview, initialTabIndex: 1)); // 點擊查看所有留言
                        },
                        child: Text(
                          '查看所有 ${displayReview.commentsCount} 則留言',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                        ),
                      ),
                  ],
                ),
              ),

              // 發布時間
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                child: Text(
                  '${displayReview.createdAt.toLocal().toString().split(' ')[0]}', // 顯示日期
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      );
    }); // End of Obx
  }
}