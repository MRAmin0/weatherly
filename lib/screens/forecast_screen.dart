import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/widgets/weather_list_items.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
// 1. اضافه کردن ایمپورت کارت کیفیت هوا
import 'package:weatherly_app/widgets/air_quality_card.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forecast)),
      body: Consumer<WeatherStore>(
        builder: (context, store, _) {
          final isPersian = store.currentLang == 'fa';
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.forecastSearchPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: store.handleRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationHeader(context, store, l10n),
                      const SizedBox(height: 24),
                      if (store.showHourly &&
                          store.hourlyForecast.isNotEmpty) ...[
                        _buildHourlySection(context, store, l10n, isPersian),
                        const SizedBox(height: 24),
                      ],
                      if (store.forecast.isNotEmpty) ...[
                        _buildDailyForecastSection(
                          context,
                          store,
                          l10n,
                          isPersian,
                        ),
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

  Widget _buildLocationHeader(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      ) {
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.fiveDayForecast,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySection(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      bool isPersian,
      ) {
    final unitSymbol = store.useCelsius ? '°C' : '°F';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12),
          child: Row(
            children: [
              Text(
                l10n.hourlyTemperatureTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '($unitSymbol)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withAlpha(153),
                ),
              ),
            ],
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
              final hourText = formatLocalHour(
                date,
                store.hourlyTimezoneOffsetSeconds ?? 0,
              );
              final tempText = '$temp$unitSymbol';

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: HourlyItem(
                  hourText: isPersian ? toPersianDigits(hourText) : hourText,
                  tempText: isPersian ? toPersianDigits(tempText) : tempText,
                  icon: iconPath,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSection(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      bool isPersian,
      ) {
    final unitSymbol = store.useCelsius ? '°C' : '°F';
    final dayFormatter = DateFormat('EEEE', store.currentLang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12),
          child: Text(
            l10n.dailyForecastTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...store.forecast.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = DateTime.parse(day['dt_txt']);
          final dayOfWeek = dayFormatter.format(date);
          final weatherMain = day['weather'][0]['main'] as String;
          final iconPath = weatherIconAsset(weatherMain);
          final minTemp = (day['main']['temp_min'] as num).toDouble();
          final maxTemp = (day['main']['temp_max'] as num).toDouble();
          final minDisplayed = store.useCelsius
              ? minTemp
              : (minTemp * 9 / 5) + 32;
          final maxDisplayed = store.useCelsius
              ? maxTemp
              : (maxTemp * 9 / 5) + 32;
          final maxText = '${maxDisplayed.toStringAsFixed(0)}$unitSymbol';
          final minText = '${minDisplayed.toStringAsFixed(0)}$unitSymbol';
          final description = translateWeatherDescription(
            weatherMain,
            lang: store.currentLang,
          );

          // دریافت AQI فعلی (چون پیش‌بینی روزانه AQI نداریم)
          final currentAqi = store.airQualityIndex ?? 0;

          // 2. اضافه کردن InkWell برای قابلیت کلیک
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                _showDayDetails(context, day, currentAqi, l10n, isPersian, dayOfWeek, description);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                            index == 0 ? l10n.today : dayOfWeek,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (index > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withAlpha(179),
                              ),
                            ),
                          ],
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                child: Icon(
                                  Icons.arrow_upward,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian ? toPersianDigits(maxText) : maxText,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                child: Icon(
                                  Icons.arrow_downward,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color?.withAlpha(153),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian ? toPersianDigits(minText) : minText,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color
                                      ?.withAlpha(153),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 3. تابع نمایش جزئیات و AQI
  void _showDayDetails(
      BuildContext context,
      dynamic dayData,
      int aqi,
      AppLocalizations l10n,
      bool isPersian,
      String dayTitle,
      String description,
      ) {
    // استخراج رطوبت و باد از داده‌های روز
    final humidityVal = dayData['main']['humidity'];
    final windVal = (dayData['wind']['speed'] as num).toDouble();

    final humidity = isPersian
        ? toPersianDigits("$humidityVal%")
        : "$humidityVal%";

    final wind = isPersian
        ? toPersianDigits("${windVal.toStringAsFixed(1)} km/h")
        : "${windVal.toStringAsFixed(1)} km/h";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "$dayTitle - $description",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ویجت AQI
                  AirQualityCard(aqi: aqi),

                  const SizedBox(height: 24),

                  // نمایش رطوبت و باد برای آن روز خاص
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailBox(
                            context,
                            Icons.water_drop_outlined,
                            Colors.lightBlue,
                            l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
                            humidity
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailBox(
                            context,
                            Icons.wind_power,
                            Colors.blueAccent,
                            l10n.localeName == 'fa' ? "باد" : "Wind",
                            wind
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailBox(BuildContext context, IconData icon, Color color, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(30),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(150),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}