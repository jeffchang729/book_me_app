// lib/features/navigation/main_screen.dart
// [樣式最終版 v2] 功能：應用程式的主畫面，採用無邊界懸浮式導覽列。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/features/navigation/home_feed_screen.dart';
import 'package:book_me_app/features/search/search_screen.dart';
import 'package:book_me_app/features/book_review/create_review_screen.dart';
import 'package:book_me_app/features/navigation/activity_screen.dart';
import 'package:book_me_app/features/navigation/profile_screen.dart';
import 'package:book_me_app/features/auth/auth_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      body: Obx(() {
        final String? currentUserId = authController.currentUser.value?.uid;
        return IndexedStack(
          index: appController.currentTabIndex.value,
          children: [
            const HomeFeedScreen(),       // 索引 0
            const SearchScreen(),         // 索引 1
            const CreateReviewScreen(),   // 索引 2
            const ActivityScreen(),       // 索引 3
            currentUserId != null
                ? ProfileScreen(userId: currentUserId) // 索引 4
                : AuthScreen( onLoginSuccess: () { /* ... */ } ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => appController.changeTabIndex(2),
        backgroundColor: theme.themeData.primaryColor,
        elevation: 4.0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: BottomAppBar(
          color: Colors.transparent, // [關鍵改造] 將 AppBar 背景設為透明
          surfaceTintColor: Colors.transparent,
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
          ),
          notchMargin: 8.0,
          elevation: 0, // [關鍵改造] 移除 AppBar 自身陰影
          child: Container(
            height: 65.0,
            // [關鍵改造] 移除此處的 decoration，不再需要背景和陰影
            // decoration: theme.neumorphicBoxDecoration(...)
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildAppBarItem(theme, appController, icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, index: 0, label: "首頁"),
                _buildAppBarItem(theme, appController, icon: Icons.search_outlined, activeIcon: Icons.search, index: 1, label: "搜尋"),
                const SizedBox(width: 48), // 為 FAB 留出空間
                _buildAppBarItem(theme, appController, icon: Icons.favorite_border, activeIcon: Icons.favorite, index: 3, label: "活動"),
                _buildAppBarItem(theme, appController, icon: Icons.person_outline, activeIcon: Icons.person, index: 4, label: "我的"),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarItem(IAppTheme theme, AppController appController, {required IconData icon, required IconData activeIcon, required int index, required String label}) {
    final bool isSelected = appController.currentTabIndex.value == index;
    return InkWell(
      onTap: () => appController.changeTabIndex(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // [關鍵] 這個 decoration 邏輯保持不變，只為選中的項目提供背景
        decoration: BoxDecoration(
          color: isSelected ? theme.themeData.primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? theme.themeData.primaryColor : theme.themeData.iconTheme.color,
          size: 28,
        ),
      ),
    );
  }
}