import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// این خط بسیار مهم است تا برنامه مدل‌ها را بشناسد و ارور ندهد
import 'package:weatherly_app/models/weather_models.dart';

class WeatherApiService {
  // دیگر نیازی به apiKey نیست
  WeatherApiService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  // سرویس Open-Meteo همیشه آماده به کار است
  bool get isConfigured => true;

  // ---------------------------------------------------------------------------
  // ۱. جستجوی شهر (Geocoding)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> resolveCity(String query, {String lang = 'en'}) async {
    final results = await fetchCitySuggestions(query, limit: 1, lang: lang);
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
      String query, {
        int limit = 10,
        String lang = 'en',
      }) async {
    if (query.trim().isEmpty) return const [];

    // استفاده از API جستجوی Open-Meteo
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=$limit&language=$lang&format=json',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (!data.containsKey('results')) return const [];

      final results = (data['results'] as List).cast<Map<String, dynamic>>();

      // استانداردسازی خروجی برای استفاده در برنامه
      return results.map((item) {
        return {
          'name': item['name'],
          'lat': item['latitude'],
          'lon': item['longitude'],
          'country': item['country_code'] ?? '',
          'state': item['admin1'] ?? '',
          'local_names': {'fa': item['name'], 'en': item['name']},
        };
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // ۲. دریافت آب‌وهوای فعلی (Current Weather)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
    String lang = 'en',
  }) async {
    // اگر مختصات نداریم، ابتدا نام شهر را جستجو می‌کنیم
    if (lat == null || lon == null) {
      if (cityName == null) return null;
      final city = await resolveCity(cityName, lang: lang);
      if (city == null) return null;
      lat = city['lat'];
      lon = city['lon'];
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,is_day,weather_code,wind_speed_10m&timezone=auto',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      final current = data['current'];

      // تبدیل فرمت Open-Meteo به فرمت OWM (برای جلوگیری از تغییر در بقیه فایل‌ها)
      return {
        'coord': {'lat': lat, 'lon': lon},
        'main': {
          'temp': current['temperature_2m'],
          'humidity': current['relative_humidity_2m'],
        },
        'wind': {
          // تبدیل کیلومتر بر ساعت به متر بر ثانیه (چون برنامه شما m/s ذخیره می‌کند)
          'speed': (current['wind_speed_10m'] as num).toDouble() / 3.6,
        },
        'weather': [
          {
            'main': _wmoToMain(current['weather_code']),
            'description': _wmoToDesc(current['weather_code']),
          }
        ],
        'name': cityName ?? 'Unknown',
      };
    } catch (e) {
      if (kDebugMode) print('Current Weather Error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ۳. دریافت پیش‌بینی ۷ روزه (Daily Forecast)
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
    String lang = 'en',
  }) async {
    // درخواست پیش‌بینی برای ۷ روز
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,relative_humidity_2m_mean&timezone=auto&forecast_days=7',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];
      final data = json.decode(response.body);
      final daily = data['daily'];

      final List<dynamic> mappedList = [];
      final count = (daily['time'] as List).length;

      for (int i = 0; i < count; i++) {
        mappedList.add({
          // ساعت را روی ۱۲ ظهر تنظیم می‌کنیم
          'dt_txt': '${daily['time'][i]} 12:00:00',
          'main': {
            // میانگین دما برای نمایش کلی
            'temp': (daily['temperature_2m_max'][i] + daily['temperature_2m_min'][i]) / 2,
            'temp_max': daily['temperature_2m_max'][i],
            'temp_min': daily['temperature_2m_min'][i],
            'humidity': daily['relative_humidity_2m_mean']?[i] ?? 50,
          },
          'weather': [
            {
              'main': _wmoToMain(daily['weather_code'][i]),
              'description': _wmoToDesc(daily['weather_code'][i]),
            }
          ],
          'wind': {
            'speed': (daily['wind_speed_10m_max'][i] as num).toDouble() / 3.6,
          }
        });
      }
      return mappedList;
    } catch (e) {
      if (kDebugMode) print('Forecast Error: $e');
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // ۴. دریافت پیش‌بینی ساعتی (Hourly Forecast)
  // ---------------------------------------------------------------------------
  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 24,
    String lang = 'en',
  }) async {
    // دریافت پیش‌بینی ساعتی برای ۴۸ ساعت آینده
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,weather_code&timezone=GMT&forecast_days=2',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);

      final hourly = data['hourly'];
      final offsetSeconds = data['utc_offset_seconds'] as int? ?? 0;

      final List<Map<String, dynamic>> entries = [];
      final timeList = hourly['time'] as List;

      // محدود کردن تعداد به اندازه نیاز
      final limit = timeList.length < count ? timeList.length : count;

      for (int i = 0; i < limit; i++) {
        String rawTime = timeList[i].toString();
        // تبدیل فرمت زمان به فرمت استاندارد SQL-like
        if (!rawTime.contains(' ')) rawTime = '${rawTime.replaceAll('T', ' ')}:00';

        entries.add({
          'dt_txt': rawTime,
          'main': {
            'temp': hourly['temperature_2m'][i],
          },
          'weather': [
            {
              'main': _wmoToMain(hourly['weather_code'][i]),
              'description': _wmoToDesc(hourly['weather_code'][i]),
            }
          ]
        });
      }

      return HourlyForecastResponse(
        entries: entries,
        timezoneOffsetSeconds: offsetSeconds,
      );
    } catch (e) {
      if (kDebugMode) print('Hourly Error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ۵. دریافت کیفیت هوا (Air Quality)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final current = data['current'];

      return {
        'aqi': (current['us_aqi'] as num?)?.toInt() ?? 0,
      };
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // توابع کمکی: تبدیل کدهای WMO به متن
  // ---------------------------------------------------------------------------

  String _wmoToMain(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Clouds';
    if (code == 45 || code == 48) return 'Atmosphere'; // مه و غبار
    if (code >= 51 && code <= 57) return 'Drizzle';
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) return 'Rain';
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) return 'Snow';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  String _wmoToDesc(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: return 'Mainly clear';
      case 2: return 'Partly cloudy';
      case 3: return 'Overcast';
      case 45: return 'Fog';
      case 48: return 'Depositing rime fog';
      case 51: return 'Light drizzle';
      case 53: return 'Moderate drizzle';
      case 55: return 'Dense drizzle';
      case 56: return 'Light freezing drizzle';
      case 57: return 'Dense freezing drizzle';
      case 61: return 'Slight rain';
      case 63: return 'Moderate rain';
      case 65: return 'Heavy rain';
      case 66: return 'Light freezing rain';
      case 67: return 'Heavy freezing rain';
      case 71: return 'Slight snow fall';
      case 73: return 'Moderate snow fall';
      case 75: return 'Heavy snow fall';
      case 77: return 'Snow grains';
      case 80: return 'Slight rain showers';
      case 81: return 'Moderate rain showers';
      case 82: return 'Violent rain showers';
      case 85: return 'Slight snow showers';
      case 86: return 'Heavy snow showers';
      case 95: return 'Thunderstorm';
      case 96: return 'Thunderstorm with slight hail';
      case 99: return 'Thunderstorm with heavy hail';
      default: return 'Unknown';
    }
  }
}