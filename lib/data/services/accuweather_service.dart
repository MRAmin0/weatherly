import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/config_reader.dart';
import '../../models/accuweather_models.dart';
import '../../models/accuweather_current.dart';

class AccuWeatherService {
  static const String _baseUrl = 'dataservice.accuweather.com';
  final http.Client _httpClient;

  AccuWeatherService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  String get _apiKey => ConfigReader.accuWeatherApiKey;

  /// 1. City Search
  Future<List<CitySearchResult>> searchCity(String query) async {
    if (query.isEmpty) return [];

    final uri = Uri.https(_baseUrl, '/locations/v1/cities/search', {
      'apikey': _apiKey,
      'q': query,
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => CitySearchResult.fromJson(e)).toList();
      } else {
        debugPrint(
          'City Search Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('City Search Exception: $e');
      return [];
    }
  }

  /// 2. Current Conditions
  Future<AccuCurrentConditions?> getCurrentConditions(
    String locationKey,
  ) async {
    final uri = Uri.https(_baseUrl, '/currentconditions/v1/$locationKey', {
      'apikey': _apiKey,
      'details': 'true',
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return AccuCurrentConditions.fromJson(data.first);
        }
      } else {
        debugPrint(
          'Current Conditions Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Current Conditions Exception: $e');
    }
    return null;
  }

  /// 3. 1-Day Forecast
  Future<DailyForecast?> getOneDayForecast(String locationKey) async {
    final uri = Uri.https(_baseUrl, '/forecasts/v1/daily/1day/$locationKey', {
      'apikey': _apiKey,
      'metric': 'true',
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> dailyForecasts = data['DailyForecasts'];
        if (dailyForecasts.isNotEmpty) {
          return DailyForecast.fromJson(dailyForecasts.first);
        }
      } else {
        debugPrint(
          '1-Day Forecast Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('1-Day Forecast Exception: $e');
    }
    return null;
  }

  /// 4. 5-Day Forecast
  Future<List<DailyForecast>> getFiveDayForecast(String locationKey) async {
    final uri = Uri.https(_baseUrl, '/forecasts/v1/daily/5day/$locationKey', {
      'apikey': _apiKey,
      'metric': 'true',
    });

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> dailyForecasts = data['DailyForecasts'];
        return dailyForecasts.map((e) => DailyForecast.fromJson(e)).toList();
      } else {
        debugPrint(
          '5-Day Forecast Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('5-Day Forecast Exception: $e');
      return [];
    }
  }
}
