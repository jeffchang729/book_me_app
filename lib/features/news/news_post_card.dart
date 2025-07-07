// lib/features/news/news_post_card.dart
// [錯誤修正 V4.5]
// 功能：修正圖片資源路徑。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/news/news_models.dart';

class NewsPostCard extends StatelessWidget {
  final PostData post;

  const NewsPostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppTheme.smartHomeNeumorphic(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [修正] 確保 Image.asset 使用的是相對於專案根目錄的完整路徑
            _buildImage(context, 'assets/images/news_placeholder.png'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  const SizedBox(height: 12),
                  _buildSourceAndActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String imagePath) {
    return Image.asset(
      imagePath,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      post.caption,
      style: Theme.of(context).textTheme.headlineSmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSourceAndActions(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.primaryColor),
              ),
              const SizedBox(height: 2),
              Text(
                post.timeAgo,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _buildActionButton(icon: Icons.share_outlined),
        const SizedBox(width: 8),
        _buildActionButton(icon: Icons.star_border_rounded),
        const SizedBox(width: 8),
        _buildActionButton(icon: Icons.bookmark_border_rounded),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.smartHomeNeumorphic(radius: 12),
      child: Icon(icon, size: 20),
    );
  }
}
