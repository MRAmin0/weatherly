import 'package:flutter/material.dart';
import 'package:weatherly_app/data/models/weather_type.dart';

class WeatherBackgroundWrapper extends StatelessWidget {
  final WeatherType weatherType;
  final Widget child;

  const WeatherBackgroundWrapper({
    super.key,
    required this.weatherType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<Color> gradientColors;

    switch (weatherType) {
      case WeatherType.clear:
        gradientColors = isDark
            ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
            : [const Color(0xFF4FC3F7), const Color(0xFF01579B)];
        break;
      case WeatherType.clouds:
        gradientColors = isDark
            ? [const Color(0xFF37474F), const Color(0xFF263238)]
            : [const Color(0xFF90A4AE), const Color(0xFF546E7A)];
        break;
      case WeatherType.rain:
      case WeatherType.drizzle:
        gradientColors = isDark
            ? [const Color(0xFF212121), const Color(0xFF01579B)]
            : [const Color(0xFF424242), const Color(0xFF1976D2)];
        break;
      case WeatherType.thunderstorm:
        gradientColors = isDark
            ? [const Color(0xFF311B92), const Color(0xFF1A237E)]
            : [const Color(0xFF512DA8), const Color(0xFF311B92)];
        break;
      case WeatherType.snow:
        gradientColors = isDark
            ? [const Color(0xFF455A64), const Color(0xFF263238)]
            : [
                const Color(0xFFB3E5FC),
                const Color(0xFF81D4FA),
              ]; // Darkened for better contrast
        break;
      case WeatherType.mist:
        gradientColors = isDark
            ? [const Color(0xFF263238), const Color(0xFF212121)]
            : [const Color(0xFFCFD8DC), const Color(0xFF90A4AE)];
        break;
      default:
        gradientColors = [
          theme.colorScheme.surfaceContainer,
          theme.colorScheme.surface,
        ];
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // 🔹 Optional Dark Overlay for light mode to ensure white text visibility
          if (!isDark)
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          child,
        ],
      ),
    );
  }
}
