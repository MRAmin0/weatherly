import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

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
        // 1. City Name
        Text(
          current.cityName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // 2. Temperature (e.g. 13.9°C)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              tempString,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 80,
                height: 1.0,
                color: theme.colorScheme.onSurface,
                letterSpacing: -2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
