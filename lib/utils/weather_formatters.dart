import 'package:intl/intl.dart';
import '../models/weather_type.dart';

/// فرمت کردن ساعت محلی
String formatLocalHour(DateTime time, int offsetSeconds) {
  // برای سادگی فعلاً فقط ساعت را نشان می‌دهیم.
  // اگر نیاز به تنظیم دقیق تایم‌زون شهر بود، باید offsetSeconds را اعمال کنیم.
  // اما چون dt_txt معمولاً زمان پیش‌بینی است، همین کافی است.
  return DateFormat('HH:mm').format(time);
}

/// آدرس فایل آیکون بر اساس وضعیت هوا
String weatherIconAsset(String main) {
  switch (main.toLowerCase()) {
    case 'thunderstorm':
      return 'assets/icons/thunderstorm.svg';
    case 'drizzle':
    case 'rain':
      return 'assets/icons/rain.svg';
    case 'snow':
      return 'assets/icons/snow.svg';
    case 'clear':
      return 'assets/icons/clear.svg';
    case 'clouds':
      return 'assets/icons/clouds.svg';
    case 'mist':
      return 'assets/icons/mist.svg';
    case 'fog':
    case 'haze':
    case 'smoke':
      return 'assets/icons/fog.svg';
    case 'dust':
    case 'sand':
    case 'ash':
    case 'squall':
    case 'tornado':
      return 'assets/icons/dust.svg';
    default:
      return 'assets/icons/clear.svg';
  }
}

String weatherTypeToApiName(WeatherType type) {
  switch (type) {
    case WeatherType.clear:
      return 'Clear';
    case WeatherType.clouds:
      return 'Clouds';
    case WeatherType.rain:
      return 'Rain';
    case WeatherType.drizzle:
      return 'Drizzle';
    case WeatherType.thunderstorm:
      return 'Thunderstorm';
    case WeatherType.snow:
      return 'Snow';
    case WeatherType.mist:
      return 'Mist';
    case WeatherType.fog:
      return 'Fog';
    case WeatherType.atmosphere:
      return 'Dust';
    default:
      return 'Clear';
  }
}

/// ترجمه فارسی وضعیت هوا
String translateWeatherDescription(String description, {String lang = 'en'}) {
  if (lang != 'fa') return description;

  final lower = description.toLowerCase();
  if (lower.contains('clear')) return 'آسمان صاف';
  if (lower.contains('clouds')) return 'ابری';
  if (lower.contains('rain')) return 'بارانی';
  if (lower.contains('snow')) return 'برفی';
  if (lower.contains('drizzle')) return 'نم‌نم باران';
  if (lower.contains('thunderstorm')) return 'رعد و برق';
  if (lower.contains('mist')) return 'مه رقیق';
  if (lower.contains('haze')) return 'غبارآلود';
  if (lower.contains('dust')) return 'ریزگرد';
  if (lower.contains('fog')) return 'مه غلیظ';
  if (lower.contains('smoke')) return 'دود';

  return description;
}
