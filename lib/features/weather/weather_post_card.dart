// lib/features/weather/weather_post_card.dart
// [視覺簡化 V5.5]
// 功能：
// 1. 移除詳細資訊區塊（風速、濕度等）的擬物化方框背景。
// 2. 重新設計該區域的佈局，改為更簡潔、輕量的純文字與圖示排列。

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:book_me_app/core/theme/app_theme.dart';
import 'package:book_me_app/features/weather/weather_models.dart';

class HourlyTemp {
  final String time;
  final double temp;
  HourlyTemp(this.time, this.temp);
}

class WeatherPostCard extends StatefulWidget {
  final WeatherCardData weatherData;
  const WeatherPostCard({Key? key, required this.weatherData})
      : super(key: key);

  @override
  _WeatherPostCardState createState() => _WeatherPostCardState();
}

class _WeatherPostCardState extends State<WeatherPostCard> {
  bool _isForecastVisible = false;

  final List<HourlyTemp> hourlyData = [
    HourlyTemp("12:00", 28),
    HourlyTemp("13:00", 29),
    HourlyTemp("14:00", 31),
    HourlyTemp("15:00", 30),
    HourlyTemp("16:00", 29),
    HourlyTemp("17:00", 28),
    HourlyTemp("18:00", 26),
    HourlyTemp("19:00", 25),
  ];

  final List<DailyForecast> sevenDayData = List.generate(7, (index) {
    final date = DateTime.now().add(Duration(days: index + 1));
    return DailyForecast(
      date: date,
      maxTemperature: 28.0 + index,
      minTemperature: 22.0 + index * 0.5,
      description: ['多雲時晴', '午後雷陣雨', '晴朗', '陰天', '有雨', '晴', '多雲'][index],
    );
  });

