import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ConfigReader {
  static late Map<String, dynamic> _config;
  static bool _initialized = false;

  // متدی برای بارگذاری فایل JSON قبل از اجرای برنامه
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        // برای وب، ابتدا از rootBundle تلاش می‌کنیم (که در build web قرار می‌گیرد)
        try {
          final configString = await rootBundle.loadString('keys.json');
          _config = json.decode(configString) as Map<String, dynamic>;
        } catch (_) {
          // Fallback: تلاش برای بارگذاری از URL
          try {
            final baseUrl = Uri.base;
            final keysUrl = baseUrl.resolve('/keys.json');
            final response = await http
                .get(keysUrl)
                .timeout(const Duration(seconds: 5));
            if (response.statusCode == 200) {
              _config = json.decode(response.body) as Map<String, dynamic>;
            } else {
              throw Exception('Failed to load keys.json');
            }
          } catch (_) {
            rethrow;
          }
        }
      } else {
        // برای موبایل و دسکتاپ
        final configString = await rootBundle.loadString('keys.json');
        _config = json.decode(configString) as Map<String, dynamic>;
      }
      _initialized = true;
    } catch (e) {
      // در صورت خطا، یک config خالی تنظیم می‌کنیم
      _config = <String, dynamic>{};
      _initialized = true;
      if (kDebugMode) {
        print('خطا در بارگذاری keys.json: $e');
      }
    }
  }

  static String getOpenWeatherApiKey() {
    if (!_initialized) {
      return 'API_KEY_NOT_FOUND';
    }
    return _config['openweathermap_api_key'] ?? 'API_KEY_NOT_FOUND';
  }
}
