/// Shared weather-related models used across the app.
enum WeatherType {
  rain,
  snow,
  clear,
  clouds,
  drizzle,
  thunderstorm,
  unknown,
}

class HourlyForecastResponse {
  HourlyForecastResponse({
    required this.entries,
    required this.timezoneOffsetSeconds,
  });

  final List<Map<String, dynamic>> entries;
  final int timezoneOffsetSeconds;
}


