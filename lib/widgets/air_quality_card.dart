import 'package:flutter/material.dart';

class AirQualityCard extends StatelessWidget {
  final int aqi; // Air Quality Index

  const AirQualityCard({
    super.key,
    required this.aqi,
  });

  @override
  Widget build(BuildContext context) {
    final isPersian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'fa';

    final _AqiInfo info = _mapAqiToInfo(aqi, isPersian);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          // دایره‌ی عدد AQI
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: info.color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                aqi > 0 ? aqi.toString() : (isPersian ? '—' : '—'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: info.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // توضیحات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                    theme.textTheme.bodyMedium?.color?.withAlpha(180),
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
      fa ? 'اطلاعات کیفیت هوا در دسترس نیست.'
          : 'Air quality data is not available.',
      Colors.grey,
    );
  } else if (aqi <= 50) {
    return _AqiInfo(
      fa ? 'خیلی خوب' : 'Good',
      fa ? 'کیفیت هوا عالی است.' : 'Air quality is considered satisfactory.',
      Colors.green,
    );
  } else if (aqi <= 100) {
    return _AqiInfo(
      fa ? 'قابل قبول' : 'Moderate',
      fa
          ? 'کیفیت هوا قابل قبول است؛ ممکن است برای گروه‌های حساس کمی نامطلوب باشد.'
          : 'Acceptable; some pollutants may be a concern for a small number of unusually sensitive people.',
      Colors.yellow.shade700,
    );
  } else if (aqi <= 150) {
    return _AqiInfo(
      fa ? 'ناسالم برای گروه‌های حساس' : 'Unhealthy for Sensitive Groups',
      fa
          ? 'افراد با مشکلات تنفسی و قلبی بهتر است فعالیت شدید در فضای باز را کاهش دهند.'
          : 'Sensitive groups should reduce prolonged or heavy outdoor exertion.',
      Colors.orange,
    );
  } else if (aqi <= 200) {
    return _AqiInfo(
      fa ? 'ناسالم' : 'Unhealthy',
      fa
          ? 'همه افراد ممکن است دچار علائم شوند؛ بهتر است فعالیت در فضای باز کاهش یابد.'
          : 'Everyone may begin to experience health effects; reduce outdoor activities.',
      Colors.red,
    );
  } else if (aqi <= 300) {
    return _AqiInfo(
      fa ? 'بسیار ناسالم' : 'Very Unhealthy',
      fa
          ? 'شرایط اضطراری؛ توصیه می‌شود تا حد امکان در فضای بسته بمانید.'
          : 'Health alert: everyone may experience more serious health effects.',
      Colors.purple,
    );
  } else {
    return _AqiInfo(
      fa ? 'خطرناک' : 'Hazardous',
      fa
          ? 'خطر جدی برای سلامت؛ از خروج غیرضروری از منزل خودداری کنید.'
          : 'Serious health effects; avoid outdoor activity.',
      Colors.brown,
    );
  }
}
