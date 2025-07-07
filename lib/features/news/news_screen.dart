// lib/features/news/news_screen.dart
// [命名重構 V4.4]
// 功能：檔案與類別名稱已更新為 NewsScreen。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/news/news_models.dart';

class NewsScreen extends StatelessWidget {
  final PostData article;
  const NewsScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final longArticleContent = List.generate(30, (i) => '這是文章段落 ${i + 1}。');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: theme.iconTheme,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/news_placeholder.png',
                fit: BoxFit.cover,
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.caption, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.primaryColor.withOpacity(0.2)),
                      const SizedBox(width: 12),
                      Text('${article.userName}・${article.timeAgo}',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Text(longArticleContent[index],
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.8)),
                );
              },
              childCount: longArticleContent.length,
            ),
          ),
        ],
      ),
    );
  }
}
