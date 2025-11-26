// lib/viewmodels/weather_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/current_weather.dart';
import '../models/daily_forecast.dart';
import '../models/hourly_forecast.dart';
import '../models/weather_type.dart';
import '../services/weather_api_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _api;

  WeatherViewModel({WeatherApiService? apiService})
    : _api = apiService ?? WeatherApiService() {
    scheduleMicrotask(_init);
  }

  // ------------------------- STATE -------------------------

  Color seedColor = Colors.deepPurple;
  bool useSystemColor = false;
  String defaultCity = 'Tehran';

  String location = '';
  CurrentWeather? currentWeather;

  List<HourlyForecastEntry> hourly = [];
  int? hourlyOffset;

  List<DailyForecastEntry> daily5 = [];

  // متغیرهای مربوط به کیفیت هوا
  int? aqi; // شاخص ۱ تا ۵ (استاندارد OpenWeather)
  double? pm2_5; // غلظت ذرات معلق برای محاسبه دقیق

  bool isLoading = false;
  String? error;
  bool useCelsius = true;
  String lang = 'fa';

  // متغیرهای مربوط به جستجو
  List<String> recent = [];
  List<Map<String, dynamic>> suggestions = [];
  Timer? _debounce;

  // ------------------------- INIT -------------------------

  Future<void> _init() async {
    await _loadPrefs();
    if (recent.isNotEmpty) {
      await fetchWeatherByCity(recent.first);
    } else {
      await fetchByDefaultCity();
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    useCelsius = prefs.getBool('useCelsius') ?? true;
    lang = prefs.getString('lang') ?? 'fa';
    recent = prefs.getStringList('recent') ?? [];
    useSystemColor = prefs.getBool('useSystemColor') ?? false;
    defaultCity = prefs.getString('defaultCity') ?? 'Tehran';

    final colorValue = prefs.getInt('seedColor');
    if (colorValue != null) {
      seedColor = Color(colorValue);
    }

    notifyListeners();
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  // ------------------------- SETTINGS -------------------------

  Future<void> setDefaultCity(String city) async {
    if (city.isEmpty) return;
    defaultCity = city;
    await _savePref('defaultCity', city);
    notifyListeners();
  }

  Future<void> setUseSystemColor(bool value) async {
    if (useSystemColor == value) return;
    useSystemColor = value;
    await _savePref('useSystemColor', value);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    if (seedColor == color) return;
    seedColor = color;
    // Use .toARGB32() for Color persistence (Flutter 3.27+)
    await _savePref('seedColor', color.value);

    if (useSystemColor) {
      setUseSystemColor(false);
    } else {
      notifyListeners();
    }
  }

  Future<void> setUseCelsius(bool value) async {
    if (useCelsius == value) return;
    useCelsius = value;
    await _savePref('useCelsius', value);
    notifyListeners();
  }

  Future<void> setLang(String value) async {
    if (lang == value) return;
    lang = value;
    await _savePref('lang', value);
    await refresh();
  }

  // ------------------------- FETCH MAIN WEATHER -------------------------

  Future<void> fetchWeatherByCity(String city) async {
    final text = city.trim();
    if (text.isEmpty) return;

    _setLoading(true);

    try {
      final data = await _api.fetchCurrentWeather(cityName: text, lang: lang);
      if (data == null) {
        error = 'شهر پیدا نشد.';
        _setLoading(false);
        return;
      }
      await _processWeatherData(data);
    } catch (e, st) {
      _handleError(e, st, 'fetchWeatherByCity');
    }
  }

  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    _setLoading(true);
    try {
      final data = await _api.fetchCurrentWeather(
        lat: lat,
        lon: lon,
        lang: lang,
      );
      if (data == null) {
        error = 'خطا در دریافت اطلاعات.';
        _setLoading(false);
        return;
      }
      await _processWeatherData(data);
    } catch (e, st) {
      _handleError(e, st, 'fetchWeatherByCoordinates');
    }
  }

  Future<void> _processWeatherData(Map<String, dynamic> data) async {
    currentWeather = CurrentWeather.fromJson(data);
    location = currentWeather!.cityName;
    error = null;
    _addRecent(location).ignore();

    final coord = data['coord'];
    final lat = (coord['lat'] as num).toDouble();
    final lon = (coord['lon'] as num).toDouble();

    // دریافت همزمان اطلاعات تکمیلی (AQI و پیش‌بینی)
    await Future.wait([fetchAqi(lat, lon), fetchHourlyAndDaily(lat, lon)]);
    _setLoading(false);
  }

  Future<void> fetchByDefaultCity() async {
    await fetchWeatherByCity(defaultCity);
  }

  Future<void> refresh() async {
    if (location.isEmpty) {
      await fetchByDefaultCity();
    } else {
      await fetchWeatherByCity(location);
    }
  }

  // ------------------------- HOURLY & DAILY -------------------------

  Future<void> fetchHourlyAndDaily(double lat, double lon) async {
    try {
      final rawList = await _api.fetchForecast(lat: lat, lon: lon, lang: lang);
      if (rawList.isEmpty) {
        hourly = [];
        daily5 = [];
        notifyListeners();
        return;
      }

      hourlyOffset = 0;

      hourly = rawList.take(8).map((item) {
        final map = item as Map<String, dynamic>;
        return HourlyForecastEntry(
          time: DateTime.parse(map['dt_txt'] as String),
          temperature: (map['main']['temp'] as num?)?.toDouble() ?? 0.0,
          weatherType: mapWeatherType(map['weather'][0]['main'] as String),
        );
      }).toList();

      final Map<String, Map<String, dynamic>> dailyMap = {};
      for (var item in rawList) {
        final map = item as Map<String, dynamic>;
        final dateStr = map['dt_txt'] as String;
        final dayKey = dateStr.split(' ')[0];

        if (!dailyMap.containsKey(dayKey)) {
          dailyMap[dayKey] = map;
        } else {
          if (dateStr.contains("12:00:00")) {
            dailyMap[dayKey] = map;
          }
        }
      }

      daily5 = dailyMap.values.take(5).map((item) {
        return DailyForecastEntry(
          date: DateTime.parse(item['dt_txt'] as String),
          minTemp: (item['main']['temp_min'] as num?)?.toDouble() ?? 0.0,
          maxTemp: (item['main']['temp_max'] as num?)?.toDouble() ?? 0.0,
          humidity: (item['main']['humidity'] as num?)?.toInt() ?? 0,
          windSpeed: (item['wind']['speed'] as num?)?.toDouble() ?? 0.0,
          main: item['weather'][0]['main'] as String? ?? 'Clear',
          weatherType: mapWeatherType(item['weather'][0]['main'] as String),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Forecast fetch error: $e");
    }
  }

  // ------------------------- AQI LOGIC (UPDATED) -------------------------

  Future<void> fetchAqi(double lat, double lon) async {
    try {
      final result = await _api.fetchAirQuality(lat: lat, lon: lon);
      if (result != null &&
          result['list'] is List &&
          (result['list'] as List).isNotEmpty) {
        final list = result['list'] as List;
        final firstItem = list[0] as Map<String, dynamic>;

        // 1. گرفتن شاخص 1 تا 5
        final main = firstItem['main'] as Map<String, dynamic>;
        aqi = (main['aqi'] as num?)?.toInt();

        // 2. گرفتن غلظت ذرات معلق (PM2.5) برای محاسبه عدد دقیق 0-500
        final components = firstItem['components'] as Map<String, dynamic>;
        pm2_5 = (components['pm2_5'] as num?)?.toDouble();
      } else {
        aqi = null;
        pm2_5 = null;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("AQI fetch error: $e");
    }
  }

  /// این گتر جادویی تبدیل غلظت PM2.5 به عدد استاندارد 0 تا 500 است
  int get calculatedAqiScore {
    if (pm2_5 == null) return 0;
    final pm = pm2_5!;

    // فرمول تبدیل PM2.5 به AQI (بر اساس استاندارد EPA)
    if (pm <= 12.0) {
      return ((50 - 0) / (12.0 - 0) * (pm - 0) + 0).round();
    } else if (pm <= 35.4) {
      return ((100 - 51) / (35.4 - 12.1) * (pm - 12.1) + 51).round();
    } else if (pm <= 55.4) {
      return ((150 - 101) / (55.4 - 35.5) * (pm - 35.5) + 101).round();
    } else if (pm <= 150.4) {
      return ((200 - 151) / (150.4 - 55.5) * (pm - 55.5) + 151).round();
    } else if (pm <= 250.4) {
      return ((300 - 201) / (250.4 - 150.5) * (pm - 150.5) + 201).round();
    } else if (pm <= 350.4) {
      return ((400 - 301) / (350.4 - 250.5) * (pm - 250.5) + 301).round();
    } else {
      return ((500 - 401) / (500.4 - 350.5) * (pm - 350.5) + 401).round();
    }
  }

  // ------------------------- SEARCH LOGIC (FIXED) -------------------------

  void searchChanged(String text) {
    _debounce?.cancel();
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      suggestions = [];
      notifyListeners();
      return;
    }

    // تاخیر ۵۰۰ میلی‌ثانیه‌ای برای بهینه کردن درخواست‌ها
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _api.fetchCitySuggestions(trimmed, lang: lang);
        suggestions = results;
      } catch (e) {
        suggestions = [];
      }
      notifyListeners();
    });
  }

  Future<void> selectCitySuggestion(Map<String, dynamic> city) async {
    final lat = (city['lat'] as num?)?.toDouble();
    final lon = (city['lon'] as num?)?.toDouble();

    if (lat == null || lon == null) return;

    final localNames = city['local_names'] as Map<String, dynamic>?;
    final cityName = localNames?[lang] ?? city['name'] ?? '';

    suggestions = []; // پاک کردن لیست پیشنهادات
    location = cityName;
    notifyListeners();

    await fetchWeatherByCoordinates(lat, lon);
  }

  Future<void> _addRecent(String city) async {
    final normalized = city.trim();
    if (normalized.isEmpty) return;
    recent.removeWhere((e) => e.toLowerCase() == normalized.toLowerCase());
    recent.insert(0, normalized);
    if (recent.length > 5) {
      recent = recent.sublist(0, 5);
    }
    await _savePref('recent', recent);
    notifyListeners();
  }

  // ------------------------- HELPERS -------------------------

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _handleError(dynamic e, StackTrace st, String context) {
    if (kDebugMode) {
      print('$context error: $e\n$st');
    }
    error = 'خطا در برقراری ارتباط';
    _setLoading(false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
