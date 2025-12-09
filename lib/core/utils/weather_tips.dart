import 'package:weatherly_app/data/models/current_weather.dart';
import 'package:weatherly_app/data/models/weather_type.dart';

/// Generates smart weather tips based on current conditions
class WeatherTips {
  /// Generate a tip based on current weather conditions
  static WeatherTip generateTip({
    required CurrentWeather weather,
    required bool isFarsi,
  }) {
    final temp = weather.temperature;
    final type = weather.weatherType;
    final humidity = weather.humidity;

    // Check for rain/precipitation first
    if (_isRainy(type)) {
      return WeatherTip(
        emoji: '☔',
        title: isFarsi ? 'هوای بارانی' : 'Rainy Weather',
        message: isFarsi ? 'چتر ببر با خودت!' : 'Take an umbrella with you!',
      );
    }

    // Check for snow
    if (type == WeatherType.snow) {
      return WeatherTip(
        emoji: '❄️',
        title: isFarsi ? 'برف می‌باره' : 'Snowing',
        message: isFarsi
            ? 'جاده‌ها لغزنده‌ست، مراقب باش!'
            : 'Roads may be slippery, be careful!',
      );
    }

    // Check for dust/sand storms
    if (_isDusty(type)) {
      return WeatherTip(
        emoji: '😷',
        title: isFarsi ? 'گرد و غبار' : 'Dusty Weather',
        message: isFarsi
            ? 'ماسک بزن و پنجره‌ها رو ببند!'
            : 'Wear a mask and close windows!',
      );
    }

    // Check for fog/mist
    if (_isFoggy(type)) {
      return WeatherTip(
        emoji: '🌫️',
        title: isFarsi ? 'هوا مه‌آلوده' : 'Foggy Weather',
        message: isFarsi
            ? 'دید کم است، آهسته رانندگی کن!'
            : 'Low visibility, drive slowly!',
      );
    }

    // Check for extreme cold
    if (temp < 0) {
      return WeatherTip(
        emoji: '🥶',
        title: isFarsi ? 'سرمای شدید' : 'Freezing Cold',
        message: isFarsi
            ? 'خیلی سرده! لباس چند لایه بپوش.'
            : 'It\'s freezing! Wear multiple layers.',
      );
    }

    // Check for cold weather
    if (temp < 10) {
      return WeatherTip(
        emoji: '🧣',
        title: isFarsi ? 'هوا سرده' : 'Cold Weather',
        message: isFarsi ? 'لباس گرم بپوش!' : 'Dress warmly!',
      );
    }

    // Check for extreme heat
    if (temp > 35) {
      return WeatherTip(
        emoji: '🥵',
        title: isFarsi ? 'گرمای شدید' : 'Extreme Heat',
        message: isFarsi
            ? 'آب زیاد بخور و از آفتاب دوری کن!'
            : 'Stay hydrated and avoid direct sun!',
      );
    }

    // Check for hot & sunny weather
    if (temp > 25 && type == WeatherType.clear) {
      return WeatherTip(
        emoji: '🕶️',
        title: isFarsi ? 'آفتابی و گرم' : 'Sunny & Warm',
        message: isFarsi
            ? 'عینک آفتابی بزن و کرم ضد آفتاب یادت نره!'
            : 'Wear sunglasses and don\'t forget sunscreen!',
      );
    }

    // Check for humid weather
    if (humidity > 80 && temp > 20) {
      return WeatherTip(
        emoji: '💧',
        title: isFarsi ? 'رطوبت بالا' : 'High Humidity',
        message: isFarsi
            ? 'هوا شرجیه، لباس سبک بپوش!'
            : 'It\'s humid, wear light clothes!',
      );
    }

    // Check for windy weather
    if (weather.windSpeed > 10) {
      return WeatherTip(
        emoji: '💨',
        title: isFarsi ? 'باد شدید' : 'Windy',
        message: isFarsi
            ? 'باد می‌زنه، کلاه و وسایل سبک رو محکم بگیر!'
            : 'It\'s windy, secure loose items!',
      );
    }

    // Default: Nice weather
    if (type == WeatherType.clear) {
      return WeatherTip(
        emoji: '☀️',
        title: isFarsi ? 'هوای عالی' : 'Great Weather',
        message: isFarsi
            ? 'هوا خوبه، روز خوبی داشته باشی!'
            : 'Weather is nice, have a great day!',
      );
    }

    // Cloudy or other conditions
    return WeatherTip(
      emoji: '🌤️',
      title: isFarsi ? 'وضعیت هوا' : 'Weather Update',
      message: isFarsi ? 'روز خوبی داشته باشی!' : 'Have a nice day!',
    );
  }

  /// Generate a morning summary message
  static String generateMorningSummary({
    required CurrentWeather weather,
    required bool isFarsi,
  }) {
    final temp = weather.temperature.round();
    final tip = generateTip(weather: weather, isFarsi: isFarsi);

    if (isFarsi) {
      return 'دمای امروز: $temp°\n${tip.emoji} ${tip.message}';
    } else {
      return 'Today\'s temperature: $temp°\n${tip.emoji} ${tip.message}';
    }
  }

  static bool _isRainy(WeatherType type) {
    return type == WeatherType.rain ||
        type == WeatherType.drizzle ||
        type == WeatherType.thunderstorm;
  }

  static bool _isDusty(WeatherType type) {
    return type == WeatherType.sand ||
        type == WeatherType.dust ||
        type == WeatherType.ash;
  }

  static bool _isFoggy(WeatherType type) {
    return type == WeatherType.fog ||
        type == WeatherType.mist ||
        type == WeatherType.haze ||
        type == WeatherType.smoke;
  }
}

/// Data class for a weather tip
class WeatherTip {
  final String emoji;
  final String title;
  final String message;

  const WeatherTip({
    required this.emoji,
    required this.title,
    required this.message,
  });

  /// Get full notification title with emoji
  String get fullTitle => '$emoji $title';

  @override
  String toString() => '$emoji $title: $message';
}
