import 'package:flutter/material.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';

class AirQualityCard extends StatelessWidget {
  final int aqi;

  const AirQualityCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    final isPersian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'fa';
    final info = _mapAqiToInfo(aqi, isPersian);

    final String aqiDisplay = isPersian
        ? toPersianDigits(aqi.toString())
        : aqi.toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: info.color.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                aqi > 0 ? aqiDisplay : '—',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: info.color,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: info.color,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
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
      fa ? 'اطلاعات در دسترس نیست.' : 'No data available.',
      Colors.grey[400]!,
    );
  } else if (aqi <= 50) {
    return _AqiInfo(
      fa ? 'پاک' : 'Good',
      fa ? 'کیفیت هوا عالی است.' : 'Air quality is great.',
      const Color(0xFFC0FF3E),
    );
  } else if (aqi <= 100) {
    return _AqiInfo(
      fa ? 'سالم' : 'Moderate',
      fa ? 'کیفیت هوا قابل قبول است.' : 'Air quality is okay.',
      const Color(0xFFF0E68C),
    );
  } else if (aqi <= 150) {
    return _AqiInfo(
      fa ? 'ناسالم برای حساس‌ها' : 'Sensitive Groups',
      fa ? 'مراقب کودکان و سالمندان باشید.' : 'Watch out for sensitive groups.',
      const Color(0xFFFFA500),
    );
  } else if (aqi <= 200) {
    return _AqiInfo(
      fa ? 'ناسالم' : 'Unhealthy',
      fa ? 'عوارض احتمالی برای همه.' : 'Health effects for all.',
      const Color(0xFFFF4500),
    );
  } else if (aqi <= 300) {
    return _AqiInfo(
      fa ? 'بسیار ناسالم' : 'Very Unhealthy',
      fa ? 'وضعیت اضطراری.' : 'Emergency situation.',
      const Color(0xFF9370DB),
    );
  } else {
    return _AqiInfo(
      fa ? 'خطرناک' : 'Hazardous',
      fa ? 'خطر جدی برای سلامت.' : 'Serious health risk.',
      const Color(0xFFFF1493),
    );
  }
}
