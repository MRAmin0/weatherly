import 'package:flutter/material.dart'; // برای Color
import 'package:intl/intl.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import '../models/weather_type.dart';

// --- انتخاب آیکون بر اساس نوع هوا ---
String weatherIconAsset(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clear':
      return 'assets/icons/clear.svg';
    case 'clouds':
      return 'assets/icons/clouds.svg';
    case 'rain':
      return 'assets/icons/rain.svg';
    case 'drizzle':
      return 'assets/icons/drizzle.svg';
    case 'thunderstorm':
      return 'assets/icons/thunderstorm.svg';
    case 'snow':
      return 'assets/icons/snow.svg';
    case 'atmosphere': // مه، غبار، ریزگرد
      return 'assets/icons/atmosphere.svg';
    default:
      return 'assets/icons/clear.svg';
  }
}

// --- تبدیل Enum به رشته برای API (اگر هنوز استفاده شود) ---
String weatherTypeToApiName(WeatherType type) {
  switch (type) {
    case WeatherType.clear:
      return 'clear';
    case WeatherType.clouds:
      return 'clouds';
    case WeatherType.rain:
      return 'rain';
    case WeatherType.drizzle:
      return 'drizzle';
    case WeatherType.thunderstorm:
      return 'thunderstorm';
    case WeatherType.snow:
      return 'snow';
    case WeatherType.atmosphere:
      return 'atmosphere';
    default:
      return 'unknown';
  }
}

// --- ترجمه توضیحات آب‌وهوا به فارسی ---
String translateWeatherDescription(String description, {required String lang}) {
  if (lang != 'fa') return description;

  final lower = description.toLowerCase();

  // ترجمه‌های استاندارد Open-Meteo و کلمات کلیدی رایج
  if (lower.contains('clear')) return 'آسمان صاف';
  if (lower.contains('mainly clear')) return 'غالباً صاف';
  if (lower.contains('partly cloudy')) return 'نیمه ابری';
  if (lower.contains('overcast')) return 'تمام ابری';
  if (lower.contains('clouds')) return 'ابری';

  if (lower.contains('fog')) return 'مه‌آلود';
  if (lower.contains('rime fog')) return 'مه یخ‌زده';
  if (lower.contains('mist')) return 'مه رقیق';
  if (lower.contains('haze')) return 'غبارآلود';
  if (lower.contains('dust')) return 'ریزگرد';
  if (lower.contains('sand')) return 'طوفان شن';
  if (lower.contains('smoke')) return 'دود';
  if (lower.contains('ash')) return 'خاکستر آتشفشانی';

  if (lower.contains('drizzle')) return 'باران ریز';
  if (lower.contains('freezing drizzle')) return 'باران ریز یخ‌زده';

  if (lower.contains('rain showers')) return 'رگبار باران';
  if (lower.contains('freezing rain')) return 'باران یخ‌زده';
  if (lower.contains('rain')) return 'بارانی';

  if (lower.contains('snow showers')) return 'رگبار برف';
  if (lower.contains('snow grains')) return 'دانه برف';
  if (lower.contains('snow')) return 'برفی';

  if (lower.contains('thunderstorm')) return 'رعد و برق';
  if (lower.contains('hail')) return 'تگرگ';

  return description; // اگر ترجمه‌ای پیدا نشد، متن اصلی را برگردان
}

// --- فرمت ساعت ---
String formatLocalHour(DateTime utcTime, int offsetSeconds) {
  final localTime = utcTime.add(Duration(seconds: offsetSeconds));
  return DateFormat('HH:00').format(localTime);
}

// --- تبدیل اعداد انگلیسی به فارسی ---
String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}

// --- رنگ شاخص کیفیت هوا (AQI) ---
Color statusColorForAqi(int aqi) {
  if (aqi <= 50) return const Color(0xFF00E400); // سبز (خوب)
  if (aqi <= 100) return const Color(0xFFFFD700); // زرد (متوسط)
  if (aqi <= 150) return const Color(0xFFFF7E00); // نارنجی (ناسالم برای حساس)
  if (aqi <= 200) return const Color(0xFFFF0000); // قرمز (ناسالم)
  if (aqi <= 300) return const Color(0xFF8F3F97); // بنفش (بسیار ناسالم)
  return const Color(0xFF7E0023); // زرشکی (خطرناک)
}

// --- متن وضعیت شاخص کیفیت هوا ---
String labelForAqi(int aqi, AppLocalizations l10n) {
  if (aqi <= 50) return l10n.aqiStatusVeryGood; // 0-50
  if (aqi <= 100) return l10n.aqiStatusGood; // 51-100
  if (aqi <= 150) return l10n.aqiStatusModerate; // 101-150
  if (aqi <= 200) return l10n.aqiStatusPoor; // 151-200
  return l10n.aqiStatusVeryPoor; // 200+
}
