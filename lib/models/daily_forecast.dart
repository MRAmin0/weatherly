// lib/models/daily_forecast.dart

import 'weather_type.dart';

class DailyForecastEntry {
  final DateTime date; // تاریخ (local)
  final double minTemp; // کمینه دما
  final double maxTemp; // بیشینه دما
  final WeatherType weatherType;
  final String main; // مثل: Rain, Clear, Clouds
  final int humidity; // میانگین رطوبت روز
  final double windSpeed; // میانگین سرعت باد

  DailyForecastEntry({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherType,
    required this.main,
    required this.humidity,
    required this.windSpeed,
  });
}
