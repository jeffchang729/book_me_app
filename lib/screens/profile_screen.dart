// lib/screens/profile_screen.dart
// 功能：顯示用戶的個人檔案，包括頭像、簡介、追蹤數量，以及發布的讀書心得。
// 支援追蹤/取消追蹤其他用戶的功能。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入認證控制器
import 'package:book_me_app/features/user/user_service.dart'; // 引入用戶服務
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/models/app_user.dart'; // 引入 AppUser 模型
import 'package:book_me_app/features/book_review/book_review.dart'; // 引入 BookReview 模型
import 'package:book_me_app/features/book_review/book_review_detail_screen.dart'; // 引入讀書心得詳情頁面

/// `ProfileScreen` 顯示特定用戶的個人檔案。
/// 如果是當前登入用戶的檔案，則顯示編輯按鈕；如果是其他用戶，則顯示追蹤按鈕。
class ProfileScreen extends StatefulWidget {
  final String userId; // 要顯示的用戶 ID

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = Get.find<UserService>();
  final BookReviewController bookReviewController = Get.find<BookReviewController>();

  // 使用 Rx<AppUser?> 來管理當前顯示的用戶資料
  final Rx<AppUser?> _profileUser = Rx<AppUser?>(null);
  // 使用 RxBool 來管理追蹤狀態
  final RxBool _isFollowing = false.obs;
  // [新增] 用於控制 ProfileScreen 內部數據載入狀態
  final RxBool _isProfileLoading = false.obs; 

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // 載入個人檔案數據
    // 監聽當前登入用戶的變化，以更新追蹤按鈕狀態
    ever(authController.currentUser, (_) => _checkFollowingStatus());
    ever(authController.currentAppUser, (_) => _checkFollowingStatus());

