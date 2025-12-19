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
  final l10n = AppLocalizations.of(context)!;

  final humidityText = isPersian ? toPersianDigits("$humidity%") : "$humidity%";

  final windSpeedStr = windSpeed.toStringAsFixed(1);
  final windText = isPersian
      ? "${toPersianDigits(windSpeedStr)} ${l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h"}"
      : "$windSpeedStr ${l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h"}";

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) {
      final content = DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        dayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Wrap legacy AirQualityCard or similar in glassy UI if needed,
                // but let's assume it looks okay or we'll update it later.
                AirQualityCard(aqi: aqi),

                const SizedBox(height: 24),
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
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Text(
                      l10n.localeName == 'fa' ? "بستن" : "Close",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: content,
      );
    },
  );
}
