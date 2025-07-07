// lib/features/stock/stock_post_card.dart
// [命名重構 V4.4]
// 功能：檔案與類別名稱已更新為 StockPostCard。

import 'package:flutter/material.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/search/search_models.dart';

class StockPostCard extends StatefulWidget {
  final StockSearchResultItem stockData;
  const StockPostCard({Key? key, required this.stockData}) : super(key: key);

  @override
  _StockPostCardState createState() => _StockPostCardState();
}

class _StockPostCardState extends State<StockPostCard> {
  bool _isAlertOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: AppTheme.smartHomeNeumorphic(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildPriceInfo(context),
            const SizedBox(height: 32),
            _buildPriceChart(context),
            const SizedBox(height: 32),
            _buildKeyMetricsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stockData.data['name'] ?? 'N/A',
                style: theme.textTheme.headlineSmall),
            Text(widget.stockData.data['symbol'] ?? 'N/A',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        Switch(
          value: _isAlertOn,
          onChanged: (value) {
            setState(() {
              _isAlertOn = value;
            });
          },
          activeColor: AppTheme.smarthome_accent_green,
        ),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    final theme = Theme.of(context);
    final price = (widget.stockData.data['price'] ?? 0.0) as num;
    final change = (widget.stockData.data['change'] ?? 0.0) as num;
    final changePercent =
        (widget.stockData.data['changePercent'] ?? 0.0) as num;
    final isPositive = change >= 0;
    final Color changeColor =
        isPositive ? AppTheme.smarthome_accent_green : const Color(0xFFF44336);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineLarge
              ?.copyWith(fontSize: 56, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
            style: theme.textTheme.titleLarge
                ?.copyWith(color: changeColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChart(BuildContext context) {
    return Container(
      height: 150,
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
      child: Center(
        child:
            Text('價格走勢圖 (待實現)', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(BuildContext context) {
    final price = (widget.stockData.data['price'] ?? 0.0) as num;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _MetricItem(
            label: '成交量', value: widget.stockData.data['volume'] ?? 'N/A'),
        _MetricItem(
            label: '市值', value: widget.stockData.data['marketCap'] ?? 'N/A'),
        _MetricItem(label: '本益比', value: '25.4'),
        _MetricItem(label: '開盤', value: (price * 0.98).toStringAsFixed(2)),
        _MetricItem(label: '最高', value: (price * 1.02).toStringAsFixed(2)),
        _MetricItem(label: '最低', value: (price * 0.97).toStringAsFixed(2)),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.smartHomeNeumorphic(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
