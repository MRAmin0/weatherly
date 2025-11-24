// lib/models/weather_type.dart

/// نوع کلی آب‌وهوا که تو کل برنامه استفاده می‌کنیم
enum WeatherType {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  // --- Added these new types ---
  mist,
  fog,
  windy,
  unknown,
  atmosphere,
}

/// تابع کمکی: تبدیل رشته‌ی API (مثل "Rain") به enum
WeatherType mapWeatherType(String? main) {
  if (main == null) return WeatherType.unknown;

  switch (main.toLowerCase()) {
    case 'clear':
      return WeatherType.clear;
    case 'clouds':
      return WeatherType.clouds;
    case 'rain':
      return WeatherType.rain;
    case 'snow':
      return WeatherType.snow;
    case 'drizzle':
      return WeatherType.drizzle;
    case 'thunderstorm':
      return WeatherType.thunderstorm;
    case 'mist':
    case 'fog':
    case 'smoke':
    case 'dust':
    case 'haze':
    case 'sand':
    case 'ash':
    case 'squall':
    case 'tornado':
    case 'atmosphere':
      return WeatherType.atmosphere;
    default:
      return WeatherType.unknown;
  }
}

/// برای اینکه کدی که الان در `current_weather.dart` نوشتی
/// و از `WeatherTypeX.fromMain(...)` استفاده می‌کند، ارور ندهد
class WeatherTypeX {
  static WeatherType fromMain(String? main) {
    return mapWeatherType(main);
  }
}
