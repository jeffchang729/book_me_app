// lib/features/stock/stock_screen.dart
// [命名重構 V4.4]
// 功能：檔案與類別名稱已更新為 StockScreen。

import 'package:flutter/material.dart';
import 'package:book_me_app/features/stock/stock_post_card.dart';
import 'package:book_me_app/features/search/search_models.dart';

class StockScreen extends StatelessWidget {
  final StockSearchResultItem stockData;

  const StockScreen({Key? key, required this.stockData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(stockData.data['name'] ?? '股票詳情',
            style: theme.textTheme.headlineSmall),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: StockPostCard(stockData: stockData),
    );
  }
}
