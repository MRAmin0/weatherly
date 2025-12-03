import 'package:weatherly_app/data/models/weather_type.dart';
// Ensure this exists for mapWeatherType

class CurrentWeather {
  final String cityName;
  final String description;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int windDirection;
  final int humidity;
  final int pressure;
  final int visibility;
  final int cloudiness;
  final String main;

  CurrentWeather({
    required this.cityName,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.cloudiness,
    required this.main,
  });

  // Getters for UI compatibility
  double get temp => temperature;
  String get weatherMain => main;

  WeatherType get weatherType => mapWeatherType(main);

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final mainData = json['main'];
    final wind = json['wind'];
    final clouds = json['clouds'];

    return CurrentWeather(
      cityName: json['name'] ?? '',
      description: weather['description'] ?? '',
      main: weather['main'] ?? 'Clear',
      temperature: (mainData['temp'] as num).toDouble(),
      feelsLike: (mainData['feels_like'] as num).toDouble(),
      humidity: (mainData['humidity'] as num).toInt(),
      pressure: (mainData['pressure'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
      windDirection: (wind['deg'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      cloudiness: (clouds['all'] as num?)?.toInt() ?? 0,
    );
  }
}
