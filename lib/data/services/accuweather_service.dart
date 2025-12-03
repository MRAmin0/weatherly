import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/config_reader.dart';
import '../../models/accuweather/accuweather_current.dart';
import '../../models/accuweather/accuweather_forecast.dart';

class AccuWeatherService {
  static const String _baseUrl = 'dataservice.accuweather.com';
  final http.Client _httpClient;

  AccuWeatherService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  String get _apiKey => ConfigReader.accuWeatherApiKey;

  /// Get current conditions with details
  Future<AccuCurrentConditions?> getCurrent(String locationKey) async {
    final uri = Uri.https(_baseUrl, '/currentconditions/v1/$locationKey', {
      'apikey': _apiKey,
      'details': 'true',
    });

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return AccuCurrentConditions.fromJson(data.first);
        }
      } else {
        debugPrint(
          'AccuWeather Current Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('AccuWeather Current Exception: $e');
    }
    return null;
  }

  /// Get 5-day forecast
  Future<List<AccuDailyForecast>> getForecast5Day(String locationKey) async {
    final uri = Uri.https(_baseUrl, '/forecasts/v1/daily/5day/$locationKey', {
      'apikey': _apiKey,
      'metric': 'true',
      'details': 'true',
    });

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> dailyForecasts = data['DailyForecasts'] ?? [];
        return dailyForecasts
            .map((e) => AccuDailyForecast.fromJson(e))
            .toList();
      } else {
        debugPrint(
          'AccuWeather Forecast Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('AccuWeather Forecast Exception: $e');
      return [];
    }
  }
}
