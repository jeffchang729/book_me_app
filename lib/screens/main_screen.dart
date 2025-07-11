// lib/screens/main_screen.dart
// 功能：應用程式的主畫面，包含底部導覽列和多個分頁內容。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/screens/home_feed_screen.dart';
import 'package:book_me_app/features/search/search_screen.dart'; // [修正] 加上這一行匯入
import 'package:book_me_app/features/book_review/create_review_screen.dart';
import 'package:book_me_app/screens/activity_screen.dart';
import 'package:book_me_app/screens/profile_screen.dart';
import 'package:book_me_app/features/auth/auth_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Obx(() {
        final String? currentUserId = authController.currentUser.value?.uid;

        return IndexedStack(
          index: appController.currentTabIndex.value,
          children: [
            const HomeFeedScreen(), // 索引 0: 首頁動態牆
            const SearchScreen(),   // 索引 1: 搜尋頁
            const CreateReviewScreen(), // 索引 2: 發布讀書心得
            const ActivityScreen(), // 索引 3: 活動通知頁
            // 索引 4: 個人檔案頁
            currentUserId != null
                ? ProfileScreen(userId: currentUserId)
                : AuthScreen(
                    initialRegisterMode: false,
                    onLoginSuccess: () {
                      Get.back(); 
                      appController.changeTabIndex(4);
                    },
                  ),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: appController.currentTabIndex.value,
          onTap: appController.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).iconTheme.color,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: '搜尋',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: '發布',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: '通知',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}