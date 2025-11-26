import 'package:flutter/material.dart';
import 'package:weatherly_app/utils/city_utils.dart'; // برای تبدیل اعداد به فارسی

class AirQualityCard extends StatelessWidget {
  final int aqi; // این عدد باید بین ۰ تا ۵۰۰ باشد

  const AirQualityCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    final isPersian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'fa';

    final _AqiInfo info = _mapAqiToInfo(aqi, isPersian);
    final theme = Theme.of(context);

    // تبدیل عدد به فارسی در صورت نیاز
    final String aqiDisplay = isPersian
        ? toPersianDigits(aqi.toString())
        : aqi.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        // سایه ملایم برای زیبایی بیشتر
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // دایره‌ی عدد AQI
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: info.color.withValues(
                alpha: 0.15,
              ), // پس‌زمینه کمرنگ هم‌رنگ شاخص
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                aqi > 0 ? aqiDisplay : '—',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: info.color,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // توضیحات متنی
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: info.color, // تیتر را هم‌رنگ وضعیت کردیم
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    height: 1.2, // فاصله بین خطوط برای خوانایی بهتر
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AqiInfo {
  final String title;
  final String subtitle;
  final Color color;

  const _AqiInfo(this.title, this.subtitle, this.color);
}

_AqiInfo _mapAqiToInfo(int? rawAqi, bool fa) {
  final aqi = rawAqi ?? 0;

  if (aqi <= 0) {
    return _AqiInfo(
      fa ? 'نامشخص' : 'Unknown',
      fa
          ? 'اطلاعات کیفیت هوا در دسترس نیست.'
          : 'Air quality data is not available.',
      Colors.grey,
    );
  } else if (aqi <= 50) {
    return _AqiInfo(
      fa ? 'پاک' : 'Good',
      fa
          ? 'کیفیت هوا عالی است و هیچ خطری ندارد.'
          : 'Air quality is satisfactory.',
      const Color(0xFF8BC34A), // سبز
    );
  } else if (aqi <= 100) {
    return _AqiInfo(
      fa ? 'سالم' : 'Moderate',
      fa
          ? 'کیفیت هوا قابل قبول است اما برای افراد بسیار حساس ممکن است مناسب نباشد.'
          : 'Air quality is acceptable.',
      const Color(0xFFFFEB3B), // زرد (کمی تیره‌تر برای خوانایی روی سفید)
    );
  } else if (aqi <= 150) {
    return _AqiInfo(
      fa ? 'ناسالم برای گروه‌های حساس' : 'Unhealthy for Sensitive Groups',
      fa
          ? 'افراد مبتلا به بیماری‌های قلبی یا ریوی، سالمندان و کودکان باید فعالیت سنگین را کاهش دهند.'
          : 'Sensitive groups should reduce outdoor exertion.',
      const Color(0xFFFF9800), // نارنجی
    );
  } else if (aqi <= 200) {
    return _AqiInfo(
      fa ? 'ناسالم' : 'Unhealthy',
      fa
          ? 'همه افراد ممکن است دچار عوارض شوند؛ فعالیت خارج از منزل را کاهش دهید.'
          : 'Everyone may begin to experience health effects.',
      const Color(0xFFF44336), // قرمز
    );
  } else if (aqi <= 300) {
    return _AqiInfo(
      fa ? 'بسیار ناسالم' : 'Very Unhealthy',
      fa
          ? 'وضعیت اضطراری؛ از منزل خارج نشوید.'
          : 'Health alert: everyone may experience serious health effects.',
      const Color(0xFF9C27B0), // بنفش
    );
  } else {
    return _AqiInfo(
      fa ? 'خطرناک' : 'Hazardous',
      fa
          ? 'خطر جدی برای سلامت تمام افراد جامعه.'
          : 'Serious health effects; avoid outdoor activity.',
      const Color(0xFF880E4F), // زرشکی
    );
  }
}
