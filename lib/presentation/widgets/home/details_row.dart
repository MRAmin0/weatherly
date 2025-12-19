import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_status_icons.dart';

class DetailsRow extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const DetailsRow({super.key, required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final current = viewModel.currentWeather;
    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';

    // --- 1. تنظیمات رطوبت ---
    final humidityVal = isPersian
        ? "${toPersianDigits(current.humidity.toString())}٪"
        : "${current.humidity}%";

    // --- 2. تنظیمات باد ---
    final double windSpeed = current.windSpeed;
    final windValString = windSpeed % 1 == 0
        ? windSpeed.toInt().toString()
        : windSpeed.toStringAsFixed(1);

    final windVal = isPersian ? toPersianDigits(windValString) : windValString;
    final windUnit = "km/h";

    // --- 3. تنظیمات کیفیت هوا ---
    final int aqiScore = viewModel.calculatedAqiScore;
    String aqiStatusText;
    Color aqiColor;

    if (aqiScore <= 50) {
      aqiStatusText = isPersian ? "پاک" : "Good";
      aqiColor = const Color(0xFF8BC34A);
    } else if (aqiScore <= 100) {
      aqiStatusText = isPersian ? "سالم" : "Moderate";
      aqiColor = const Color(0xFFFFEB3B);
    } else if (aqiScore <= 150) {
      aqiStatusText = isPersian ? "ناسالم" : "Sensitive";
      aqiColor = const Color(0xFFFF9800);
    } else if (aqiScore <= 200) {
      aqiStatusText = isPersian ? "ناسالم" : "Unhealthy";
      aqiColor = const Color(0xFFF44336);
    } else if (aqiScore <= 300) {
      aqiStatusText = isPersian ? "خیلی ناسالم" : "V. Unhealthy";
      aqiColor = const Color(0xFF9C27B0);
    } else {
      aqiStatusText = isPersian ? "خطرناک" : "Hazardous";
      aqiColor = const Color(0xFF880E4F);
    }

    final aqiVal = isPersian
        ? toPersianDigits(aqiScore.toString())
        : aqiScore.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- کارت رطوبت ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
            mainValue: humidityVal,
            subValue: " ",
            icon: const HumidityIcon(),
          ),
        ),

        const SizedBox(width: 8),

        // --- کارت باد ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "باد" : "Wind",
            mainValue: windVal,
            subValue: windUnit,
            icon: WindTurbineIcon(windSpeed: windSpeed),
          ),
        ),

        const SizedBox(width: 8),

        // --- کارت کیفیت هوا ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "کیفیت هوا" : "AQI",
            mainValue: aqiVal,
            subValue: aqiStatusText,
            subValueColor: aqiColor,
            isAqi: true,
            icon: AirQualityIcon(color: aqiColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBox({
    required BuildContext context,
    required String title,
    required String mainValue,
    required String subValue,
    required Widget icon,
    Color? subValueColor,
    bool isAqi = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 28, width: 28, child: Center(child: icon)),
          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              mainValue,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1.0,
                color: isAqi ? subValueColor : Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subValue,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: subValueColor ?? Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
