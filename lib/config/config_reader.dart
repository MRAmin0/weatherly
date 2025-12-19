import 'dart:convert';
import 'package:flutter/services.dart';

abstract class ConfigReader {
  static Map<String, dynamic> _config = {};

  static Future<void> initialize() async {
    final configString = await rootBundle.loadString('assets/config/keys.json');
    _config = json.decode(configString) as Map<String, dynamic>;
  }

  static String get openWeatherApiKey {
    return _config['open_weather_api_key'] as String;
  }

  static String get accuWeatherApiKey {
    return _config['accu_weather_api_key'] ?? '';
  }
}
