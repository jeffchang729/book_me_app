// lib/app/navigation_widgets.dart
// [體驗重構 V4.6]
// 功能：
// 1. 新增 isSearchActive 參數，使中間的搜尋按鈕也能呈現選中狀態。
// 2. 優化了 UI 元件的命名與結構。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/app_theme.dart';
import 'package:book_me_app/core/bottom_bar_item.dart';

class ElegantBottomBar extends StatelessWidget {
  const ElegantBottomBar({
    Key? key,
    required this.items,
    required this.onTabChange,
    required this.currentIndex,
    required this.onSearchClick,
    required this.isSearchActive, // [新增]
  }) : super(key: key);

  final List<ElegantBottomBarItem> items;
  final ValueChanged<int> onTabChange;
  final int currentIndex;
  final VoidCallback onSearchClick;
  final bool isSearchActive; // [新增] 標記搜尋分頁是否為當前頁面

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barHeight = 65.0;

    return Container(
      height: barHeight + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: AppTheme.smartHomeNeumorphic(radius: 0),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildBarItems(context),
          ),
          _buildSearchButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return Positioned(
      top: -20,
      child: GestureDetector(
        onTap: onSearchClick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 64,
          height: 64,
          // [修改] 根據 isSearchActive 參數來決定是否顯示凹陷效果
          decoration: AppTheme.smartHomeNeumorphic(
            radius: 32,
            isConcave: isSearchActive,
          ),
          child: Icon(
              // [修改] 當搜尋被選中時，圖示也可以變為實心，提供更強的視覺回饋
              isSearchActive ? Icons.search : Icons.search_rounded,
              color: Theme.of(context).primaryColor,
              size: 32),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems(BuildContext context) {
    List<Widget> barItems = [];
    final int middleIndex = (items.length / 2).floor();
    for (int i = 0; i < items.length; i++) {
      if (i == middleIndex) {
        barItems.add(const SizedBox(width: 80));
      }
      final item = items[i];
      final isSelected = currentIndex == i;
      barItems.add(
        _NeumorphicBottomBarTab(
          item: item,
          isSelected: isSelected,
          onTap: () => onTabChange(i),
        ),
      );
    }
    return barItems;
  }
}

class _NeumorphicBottomBarTab extends StatelessWidget {
  const _NeumorphicBottomBarTab({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final ElegantBottomBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;
    final inactiveColor = theme.iconTheme.color;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: isSelected
              ? AppTheme.smartHomeNeumorphic(radius: 12, isConcave: true)
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon,
                  size: 26, color: isSelected ? activeColor : inactiveColor),
              const SizedBox(height: 2),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
