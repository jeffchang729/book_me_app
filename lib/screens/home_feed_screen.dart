// lib/screens/home_feed_screen.dart
// 功能：顯示用戶關注的讀書心得動態 (Instagram 首頁風格)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

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
              // TODO: 未來導航到發布新內容
              Get.snackbar('功能待開發', '發布功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          IconButton(
            icon: Icon(Icons.message_outlined, color: theme.iconTheme.color),
            onPressed: () {
              // TODO: 未來導航到訊息頁面
              Get.snackbar('功能待開發', '訊息功能仍在開發中。', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '讀書心得動態',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '這裡將顯示您關注的讀書心得貼文',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
