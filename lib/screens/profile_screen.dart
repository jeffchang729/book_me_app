// lib/screens/profile_screen.dart
// 功能：顯示用戶的個人檔案資訊和讀書心得網格 (Instagram 個人檔案風格)，支援顯示心得圖片。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入認證控制器
import 'package:book_me_app/features/auth/auth_screen.dart'; // 引入 AuthScreen
import 'package:book_me_app/core/app_theme.dart'; // 引入 AppTheme
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/models/book_review.dart'; // 引入讀書心得模型
import 'package:book_me_app/core/app_controller.dart'; // [新增] 引入 AppController

/// `ProfileScreen` 用於顯示當前登入用戶的個人檔案資訊。
/// 其設計靈感來自 Instagram 的個人檔案頁面，包含用戶頭像、簡介和已發布的讀書心得網格。
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme; // 獲取當前主題
    final AuthController authController = Get.find<AuthController>(); // 獲取認證控制器
    final BookReviewController bookReviewController = Get.find<BookReviewController>(); // 獲取讀書心得控制器
    final AppController appController = Get.find<AppController>(); // [新增] 獲取 AppController

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // AppBar 背景色
        elevation: 0, // 無陰影
        title: Obx(() => Text( // 使用 Obx 監聽 currentUser 變化
          authController.currentUser.value?.email ?? '我的個人檔案', // 顯示當前用戶 Email 或預設文字
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        )),
        centerTitle: false, // 標題左對齊
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: theme.iconTheme.color), // 菜單按鈕
            onPressed: () {
              // TODO: 未來導航到設定或更多選項
              Get.snackbar('功能待開發', '設定功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          // 登出按鈕 (只有登入後才顯示)
          Obx(() => authController.currentUser.value != null
              ? IconButton(
                  icon: Icon(Icons.logout, color: theme.iconTheme.color),
                  onPressed: () {
                    authController.signOut(); // 呼叫登出方法
                    Get.snackbar('登出成功', '您已成功登出。', snackPosition: SnackPosition.BOTTOM);
                  },
                )
              : const SizedBox.shrink()), // 未登入時隱藏
        ],
      ),
      body: Obx(() {
        if (authController.currentUser.value == null) {
          // 如果用戶未登入，顯示登入提示頁面
          return _buildLoginPromptPage(context, authController, appController); // [修正] 傳遞 appController
        } else {
          // 如果用戶已登入，顯示實際的個人檔案內容
          return RefreshIndicator( // 增加下拉刷新功能
            onRefresh: () async {
              await bookReviewController.fetchUserBookReviews(authController.currentUser.value!.uid);
            },
            child: Column(
              children: [
                // 佔位符：用戶頭像和基本資訊
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        child: Icon(Icons.person, size: 60, color: theme.primaryColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        authController.currentUser.value?.displayName ?? authController.currentUser.value?.email ?? '用戶名稱', 
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '這裡是用戶的簡介，分享您的讀書旅程！', 
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '我的讀書心得貼文',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                // 顯示讀書心得列表或載入/空狀態
                Expanded(
                  child: Obx(() {
                    if (bookReviewController.isLoading.value && bookReviewController.userBookReviews.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (bookReviewController.userBookReviews.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 60, color: theme.iconTheme.color?.withOpacity(0.5)),
                            const SizedBox(height: 20),
                            Text(
                              '還沒有讀書心得呢！',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '點擊下方加號按鈕，分享您的第一篇心得吧。',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else {
                      // 使用 GridView 顯示心得，模仿 Instagram 的貼文網格
                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 每行3個項目
                          crossAxisSpacing: 4.0, // 水平間距
                          mainAxisSpacing: 4.0, // 垂直間距
                        ),
                        itemCount: bookReviewController.userBookReviews.length,
                        itemBuilder: (context, index) {
                          final review = bookReviewController.userBookReviews[index];
                          return _BookReviewGridItem(review: review); // 顯示單個心得網格項目
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  /// 建立未登入時顯示的登入提示頁面。
  Widget _buildLoginPromptPage(BuildContext context, AuthController authController, AppController appController) { // [修正] 接收 appController
    final theme = context.theme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.5)),
        const SizedBox(height: 20),
        Text(
          '登入以查看您的個人檔案',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '管理您的讀書心得和個人資訊。',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              authController.toggleAuthMode(); // 切換到登入模式
              // [修正] 導航到 AuthScreen，並傳遞回調函數以返回當前頁面
              Get.to(() => AuthScreen(onLoginSuccess: () {
                appController.changeTabIndex(4); // 返回到個人檔案頁面 (索引 4)
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              '登入或註冊',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// `_BookReviewGridItem` 顯示單個讀書心得在個人檔案頁面的網格預覽。
/// 它會嘗試顯示書籍封面圖片，如果沒有圖片則顯示書名。
class _BookReviewGridItem extends StatelessWidget {
  final BookReview review;

  const _BookReviewGridItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () {
        // TODO: 導航到讀書心得詳情頁面
        Get.snackbar('功能待開發', '點擊心得查看詳情功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
      },
      child: Container(
        decoration: AppTheme.smartHomeNeumorphic(radius: 8), // 為網格項目添加 Neumorphism 效果
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: review.bookCoverUrl != null && review.bookCoverUrl!.isNotEmpty
              ? Image.network(
                  review.bookCoverUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
                        child: Icon(Icons.image_not_supported_outlined, size: 40, color: theme.iconTheme.color?.withOpacity(0.5)),
                      ),
                    );
                  },
                )
              : Container(
                  color: theme.primaryColor.withOpacity(0.1), // 沒有圖片時的背景色
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        review.bookTitle, // 顯示書名
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
