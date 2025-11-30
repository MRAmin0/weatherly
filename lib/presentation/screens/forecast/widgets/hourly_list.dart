import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../presentation/widgets/common/glass_container.dart';
import '../../../../core/utils/weather_formatters.dart';
import '../../../../core/utils/city_utils.dart';

class HourlyList extends StatelessWidget {
  /// vm.hourly را همین‌طور پاس بده (لیست هر مدلی که هست)
  final List<dynamic> items;
  final bool isPersian;
  final bool useCelsius;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final int offset;

  const HourlyList({
    super.key,
    required this.items,
    required this.isPersian,
    required this.useCelsius,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final hour = items[i];

          final time = formatLocalHour(hour.time, offset);
          final rawTemp = hour.temperature as num;
          final temp = useCelsius ? rawTemp : (rawTemp * 9 / 5) + 32;

          final iconPath = weatherIconAsset(
            weatherTypeToApiName(hour.weatherType),
          );

          final tempText = "${temp.toStringAsFixed(0)}°";

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: GlassContainer(
              isDark: isDark,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width:
                    60, // Keep fixed width for alignment within the glass container
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPersian ? toPersianDigits(time) : time,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SvgPicture.asset(iconPath, width: 32, height: 32),
                    Text(
                      isPersian ? toPersianDigits(tempText) : tempText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
