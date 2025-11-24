import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/widgets/animations/weather_animator.dart';
// FIX: Import city_utils to use toPersianDigits
import 'package:weatherly_app/utils/city_utils.dart';

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
    final theme = Theme.of(context);
    final current = viewModel.currentWeather;

    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';
    final temp = viewModel.useCelsius
        ? current.temp
        : (current.temp * 9 / 5) + 32;
    final unit = viewModel.useCelsius ? "°C" : "°F";
    final tempText = "${temp.toStringAsFixed(0)}$unit";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isPersian ? toPersianDigits(tempText) : tempText,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 80,
            height: 1.0,
            fontWeight: FontWeight.w400,
            color: theme.textTheme.displayLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          viewModel.location,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              translateWeatherDescription(
                current.description,
                lang: viewModel.lang,
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            WeatherAnimator(
              weatherType: current.weatherType,
              child: SvgPicture.asset(
                weatherIconAsset(current.weatherMain),
                width: 40,
                height: 40,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
