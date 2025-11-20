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

  Future<Map<String, dynamic>?> resolveCity(String query, {String lang = 'en'}) async {
    final results = await fetchCitySuggestions(query, limit: 5, lang: lang);
    if (results.isEmpty) return null;
    return sortAndDeduplicateCities(results, query, maxItems: 1).first;
  }

  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
    String query, {
    int limit = 10,
    String lang = 'en',
  }) async {
    if (!isConfigured) return const [];
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
    String lang = 'en',
  }) async {
    if (!isConfigured) return null;
    Uri? uri;

    String langParam = '&lang=$lang';

    if (lat != null && lon != null) {
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric$langParam',
      );
    } else if (cityName != null && cityName.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(cityName.trim());
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$encoded&appid=$apiKey&units=metric$langParam',
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
    String lang = 'en',
  }) async {
    if (!isConfigured) return const [];

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=$lang',
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
    String lang = 'en',
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=$count&lang=$lang',
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
      final entries = (data?['list'] as List<dynamic>? ?? const []);
      if (entries.isEmpty) return null;

      final first = entries.first as Map<String, dynamic>? ?? const {};
      final components = (first['components'] as Map<String, dynamic>?) ?? const {};
      final rawIndex = (first['main']?['aqi'] as num?)?.toInt() ?? 0;
      final pm25 = (components['pm2_5'] as num?)?.toDouble();
      final pm10 = (components['pm10'] as num?)?.toDouble();
      final no2 = (components['no2'] as num?)?.toDouble();
      final so2 = (components['so2'] as num?)?.toDouble();
      final o3 = (components['o3'] as num?)?.toDouble();

      final computedAqi = pm25 != null ? _calculateAqiFromPm25(pm25) : _indexToAqiRange(rawIndex);

      return {
        'aqi': computedAqi,
        'pm2_5': pm25,
        'pm10': pm10,
        'no2': no2,
        'so2': so2,
        'o3': o3,
        'raw_index': rawIndex,
      };
    } catch (_) {
      return null;
    }
  }

  int _calculateAqiFromPm25(double pm25) {
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 12.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 12.1, 'cHigh': 35.4, 'iLow': 51, 'iHigh': 100},
      {'cLow': 35.5, 'cHigh': 55.4, 'iLow': 101, 'iHigh': 150},
      {'cLow': 55.5, 'cHigh': 150.4, 'iLow': 151, 'iHigh': 200},
      {'cLow': 150.5, 'cHigh': 250.4, 'iLow': 201, 'iHigh': 300},
      {'cLow': 250.5, 'cHigh': 350.4, 'iLow': 301, 'iHigh': 400},
      {'cLow': 350.5, 'cHigh': 500.4, 'iLow': 401, 'iHigh': 500},
    ];

    final value = pm25.clamp(0, 500.4);
    for (final bp in breakpoints) {
      final cLow = bp['cLow']! as double;
      final cHigh = bp['cHigh']! as double;
      if (value >= cLow && value <= cHigh) {
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final result = (((iHigh - iLow) / (cHigh - cLow)) * (value - cLow) + iLow).round();
        return result.clamp(0, 500);
      }
    }
    return 500;
  }

  int _indexToAqiRange(int index) {
    switch (index) {
      case 1:
        return 20;
      case 2:
        return 35;
      case 3:
        return 60;
      case 4:
        return 120;
      case 5:
        return 200;
      default:
        return 0;
    }
  }

  Future<T?> _decodeJson<T>(String source) async {
    try {
      if (kIsWeb) {
        return _parseJson(source) as T?;
      }
      return await compute(_parseJson, source) as T?;
    } catch (_) {
      return null;
    }
  }
}

dynamic _parseJson(String source) => json.decode(source);
