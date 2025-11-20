import 'package:flutter/material.dart';

import '../models/weather_models.dart';

String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '٫'];

  var output = input;
  for (var i = 0; i < english.length; i++) {
    output = output.replaceAll(english[i], persian[i]);
  }

  return output;
}

String formatLocalHour(DateTime utc, int offsetSeconds) {
  final local = utc.add(Duration(seconds: offsetSeconds));
  final hour = local.hour.toString().padLeft(2, '0');
  return '$hour:00';
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
    default:
      return 'unknown';
  }
}

String translateWeather(WeatherType type) {
  switch (type) {
    case WeatherType.clear:
      return 'صاف';
    case WeatherType.clouds:
      return 'ابری';
    case WeatherType.rain:
    case WeatherType.drizzle:
    case WeatherType.thunderstorm:
      return 'بارانی';
    case WeatherType.snow:
      return 'برفی';
    default:
      return 'نامشخص';
  }
}

String translateWeatherDescription(String weatherMain, {String lang = 'fa'}) {
  final normalized = weatherMain.toLowerCase();
  if (lang == 'fa') {
    switch (normalized) {
      case 'clear':
        return 'صاف';
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        return 'ابری';
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
      case 'shower rain':
        return 'بارانی';
      case 'drizzle':
      case 'light intensity drizzle':
        return 'باران نم نم';
      case 'thunderstorm':
      case 'thunderstorm with light rain':
      case 'thunderstorm with rain':
      case 'thunderstorm with heavy rain':
        return 'رعد و برق';
      case 'snow':
      case 'light snow':
      case 'heavy snow':
        return 'برفی';
      case 'mist':
      case 'fog':
        return 'مه‌آلود';
      default:
        return 'نامشخص';
    }
  } else {
    switch (normalized) {
      case 'clear':
        return 'Clear sky';
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        return 'Cloudy';
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
      case 'shower rain':
        return 'Rainy';
      case 'drizzle':
      case 'light intensity drizzle':
        return 'Drizzle';
      case 'thunderstorm':
      case 'thunderstorm with light rain':
      case 'thunderstorm with rain':
      case 'thunderstorm with heavy rain':
        return 'Thunderstorm';
      case 'snow':
      case 'light snow':
      case 'heavy snow':
        return 'Snowy';
      case 'mist':
      case 'fog':
        return 'Foggy';
      default:
        return 'Unknown';
    }
  }
}

String weatherIconAsset(String weather) {
  switch (weather) {
    case 'Clear':
      return 'assets/icons/sun.svg';
    case 'Clouds':
      return 'assets/icons/cloud.svg';
    case 'Rain':
    case 'Drizzle':
      return 'assets/icons/rain.svg';
    case 'Thunderstorm':
      return 'assets/icons/storm.svg';
    case 'Snow':
      return 'assets/icons/snow.svg';
    default:
      return 'assets/icons/cloud.svg';
  }
}

Color statusColorForAqi(int aqi) {
  // رنگ‌های استاندارد US AQI
  if (aqi <= 50) {
    return const Color(0xFF00E400); // Good - سبز روشن
  } else if (aqi <= 100) {
    return const Color(0xFFFFC107); // Moderate - زرد (تیره‌تر برای لایت مود)
  } else if (aqi <= 150) {
    return const Color(0xFFFF7E00); // Unhealthy for Sensitive Groups - نارنجی
  } else if (aqi <= 200) {
    return const Color(0xFFFF0000); // Unhealthy - قرمز
  } else if (aqi <= 300) {
    return const Color(0xFF8F3F97); // Very Unhealthy - بنفش
  } else {
    return const Color(0xFF7E0023); // Hazardous - قهوه‌ای/زرشکی
  }
}

String labelForAqi(int aqi) {
  // بر اساس استاندارد US AQI
  if (aqi <= 50) {
    return 'پاک'; // Good
  } else if (aqi <= 100) {
    return 'متوسط'; // Moderate
  } else if (aqi <= 150) {
    return 'ناسالم برای گروه‌های حساس'; // Unhealthy for Sensitive Groups
  } else if (aqi <= 200) {
    return 'ناسالم'; // Unhealthy
  } else if (aqi <= 300) {
    return 'بسیار ناسالم'; // Very Unhealthy
  } else {
    return 'خطرناک'; // Hazardous
  }
}
