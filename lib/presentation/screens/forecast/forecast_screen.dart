import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/charts/temperature_chart.dart';

import 'widgets/location_header.dart';
import 'widgets/hourly_list.dart';
import 'widgets/daily_list.dart';

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
        ? Colors.white.withAlpha(179) // ~0.7
        : Colors.black.withAlpha(153); // ~0.6

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
                    color: theme.colorScheme.error,
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
            backgroundColor: textColor.withAlpha(40),
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LocationHeader(
                    city: vm.location,
                    subtitle: l10n.localeName == 'fa'
                        ? "پیش‌بینی ۵ روز آینده"
                        : "Next 5 Days Forecast",
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 24),

                  // نمودار دما و لیست ساعتی
                  if (vm.hourly.isNotEmpty) ...[
                    TemperatureChart(
                      hourlyData: vm.hourly,
                      useCelsius: vm.useCelsius,
                      isPersian: isPersian,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            l10n.hourlyTemperatureTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "(${vm.useCelsius ? '°C' : '°F'})",
                            style: TextStyle(color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HourlyList(
                        items: vm.hourly,
                        isPersian: isPersian,
                        useCelsius: vm.useCelsius,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        offset: vm.hourlyOffset ?? 0,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ۵ روز آینده
                  if (vm.daily5.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dailyForecastTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DailyList(
                            items: vm.daily5,
                            isPersian: isPersian,
                            useCelsius: vm.useCelsius,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            langCode: vm.lang,
                            aqiScore: vm.calculatedAqiScore,
                          ),
                        ],
                      ),
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
}
