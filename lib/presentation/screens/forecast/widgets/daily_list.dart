import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/weather_formatters.dart';
import '../../../../core/utils/city_utils.dart';
import 'glass_box.dart';
import 'day_detail_sheet.dart';

class DailyList extends StatelessWidget {
  /// vm.daily5 را همین‌طور پاس بده
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
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
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
              child: GlassBox(
                isDark: isDark,
                radius: 20,
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SvgPicture.asset(iconPath, width: 42, height: 42),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 16,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPersian ? toPersianDigits(maxText) : maxText,
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
                        const Icon(
                          Icons.arrow_downward_rounded,
                          size: 16,
                          color: Colors.lightBlueAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPersian ? toPersianDigits(minText) : minText,
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
