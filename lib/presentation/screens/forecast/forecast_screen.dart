import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

import 'package:weatherly_app/presentation/widgets/cards/air_quality_card.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_status_icons.dart';
import 'package:weatherly_app/presentation/widgets/charts/temperature_chart.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.forecast),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          final isPersian = vm.lang == 'fa';

          // ----------- STATES ----------
          if (vm.isLoading && vm.location.isEmpty) {
            return Center(child: CircularProgressIndicator(color: textColor));
          }

          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  vm.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          if (vm.location.isEmpty || vm.currentWeather == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.forecastSearchPrompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: textColor,
            backgroundColor: textColor.withValues(alpha: 0.2),
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLocationHeader(
                    context,
                    vm,
                    l10n,
                    textColor,
                    subTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 24),

                  if (vm.hourly.isNotEmpty) ...[
                    TemperatureChart(
                      hourlyData: vm.hourly,
                      useCelsius: vm.useCelsius,
                      isPersian: isPersian,
                    ),
                    const SizedBox(height: 24),
                    _buildHourlySection(
                      context,
                      vm,
                      l10n,
                      isPersian,
                      textColor,
                      subTextColor,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (vm.daily5.isNotEmpty)
                    _buildDailySection(
                      context,
                      vm,
                      l10n,
                      isPersian,
                      textColor,
                      subTextColor,
                      isDark,
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------- HEADER GLASS --------------------

  Widget _buildLocationHeader(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _glassBox(isDark),
          child: Column(
            children: [
              Icon(Icons.location_on, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                vm.location,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.localeName == 'fa'
                    ? "پیش‌بینی ۵ روز آینده"
                    : "Next 5 Days Forecast",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: subTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- HOURLY --------------------

  Widget _buildHourlySection(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    bool isPersian,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final unit = vm.useCelsius ? '°C' : '°F';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.hourlyTemperatureTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text('($unit)', style: TextStyle(color: subTextColor)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vm.hourly.length,
                itemBuilder: (context, i) {
                  final hour = vm.hourly[i];

                  final time = formatLocalHour(hour.time, vm.hourlyOffset ?? 0);
                  final temp = vm.useCelsius
                      ? hour.temperature
                      : (hour.temperature * 9 / 5) + 32;
                  final iconPath = weatherIconAsset(
                    weatherTypeToApiName(hour.weatherType),
                  );

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: _glassBoxSmall(isDark),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPersian ? toPersianDigits(time) : time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          SvgPicture.asset(iconPath, width: 32, height: 32),
                          Text(
                            isPersian
                                ? toPersianDigits(
                                    "${temp.toStringAsFixed(0)}$unit",
                                  )
                                : "${temp.toStringAsFixed(0)}$unit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- DAILY --------------------

  Widget _buildDailySection(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    bool isPersian,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final unit = vm.useCelsius ? '°C' : '°F';
    final formatter = DateFormat('EEEE', vm.lang);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyForecastTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vm.daily5.length,
                itemBuilder: (context, i) {
                  final day = vm.daily5[i];

                  final dayName = formatter.format(day.date);
                  final iconPath = weatherIconAsset(day.main);
                  final desc = translateWeatherDescription(
                    day.main,
                    lang: vm.lang,
                  );

                  final max = vm.useCelsius
                      ? day.maxTemp
                      : (day.maxTemp * 9 / 5) + 32;
                  final min = vm.useCelsius
                      ? day.minTemp
                      : (day.minTemp * 9 / 5) + 32;

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(14),
                      decoration: _glassBox(isDark),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPersian ? toPersianDigits(dayName) : dayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SvgPicture.asset(iconPath, width: 42, height: 42),
                          Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: subTextColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 16,
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian
                                    ? toPersianDigits(
                                        "${max.toStringAsFixed(0)}$unit",
                                      )
                                    : "${max.toStringAsFixed(0)}$unit",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian
                                    ? toPersianDigits(
                                        "${min.toStringAsFixed(0)}$unit",
                                      )
                                    : "${min.toStringAsFixed(0)}$unit",
                                style: TextStyle(color: subTextColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Glass Styles --------------------

  BoxDecoration _glassBox(bool isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.10),
              ],
      ),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.08),
      ),
    );
  }

  BoxDecoration _glassBoxSmall(bool isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04),
              ]
            : [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
      ),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.06),
      ),
    );
  }
}
