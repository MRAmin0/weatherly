// lib/widgets/home/details_row.dart
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

    // 1. Humidity Setup
    final humidityVal = isPersian
        ? "${toPersianDigits(current.humidity.toString())}٪"
        : "${current.humidity}%";

    // 2. Wind Setup & Animation Logic
    final double windSpeed = current.windSpeed;
    final windValString = windSpeed % 1 == 0
        ? windSpeed.toInt().toString()
        : windSpeed.toStringAsFixed(1);

    final windVal = isPersian ? toPersianDigits(windValString) : windValString;
    final windUnit = isPersian ? "km/h" : "km/h";

    // محاسبه سرعت چرخش توربین بر اساس سرعت باد
    // فرمول: پایه زمانی (مثلاً ۶۰۰۰ میلی‌ثانیه) تقسیم بر سرعت.
    // اگر سرعت ۵ باشه: ۱۲۰۰ میلی‌ثانیه (آرام)
    // اگر سرعت ۳۰ باشه: ۲۰۰ میلی‌ثانیه (خیلی سریع)
    // clamp برای جلوگیری از سرعت‌های غیرمنطقی
    final Duration? windDuration = windSpeed > 0.5
        ? Duration(milliseconds: (6000 / windSpeed).clamp(200, 5000).toInt())
        : null;

    // 3. AQI Setup
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

    // آیکون باد (توربین)
    Widget windIcon = SvgPicture.asset(
      'assets/icons/turbine.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
    );

    // اگر باد میوزد، انیمیت کن، اگر نه، ثابت نشان بده
    if (windDuration != null) {
      windIcon = WeatherAnimator(
        weatherType: WeatherType.clear, // نوع clear انیمیشن چرخش دارد
        customDuration: windDuration, // سرعت محاسبه شده
        child: windIcon,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HUMIDITY ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
            mainValue: humidityVal,
            subValue: " ",
            icon: const WeatherAnimator(
              weatherType: WeatherType.clear, // مهم نیست چون onPulse داریم
              onPulse: true, // فقط پالس ساده
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
            mainValue: windVal,
            subValue: windUnit,
            icon: windIcon, // آیکون داینامیک
          ),
        ),

        const SizedBox(width: 12),

        // --- AQI ---
        Expanded(
          child: _buildDetailBox(
            context: context,
            title: l10n.localeName == 'fa' ? "کیفیت هوا" : "AQI",
            mainValue: aqiVal,
            subValue: aqiStatusText,
            subValueColor: aqiColor,
            isAqi: true,
            // اینجا دیگه WeatherAnimator نداریم -> ثابت
            icon: Icon(Icons.air, color: aqiColor, size: 28),
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
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
