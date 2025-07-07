// lib/features/home/home_screen.dart
// [動畫還原 & 體驗升級 V5.8]
// 功能：
// 1. [恢復] 將 HomeScreen 恢復為 StatefulWidget，並重新引入 AnimationController，讓卡片滑入動畫回歸。
// 2. [升級] 使用 GetX 的 `ever` 監聽器，監聽分頁切換事件。確保每次切換到空白的首頁時，都能觸發並重新播放入場動畫。
// 3. [恢復] 恢復四個可互動的佔位符卡片，提升空白頁面的功能性與引導性。

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/home/home_controller.dart';
import 'package:book_me_app/features/home/home_summary_card.dart';
import 'package:book_me_app/features/search/search_controller.dart';
import 'package:book_me_app/features/search/search_models.dart';

import 'package:book_me_app/features/news/news_post_card.dart';
import 'package:book_me_app/features/stock/stock_grid_item.dart';
import 'package:book_me_app/features/weather/weather_post_card.dart';

// [修改] 恢復為 StatefulWidget 以管理動畫
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // [恢復] 動畫控制器
  late final AnimationController _animationController;
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // [新增] 智慧動畫觸發器
    // `ever` 會監聽 `currentTabIndex` 的每一次變化
    ever(homeController.currentTabIndex, (int tabIndex) {
      // 當切換到首頁(index 0)時，嘗試播放動畫
      if (tabIndex == 0) {
        _playAnimation();
      }
    });

    // 首次進入時，也嘗試播放一次
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAnimation());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // [新增] 播放動畫的方法
  void _playAnimation() {
    // 只有在首頁是空的狀態下，才重設並播放動畫
    if (mounted && homeController.trackedItems.isEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('TELL ME', style: theme.textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // [修改] 根據 Obx 的狀態來決定是否顯示 AppBar
        toolbarHeight: homeController.trackedItems.isEmpty ? 0 : kToolbarHeight,
      ),
      body: Obx(() {
        if (homeController.trackedItems.isEmpty) {
          // [恢復] 顯示帶有動畫和互動的儀表板佔位符
          return _buildAnimatedEmptyStateDashboard(context);
        } else {
          return Column(
            children: [
              _buildSummarySection(context, homeController),
              _buildDetailSection(context, homeController),
            ],
          );
        }
      }),
    );
  }

  // ... _buildSummarySection 和 _buildDetailSection 維持不變 ...
  Widget _buildSummarySection(BuildContext context, HomeController controller) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: SizedBox(
        height: 180,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          children: [
            if (controller.trackedWeathers.isNotEmpty)
              Obx(() => HomeSummaryCard(
                    itemType: SearchResultType.weather,
                    isSelected: controller.selectedType.value ==
                        SearchResultType.weather,
                    onTap: () => controller.selectContent(
                        type: SearchResultType.weather),
                  )),
            if (controller.trackedStocks.isNotEmpty)
              Obx(() => HomeSummaryCard(
                    itemType: SearchResultType.stock,
                    isSelected:
                        controller.selectedType.value == SearchResultType.stock,
                    onTap: () =>
                        controller.selectContent(type: SearchResultType.stock),
                  )),
            ...controller.trackedNewsTopics.map((topic) {
              return Obx(() => HomeSummaryCard(
                    newsTopic: topic,
                    isSelected: controller.selectedType.value ==
                            SearchResultType.news &&
                        controller.selectedNewsTopic.value == topic,
                    onTap: () => controller.selectContent(
                      type: SearchResultType.news,
                      newsTopic: topic,
                    ),
                  ));
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, HomeController controller) {
    return Expanded(
      child: Obx(() {
        final type = controller.selectedType.value;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _buildDetailContent(context, controller, type),
        );
      }),
    );
  }

  Widget _buildDetailContent(
      BuildContext context, HomeController controller, SearchResultType? type) {
    switch (type) {
      case SearchResultType.weather:
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: controller.trackedWeathers.length,
          itemBuilder: (context, index) {
            final weatherItem = controller.trackedWeathers[index];
            return WeatherPostCard(
                key: ValueKey(weatherItem.id), weatherData: weatherItem.data);
          },
        );
      case SearchResultType.stock:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: controller.trackedStocks.length,
          itemBuilder: (context, index) {
            final stockItem =
                controller.trackedStocks[index] as StockSearchResultItem;
            return StockGridItem(stockData: stockItem);
          },
        );
      case SearchResultType.news:
        final selectedTopic = controller.selectedNewsTopic.value;
        if (selectedTopic == null) return const SizedBox.shrink();
        final relevantNews = controller.trackedNews
            .where(
                (item) => (item as NewsSearchResultItem).topic == selectedTopic)
            .toList();
        if (relevantNews.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: relevantNews.length,
          itemBuilder: (context, index) {
            final newsItem = relevantNews[index];
            return NewsPostCard(
                key: ValueKey(newsItem.id), post: newsItem.data);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // [恢復] 帶有動畫與互動功能的空白頁面
  Widget _buildAnimatedEmptyStateDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = Get.find<SearchController>();

    final animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)));
    final animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)));
    final animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)));
    final animation4 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('歡迎使用 TELL ME',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            '您的專屬智慧資訊中心\n點擊下方卡片，開始新增您的追蹤項目',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color, height: 1.6),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                  child: _AnimatedPlaceholderCard(
                animation: animation1,
                icon: Icons.wb_sunny_outlined,
                label: '天氣',
                onTap: () {
                  homeController.changeTabIndex(1);
                  searchController.performSearch('天氣');
                },
              )),
              const SizedBox(width: 20),
              Expanded(
                  child: _AnimatedPlaceholderCard(
                animation: animation2,
                icon: Icons.show_chart_rounded,
                label: '股票',
                onTap: () {
                  homeController.changeTabIndex(1);
                  searchController.performSearch('所有股票');
                },
              )),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _AnimatedPlaceholderCard(
                animation: animation3,
                icon: Icons.article_outlined,
                label: '新聞',
                onTap: () {
                  homeController.changeTabIndex(1);
                  searchController.performSearch('今日頭條');
                },
              )),
              const SizedBox(width: 20),
              Expanded(
                  child: _AnimatedPlaceholderCard(
                animation: animation4,
                icon: Icons.add_rounded,
                label: '更多',
                onTap: () => homeController.changeTabIndex(1),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

class _AnimatedPlaceholderCard extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedPlaceholderCard({
    Key? key,
    required this.animation,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration:
                AppTheme.smartHomeNeumorphic(isConcave: true, radius: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: (theme.iconTheme.color ??
                          AppTheme.smarthome_secondary_text)
                      .withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: (theme.textTheme.titleLarge?.color ??
                            AppTheme.smarthome_primary_text)
                        .withOpacity(0.8),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