    // 開始監聽此用戶的讀書心得
    bookReviewController.startUserReviewsListener(widget.userId);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _loadProfileData(); // 當 userId 改變時重新載入數據
      bookReviewController.startUserReviewsListener(widget.userId); // 重新監聽新用戶的心得
    }
  }

  @override
  void dispose() {
    // 在頁面銷毀時停止監聽用戶心得
    bookReviewController.stopUserReviewsListener();
    super.dispose();
  }

  // 載入用戶個人檔案數據
  Future<void> _loadProfileData() async {
    _isProfileLoading.value = true; // 開始載入
    _profileUser.value = null; // 清空舊資料
    try {
      final user = await userService.fetchUser(widget.userId);
      _profileUser.value = user; // 更新響應式變數
      _checkFollowingStatus(); // 檢查追蹤狀態
    } catch (e) {
      Get.snackbar('錯誤', '載入個人檔案失敗: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      _isProfileLoading.value = false; // 載入完成
    }
  }

  // 檢查當前登入用戶是否已追蹤此檔案用戶
  void _checkFollowingStatus() {
    final currentAppUser = authController.currentAppUser.value;
    if (_profileUser.value != null && currentAppUser != null && currentAppUser.userId != _profileUser.value!.userId) {
      _isFollowing.value = currentAppUser.following.contains(_profileUser.value!.userId);
    } else {
      _isFollowing.value = false; // 如果是自己或未登入，則不顯示追蹤狀態
    }
  }

  // 追蹤/取消追蹤邏輯
  Future<void> _toggleFollowUser() async {
    final currentUserId = authController.currentUser.value?.uid;
    if (currentUserId == null || _profileUser.value == null) {
      Get.snackbar('提示', '請先登入才能進行追蹤操作。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      return;
    }

    if (currentUserId == _profileUser.value!.userId) {
      Get.snackbar('提示', '不能追蹤自己喔！', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      return;
    }

    // 可以在這裡顯示局部 loading
    final success = await userService.toggleFollow(currentUserId, widget.userId, _isFollowing.value);
    if (success) {
      _isFollowing.toggle(); // 更新本地追蹤狀態
      // 成功後重新載入兩個用戶的 AppUser 資料，確保數量更新
      await authController.fetchAndUpdateCurrentUserProfile(); // 更新當前用戶的 AppUser
      // _loadProfileData() 會重新載入此檔案用戶的 AppUser 和心得，以反映 follower 數量變化
      await _loadProfileData(); 
    } else {
      Get.snackbar('錯誤', '追蹤操作失敗，請稍後再試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isCurrentUserProfile = authController.currentUser.value?.uid == widget.userId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              _profileUser.value?.userName ?? '載入中...', // 觀察 _profileUser
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            )),
        centerTitle: false,
        actions: [
          if (isCurrentUserProfile)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: theme.iconTheme.color),
              onPressed: () {
                Get.snackbar('功能待開發', '個人檔案設定功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
              },
            ),
        ],
      ),
      body: Obx(() { // 將整個 Column 包裹在 Obx 中，以響應 _profileUser 的變化
        final AppUser? user = _profileUser.value;

        if (user == null || _isProfileLoading.value) { // [修正] 顯示 _isProfileLoading
          // 如果用戶資料為空，顯示載入中或錯誤訊息
          return Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 頭像和名稱居中
            children: [
              // 用戶頭像
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                backgroundImage: user.userAvatarUrl != null && user.userAvatarUrl!.isNotEmpty
                    ? NetworkImage(user.userAvatarUrl!) as ImageProvider
                    : null,
                child: user.userAvatarUrl == null || user.userAvatarUrl!.isEmpty
                    ? Icon(Icons.person, size: 70, color: theme.primaryColor)
                    : null,
              ),
              const SizedBox(height: 16),
              // 用戶名稱
              Text(
                user.userName,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 個人簡介
              Text(
                user.bio ?? '這是用戶的簡介，分享您的讀書旅程！',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 追蹤數量顯示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCountColumn('追蹤中', user.following.length, theme),
                  const SizedBox(width: 40),
                  _buildCountColumn('追蹤者', user.followers.length, theme),
                ],
              ),
              const SizedBox(height: 24),

              // 編輯/追蹤按鈕
              SizedBox(
                width: double.infinity, // 讓按鈕佔滿寬度
                child: isCurrentUserProfile
                    ? _buildEditProfileButton(theme) // 編輯個人檔案
                    : _buildFollowButton(theme), // 追蹤/已追蹤按鈕
              ),
              const SizedBox(height: 32),

              // 讀書心得貼文標題
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${user.userName} 的讀書心得貼文',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 24, thickness: 1), // 分隔線

              // 讀書心得網格顯示
              Obx(() { // 獨立的 Obx 來監聽 userBookReviews
                if (bookReviewController.isLoading.value && bookReviewController.userBookReviews.isEmpty) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                } else if (bookReviewController.userBookReviews.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.5)),
                          const SizedBox(height: 20),
                          Text(
                            '還沒有讀書心得呢！',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          if (isCurrentUserProfile)
                            Text(
                              '點擊下方加號按鈕，分享您的第一篇心得吧。',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true, // 讓 GridView 根據內容自動適應高度
                    physics: const NeverScrollableScrollPhysics(), // 禁用 GridView 自身的滾動
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 每行3個項目
                      crossAxisSpacing: 8.0, // 水平間距
                      mainAxisSpacing: 8.0, // 垂直間距
                      childAspectRatio: 0.7, // 調整長寬比，讓圖片不會過於扁平
                    ),
                    itemCount: bookReviewController.userBookReviews.length,
                    itemBuilder: (context, index) {
                      final review = bookReviewController.userBookReviews[index];
                      return _BookReviewGridItem(review: review);
                    },
                  );
                }
              }),
            ],
          ),
        );
      }),
    );
  }

  // 輔助函數：顯示數量和標籤的欄位
  Widget _buildCountColumn(String label, int count, ThemeData theme) {
    return Column(
      children: [
        Text(
          '$count',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // 輔助函數：編輯個人檔案按鈕
  Widget _buildEditProfileButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        Get.snackbar('功能待開發', '編輯個人檔案功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor.withOpacity(0.1), // 淺色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: theme.primaryColor.withOpacity(0.3)), // 邊框
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '編輯個人檔案',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor), // 文字顏色使用主題主色
        ),
      ),
    );
  }

  // 輔助函數：追蹤/已追蹤按鈕
  Widget _buildFollowButton(ThemeData theme) {
    return Obx(() => ElevatedButton( // 包裹在 Obx 中監聽 _isFollowing
      onPressed: _toggleFollowUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing.value ? theme.primaryColor.withOpacity(0.1) : theme.primaryColor, // 已追蹤淺色，未追蹤深色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: _isFollowing.value ? BorderSide(color: theme.primaryColor.withOpacity(0.3)) : BorderSide.none, // 已追蹤有邊框
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          _isFollowing.value ? '已追蹤' : '追蹤',
          style: theme.textTheme.titleLarge?.copyWith(
            color: _isFollowing.value ? theme.primaryColor : Colors.white, // 文字顏色對應背景色
          ),
        ),
      ),
    ));
  }
}

/// `_BookReviewGridItem` 顯示單個讀書心得在網格中的縮略圖。
class _BookReviewGridItem extends StatelessWidget {
  final BookReview review;

  const _BookReviewGridItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () {
        Get.to(() => BookReviewDetailScreen(review: review));
      },
      child: Container(
        decoration: AppTheme.smartHomeNeumorphic(radius: 10), // 網格項目的 Neumorphism 效果
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: review.bookCoverUrl != null && review.bookCoverUrl!.isNotEmpty
              ? Image.network(
                  review.bookCoverUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
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
                      color: theme.primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 40, color: theme.iconTheme.color?.withOpacity(0.5)),
                      ),
                    );
                  },
                )
              : Container(
                  color: theme.primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 40, color: theme.iconTheme.color?.withOpacity(0.5)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            review.bookTitle,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}