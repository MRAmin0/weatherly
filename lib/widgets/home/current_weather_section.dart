import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/utils/city_utils.dart'; // برای اعداد فارسی
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
// ✅ ایمپورت فایل جدید:
import 'package:weatherly_app/widgets/animations/main_weather_icon.dart';

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

    // تبدیل دما
    final tempValue = viewModel.useCelsius
        ? current.temp
        : (current.temp * 9 / 5) + 32;

    final tempString = isPersian
        ? toPersianDigits(tempValue.toStringAsFixed(0))
        : tempValue.toStringAsFixed(0);

    final unit = viewModel.useCelsius ? "°C" : "°F";

    return Column(
      children: [
        // ---------------- آیکون انیمیشنی بزرگ ----------------
        MainWeatherIcon(
          weatherType: current.weatherType,
          size: 140, // سایز بزرگ برای وسط صفحه
        ),

        const SizedBox(height: 16),

        // ---------------- دما ----------------
        Text(
          "$tempString$unit",
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 80,
            height: 1.0,
          ),
        ),

        const SizedBox(height: 8),

        // ---------------- نام شهر ----------------
        Text(
          current.cityName,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
          ),
        ),

        const SizedBox(height: 8),

        // ---------------- توضیحات (صاف، ابری و...) ----------------
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            translateWeatherDescription(current.main, lang: viewModel.lang),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
