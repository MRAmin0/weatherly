import '../models/weather_type.dart';

/// تبدیل اعداد انگلیسی به فارسی
String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}

/// تبدیل وضعیت هوا از متن API به Enum داخلی برنامه
WeatherType mapWeatherType(String main) {
  switch (main.toLowerCase()) {
    case 'thunderstorm':
      return WeatherType.thunderstorm;
    case 'drizzle':
      return WeatherType.drizzle;
    case 'rain':
      return WeatherType.rain;
    case 'snow':
      return WeatherType.snow;
    case 'clear':
      return WeatherType.clear;
    case 'clouds':
      return WeatherType.clouds;

    // تمام این موارد جزو وضعیت‌های جوی خاص (Atmosphere) هستند
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust': // ریزگرد
    case 'fog':
    case 'sand':
    case 'ash':
    case 'squall':
    case 'tornado':
      return WeatherType.atmosphere;

    default:
      return WeatherType.clear;
  }
}
