import 'package:flutter/material.dart';
import 'package:weatherly_app/data/models/weather_type.dart';

class WeatherGradients {
  static LinearGradient getGradient(WeatherType type, Color seedColor) {
    List<Color> colors;

    final Color baseColor = seedColor;

    final Color accentColor = Color.lerp(baseColor, Colors.white, 0.4)!;
    final Color darkAccent = Color.lerp(baseColor, Colors.black, 0.3)!;

    switch (type) {
      case WeatherType.clear:
        colors = [accentColor, Colors.blue.shade300];
        break;
      case WeatherType.clouds:
      case WeatherType.mist:
      case WeatherType.fog:
      case WeatherType.atmosphere:
        colors = [
          baseColor.withValues(alpha: 0.9),
          Colors.grey.shade400.withValues(alpha: 0.7),
        ];
        break;
      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        colors = [darkAccent, Colors.black.withValues(alpha: 0.7)];
        break;
      case WeatherType.snow:
        colors = [accentColor, Colors.blue.shade100];
        break;
      default:
        colors = [baseColor, darkAccent];
    }

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );
  }
}