  IconData _getWeatherIcon(String description, bool isDayTime) {
    final desc = description.toLowerCase();
    if (desc.contains('晴'))
      return isDayTime ? FontAwesomeIcons.sun : FontAwesomeIcons.moon;
    if (desc.contains('雷')) return FontAwesomeIcons.cloudBolt;
    if (desc.contains('雨')) return FontAwesomeIcons.cloudRain;
    if (desc.contains('雪')) return FontAwesomeIcons.snowflake;
    if (desc.contains('雲'))
      return isDayTime ? FontAwesomeIcons.cloudSun : FontAwesomeIcons.cloudMoon;
    return isDayTime ? FontAwesomeIcons.sun : FontAwesomeIcons.moon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: AppTheme.smartHomeNeumorphic(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildMainWeatherInfo(context),
          const SizedBox(height: 32),
          _buildHourlyForecastChart(context),
          const SizedBox(height: 32),
          // [驗證] 此處現在呼叫的是簡化後的 Widget
          _buildDetailsSection(context),
          const SizedBox(height: 16),
          _buildSevenDayForecastSection(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(widget.weatherData.locationName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {
            setState(() {
              _isForecastVisible = !_isForecastVisible;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.smartHomeNeumorphic(
                color: AppTheme.smarthome_bg, isConcave: _isForecastVisible),
            child: Row(
              children: [
                Text('7日預報', style: theme.textTheme.labelLarge),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isForecastVisible ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: FaIcon(FontAwesomeIcons.chevronDown,
                      size: 14, color: theme.iconTheme.color),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMainWeatherInfo(BuildContext context) {
    final theme = Theme.of(context);
    final currentWeather = widget.weatherData.currentWeather;
    final bool isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;

    return Row(
      children: [
        FaIcon(_getWeatherIcon(currentWeather.description, isDayTime),
            color: AppTheme.smarthome_primary_blue, size: 80),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: '${currentWeather.temperature.round()}',
                style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: AppTheme.smarthome_primary_text,
                    fontSize: 80),
                children: <TextSpan>[
                  TextSpan(
                      text: '°C',
                      style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppTheme.smarthome_primary_blue
                              .withOpacity(0.8))),
                ],
              ),
            ),
            Text(currentWeather.description,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppTheme.smarthome_secondary_text)),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyForecastChart(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true),
      child: CustomPaint(
        painter: _HourlyForecastChartPainter(
          data: hourlyData,
          primaryColor: AppTheme.smarthome_primary_blue,
          textColor: AppTheme.smarthome_secondary_text,
        ),
        size: Size.infinite,
      ),
    );
  }

  // [重大修改] 取代 _buildDetailsGrid，使用 Column 和 Row 實現更簡潔的 2x2 佈局
  Widget _buildDetailsSection(BuildContext context) {
    final currentWeather = widget.weatherData.currentWeather;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                icon: FontAwesomeIcons.wind,
                label: '風速',
                value:
                    '${currentWeather.windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s',
              ),
            ),
            Expanded(
              child: _DetailItem(
                icon: FontAwesomeIcons.droplet,
                label: '濕度',
                value: '${currentWeather.humidity}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24), // 兩行之間的垂直間距
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                icon: FontAwesomeIcons.sun,
                label: '紫外線',
                value: '強',
              ),
            ),
            Expanded(
              child: _DetailItem(
                icon: FontAwesomeIcons.solidClock,
                label: '日出/落',
                value: '05:30/18:45',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSevenDayForecastSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isForecastVisible
          ? Column(
              children: [
                const SizedBox(height: 16),
                const Divider(thickness: 1, height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sevenDayData.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: AppTheme.smarthome_bg, height: 1),
                  itemBuilder: (context, index) {
                    final forecast = sevenDayData[index];
                    return _buildForecastTile(forecast);
                  },
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildForecastTile(DailyForecast forecast) {
    final theme = Theme.of(context);
    final bool isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;

    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: FaIcon(_getWeatherIcon(forecast.description, isDayTime),
          color: AppTheme.smarthome_secondary_text, size: 24),
      title: Text(
        DateFormat('EEEE', 'zh_TW').format(forecast.date),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '${forecast.minTemperature.round()}° / ${forecast.maxTemperature.round()}°',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}

// [重大修改] _DetailItem 不再有自己的背景方框
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 移除外層的 Container 和 decoration
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // 從左邊開始對齊
      children: [
        FaIcon(icon, color: AppTheme.smarthome_secondary_text, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// ... (_HourlyForecastChartPainter 維持不變) ...
class _HourlyForecastChartPainter extends CustomPainter {
  final List<HourlyTemp> data;
  final Color primaryColor;
  final Color textColor;

  _HourlyForecastChartPainter(
      {required this.data,
      required this.primaryColor,
      required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double padding = 20.0;
    final double chartHeight = size.height - padding * 2.5;
    final double chartWidth = size.width - padding * 2;

    final maxTemp = data.map((d) => d.temp).reduce((a, b) => a > b ? a : b);
    final minTemp = data.map((d) => d.temp).reduce((a, b) => a < b ? a : b);
    final tempRange = (maxTemp - minTemp).abs() < 1 ? 1 : (maxTemp - minTemp);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i * chartWidth / (data.length - 1));
      final y = padding +
          chartHeight -
          ((data[i].temp - minTemp) / tempRange * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, size.height - padding);
    path.lineTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, p2.dx, p2.dy);
    }
    path.lineTo(points.last.dx, size.height - padding);
    path.close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.01)],
      );
    canvas.drawPath(path, paint);

    for (int i = 0; i < data.length; i++) {
      final timePainter = TextPainter(
        text: TextSpan(
            text: data[i].time,
            style: TextStyle(color: textColor, fontSize: 12)),
        textDirection: ui.TextDirection.ltr,
      );
      timePainter.layout();
      timePainter.paint(canvas,
          Offset(points[i].dx - timePainter.width / 2, size.height - padding));

      final tempPainter = TextPainter(
        text: TextSpan(
            text: '${data[i].temp.round()}°',
            style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        textDirection: ui.TextDirection.ltr,
      );
      tempPainter.layout();
      tempPainter.paint(canvas,
          Offset(points[i].dx - tempPainter.width / 2, points[i].dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
