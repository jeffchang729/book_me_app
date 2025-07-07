// lib/app/app_container.dart
// [體驗重構 V4.6]
// 功能：
// 1. 將 SearchScreen 整合為主分頁之一，而非彈出式視窗。
// 2. 調整 PageView 與 ElegantBottomBar 的邏輯以支援三個分頁。
// 3. 實現了在搜尋時保留底部導覽列的全新體驗。

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:book_me_app/features/home/home_controller.dart';
import 'package:book_me_app/features/home/home_screen.dart';
import 'package:book_me_app/features/search/search_screen.dart';
import 'package:book_me_app/app/navigation_widgets.dart';
import 'package:book_me_app/app/bottom_bar_item.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  final HomeController homeController = Get.find<HomeController>();

  late final PageController _pageController;
  late final List<ElegantBottomBarItem> _bottomBarItems;

  // [修改] 將頁面列表移至此處，使其在整個 State 生命週期內都可存取
  final List<Widget> _tabPages = [
    const HomeScreen(),
    const SearchScreen(), // [新增] SearchScreen 現在是第二個分頁
    Center(
        child: Text('設定頁面 (待建)',
            style: ThemeData.light().textTheme.headlineSmall)),
  ];

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(initialPage: homeController.currentTabIndex.value);

    // [修改] 底部項目現在只包含左右兩側的圖示
    _bottomBarItems = [
      ElegantBottomBarItem(icon: Icons.home_filled, label: '首頁'),
      ElegantBottomBarItem(icon: Icons.settings_outlined, label: '設定'),
    ];

    // 監聽 Controller 的變化，以程式碼驅動頁面切換
    ever(homeController.currentTabIndex, _handleTabChangeFromController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 當 Controller 的 tab index 改變時，動畫切換 PageView
  void _handleTabChangeFromController(int index) {
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // 當使用者點擊底部導覽列的項目時
  void _onTabTapped(int uiIndex) {
    // 左右兩側的按鈕 (首頁、設定)
    // uiIndex 0 -> pageIndex 0
    // uiIndex 1 -> pageIndex 2
    final int pageIndex = (uiIndex == 0) ? 0 : 2;
    homeController.changeTabIndex(pageIndex);
  }

  // [修改] 當使用者點擊中間的搜尋按鈕時
  void _handleSearchClick() {
    // 直接切換到索引為 1 的 SearchScreen 分頁
    homeController.changeTabIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // 禁止手勢滑動，統一由底部按鈕控制
            children: _tabPages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(() {
              // [修改] 根據 Controller 的 currentTabIndex 計算底部導覽列的選中狀態
              int selectedUiIndex = -1; // -1 表示中間的搜尋按鈕被選中
              if (homeController.currentTabIndex.value == 0) {
                selectedUiIndex = 0; // 首頁
              } else if (homeController.currentTabIndex.value == 2) {
                selectedUiIndex = 1; // 設定
              }

              return ElegantBottomBar(
                items: _bottomBarItems,
                currentIndex: selectedUiIndex,
                isSearchActive: homeController.currentTabIndex.value ==
                    1, // [新增] 傳遞搜尋分頁是否活躍的狀態
                onTabChange: _onTabTapped,
                onSearchClick: _handleSearchClick,
              );
            }),
          ),
        ],
      ),
    );
  }
}
