// lib/features/navigation/profile_screen.dart
// [修正完成] 功能：顯示用戶的個人檔案，採用分離式擬物化風格並移除舊引用。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/features/user/user_service.dart';
import 'package:book_me_app/features/book_review/book_review_controller.dart';
import 'package:book_me_app/models/app_user.dart';
import 'package:book_me_app/features/book_review/book_review.dart';
import 'package:book_me_app/features/book_review/book_review_detail_screen.dart';
import 'package:book_me_app/core/app_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = Get.find<UserService>();
  final BookReviewController bookReviewController = Get.find<BookReviewController>();
  final AppController appController = Get.find<AppController>();

  final Rx<AppUser?> _profileUser = Rx<AppUser?>(null);
  final RxBool _isFollowing = false.obs;
  final RxBool _isProfileLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    ever(authController.currentUser, (_) => _checkFollowingStatus());
    ever(authController.currentAppUser, (_) => _checkFollowingStatus());
    bookReviewController.startUserReviewsListener(widget.userId);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _loadProfileData();
      bookReviewController.stopUserReviewsListener();
      bookReviewController.startUserReviewsListener(widget.userId);
    }
  }

  @override
  void dispose() {
    bookReviewController.stopUserReviewsListener();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    _isProfileLoading.value = true;
    _profileUser.value = null;
    final user = await userService.fetchUser(widget.userId);
    _profileUser.value = user;
    _checkFollowingStatus();
    _isProfileLoading.value = false;
  }

  void _checkFollowingStatus() {
    final currentAppUser = authController.currentAppUser.value;
    if (_profileUser.value != null && currentAppUser != null) {
      if (currentAppUser.userId != _profileUser.value!.userId) {
        _isFollowing.value = currentAppUser.following.contains(_profileUser.value!.userId);
      } else {
        _isFollowing.value = false;
      }
    } else {
      _isFollowing.value = false;
    }
  }

  Future<void> _toggleFollowUser() async {
    final currentUserId = authController.currentUser.value?.uid;
    final currentAppUser = authController.currentAppUser.value;
    if (currentUserId == null || _profileUser.value == null || currentAppUser == null) return;
    if (currentUserId == _profileUser.value!.userId) return;

    final success = await userService.toggleFollow(currentUserId, widget.userId, _isFollowing.value);
    if (success) {
      _isFollowing.toggle();
      await authController.fetchAndUpdateCurrentUserProfile();
      await _loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = appController.currentTheme.value;
    final bool isCurrentUserProfile = authController.currentUser.value?.uid == widget.userId;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      body: Obx(() {
        final AppUser? user = _profileUser.value;

        if (user == null || _isProfileLoading.value) {
          return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
        }

        return Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 280),
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTopBar(theme, isCurrentUserProfile),
                    const SizedBox(height: 10),
                    _buildUserInfoSection(theme, user),
                    _buildContentSection(theme, user, isCurrentUserProfile),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopBar(IAppTheme theme, bool isCurrentUserProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.themeData.iconTheme.color),
            onPressed: () => Get.back(),
          ),
          Obx(() => Text(
                _profileUser.value?.userName ?? (isCurrentUserProfile ? '我的檔案' : '載入中...'),
                style: theme.themeData.textTheme.headlineSmall,
              )),
          if (isCurrentUserProfile)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: theme.themeData.iconTheme.color),
              onPressed: () {},
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(IAppTheme theme, AppUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            decoration: theme.neumorphicBoxDecoration(
              radius: 65,
              color: theme.primaryBackgroundColor,
            ),
            padding: const EdgeInsets.all(5),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.secondaryBackgroundColor,
              backgroundImage: user.userAvatarUrl != null && user.userAvatarUrl!.isNotEmpty
                  ? NetworkImage(user.userAvatarUrl!) as ImageProvider
                  : null,
              child: user.userAvatarUrl == null || user.userAvatarUrl!.isEmpty
                  ? Icon(Icons.person, size: 70, color: theme.themeData.primaryColor)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(user.userName, style: theme.themeData.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            user.bio ?? '這是用戶的簡介，分享您的讀書旅程！',
            style: theme.themeData.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: theme.neumorphicBoxDecoration(
              radius: 20,
              color: theme.primaryBackgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCountColumn('追蹤中', user.following.length, theme),
                const SizedBox(width: 50),
                _buildCountColumn('追蹤者', user.followers.length, theme),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContentSection(IAppTheme theme, AppUser user, bool isCurrentUserProfile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: isCurrentUserProfile
                ? _buildEditProfileButton(theme)
                : _buildFollowButton(theme),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${user.userName} 的讀書心得貼文',
              style: theme.themeData.textTheme.titleLarge,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          Obx(() {
            if (bookReviewController.isLoading.value && bookReviewController.userBookReviews.isEmpty) {
              return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
            } else if (bookReviewController.userBookReviews.isEmpty) {
              return _buildEmptyState(theme, isCurrentUserProfile);
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: bookReviewController.userBookReviews.length,
                itemBuilder: (context, index) {
                  final review = bookReviewController.userBookReviews[index];
                  return _BookReviewGridItem(review: review, theme: theme);
                },
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCountColumn(String label, int count, IAppTheme theme) {
    return Column(
      children: [
        Text('$count', style: theme.themeData.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(label, style: theme.themeData.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildEditProfileButton(IAppTheme theme) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: theme.neumorphicBoxDecoration(
          radius: 15,
          color: theme.secondaryBackgroundColor,
        ),
        child: Center(
          child: Text(
            '編輯個人檔案',
            style: theme.themeData.textTheme.titleLarge?.copyWith(color: theme.themeData.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(IAppTheme theme) {
    return Obx(() {
      final bool isFollowing = _isFollowing.value;
      return ElevatedButton(
        onPressed: _toggleFollowUser,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: theme.neumorphicBoxDecoration(
            radius: 15,
            color: isFollowing ? theme.secondaryBackgroundColor : theme.themeData.primaryColor,
            gradient: isFollowing ? null : LinearGradient(
              colors: [theme.themeData.primaryColor, const Color(0xFF6A95FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              isFollowing ? '已追蹤' : '追蹤',
              style: theme.themeData.textTheme.titleLarge?.copyWith(
                color: isFollowing ? theme.themeData.primaryColor : Colors.white,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(IAppTheme theme, bool isCurrentUserProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: theme.themeData.iconTheme.color?.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('還沒有讀書心得呢！', style: theme.themeData.textTheme.headlineSmall),
          if (isCurrentUserProfile) ...[
            const SizedBox(height: 10),
            Text('點擊下方加號按鈕，分享您的第一篇心得吧。', style: theme.themeData.textTheme.bodyMedium, textAlign: TextAlign.center),
          ]
        ],
      ),
    );
  }
}

class _BookReviewGridItem extends StatelessWidget {
  final BookReview review;
  final IAppTheme theme;

  const _BookReviewGridItem({required this.review, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BookReviewDetailScreen(review: review));
      },
      child: Container(
        decoration: theme.neumorphicBoxDecoration( // [修正] 使用 theme 物件
          radius: 15,
          color: theme.secondaryBackgroundColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: review.bookCoverUrl != null && review.bookCoverUrl!.isNotEmpty
              ? Image.network(
                  review.bookCoverUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.image_not_supported_outlined, color: theme.themeData.iconTheme.color));
                  },
                )
              : Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, size: 40, color: theme.themeData.iconTheme.color?.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        review.bookTitle,
                        style: theme.themeData.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}