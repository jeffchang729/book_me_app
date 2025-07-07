// lib/features/home/home_summary_card.dart
// [體驗重構 V4.8]
// 功能：新增 newsTopic 參數，使卡片能夠顯示新聞主題。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/news/news_models.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/weather/weather_models.dart';

class HomeSummaryCard extends StatelessWidget {
  final UniversalSearchResult? item;
  final SearchResultType? itemType;
  final String? newsTopic; // [新增] 用於顯示新聞主題
  final bool isSelected;
  final VoidCallback onTap;

  const HomeSummaryCard({
    Key? key,
    this.item,
    this.itemType,
    this.newsTopic, // [新增]
    required this.isSelected,
    required this.onTap,
  })  : assert(item != null || itemType != null || newsTopic != null,
            'Either item, itemType or newsTopic must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // [修改] 優先從 itemType 或 newsTopic 判斷類型
    final type =
        item?.type ?? (newsTopic != null ? SearchResultType.news : itemType!);

    final decoration =
        AppTheme.smartHomeNeumorphic(isConcave: isSelected, radius: 20);
    final activeColor = _getAccentColor(type);
    final inactiveColor = theme.iconTheme.color;
    final contentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForType(type), color: contentColor, size: 28),
            const Spacer(),
            Text(
              _getTitle(type),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _getSubtitle(type),
              style: theme.textTheme.bodyMedium?.copyWith(color: contentColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ... _getAccentColor 和 _getIconForType 維持不變 ...
  Color _getAccentColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return AppTheme.smarthome_primary_blue;
      case SearchResultType.stock:
        return AppTheme.smarthome_accent_green;
      case SearchResultType.news:
        return AppTheme.smarthome_accent_pink;
      default:
        return AppTheme.smarthome_secondary_text;
    }
  }

  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.weather:
        return Icons.wb_cloudy_outlined;
      case SearchResultType.stock:
        return Icons.show_chart_rounded;
      case SearchResultType.news:
        return Icons.article_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // [修改] 增加對 newsTopic 的處理
  String _getTitle(SearchResultType type) {
    if (newsTopic != null) return newsTopic!;
    if (item != null) {
      // ... 此處邏輯用不到了，但保留以防萬一
      return item!.title;
    }
    switch (type) {
      case SearchResultType.weather:
        return '天氣總覽';
      case SearchResultType.stock:
        return '股市總覽';
      case SearchResultType.news:
        return '新聞主題'; // 理論上不會顯示
      default:
        return '未知';
    }
  }

  // [修改] 增加對 newsTopic 的處理
  String _getSubtitle(SearchResultType type) {
    if (newsTopic != null) return '新聞主題';
    if (item != null) {
      // ... 此處邏輯用不到了，但保留以防萬一
      return item!.subtitle;
    }
    switch (type) {
      case SearchResultType.weather:
        return '多個地點';
      case SearchResultType.stock:
        return '多支股票';
      case SearchResultType.news:
        return '多則新聞'; // 理論上不會顯示
      default:
        return '';
    }
  }
}
