// lib/features/stock/stock_models.dart
// [API串接 V6.2 - 新檔案]
// 功能：定義從 Yahoo Finance API 獲取的股票報價資料模型。

// // 代表單一一支股票的詳細報價資料。
class StockQuote {
  StockQuote({
    required this.symbol,
    required this.shortName,
    required this.longName,
    required this.regularMarketPrice,
    required this.regularMarketChange,
    required this.regularMarketChangePercent,
    required this.regularMarketVolume,
    required this.marketCap,
    required this.regularMarketOpen,
    required this.regularMarketDayHigh,
    required this.regularMarketDayLow,
    required this.currency,
  });

  // // 股票代號 (e.g., "2330.TW", "AAPL")
  final String symbol;
  // // 公司簡稱 (e.g., "台積電", "Apple")
  final String shortName;
  // // 公司全名 (e.g., "Taiwan Semiconductor Manufacturing Company Limited")
  final String longName;
  // // 目前股價
  final double regularMarketPrice;
  // // 漲跌金額
  final double regularMarketChange;
  // // 漲跌幅 (%)
  final double regularMarketChangePercent;
  // // 成交量
  final int regularMarketVolume;
  // // 市值
  final int? marketCap;
  // // 開盤價
  final double regularMarketOpen;
  // // 當日最高價
  final double regularMarketDayHigh;
  // // 當日最低價
  final double regularMarketDayLow;
  // // 貨幣單位 (e.g., "TWD", "USD")
  final String currency;

  // // 從 Yahoo Finance API 的 JSON 回應中建立 StockQuote 實例的工廠建構子。
  factory StockQuote.fromJson(Map<String, dynamic> json) {
    // // 一個輔助函數，安全地從 json 中提取數值，提供預設值以避免 null
    T _safeGet<T>(String key, T defaultValue) {
      return (json[key] ?? defaultValue) as T;
    }

    return StockQuote(
      symbol: _safeGet('symbol', 'N/A'),
      shortName: _safeGet('shortName', 'N/A'),
      longName: _safeGet('longName', 'N/A'),
      regularMarketPrice: _safeGet('regularMarketPrice', 0.0),
      regularMarketChange: _safeGet('regularMarketChange', 0.0),
      regularMarketChangePercent: _safeGet('regularMarketChangePercent', 0.0),
      regularMarketVolume: _safeGet('regularMarketVolume', 0),
      marketCap: _safeGet('marketCap', null),
      regularMarketOpen: _safeGet('regularMarketOpen', 0.0),
      regularMarketDayHigh: _safeGet('regularMarketDayHigh', 0.0),
      regularMarketDayLow: _safeGet('regularMarketDayLow', 0.0),
      currency: _safeGet('currency', 'USD'),
    );
  }

  // // 將 StockQuote 物件轉換回 Map<String, dynamic>，方便 UI 元件使用。
  // // 這維持了與舊有 `StockSearchResultItem` data 欄位的相容性。
  Map<String, dynamic> toDisplayMap() {
    return {
      'symbol': symbol,
      'name': shortName,
      'price': regularMarketPrice,
      'change': regularMarketChange,
      'changePercent': regularMarketChangePercent,
      'volume': '${(regularMarketVolume / 1000).toStringAsFixed(0)}張', // 單位轉換
      'marketCap': marketCap != null ? '${(marketCap! / 1.0e12).toStringAsFixed(2)}兆' : 'N/A', // 單位轉換
    };
  }
}
