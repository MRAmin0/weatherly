enum WeatherType {
  rain,
  snow,
  clear,
  clouds,
  drizzle,
  thunderstorm,
  atmosphere, // برای مه، گردوغبار، دود و ...
  unknown,
}

class CurrentWeather {
  final double temperature;
  final String description;
  final WeatherType weatherType;
  final String cityName;
  final int humidity;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.description,
    required this.weatherType,
    required this.cityName,
    required this.humidity,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weatherList = json['weather'] as List?;
    final weatherData = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList[0]
        : {};
    final wind = json['wind'] ?? {};

    return CurrentWeather(
      cityName: json['name'] ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      description: weatherData['description'] ?? '',
      weatherType: _mapStringToWeatherType(weatherData['main']?.toString()),
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HourlyForecastResponse {
  HourlyForecastResponse({
    required this.entries,
    required this.timezoneOffsetSeconds,
  });

  final List<Map<String, dynamic>> entries;
  final int timezoneOffsetSeconds;
}

// تابع تشخیص نوع هوا (اصلاح شده برای ریزگرد و مه)
WeatherType _mapStringToWeatherType(String? main) {
  if (main == null) return WeatherType.unknown;
  switch (main.toLowerCase()) {
    case 'thunderstorm':
      return WeatherType.thunderstorm;
    case 'drizzle':
      return WeatherType.drizzle;
    case 'rain':
      return WeatherType.rain;
    case 'snow':
      return WeatherType.snow;
    case 'clear':
      return WeatherType.clear;
    case 'clouds':
      return WeatherType.clouds;
  // موارد جوی خاص (مه، غبار، دود، شن و ...)
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
    case 'sand':
    case 'ash':
    case 'squall':
    case 'tornado':
      return WeatherType.atmosphere;
    default:
      return WeatherType.unknown;
  }
}