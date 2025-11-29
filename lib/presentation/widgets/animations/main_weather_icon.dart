import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_animator.dart';
// lib/widgets/animations/svg_assets.dart
import 'package:weatherly_app/presentation/widgets/animations/icon/svg_assets.dart';

class MainWeatherIcon extends StatelessWidget {
  final WeatherType weatherType;
  final double size;

  const MainWeatherIcon({
    super.key,
    required this.weatherType,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    // اگر هوا صاف است، از آیکون ترکیبی (ابر + خورشید چرخان) استفاده کن
    if (weatherType == WeatherType.clear) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // لایه ۱: ابر ثابت (زیر خورشید)
            SvgPicture.string(cloudSvg, width: size, height: size),

            // لایه ۲: خورشید چرخان
            WeatherAnimator(
              weatherType: WeatherType.clear, // تریگر چرخش
              customDuration: const Duration(seconds: 15), // سرعت چرخش ملایم
              child: SvgPicture.string(sunSvg, width: size, height: size),
            ),
          ],
        ),
      );
    }

    // برای سایر وضعیت‌های آب‌وهوایی، از آیکون‌های پیش‌فرض استفاده کن
    final IconData iconData;
    final Color iconColor;

    switch (weatherType) {
      case WeatherType.clouds:
        iconData = Icons.cloud_rounded;
        iconColor = Colors.grey.shade400;
        break;

      case WeatherType.rain:
      case WeatherType.drizzle:
        iconData = Icons.water_drop;
        iconColor = Colors.lightBlueAccent;
        break;

      case WeatherType.thunderstorm:
        iconData = Icons.thunderstorm;
        iconColor = Colors.deepPurpleAccent;
        break;

      case WeatherType.snow:
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue.shade100;
        break;

      case WeatherType.windy:
        iconData = Icons.air;
        iconColor = Colors.blueGrey;
        break;

      case WeatherType.fog:
      case WeatherType.mist:
        iconData = Icons.foggy;
        iconColor = Colors.blueGrey.shade200;
        break;

      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.grey;
    }

    return WeatherAnimator(
      weatherType: weatherType,
      child: Icon(
        iconData,
        size: size,
        color: iconColor,
        shadows: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
