import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const WeatherDetailsGrid({
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

    // Helper to format values
    String fmt(double val, {int decimals = 1}) {
      final s = val.toStringAsFixed(decimals);
      return isPersian ? toPersianDigits(s) : s;
    }

    // 1. Weather Condition
    final conditionText = translateWeatherDescription(
      current.main,
      lang: viewModel.lang,
    );

    // 2. RealFeel
    final realFeelVal = viewModel.useCelsius
        ? current.feelsLike
        : (current.feelsLike * 9 / 5) + 32;
    final realFeelString = fmt(realFeelVal);

    // 3. Wind
    final windVal = fmt(current.windSpeed);

    // 4. Humidity
    final humidityVal = isPersian
        ? toPersianDigits(current.humidity.toString())
        : current.humidity.toString();

    // 5. Visibility (km)
    final visibilityKm = current.visibility / 1000;
    final visibilityVal = fmt(visibilityKm);

    // 6. AQI
    final aqiScore = viewModel.calculatedAqiScore;
    final aqiVal = isPersian
        ? toPersianDigits(aqiScore.toString())
        : aqiScore.toString();
    String aqiText;
    if (aqiScore <= 50)
      aqiText = isPersian ? "خوب" : "Good";
    else if (aqiScore <= 100)
      aqiText = isPersian ? "متوسط" : "Moderate";
    else
      aqiText = isPersian ? "ناسالم" : "Unhealthy";

    // 7. Cloud Cover
    final cloudVal = isPersian
        ? toPersianDigits(current.cloudiness.toString())
        : current.cloudiness.toString();

    // 8. Wind Direction
    final windDirVal = _getWindDirectionText(current.windDirection);

    final items = [
      // Row 1: Condition - RealFeel
      _GridItem(
        title: isPersian ? "وضعیت هوا" : "Condition",
        value: conditionText,
        icon: Icons.wb_sunny_outlined, // Placeholder icon
        customValueWidget: Text(
          conditionText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14, // Slightly smaller for potentially long text
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _GridItem(
        title: isPersian ? "احساس واقعی" : "RealFeel",
        value: "$realFeelString°",
        icon: Icons.thermostat,
        customValueWidget: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(text: realFeelString),
              TextSpan(
                text: "°",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),

      // Row 2: Wind - Humidity
      _GridItem(
        title: isPersian ? "باد" : "Wind",
        value: "$windVal ${isPersian ? 'km/h' : 'km/h'}",
        icon: Icons.air,
        customValueWidget: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: isPersian ? "km/h " : "km/h ",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(text: windVal),
            ],
          ),
        ),
      ),
      _GridItem(
        title: isPersian ? "رطوبت" : "Humidity",
        value: "$humidityVal%",
        icon: Icons.water_drop,
        customValueWidget: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(text: humidityVal),
              TextSpan(
                text: "%",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),

      // Row 3: Visibility - AQI
      _GridItem(
        title: isPersian ? "دید" : "Visibility",
        value: "$visibilityVal km",
        icon: Icons.visibility,
        customValueWidget: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: isPersian ? "km " : "km ",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(text: visibilityVal),
            ],
          ),
        ),
      ),
      _GridItem(
        title: isPersian ? "کیفیت هوا" : "AQI",
        value: "$aqiText $aqiVal",
        icon: Icons.wb_sunny_outlined,
        customValueWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPersian ? "شاخص" : "Index",
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "($aqiText) $aqiVal",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // Row 4: Cloud Cover - Wind Direction
      _GridItem(
        title: isPersian ? "پوشش ابر" : "Cloud Cover",
        value: "$cloudVal%",
        icon: Icons.cloud,
        customValueWidget: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(text: cloudVal),
              TextSpan(
                text: "%",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      _GridItem(
        title: isPersian ? "جهت باد" : "Wind Dir",
        value: windDirVal,
        icon: Icons.navigation,
        iconRotation: current.windDirection.toDouble(),
        customValueWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              windDirVal,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Transform.rotate(
              angle: (current.windDirection * 3.14159 / 180),
              child: Icon(
                Icons.navigation,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width:
              (MediaQuery.of(context).size.width - 64 - 12) /
              2, // Width - (SliverPadding 32 + ContainerPadding 32) - Spacing 12
          child: _buildGridCard(context, item),
        );
      }).toList(),
    );
  }

  Widget _buildGridCard(BuildContext context, _GridItem item) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                item.customValueWidget ??
                    Text(
                      item.value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ],
            ),
          ),
          Icon(
            item.icon,
            color: theme.colorScheme.primary.withOpacity(0.7),
            size: 24,
          ),
        ],
      ),
    );
  }

  String _getWindDirectionText(int deg) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((deg + 22.5) % 360) ~/ 45;
    return directions[index];
  }
}

class _GridItem {
  final String title;
  final String value;
  final IconData icon;
  final double? iconRotation;
  final Widget? customValueWidget;

  _GridItem({
    required this.title,
    required this.value,
    required this.icon,
    this.iconRotation,
    this.customValueWidget,
  });
}
