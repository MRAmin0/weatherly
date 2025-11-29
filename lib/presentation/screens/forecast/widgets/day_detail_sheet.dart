import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/presentation/widgets/cards/air_quality_card.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_status_icons.dart';

import 'weather_icon_item.dart';

Future<void> showDayDetailSheet({
  required BuildContext context,
  required String dayTitle,
  required String description,
  required int humidity,
  required double windSpeed,
  required int aqi,
  required bool isPersian,
}) async {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;
  final isDark = theme.brightness == Brightness.dark;

  final humidityText = isPersian ? toPersianDigits("$humidity%") : "$humidity%";

  final windSpeedStr = windSpeed.toStringAsFixed(1);
  final windText = isPersian
      ? "${toPersianDigits(windSpeedStr)} ${l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h"}"
      : "$windSpeedStr ${l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h"}";

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            final baseColor = isDark
                ? Colors.black.withAlpha(200)
                : theme.colorScheme.surface.withAlpha(235);

            return Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(40)
                      : theme.dividerColor.withAlpha(60),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withAlpha(120),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.dividerColor.withAlpha(30),
                            ),
                            child: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$dayTitle - $description",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AirQualityCard(aqi: aqi),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: WeatherDetailBox(
                          icon: const HumidityIcon(),
                          title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
                          value: humidityText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: WeatherDetailBox(
                          icon: WindTurbineIcon(windSpeed: windSpeed),
                          title: l10n.localeName == 'fa' ? "باد" : "Wind",
                          value: windText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: theme.dividerColor.withAlpha(100),
                        ),
                      ),
                      child: Text(l10n.localeName == 'fa' ? "بستن" : "Close"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
