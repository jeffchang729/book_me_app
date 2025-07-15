// lib/features/navigation/explore_screen.dart
// [風格改造] 功能：探索頁面，採用分離式擬物化風格。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryBackgroundColor,
        elevation: 0,
        title: GestureDetector(
          onTap: () => appController.changeTabIndex(1), // 點擊導向真正的搜尋頁
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: theme.neumorphicBoxDecoration(
              isConcave: true,
              radius: 22.5,
              color: theme.primaryBackgroundColor,
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: theme.themeData.iconTheme.color),
                const SizedBox(width: 12),
                Text('搜尋書籍、作者或用戶...', style: theme.themeData.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 15, // 示例探索內容數量
          itemBuilder: (context, index) {
            return Container(
              decoration: theme.neumorphicBoxDecoration(
                radius: 15,
                color: theme.secondaryBackgroundColor,
              ),
              child: Center(
                child: Text('內容 ${index + 1}', style: theme.themeData.textTheme.bodySmall),
              ),
            );
          },
        ),
      ),
    );
  }
}