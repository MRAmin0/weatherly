import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/config_reader.dart';
import '../../models/openweathermap/owm_current.dart';
import '../../models/openweathermap/owm_forecast.dart';

class OpenWeatherMapService {
  static const String _baseUrl = 'api.openweathermap.org';
  final http.Client _httpClient;

  OpenWeatherMapService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  String get _apiKey => ConfigReader.openWeatherApiKey;

  /// Get current weather
  Future<OwmCurrent?> getCurrent(double lat, double lon) async {
    final uri = Uri.https(_baseUrl, '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
    });

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OwmCurrent.fromJson(data);
      } else {
        debugPrint(
          'OpenWeatherMap Current Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('OpenWeatherMap Current Exception: $e');
    }
    return null;
  }

  /// Get 5-day / 3-hour forecast
  Future<List<OwmForecast>> getForecast(double lat, double lon) async {
    final uri = Uri.https(_baseUrl, '/data/2.5/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
    });

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['list'] ?? [];
        return list.map((e) => OwmForecast.fromJson(e)).toList();
      } else {
        debugPrint(
          'OpenWeatherMap Forecast Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('OpenWeatherMap Forecast Exception: $e');
      return [];
    }
  }
}
