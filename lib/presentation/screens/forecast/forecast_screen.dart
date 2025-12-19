import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/charts/temperature_chart.dart';

import 'widgets/location_header.dart';
import 'widgets/daily_list.dart';
import 'widgets/hourly_list.dart';

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

    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final isPersian = vm.lang == 'fa';

        Widget content;

        if (vm.isLoading && vm.location.isEmpty) {
          content = const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (vm.error != null) {
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else {
          content = RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.forecast,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LocationHeader(
                            city: vm.location,
                            subtitle: l10n.localeName == 'fa'
                                ? "پیش‌بینی ۵ روز آینده"
                                : "Next 5 Days Forecast",
                            isDark: true,
                            textColor: Colors.white,
                            subTextColor: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),

                        if (vm.hourly.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: isPersian
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                l10n.localeName == 'fa'
                                    ? "ساعات آینده"
                                    : "Hourly Forecast",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: HourlyList(
                              items: vm.hourly,
                              isPersian: isPersian,
                              useCelsius: vm.useCelsius,
                              isDark: true,
                              textColor: Colors.white,
                              subTextColor: Colors.white.withValues(alpha: 0.7),
                              offset: 0, // Or appropriate offset if available
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    24,
                                    16,
                                    16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(35),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          bottom: 16,
                                        ),
                                        child: Text(
                                          l10n.localeName == 'fa'
                                              ? "نمودار دما"
                                              : "Temperature Chart",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      TemperatureChart(
                                        hourlyData: vm.hourly,
                                        useCelsius: vm.useCelsius,
                                        isPersian: isPersian,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (vm.daily5.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dailyForecastTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DailyList(
                                  items: vm.daily5,
                                  isPersian: isPersian,
                                  useCelsius: vm.useCelsius,
                                  isDark: true,
                                  textColor: Colors.white,
                                  subTextColor: Colors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                  langCode: vm.lang,
                                  aqiScore: vm.calculatedAqiScore,
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Scaffold(backgroundColor: Colors.transparent, body: content);
      },
    );
  }
}
