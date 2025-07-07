// lib/screens/main_screen.dart
// 功能：應用程式的主畫面容器，包含底部導航列，用於切換不同功能頁面 (Instagram 風格)。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/screens/home_feed_screen.dart'; // 引入首頁動態 (Instagram 首頁)
import 'package:book_me_app/screens/explore_screen.dart'; // 引入探索頁面 (Instagram 探索)
import 'package:book_me_app/screens/activity_screen.dart'; // 引入活動頁面 (Instagram 活動)
import 'package:book_me_app/screens/profile_screen.dart'; // 引入個人檔案頁面 (Instagram 個人檔案)
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入 AuthController
import 'package:book_me_app/features/auth/auth_screen.dart'; // 引入 AuthScreen
import 'package:book_me_app/screens/create_review_screen.dart'; // 引入新增讀書心得畫面

/// `MainScreen` 是應用程式登入後的主要介面。
/// 它包含一個底部導覽列，允許用戶在不同的核心功能頁面之間切換，
/// 這些頁面設計旨在模仿 Instagram 的用戶體驗。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // 確保 super.key 傳遞正確，並保持 const 構造

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AppController appController = Get.find<AppController>(); // 獲取 AppController 實例
  final AuthController authController = Get.find<AuthController>(); // 獲取 AuthController 實例

  // 定義底部導航列對應的頁面列表
  // 這些頁面將根據底部導航列的選擇而顯示。
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeFeedScreen(), // 索引 0: 首頁動態 (讀書心得列表)
    const ExploreScreen(), // 索引 1: 探索/搜尋 (發現書籍和用戶)
    const Center(child: Text('發布新內容', style: TextStyle(fontSize: 30))), // 索引 2: 佔位符：發布新內容
    const ActivityScreen(), // 索引 3: 活動/通知 (按讚、留言、追蹤等通知)
    const ProfileScreen(), // 索引 4: 個人檔案 (用戶自己的資料和貼文)
  ];

  /// 處理底部導航項目點擊事件。
  /// @param index - 被點擊項目的索引。
  void _onItemTapped(int index) {
    // 檢查是否點擊了需要登入的功能 (例如：發布、活動、個人檔案)
    if (index == 2 || index == 3 || index == 4) {
      if (authController.currentUser.value == null) {
        // 如果用戶未登入，則顯示登入提示
        // [修正] 傳遞一個回調函數，在登入成功後執行跳轉
        _showLoginPrompt(context, () {
          // 登入成功後，將底部導覽列切換到原先嘗試訪問的頁面
          appController.changeTabIndex(index);
        });
        return; // 阻止頁面切換
      }
    }

    if (index == 2) { // 如果點擊的是中間的「發布」按鈕 (索引為 2)
      // 導航到新增讀書心得畫面
      Get.to(() => const CreateReviewScreen());
      return; // 阻止切換底部導覽列頁面
    }
    
    // 呼叫 AppController 來改變當前選中的索引
    appController.changeTabIndex(index);
  }

  /// 顯示登入提示的對話框。
  /// @param onLoginSuccess - 登入成功後要執行的回調函數。
  void _showLoginPrompt(BuildContext context, VoidCallback onLoginSuccess) { // [修正] 接收 onLoginSuccess 回調
    Get.defaultDialog(
      title: "請先登入",
      middleText: "要使用此功能，您需要登入或註冊 BookMe 帳號。",
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titleStyle: Theme.of(context).textTheme.headlineSmall,
      middleTextStyle: Theme.of(context).textTheme.bodyLarge,
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // 關閉對話框
            authController.toggleAuthMode(); // 切換到登入模式
            // [修正] 導航到 AuthScreen，並將 onLoginSuccess 傳遞給它
            Get.to(() => AuthScreen(onLoginSuccess: onLoginSuccess));
          },
          child: Text("前往登入/註冊", style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
        TextButton(
          onPressed: () => Get.back(), // 關閉對話框
          child: Text("取消", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme; // 獲取當前主題

    return Scaffold(
      body: Obx(() => Center( // 使用 Obx 監聽 appController.currentTabIndex
        child: _widgetOptions.elementAt(appController.currentTabIndex.value), // 顯示當前選中的頁面
      )),
      bottomNavigationBar: Container(
        // 底部導航列的 Neumorphism 風格裝飾
        decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 0), 
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: theme.iconTheme.color), // 未選中圖示
              activeIcon: Icon(Icons.home, color: theme.primaryColor), // 選中圖示
              label: '首頁', // 標籤文字
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined, color: theme.iconTheme.color),
              activeIcon: Icon(Icons.search, color: theme.primaryColor),
              label: '探索',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, color: theme.iconTheme.color), // 發布按鈕
              activeIcon: Icon(Icons.add_box, color: theme.primaryColor),
              label: '發布',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, color: theme.iconTheme.color),
              activeIcon: Icon(Icons.favorite, color: theme.primaryColor),
              label: '活動',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, color: theme.iconTheme.color),
              activeIcon: Icon(Icons.person, color: theme.primaryColor),
              label: '個人',
            ),
          ],
          currentIndex: appController.currentTabIndex.value, // 從 AppController 獲取當前索引
          selectedItemColor: theme.primaryColor, // 選中項目的顏色
          unselectedItemColor: theme.iconTheme.color, // 未選中項目的顏色
          onTap: _onItemTapped, // 點擊事件處理
          type: BottomNavigationBarType.fixed, // 固定樣式，所有項目都可見
          backgroundColor: theme.scaffoldBackgroundColor, // 背景色與 Scaffold 一致
          showSelectedLabels: false, // 不顯示選中項目的文字標籤
          showUnselectedLabels: false, // 不顯示未選中項目的文字標籤
        ),
      ),
    );
  }
}
