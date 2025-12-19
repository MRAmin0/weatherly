import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weatherly_app/config/config_reader.dart'; // 1. Import ConfigReader

import 'base_weather_service.dart';
import '../models/hourly_forecast.dart';

/// سرویس مخصوص OpenWeatherMap
class WeatherApiService implements BaseWeatherService {
  WeatherApiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  // 2. دریافت کلید از ConfigReader به جای مقدار ثابت
  String get _apiKey => ConfigReader.openWeatherApiKey;

  // چک کردن اینکه آیا کلید خوانده شده معتبر است (خالی نیست)
  bool get isConfigured => _apiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // ۱. جستجوی شهر (Geocoding - OpenWeatherMap)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> resolveCity(
    String query, {
    String lang = 'en',
  }) async {
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

    final uri = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': query,
      'limit': '$limit',
      'appid': _apiKey,
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];

      final data = json.decode(response.body) as List<dynamic>;
      final uniqueItems = <String, Map<String, dynamic>>{};

      for (var item in data) {
        final m = item as Map<String, dynamic>;
        final name = m['name'] as String;
        final lat = (m['lat'] as num).toDouble();
        final lon = (m['lon'] as num).toDouble();
        final country = m['country'] ?? '';
        final state = m['state'] ?? '';

        // Create a unique key based on name, country, and state.
        // We ignore coordinates to aggressively merge duplicates.
        final key = '${name.toLowerCase()}_${country}_$state';

        if (!uniqueItems.containsKey(key)) {
          uniqueItems[key] = {
            'name': name,
            'lat': lat,
            'lon': lon,
            'country': country,
            'state': state,
            'local_names': (m['local_names'] as Map<String, dynamic>?) ?? {},
          };
        }
      }

      return uniqueItems.values.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Geocoding error: $e');
      }
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // ۲. آب‌وهوای فعلی (Current Weather - /data/2.5/weather)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
    String lang = 'en',
  }) async {
    try {
      if (lat == null || lon == null) {
        if (cityName == null) return null;
        final city = await resolveCity(cityName, lang: lang);
        if (city == null) return null;
        lat = (city['lat'] as num).toDouble();
        lon = (city['lon'] as num).toDouble();
      }

      final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
        'lang': lang,
      });

      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Current weather status: ${response.statusCode}');
          print(response.body);
        }
        return null;
      }

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Current Weather Error: $e');
      }
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ۳. پیش‌بینی ۵ روزه / ساعتی (5 day / 3h forecast - /data/2.5/forecast)
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
    String lang = 'en',
  }) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Forecast status: ${response.statusCode}');
          print(response.body);
        }
        return const [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>?;

      return list ?? const [];
    } catch (e) {
      if (kDebugMode) {
        print('Forecast Error: $e');
      }
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // ۴. پیش‌بینی ساعتی برای View جدید
  // ---------------------------------------------------------------------------
  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 24,
    String lang = 'en',
  }) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Hourly forecast status: ${response.statusCode}');
          print(response.body);
        }
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>? ?? const [];
      final timezoneOffsetSeconds = (data['city']?['timezone'] as int?) ?? 0;

      final limit = min(count, list.length);
      final entries = <Map<String, dynamic>>[];

      for (var i = 0; i < limit; i++) {
        final item = list[i] as Map<String, dynamic>;
        entries.add(item);
      }

      return HourlyForecastResponse(
        entries: entries,
        timezoneOffsetSeconds: timezoneOffsetSeconds,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Hourly Error: $e');
      }
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ۵. کیفیت هوا (Air Quality) - اصلاح شده
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/air_pollution', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Air quality status: ${response.statusCode}');
          print(response.body);
        }
        return null;
      }

      // تغییر مهم: برگرداندن کل دیتای جیسون به جای پردازش آن
      // این باعث می‌شود ViewModel بتواند کلید 'list' را ببیند
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Air quality error: $e');
      }
      return null;
    }
  }
}
