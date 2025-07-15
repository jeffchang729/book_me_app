// lib/features/navigation/home_feed_screen.dart
// [最終修正] 功能：為動態牆列表增加底部內邊距，避免內容被導覽列裁切。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/book_review/book_review_controller.dart';
import 'package:book_me_app/features/book_review/book_review.dart';
import 'package:book_me_app/features/book_review/book_review_detail_screen.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/features/user/user_service.dart';
import 'package:book_me_app/models/app_user.dart';
import 'package:book_me_app/features/navigation/profile_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final BookReviewController bookReviewController = Get.find<BookReviewController>();
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = Get.find<UserService>();
  final AppController appController = Get.find<AppController>();

  final RxList<AppUser> _followingUsers = <AppUser>[].obs;

  @override
  void initState() {
    super.initState();
    bookReviewController.startPublicReviewsListener();
    ever(authController.currentAppUser, (_) => _fetchFollowingUsers());
    _fetchFollowingUsers();
  }

  Future<void> _fetchFollowingUsers() async {
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
    _followingUsers.assignAll(users);
  }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryBackgroundColor,
        elevation: 0,
        title: Text(
          'BookMe',
          style: theme.themeData.textTheme.headlineLarge?.copyWith(fontFamily: 'WorkSans'),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.message_outlined, color: theme.themeData.iconTheme.color),
            onPressed: () {
              Get.snackbar('功能待開發', '訊息功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await bookReviewController.startPublicReviewsListener();
          await _fetchFollowingUsers();
        },
        color: theme.themeData.primaryColor,
        backgroundColor: theme.secondaryBackgroundColor,
        child: Column(
          children: [
            _buildFollowingUsersList(theme),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.secondaryBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Obx(() {
                  if (bookReviewController.isLoading.value && bookReviewController.publicBookReviews.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: theme.themeData.primaryColor));
                  }
                  if (bookReviewController.publicBookReviews.isEmpty) {
                    return Center(
                      child: Text('目前沒有公開的讀書心得', style: theme.themeData.textTheme.bodyLarge),
                    );
                  }
                  return ListView.builder(
                    // [修正] 增加底部 padding，值約等於 BottomAppBar 的高度
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 90), 
                    itemCount: bookReviewController.publicBookReviews.length,
                    itemBuilder: (context, index) {
                      final review = bookReviewController.publicBookReviews[index];
                      return _BookReviewPostCard(review: review, theme: theme);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingUsersList(IAppTheme theme) {
    return Obx(() => _followingUsers.isEmpty && authController.currentUser.value != null
        ? const SizedBox(height: 110) // 保持佔位高度
        : Container(
            height: 110,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                        onTap: () => Get.to(() => ProfileScreen(userId: user.userId)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: theme.neumorphicBoxDecoration(
                            radius: 35,
                            color: theme.primaryBackgroundColor,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.secondaryBackgroundColor,
                            backgroundImage: user.userAvatarUrl != null && user.userAvatarUrl!.isNotEmpty
                                ? NetworkImage(user.userAvatarUrl!) as ImageProvider
                                : null,
                            child: user.userAvatarUrl == null || user.userAvatarUrl!.isEmpty
                                ? Icon(Icons.person, size: 35, color: theme.themeData.primaryColor)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.userName.length > 5 ? '${user.userName.substring(0, 4)}...' : user.userName,
                        style: theme.themeData.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ));
  }
}

class _BookReviewPostCard extends StatelessWidget {
  final BookReview review;
  final IAppTheme theme;

  const _BookReviewPostCard({required this.review, required this.theme});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final BookReviewController bookReviewController = Get.find<BookReviewController>();

    return Obx(() {
      final BookReview? displayReview = bookReviewController.publicBookReviews.firstWhereOrNull((r) => r.id == review.id) ??
          bookReviewController.userBookReviews.firstWhereOrNull((r) => r.id == review.id);

      if (displayReview == null) return const SizedBox.shrink();

      final bool isLiked = displayReview.likedBy.contains(authController.currentUser.value?.uid);

      return GestureDetector(
        onTap: () => Get.to(() => BookReviewDetailScreen(review: displayReview)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          decoration: theme.neumorphicBoxDecoration(
            radius: 25,
            color: theme.secondaryBackgroundColor
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => ProfileScreen(userId: displayReview.userId)),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: displayReview.userAvatarUrl != null && displayReview.userAvatarUrl!.isNotEmpty
                            ? NetworkImage(displayReview.userAvatarUrl!) as ImageProvider : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => ProfileScreen(userId: displayReview.userId)),
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text(displayReview.userName, style: theme.themeData.textTheme.titleLarge),
                              Text("分享了《${displayReview.bookTitle}》", style: theme.themeData.textTheme.bodySmall, overflow: TextOverflow.ellipsis,),
                           ],
                        ),
                      ),
                    ),
                    Icon(Icons.more_horiz, color: theme.themeData.iconTheme.color),
                  ],
                ),
              ),

              if (displayReview.bookCoverUrl != null && displayReview.bookCoverUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      displayReview.bookCoverUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  displayReview.reviewContent,
                  style: theme.themeData.textTheme.bodyLarge?.copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.redAccent : theme.themeData.iconTheme.color,
                          ),
                          onPressed: () {
                            if (authController.currentUser.value?.uid != null) {
                              bookReviewController.toggleLike(displayReview, authController.currentUser.value!.uid);
                            }
                          },
                        ),
                        Text('${displayReview.likesCount}', style: theme.themeData.textTheme.bodyMedium),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline, color: theme.themeData.iconTheme.color),
                          onPressed: () => Get.to(() => BookReviewDetailScreen(review: displayReview, initialTabIndex: 1)),
                        ),
                        Text('${displayReview.commentsCount}', style: theme.themeData.textTheme.bodyMedium),
                      ],
                    ),
                    Text(
                      displayReview.createdAt.toLocal().toString().split(' ')[0],
                      style: theme.themeData.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    });
  }
}