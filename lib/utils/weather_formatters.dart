import 'package:intl/intl.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/models/weather_models.dart';
import 'package:flutter/material.dart';
// تابع انتخاب آیکون بر اساس نوع هوا
String weatherIconAsset(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clear':
      return 'assets/icons/clear.svg';
    case 'clouds':
      return 'assets/icons/clouds.svg';
    case 'rain':
      return 'assets/icons/rain.svg';
    case 'drizzle':
      return 'assets/icons/rain.svg'; // معمولا همان باران است
    case 'thunderstorm':
      return 'assets/icons/thunderstorm.svg';
    case 'snow':
      return 'assets/icons/snow.svg';
    case 'atmosphere': // برای ریزگرد و مه
      return 'assets/icons/clouds.svg'; // موقتاً ابر نشان می‌دهیم (یا اگر آیکون mist.svg دارید آن را بنویسید)
    default:
      return 'assets/icons/clear.svg';
  }
}

// تبدیل enum به رشته برای استفاده در تابع بالا
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

// ترجمه وضعیت هوا به فارسی
String translateWeatherDescription(String description, {required String lang}) {
  if (lang != 'fa') return description;

  // نگاشت ساده برای ترجمه کلمات کلیدی
  final lower = description.toLowerCase();
  if (lower.contains('clear')) return 'آسمان صاف';
  if (lower.contains('clouds')) return 'ابری';
  if (lower.contains('rain')) return 'بارانی';
  if (lower.contains('thunderstorm')) return 'رعد و برق';
  if (lower.contains('snow')) return 'برفی';
  if (lower.contains('mist')) return 'مه';
  if (lower.contains('smoke')) return 'دود';
  if (lower.contains('haze')) return 'غبار';
  if (lower.contains('dust')) return 'گرد و خاک';
  if (lower.contains('fog')) return 'مه غلیظ';
  if (lower.contains('sand')) return 'شن';
  if (lower.contains('ash')) return 'خاکستر';
  if (lower.contains('squall')) return 'بوران';
  if (lower.contains('tornado')) return 'گردباد';

  return description;
}

String formatLocalHour(DateTime utcTime, int offsetSeconds) {
  final localTime = utcTime.add(Duration(seconds: offsetSeconds));
  return DateFormat('HH:00').format(localTime);
}

String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}

Color statusColorForAqi(int aqi) {
  if (aqi <= 50) return const Color(0xFF00E400); // Good
  if (aqi <= 100) return const Color(0xFFFFD700); // Moderate (Gold -> slightly darker yellow)
  if (aqi <= 150) return const Color(0xFFFF7E00); // Unhealthy for Sensitive
  if (aqi <= 200) return const Color(0xFFFF0000); // Unhealthy
  if (aqi <= 300) return const Color(0xFF8F3F97); // Very Unhealthy
  return const Color(0xFF7E0023); // Hazardous
}

String labelForAqi(int aqi, AppLocalizations l10n) {
  if (aqi <= 25) return l10n.aqiStatusVeryGood;
  if (aqi <= 37) return l10n.aqiStatusGood;
  if (aqi <= 50) return l10n.aqiStatusModerate;
  if (aqi <= 90) return l10n.aqiStatusPoor;
  return l10n.aqiStatusVeryPoor;
}