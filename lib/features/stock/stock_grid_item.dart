// lib/features/stock/stock_grid_item.dart
// [命名重構 V4.4]
// 功能：更新 import 路徑與導航目標。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/search/search_models.dart';
import 'package:book_me_app/features/stock/stock_screen.dart';

class StockGridItem extends StatelessWidget {
  final StockSearchResultItem stockData;
  const StockGridItem({Key? key, required this.stockData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = (stockData.data['price'] ?? 0.0) as num;
    final change = (stockData.data['change'] ?? 0.0) as num;
    final isPositive = change >= 0;
    final Color changeColor =
        isPositive ? AppTheme.smarthome_accent_green : const Color(0xFFF44336);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => StockScreen(stockData: stockData), // 導航至 StockScreen
          transition: Transition.rightToLeftWithFade,
        );
      },
      child: Container(
        decoration: AppTheme.smartHomeNeumorphic(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockData.data['name'] ?? 'N/A',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stockData.data['symbol'] ?? '----',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${(stockData.data['changePercent'] ?? 0.0).toStringAsFixed(2)}%)',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: changeColor, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
