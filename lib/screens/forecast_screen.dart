import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/widgets/weather_list_items.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیش‌بینی')),
      body: Consumer<WeatherStore>(
        builder: (context, store, _) {
          if (store.isLoading && store.location.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  store.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          if (store.location.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'برای مشاهده پیش‌بینی، ابتدا شهر مورد نظر را جستجو کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: store.handleRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationHeader(context, store),
                      const SizedBox(height: 24),
                      if (store.showHourly && store.hourlyForecast.isNotEmpty) ...[
                        _buildHourlySection(context, store),
                        const SizedBox(height: 24),
                      ],
                      if (store.forecast.isNotEmpty) ...[
                        _buildDailyForecastSection(context, store),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context, WeatherStore store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            store.location,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'پیش‌بینی ۵ روز آینده',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha(179),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySection(BuildContext context, WeatherStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12),
          child: Text(
            'دمای ساعتی',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 120,
          width: math.min(MediaQuery.of(context).size.width, 900.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: store.hourlyForecast.length,
            cacheExtent: 200,
            itemBuilder: (context, index) {
              final hour = store.hourlyForecast[index];
              final date = DateTime.parse(hour['dt_txt']).toUtc();
              final rawTemp = (hour['main']['temp'] as num).toDouble();
              final displayedTemp = store.useCelsius
                  ? rawTemp
                  : (rawTemp * 9 / 5) + 32;
              final temp = displayedTemp.toStringAsFixed(0);
              final main = hour['weather'][0]['main'] as String;
              final iconPath = weatherIconAsset(main);

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: HourlyItem(
                  hourText: toPersianDigits(
                    formatLocalHour(
                      date,
                      store.hourlyTimezoneOffsetSeconds ?? 0,
                    ),
                  ),
                  tempText: toPersianDigits('$temp°'),
                  icon: iconPath,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSection(BuildContext context, WeatherStore store) {
    final daysFa = [
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
      'یک‌شنبه',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12),
          child: Text(
            'پیش‌بینی روزانه',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...store.forecast.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = DateTime.parse(day['dt_txt']);
          final dayOfWeek = daysFa[(date.weekday - 1) % 7];
          final weatherMain = day['weather'][0]['main'] as String;
          final iconPath = weatherIconAsset(weatherMain);
          final description = day['weather'][0]['description'] as String? ?? '';
          final minTemp = (day['main']['temp_min'] as num).toDouble();
          final maxTemp = (day['main']['temp_max'] as num).toDouble();
          final minDisplayed = store.useCelsius
              ? minTemp
              : (minTemp * 9 / 5) + 32;
          final maxDisplayed = store.useCelsius
              ? maxTemp
              : (maxTemp * 9 / 5) + 32;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index == 0 ? 'امروز' : dayOfWeek,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withAlpha(179),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SvgPicture.asset(
                  iconPath,
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        toPersianDigits('${maxDisplayed.toStringAsFixed(0)}°'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toPersianDigits('${minDisplayed.toStringAsFixed(0)}°'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withAlpha(153),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

