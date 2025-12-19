import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/animations/main_weather_icon.dart';

class CurrentWeatherSection extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const CurrentWeatherSection({
    super.key,
    required this.viewModel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final current = viewModel.currentWeather;
    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';
    final theme = Theme.of(context);

    final tempValue = viewModel.useCelsius
        ? current.temp
        : (current.temp * 9 / 5) + 32;

    final tempString = isPersian
        ? toPersianDigits(tempValue.toStringAsFixed(0))
        : tempValue.toStringAsFixed(0);

    final unit = viewModel.useCelsius ? "°C" : "°F";

    return Column(
      children: [
        MainWeatherIcon(weatherType: current.weatherType, size: 160),
        const SizedBox(height: 16),
        Text(
          "$tempString$unit",
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 96,
            height: 1.0,
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // --- Real Feel ---
        _buildRealFeel(
          context,
          current.feelsLike,
          viewModel.useCelsius,
          isPersian,
          unit,
        ),

        const SizedBox(height: 12),
        Text(
          current.cityName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translateWeatherDescription(current.main, lang: viewModel.lang),
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRealFeel(
    BuildContext context,
    double feelsLike,
    bool useCelsius,
    bool isPersian,
    String unit,
  ) {
    final realFeelVal = useCelsius ? feelsLike : (feelsLike * 9 / 5) + 32;
    final realFeelStr = isPersian
        ? toPersianDigits(realFeelVal.toStringAsFixed(0))
        : realFeelVal.toStringAsFixed(0);

    final label = isPersian ? "حس واقعی" : "Real Feel";

    final formattedStr = isPersian
        ? "\u200E$realFeelStr$unit"
        : "$realFeelStr$unit";

    return Text(
      "$label: $formattedStr",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
