import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/models/weather_type.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/utils/city_utils.dart';
import 'package:weatherly_app/widgets/animations/weather_animator.dart';

class DetailsRow extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const DetailsRow({super.key, required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final current = viewModel.currentWeather;
    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';

    // --- Humidity & Wind ---
    final humidityText = isPersian
        ? toPersianDigits("${current.humidity}%")
        : "${current.humidity}%";

    final windText = isPersian
        ? toPersianDigits(current.windSpeed.toString())
        : current.windSpeed.toString();
    final windUnit = isPersian ? "کیلومتر/ساعت" : "km/h";

    // --- AQI Logic (Updated) ---
    // حالا از عدد محاسبه شده (0 تا 500) استفاده می‌کنیم
    final int aqiScore = viewModel.calculatedAqiScore;

    String aqiStatusText;
    Color aqiColor;

    // شرط‌ها بر اساس استاندارد 0 تا 500
    if (aqiScore <= 50) {
      aqiStatusText = isPersian ? "پاک" : "Good";
      aqiColor = const Color(0xFF8BC34A);
    } else if (aqiScore <= 100) {
      aqiStatusText = isPersian ? "سالم" : "Moderate";
      aqiColor = const Color(0xFFFFEB3B);
    } else if (aqiScore <= 150) {
      aqiStatusText = isPersian ? "ناسالم (حساس)" : "Unhealthy (Sen.)";
      aqiColor = const Color(0xFFFF9800);
    } else if (aqiScore <= 200) {
      aqiStatusText = isPersian ? "ناسالم" : "Unhealthy";
      aqiColor = const Color(0xFFF44336);
    } else if (aqiScore <= 300) {
      aqiStatusText = isPersian ? "بسیار ناسالم" : "Very Unhealthy";
      aqiColor = const Color(0xFF9C27B0);
    } else {
      aqiStatusText = isPersian ? "خطرناک" : "Hazardous";
      aqiColor = const Color(0xFF880E4F);
    }

    // نمایش عدد فارسی یا انگلیسی
    final String scoreText = isPersian
        ? toPersianDigits(aqiScore.toString())
        : aqiScore.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- HUMIDITY ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
            value: humidityText,
            icon: const WeatherAnimator(
              weatherType: WeatherType.rain,
              isSmallIcon: true,
              child: Icon(
                Icons.water_drop_outlined,
                color: Colors.lightBlueAccent,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // --- WIND ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "باد" : "Wind",
            value: "$windText\n$windUnit",
            icon: WeatherAnimator(
              weatherType: WeatherType.clear,
              isSmallIcon: true,
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
        ),
        const SizedBox(width: 12),

        // --- AQI (Correct Number) ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "کیفیت هوا" : "AQI",
            // اینجا هم متن وضعیت و هم عدد را نشان می‌دهیم
            value: "$aqiStatusText\n($scoreText)",
            isLongText: true,
            textColor: aqiColor, // رنگ متن عدد را رنگی می‌کنیم
            icon: WeatherAnimator(
              weatherType: WeatherType.fog,
              isSmallIcon: true,
              child: Icon(Icons.air, color: aqiColor, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBox({
    required BuildContext context,
    required String title,
    required String value,
    required Widget icon,
    bool isLongText = false,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 32, width: 32, child: Center(child: icon)),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isLongText ? 13 : 14,
                  // اگر رنگ خاصی دادیم (برای AQI) اعمال کن، وگرنه رنگ پیشفرض
                  color: textColor ?? theme.textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
