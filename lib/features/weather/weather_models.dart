// lib/features/weather/weather_models.dart
// [架構重組 V4.3 - 步驟 2.1]
// 功能：檔案已移至最終位置。程式碼無需變更。

class WeatherCardData {
  WeatherCardData({
    required this.id,
    required this.locationName,
    required this.currentWeather,
    this.forecast,
    this.cardColor = '0xFF4A90E2',
    this.createdAt,
  });

  final String id;
  final String locationName;
  final CurrentWeather currentWeather;
  final WeatherForecast? forecast;
  final String cardColor;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'locationName': locationName,
    'currentWeather': currentWeather.toJson(),
    'forecast': forecast?.toJson(),
    'cardColor': cardColor,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory WeatherCardData.fromJson(Map<String, dynamic> json) => WeatherCardData(
    id: json['id'],
    locationName: json['locationName'],
    currentWeather: CurrentWeather.fromJson(json['currentWeather']),
    forecast: json['forecast'] != null ? WeatherForecast.fromJson(json['forecast']) : null,
    cardColor: json['cardColor'] ?? '0xFF4A90E2',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

class CurrentWeather {
  CurrentWeather({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.pressure,
    this.windSpeed,
    this.updateTime,
  });

  final double temperature;
  final String description;
  final int humidity;
  final double pressure;
  final double? windSpeed;
  final DateTime? updateTime;

  String get comfortLevel {
    if (temperature >= 30) return '炎熱';
    if (temperature >= 25) return '溫暖';
    if (temperature >= 20) return '舒適';
    return '涼爽';
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'description': description,
    'humidity': humidity,
    'pressure': pressure,
    'windSpeed': windSpeed,
    'updateTime': updateTime?.toIso8601String(),
  };

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
    temperature: (json['temperature'] as num).toDouble(),
    description: json['description'],
    humidity: (json['humidity'] as num).toInt(),
    pressure: (json['pressure'] as num).toDouble(),
    windSpeed: (json['windSpeed'] as num?)?.toDouble(),
    updateTime: json['updateTime'] != null ? DateTime.parse(json['updateTime']) : null,
  );
}

class WeatherForecast {
  WeatherForecast({ required this.dailyForecasts, this.updateTime });
  final List<DailyForecast> dailyForecasts;
  final DateTime? updateTime;

  Map<String, dynamic> toJson() => {
    'dailyForecasts': dailyForecasts.map((f) => f.toJson()).toList(),
    'updateTime': updateTime?.toIso8601String(),
  };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => WeatherForecast(
    dailyForecasts: (json['dailyForecasts'] as List).map((i) => DailyForecast.fromJson(i)).toList(),
    updateTime: json['updateTime'] != null ? DateTime.parse(json['updateTime']) : null,
  );
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.description,
    this.rainProbability,
    this.weatherIconCode,
  });

  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String description;
  final int? rainProbability;
  final String? weatherIconCode;

  String get dateText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = DateTime(date.year, date.month, date.day).difference(today).inDays;
    if (difference == 0) return '今天';
    if (difference == 1) return '明天';
    const weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
    return weekdays[date.weekday - 1];
  }

  String get temperatureRange => '${minTemperature.round()}° - ${maxTemperature.round()}°';

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'maxTemperature': maxTemperature,
    'minTemperature': minTemperature,
    'description': description,
    'rainProbability': rainProbability,
    'weatherIconCode': weatherIconCode,
  };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
    date: DateTime.parse(json['date']),
    maxTemperature: (json['maxTemperature'] as num).toDouble(),
    minTemperature: (json['minTemperature'] as num).toDouble(),
    description: json['description'],
    rainProbability: (json['rainProbability'] as num?)?.toInt(),
    weatherIconCode: json['weatherIconCode'],
  );
}

class WeatherSearchResult {
  WeatherSearchResult({
    required this.locationName,
    required this.fullLocationName,
    required this.locationCode,
  });

  final String locationName;
  final String fullLocationName;
  final String locationCode;
}
