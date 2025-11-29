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
    final windUnit = isPersian ? "km/h" : "km/h";

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
      aqiStatusText = isPersian
          ? "ناسالم برای گروه‌های حساس"
          : "Unhealthy for Sensitive Groups";
      aqiColor = const Color(0xFFFF9800);
    } else if (aqiScore <= 200) {
      aqiStatusText = isPersian ? "ناسالم" : "Unhealthy";
      aqiColor = const Color(0xFFF44336);
    } else if (aqiScore <= 300) {
      aqiStatusText = isPersian ? "خیلی ناسالم" : "Very Unhealthy";
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
            // استفاده از ویجت جدا شده
            icon: const HumidityIcon(),
          ),
        ),

        const SizedBox(width: 12),

        // --- کارت باد ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "باد" : "Wind",
            mainValue: windVal,
            subValue: windUnit,
            // استفاده از ویجت جدا شده (فقط سرعت را پاس می‌دهیم)
            icon: WindTurbineIcon(windSpeed: windSpeed),
          ),
        ),

        const SizedBox(width: 12),

        // --- کارت کیفیت هوا ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "کیفیت هوا" : "AQI",
            mainValue: aqiVal,
            subValue: aqiStatusText,
            subValueColor: aqiColor,
            isAqi: true,
            // استفاده از ویجت جدا شده
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
    final theme = Theme.of(context);

    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        // رنگ شیشه‌ای: سطح با شفافیت ۲۰٪
        color: theme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        // حاشیه محو برای افکت شیشه
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
        // سایه کمتر برای حفظ سبکی
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32, width: 32, child: Center(child: icon)),
          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              mainValue,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: isAqi ? 22 : 24,
                height: 1.0,
                color: isAqi ? subValueColor : null,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              subValue,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isAqi ? 10 : 12,
                height: 1.1,
                color:
                    subValueColor ??
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
