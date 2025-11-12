import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';
import '../utils/city_utils.dart';

class WeatherApiService {
  WeatherApiService({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _httpClient;

  bool get isConfigured => apiKey != 'API_KEY_NOT_FOUND';

  Future<Map<String, dynamic>?> resolveCity(String query) async {
    final results = await fetchCitySuggestions(query, limit: 5);
    if (results.isEmpty) return null;
    return sortAndDeduplicateCities(results, query, maxItems: 1).first;
  }

  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (!isConfigured) return const [];
    final lang = isPersianText(query) ? 'fa' : 'en';
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$encoded&limit=$limit&appid=$apiKey&lang=$lang',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];

      final data = await _decodeJson<List<dynamic>>(response.body);
      if (data == null) return const [];

      final mapped = data.cast<Map<String, dynamic>>();
      return sortAndDeduplicateCities(mapped, query, maxItems: limit);
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    if (!isConfigured) return null;
    Uri? uri;

    if (lat != null && lon != null) {
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      );
    } else if (cityName != null && cityName.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(cityName.trim());
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$encoded&appid=$apiKey&units=metric',
      );
    }

    if (uri == null) return null;

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      return _decodeJson<Map<String, dynamic>>(response.body);
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
  }) async {
    if (!isConfigured) return const [];

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      return (data?['list'] as List<dynamic>? ?? const []);
    } catch (_) {
      return const [];
    }
  }

  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 8,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=$count',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      final entries =
          List<Map<String, dynamic>>.from(data?['list'] ?? const []);
      final timezone =
          (data?['city']?['timezone'] as int?) ?? 0;
      return HourlyForecastResponse(
        entries: entries,
        timezoneOffsetSeconds: timezone,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      final item = data?['list']?[0] as Map<String, dynamic>?;
      if (item == null) return null;
      
      final aqiIndex = item['main']?['aqi'] as int?;
      final components = item['components'] as Map<String, dynamic>?;
      
      if (aqiIndex == null) return null;
      
      // محاسبه AQI واقعی از PM2.5 (معمولاً دقیق‌ترین شاخص)
      final pm25 = (components?['pm2_5'] as num?)?.toDouble();
      int? realAqi;
      
      if (pm25 != null) {
        realAqi = _calculateAqiFromPm25(pm25);
      } else {
        // اگر PM2.5 موجود نبود، از index به محدوده تبدیل می‌کنیم
        realAqi = _indexToAqiRange(aqiIndex);
      }
      
      return {
        'index': aqiIndex,
        'aqi': realAqi,
        'components': components,
      };
    } catch (_) {
      return null;
    }
  }

  int _calculateAqiFromPm25(double pm25) {
    // فرمول محاسبه AQI از PM2.5 بر اساس استاندارد US EPA
    if (pm25 <= 12.0) {
      return ((50.0 / 12.0) * pm25).round();
    } else if (pm25 <= 35.4) {
      return (((100.0 - 51.0) / (35.4 - 12.1)) * (pm25 - 12.1) + 51.0).round();
    } else if (pm25 <= 55.4) {
      return (((150.0 - 101.0) / (55.4 - 35.5)) * (pm25 - 35.5) + 101.0).round();
    } else if (pm25 <= 150.4) {
      return (((200.0 - 151.0) / (150.4 - 55.5)) * (pm25 - 55.5) + 151.0).round();
    } else if (pm25 <= 250.4) {
      return (((300.0 - 201.0) / (250.4 - 150.5)) * (pm25 - 150.5) + 201.0).round();
    } else {
      return (((500.0 - 301.0) / (500.0 - 250.5)) * (pm25 - 250.5) + 301.0).round().clamp(301, 500);
    }
  }

  int _indexToAqiRange(int index) {
    // تبدیل index به میانگین محدوده AQI
    switch (index) {
      case 1:
        return 25; // 0-50
      case 2:
        return 75; // 51-100
      case 3:
        return 125; // 101-150
      case 4:
        return 175; // 151-200
      case 5:
        return 250; // 201-300
      default:
        return 0;
    }
  }

  Future<T?> _decodeJson<T>(String source) async {
    try {
      if (kIsWeb) {
        return json.decode(source) as T;
      }
      final decoded = await compute(_parseJson, source);
      return decoded as T?;
    } catch (_) {
      return null;
    }
  }
}

dynamic _parseJson(String source) => json.decode(source);


