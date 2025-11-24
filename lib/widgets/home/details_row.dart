import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/models/weather_type.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/widgets/animations/weather_animator.dart';

class DetailsRow extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const DetailsRow({super.key, required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final current = viewModel.currentWeather;
    // اگر اطلاعات آب و هوا هنوز لود نشده، چیزی نشان نده
    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';

    // --- Humidity Data ---
    final humidityText = isPersian
        ? toPersianDigits("${current.humidity}%")
        : "${current.humidity}%";

    // --- Wind Data ---
    final windText = isPersian
        ? toPersianDigits(current.windSpeed.toString())
        : current.windSpeed.toString();
    final windUnit = isPersian ? "کیلومتر/ساعت" : "km/h";

    // --- AQI Data ---
    // خواندن مقدار کیفیت هوا از ویومدل
    final int aqiValue = viewModel.aqi ?? 0;
    final aqiText = isPersian
        ? toPersianDigits(aqiValue.toString())
        : aqiValue.toString();

    // تعیین رنگ و آیکون بر اساس میزان آلودگی (اختیاری برای زیبایی بیشتر)
    Color aqiColor = Colors.greenAccent;
    if (aqiValue > 100) aqiColor = Colors.orangeAccent;
    if (aqiValue > 150) aqiColor = Colors.redAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ---------------- HUMIDITY CARD ----------------
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

        const SizedBox(width: 12), // فاصله بین کارت‌ها
        // ---------------- WIND CARD ----------------
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

        const SizedBox(width: 12), // فاصله بین کارت‌ها
        // ---------------- AIR QUALITY CARD ----------------
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "کیفیت هوا" : "AQI",
            value: aqiText,
            icon: WeatherAnimator(
              weatherType: WeatherType.fog,
              isSmallIcon: true,
              child: Icon(
                Icons.air,
                color: aqiColor, // تغییر رنگ بر اساس شدت آلودگی
                size: 28,
              ),
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
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
