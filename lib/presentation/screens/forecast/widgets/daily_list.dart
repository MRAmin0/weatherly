import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/weather_formatters.dart';
import '../../../../core/utils/city_utils.dart';
import '../../../../presentation/widgets/common/glass_container.dart';
import 'day_detail_sheet.dart';

class DailyList extends StatelessWidget {
  final List<dynamic> items;
  final bool isPersian;
  final bool useCelsius;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final String langCode;
  final int aqiScore;

  const DailyList({
    super.key,
    required this.items,
    required this.isPersian,
    required this.useCelsius,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.langCode,
    required this.aqiScore,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE', langCode);

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final day = items[i];

          final date = day.date as DateTime;
          final main = day.main as String;
          final minTemp = day.minTemp as num;
          final maxTemp = day.maxTemp as num;
          final humidity = day.humidity as int;
          final windSpeed = day.windSpeed as double;

          final dayName = formatter.format(date);
          final titleText = isPersian ? toPersianDigits(dayName) : dayName;

          final unitSymbol = useCelsius ? '°C' : '°F';

          final maxDisplayed = useCelsius ? maxTemp : (maxTemp * 9 / 5) + 32;
          final minDisplayed = useCelsius ? minTemp : (minTemp * 9 / 5) + 32;

          final maxText = '${maxDisplayed.toStringAsFixed(0)}$unitSymbol';
          final minText = '${minDisplayed.toStringAsFixed(0)}$unitSymbol';

          final description = translateWeatherDescription(main, lang: langCode);
          final iconPath = weatherIconAsset(main);

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: SizedBox(
              width: 125,
              child: GlassContainer(
                isDark: true, // Force white styles
                borderRadius: 25,
                padding: EdgeInsets.zero,
                onTap: () {
                  showDayDetailSheet(
                    context: context,
                    dayTitle: titleText,
                    description: description,
                    humidity: humidity,
                    windSpeed: windSpeed,
                    aqi: aqiScore,
                    isPersian: isPersian,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        titleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SvgPicture.asset(iconPath, width: 48, height: 48),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_upward_rounded,
                                size: 14,
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian ? toPersianDigits(maxText) : maxText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_downward_rounded,
                                size: 14,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPersian ? toPersianDigits(minText) : minText,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
