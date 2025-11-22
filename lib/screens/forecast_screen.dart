import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/widgets/air_quality_card.dart'; // آدرس کامل

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forecast)),
      body: Consumer<WeatherStore?>(
        builder: (context, store, _) {
          // اگر به هر دلیلی هنوز استور آماده نیست
          if (store == null) {
            return const Center(child: CircularProgressIndicator());
          }

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
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLocationHeader(context, store, l10n),
                  const SizedBox(height: 24),

                  if (store.showHourly && store.hourlyForecast.isNotEmpty) ...[
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
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                store.location,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.localeName == 'fa'
                    ? "پیش‌بینی ۷ روز آینده"
                    : "Next 7 Days Forecast",
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
        ),
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($unitSymbol)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: store.hourlyForecast.length,
                cacheExtent: 200,
                itemBuilder: (context, index) {
                  final hour = store.hourlyForecast[index];
                  final date = DateTime.parse(hour['dt_txt']).toUtc();
                  final rawTemp = (hour['main']['temp'] as num).toDouble();
                  final displayedTemp =
                  store.useCelsius ? rawTemp : (rawTemp * 9 / 5) + 32;
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
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withAlpha(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPersian ? toPersianDigits(hourText) : hourText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SvgPicture.asset(
                            iconPath,
                            width: 32,
                            height: 32,
                          ),
                          Text(
                            isPersian ? toPersianDigits(tempText) : tempText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
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

  Widget _buildDailyForecastSection(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      bool isPersian,
      ) {
    final unitSymbol = store.useCelsius ? '°C' : '°F';
    final dayFormatter = DateFormat('EEEE', store.currentLang);

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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
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

              final minDisplayed =
              store.useCelsius ? minTemp : (minTemp * 9 / 5) + 32;
              final maxDisplayed =
              store.useCelsius ? maxTemp : (maxTemp * 9 / 5) + 32;

              final maxText = '${maxDisplayed.toStringAsFixed(0)}$unitSymbol';
              final minText = '${minDisplayed.toStringAsFixed(0)}$unitSymbol';

              final description = translateWeatherDescription(
                weatherMain,
                lang: store.currentLang,
              );

              final currentAqi = store.airQualityIndex ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    _showDayDetails(
                      context,
                      day,
                      currentAqi,
                      l10n,
                      isPersian,
                      dayOfWeek,
                      description,
                    );
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
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index == 0 ? l10n.today : dayOfWeek,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (index > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha(179),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          iconPath,
                          width: 40,
                          height: 40,
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withAlpha(150),
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

  void _showDayDetails(
      BuildContext context,
      dynamic dayData,
      int aqi,
      AppLocalizations l10n,
      bool isPersian,
      String dayTitle,
      String description,
      ) {
    final humidityVal = dayData['main']['humidity'];
    final windVal = (dayData['wind']['speed'] as num).toDouble();

    final humidity =
    isPersian ? toPersianDigits("$humidityVal%") : "$humidityVal%";

    final windSpeedText = isPersian
        ? toPersianDigits(windVal.toStringAsFixed(1))
        : windVal.toStringAsFixed(1);

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
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AirQualityCard(aqi: aqi),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailBox(
                          context: context,
                          icon: ScaleTransition(
                            scale: _pulseAnimation,
                            child: const Icon(
                              Icons.water_drop_outlined,
                              color: Colors.lightBlue,
                              size: 28,
                            ),
                          ),
                          title:
                          l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
                          value: humidity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailBox(
                          context: context,
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: Container(
                                  width: 3,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withAlpha(150),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: RotationTransition(
                                  turns: _rotationController,
                                  child: SvgPicture.asset(
                                    'assets/icons/turbine.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.blueAccent,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: l10n.localeName == 'fa' ? "باد" : "Wind",
                          value: "$windSpeedText $windUnit",
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

  Widget _buildDetailBox({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String value,
  }) {
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
          SizedBox(height: 32, width: 32, child: Center(child: icon)),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withAlpha(150),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
