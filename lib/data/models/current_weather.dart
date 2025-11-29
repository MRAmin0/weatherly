import 'package:weatherly_app/data/models/weather_type.dart';
// Ensure this exists for mapWeatherType

class CurrentWeather {
  final String cityName;
  final String description;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final String main;

  CurrentWeather({
    required this.cityName,
    required this.description,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
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

    return CurrentWeather(
      cityName: json['name'] ?? '',
      description: weather['description'] ?? '',
      main: weather['main'] ?? 'Clear',
      temperature: (mainData['temp'] as num).toDouble(),
      humidity: (mainData['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
    );
  }
}
