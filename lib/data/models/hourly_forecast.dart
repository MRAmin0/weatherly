import 'weather_type.dart';

class HourlyForecastEntry {
  final DateTime time;
  final double temperature;
  final WeatherType weatherType;

  HourlyForecastEntry({
    required this.time,
    required this.temperature,
    required this.weatherType,
  });
}

class HourlyForecastResponse {
  final List<Map<String, dynamic>> entries;
  final int timezoneOffsetSeconds;

  HourlyForecastResponse({
    required this.entries,
    required this.timezoneOffsetSeconds,
  });
}
