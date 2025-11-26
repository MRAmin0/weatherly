import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/utils/city_utils.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/widgets/air_quality_card.dart';
import 'package:weatherly_app/widgets/animations/weather_status_icons.dart'; // برای آیکون‌های جدید

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent, // شفاف برای دیدن گرادینت
      appBar: AppBar(
        title: Text(l10n.forecast),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          final isPersian = vm.lang == 'fa';

          if (vm.isLoading && vm.location.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (vm.error != null) {
            return Center(
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
          }

          if (vm.location.isEmpty || vm.currentWeather == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.forecastSearchPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLocationHeader(context, vm, l10n),
                  const SizedBox(height: 24),

                  if (vm.hourly.isNotEmpty) ...[
                    _buildHourlySection(context, vm, l10n, isPersian),
                    const SizedBox(height: 24),
                  ],

                  if (vm.daily5.isNotEmpty) ...[
                    _buildDailyForecastSection(context, vm, l10n, isPersian),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Location Header ----------------

  Widget _buildLocationHeader(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // Glassmorphism
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                vm.location,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.localeName == 'fa'
                    ? "پیش‌بینی ۵ روز آینده"
                    : "Next 5 Days Forecast",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Hourly Section ----------------

  Widget _buildHourlySection(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    bool isPersian,
  ) {
    final unitSymbol = vm.useCelsius ? '°C' : '°F';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    l10n.hourlyTemperatureTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($unitSymbol)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vm.hourly.length,
                cacheExtent: 200,
                itemBuilder: (context, index) {
                  final hour = vm.hourly[index];

                  final hourText = formatLocalHour(
                    hour.time,
                    vm.hourlyOffset ?? 0,
                  );

                  final rawTemp = hour.temperature;
                  final displayedTemp = vm.useCelsius
                      ? rawTemp
                      : (rawTemp * 9 / 5) + 32;
                  final tempText =
                      '${displayedTemp.toStringAsFixed(0)}$unitSymbol';

                  final iconPath = weatherIconAsset(
                    weatherTypeToApiName(hour.weatherType),
                  );

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1), // Glass
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPersian ? toPersianDigits(hourText) : hourText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                          ),
                          SvgPicture.asset(
                            iconPath,
                            width: 32,
                            height: 32,
                            // اگر آیکون‌ها سیاه هستند، سفیدشان کن (اختیاری)
                            // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          Text(
                            isPersian ? toPersianDigits(tempText) : tempText,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

  // ---------------- Daily 5-day Section ----------------

  Widget _buildDailyForecastSection(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    bool isPersian,
  ) {
    final unitSymbol = vm.useCelsius ? '°C' : '°F';
    final dayFormatter = DateFormat('EEEE', vm.lang);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.dailyForecastTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...vm.daily5.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;

              final dayOfWeek = dayFormatter.format(day.date);
              final weatherMain = day.main;
              final iconPath = weatherIconAsset(weatherMain);

              final minDisplayed = vm.useCelsius
                  ? day.minTemp
                  : (day.minTemp * 9 / 5) + 32;
              final maxDisplayed = vm.useCelsius
                  ? day.maxTemp
                  : (day.maxTemp * 9 / 5) + 32;

              final maxText = '${maxDisplayed.toStringAsFixed(0)}$unitSymbol';
              final minText = '${minDisplayed.toStringAsFixed(0)}$unitSymbol';

              final description = translateWeatherDescription(
                weatherMain,
                lang: vm.lang,
              );

              final currentAqi = vm.calculatedAqiScore;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    _showDayDetails(
                      context: context,
                      dayTitle: index == 0 ? l10n.today : dayOfWeek,
                      description: description,
                      dayHumidity: day.humidity,
                      dayWindSpeed: day.windSpeed,
                      aqi: currentAqi,
                      l10n: l10n,
                      isPersian: isPersian,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1), // Glass
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index == 0 ? l10n.today : dayOfWeek,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(iconPath, width: 40, height: 40),
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
                                children: [
                                  const Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 16,
                                    color: Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPersian
                                        ? toPersianDigits(maxText)
                                        : maxText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 16,
                                    color: Colors.lightBlueAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPersian
                                        ? toPersianDigits(minText)
                                        : minText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
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
        ),
      ),
    );
  }

  // ---------------- Bottom Sheet (Day Details) ----------------

  void _showDayDetails({
    required BuildContext context,
    required String dayTitle,
    required String description,
    required int dayHumidity,
    required double dayWindSpeed,
    required int aqi,
    required AppLocalizations l10n,
    required bool isPersian,
  }) {
    final humidity = isPersian
        ? toPersianDigits("$dayHumidity%")
        : "$dayHumidity%";

    final windSpeedText = isPersian
        ? toPersianDigits(dayWindSpeed.toStringAsFixed(1))
        : dayWindSpeed.toStringAsFixed(1);

    final windUnit = l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h";

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
            // چون باتم شیت روی صفحه میاد، بهتره پس‌زمینه سالید (غیرشفاف) داشته باشه
            // تا با محتوای زیر قاطی نشه، یا یک بلر (Blur) قوی داشته باشه.
            // فعلاً از رنگ تم استفاده میکنیم برای خوانایی.
            final sheetColor = Theme.of(context).scaffoldBackgroundColor;

            return Container(
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  // --- Header ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
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
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // AQI Card
                  AirQualityCard(aqi: aqi),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailBox(
                          context: context,
                          title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
                          value: humidity,
                          // استفاده از آیکون انیمیشنی جدید
                          icon: const HumidityIcon(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailBox(
                          context: context,
                          title: l10n.localeName == 'fa' ? "باد" : "Wind",
                          value: "$windSpeedText $windUnit",
                          // استفاده از آیکون انیمیشنی جدید
                          icon: WindTurbineIcon(windSpeed: dayWindSpeed),
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
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(l10n.localeName == 'fa' ? "بستن" : "Close"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailBox({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String value,
  }) {
    // این باکس‌ها چون داخل باتم شیت هستند (که پس‌زمینه سفید/تیره دارد)،
    // نیازی نیست شیشه‌ای باشند و از استایل تم پیروی می‌کنند.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 32, width: 32, child: Center(child: icon)),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
