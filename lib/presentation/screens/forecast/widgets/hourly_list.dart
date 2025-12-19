import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../presentation/widgets/common/glass_container.dart';
import '../../../../core/utils/weather_formatters.dart';
import '../../../../core/utils/city_utils.dart';

class HourlyList extends StatelessWidget {
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
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
              isDark: true, // Force white styles
              borderRadius: 25,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: SizedBox(
                width: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPersian ? toPersianDigits(time) : time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SvgPicture.asset(iconPath, width: 36, height: 36),
                    const SizedBox(height: 8),
                    Text(
                      isPersian ? toPersianDigits(tempText) : tempText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
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
