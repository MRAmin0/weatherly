import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigReader {
  static late Map<String, dynamic> _config;

  // متدی برای بارگذاری فایل JSON قبل از اجرای برنامه
  static Future<void> initialize() async {
    final configString = await rootBundle.loadString('keys.json');
    _config = json.decode(configString) as Map<String, dynamic>;
  }

  static String getOpenWeatherApiKey() {
    return _config['openweathermap_api_key'] ?? 'API_KEY_NOT_FOUND';
  }
}