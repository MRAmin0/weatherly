import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/charts/temperature_chart.dart';
import 'package:weatherly_app/presentation/widgets/common/app_background.dart';

import 'widgets/location_header.dart';
import 'widgets/daily_list.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final isDark = theme.brightness == Brightness.dark;

        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark
            ? Colors.white.withAlpha(179)
            : Colors.black.withAlpha(153);

        final isPersian = vm.lang == 'fa';

        Widget content;

        if (vm.isLoading && vm.location.isEmpty) {
          content = Center(child: CircularProgressIndicator(color: textColor));
        } else if (vm.error != null) {
          content = Center(
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
        } else if (vm.location.isEmpty || vm.currentWeather == null) {
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                l10n.forecastSearchPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          );
        } else {
          content = RefreshIndicator(
            color: textColor,
            backgroundColor: textColor.withAlpha(40),
            onRefresh: vm.refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom AppBar area matching HomePage
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  l10n.forecast,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

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

                          if (vm.hourly.isNotEmpty) ...[
                            TemperatureChart(
                              hourlyData: vm.hourly,
                              useCelsius: vm.useCelsius,
                              isPersian: isPersian,
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (vm.daily5.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: [const AppBackground(), content]),
        );
      },
    );
  }
}
