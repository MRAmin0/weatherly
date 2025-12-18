import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weatherly_app/data/models/current_weather.dart';
import 'package:weatherly_app/data/models/daily_forecast.dart';
import 'package:weatherly_app/data/models/hourly_forecast.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/data/services/weather_api_service.dart';
import 'package:weatherly_app/data/services/notification_service.dart';
import 'package:weatherly_app/core/utils/weather_tips.dart';
import 'package:weatherly_app/data/services/background_service_export.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _api;

  WeatherViewModel({WeatherApiService? apiService})
    : _api = apiService ?? WeatherApiService() {
    scheduleMicrotask(_init);
  }

  // ------------------------- UI / THEME STATE -------------------------
  ThemeMode themeMode = ThemeMode.system;
  Color seedColor = Colors.deepPurple;
  bool useSystemColor = false;

  String defaultCity = 'Tehran';

  // ------------------------- WEATHER STATE -------------------------
  String location = '';
  CurrentWeather? currentWeather;
  List<HourlyForecastEntry> hourly = [];
  int? hourlyOffset;
  List<DailyForecastEntry> daily5 = [];
  int? aqi;
  double? pm2_5;

  bool isLoading = false;
  String? error;
  bool useCelsius = true;
  String lang = 'fa';

  // ------------------------- NOTIFICATION STATE -------------------------
  bool smartNotificationsEnabled = true;
  bool dailyNotificationsEnabled = false;
  int dailyNotificationHour = 7;
  int dailyNotificationMinute = 0;
  bool _notificationShownThisSession = false;
  final NotificationService _notificationService = NotificationService();

  List<String> recent = [];
  List<Map<String, dynamic>> suggestions = [];
  Timer? _debounce;

  // ------------------------- INIT & PREFS -------------------------
  Future<void> _init() async {
    await _loadPrefs();
    if (recent.isNotEmpty) {
      await fetchWeatherByCity(recent.first);
    } else {
      await fetchByDefaultCity();
    }
    // After first weather fetch, schedule background task if needed
    await scheduleBackgroundWeatherCheck();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    useCelsius = prefs.getBool('useCelsius') ?? true;
    lang = prefs.getString('lang') ?? 'fa';
    recent = prefs.getStringList('recent') ?? [];
    useSystemColor = prefs.getBool('useSystemColor') ?? false;
    defaultCity = prefs.getString('defaultCity') ?? 'Tehran';

    // Notification settings
    smartNotificationsEnabled = prefs.getBool('smartNotifications') ?? true;
    dailyNotificationsEnabled = prefs.getBool('dailyNotifications') ?? false;
    dailyNotificationHour = prefs.getInt('dailyNotificationHour') ?? 7;
    dailyNotificationMinute = prefs.getInt('dailyNotificationMinute') ?? 0;

    // رنگ تم (seed)
    final seedColorValue = prefs.getInt('seedColor');
    if (seedColorValue != null) seedColor = Color(seedColorValue);

    final themeStr = prefs.getString('themeMode');
    if (themeStr == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    // Initialize notification service
    await _initNotifications();

    notifyListeners();
  }

  Future<void> _initNotifications() async {
    try {
      await _notificationService.initialize();
      await _notificationService.requestPermission();

      // Setup daily notification if enabled
      if (dailyNotificationsEnabled) {
        await _scheduleDailyNotification();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      // Don't throw - notification errors shouldn't block app startup
    }
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

  // ------------------------- SETTINGS ACTIONS -------------------------
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;

    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';

    await _savePref('themeMode', modeStr);
    notifyListeners();
  }

  Future<void> setLang(String value) async {
    if (lang == value) return;
    lang = value;
    await _savePref('lang', value);
    await refresh();
  }

  Future<void> setSeedColor(Color color) async {
    if (seedColor.toARGB32() == color.toARGB32()) return;
    seedColor = color;
    await _savePref('seedColor', color.toARGB32());
    if (useSystemColor) {
      await setUseSystemColor(false);
    } else {
      notifyListeners();
    }
  }

  Future<void> setUseSystemColor(bool value) async {
    if (useSystemColor == value) return;
    useSystemColor = value;
    await _savePref('useSystemColor', value);
    notifyListeners();
  }

  Future<void> setUseCelsius(bool value) async {
    if (useCelsius == value) return;
    useCelsius = value;
    await _savePref('useCelsius', value);
    notifyListeners();
  }

  Future<void> setDefaultCity(String city) async {
    if (city.isEmpty) return;
    defaultCity = city;
    await _savePref('defaultCity', city);
    notifyListeners();
  }

  // ------------------------- NOTIFICATION SETTINGS -------------------------
  Future<void> setSmartNotifications(bool value) async {
    smartNotificationsEnabled = value;
    notifyListeners(); // Update UI immediately
    await _savePref('smartNotifications', value);

    // Schedule or cancel the background task based on the new value
    if (value) {
      await scheduleBackgroundWeatherCheck();
    } else {
      await cancelBackgroundWeatherCheck();
    }
  }

  Future<void> setDailyNotifications(bool value) async {
    dailyNotificationsEnabled = value;
    notifyListeners(); // Update UI immediately

    await _savePref('dailyNotifications', value);

    if (kIsWeb) return;

    try {
      if (value) {
        await _scheduleDailyNotification();
      } else {
        await _notificationService.cancelDailyNotification();
      }
    } catch (e) {
      debugPrint('Error setting daily notification: $e');
    }
  }

  Future<void> setDailyNotificationTime(int hour, int minute) async {
    dailyNotificationHour = hour;
    dailyNotificationMinute = minute;
    notifyListeners(); // Update UI immediately

    await _savePref('dailyNotificationHour', hour);
    await _savePref('dailyNotificationMinute', minute);

    if (kIsWeb) return;

    if (dailyNotificationsEnabled) {
      await _scheduleDailyNotification();
    }
  }

  Future<void> _scheduleDailyNotification() async {
    if (kIsWeb) return;

    final isFarsi = lang == 'fa';
    await _notificationService.scheduleDailyNotification(
      hour: dailyNotificationHour,
      minute: dailyNotificationMinute,
      title: isFarsi ? '☀️ هوای امروز' : '☀️ Today\'s Weather',
      body: isFarsi
          ? 'به اپ ودرلی سر بزن تا وضعیت هوا رو ببینی!'
          : 'Check Weatherly for today\'s forecast!',
    );
  }

  /// Show smart weather notification based on current conditions
  Future<void> showSmartNotification() async {
    if (kIsWeb || !smartNotificationsEnabled || _notificationShownThisSession) {
      return;
    }
    if (currentWeather == null) return;

    try {
      final isFarsi = lang == 'fa';
      final tip = WeatherTips.generateTip(
        weather: currentWeather!,
        isFarsi: isFarsi,
      );

      await _notificationService.showWeatherNotification(
        title: tip.fullTitle,
        body: tip.message,
      );

      _notificationShownThisSession = true;
    } catch (e) {
      debugPrint('Error showing smart notification: $e');
      // Don't rethrow - notification errors shouldn't break the app
    }
  }

  // حذف شهر از لیست اخیر
  Future<void> removeRecent(String city) async {
    recent.removeWhere((e) => e.toLowerCase() == city.toLowerCase());
    await _savePref('recent', recent);
    notifyListeners();
  }

  // ------------------------- WEATHER LOGIC -------------------------
  void _clearWeatherData() {
    currentWeather = null;
    hourly = [];
    daily5 = [];
    aqi = null;
    pm2_5 = null;
    error = null;
  }

  Future<void> fetchWeatherByCity(String city) async {
    final text = city.trim();
    if (text.isEmpty) return;
    
    _clearWeatherData();
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
    _clearWeatherData();
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

    await Future.wait([fetchAqi(lat, lon), fetchHourlyAndDaily(lat, lon)]);

    // Show smart notification after successful weather fetch
    await showSmartNotification();

    _setLoading(false);
  }

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
        } else if (dateStr.contains('12:00:00')) {
          dailyMap[dayKey] = map;
        }
      }

      daily5 = dailyMap.values.take(5).map((item) {
        return DailyForecastEntry(
          date: DateTime.parse(item['dt_txt'] as String),
          minTemp: (item['main']['temp_min'] as num?)?.toDouble() ?? 0.0,
          maxTemp: (item['main']['temp_max'] as num?)?.toDouble() ?? 0.0,
          humidity: (item['main']['humidity'] as num?)?.toInt() ?? 0,
          windSpeed: (item['wind']['speed'] as num?)?.toDouble() ?? 0.0,
          main: item['weather'][0]['main'] ?? 'Clear',
          weatherType: mapWeatherType(item['weather'][0]['main'] as String),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Forecast fetch error: $e');
    }
  }

  Future<void> fetchAqi(double lat, double lon) async {
    try {
      final result = await _api.fetchAirQuality(lat: lat, lon: lon);
      if (result != null &&
          result['list'] is List &&
          (result['list'] as List).isNotEmpty) {
        final first = (result['list'] as List)[0] as Map<String, dynamic>;
        final main = first['main'] as Map<String, dynamic>;
        aqi = (main['aqi'] as num?)?.toInt();
        final components = first['components'] as Map<String, dynamic>;
        pm2_5 = (components['pm2_5'] as num?)?.toDouble();
      } else {
        aqi = null;
        pm2_5 = null;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('AQI fetch error: $e');
    }
  }

  int get calculatedAqiScore {
    if (pm2_5 == null) return 0;
    final pm = pm2_5!;
    if (pm <= 12.0) {
      return ((50 - 0) / (12 - 0) * (pm - 0) + 0).round();
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

  void searchChanged(String text) {
    _debounce?.cancel();
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      suggestions = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _api.fetchCitySuggestions(trimmed, lang: lang);

        // تشخیص زبان ورودی (آیا کاراکتر فارسی دارد؟)
        final isFarsiInput = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);

        final processedResults = results.map((city) {
          final localNames = city['local_names'] as Map<String, dynamic>?;
          String displayName = city['name'];

          if (localNames != null) {
            if (isFarsiInput && localNames.containsKey('fa')) {
              displayName = localNames['fa'];
            } else if (!isFarsiInput && localNames.containsKey('en')) {
              displayName = localNames['en'];
            }
          }

          // ایجاد یک مپ جدید با نام اصلاح شده برای نمایش
          return {
            ...city,
            'name': displayName,
            'original_name': city['name'], // نگهداری نام اصلی
          };
        }).toList();

        suggestions = processedResults;
      } catch (_) {
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

    suggestions = [];
    location = cityName;
    notifyListeners();

    await fetchWeatherByCoordinates(lat, lon);
  }

  Future<void> _addRecent(String city) async {
    final name = city.trim();
    if (name.isEmpty) return;
    recent.removeWhere((e) => e.toLowerCase() == name.toLowerCase());
    recent.insert(0, name);
    if (recent.length > 5) recent = recent.sublist(0, 5);
    await _savePref('recent', recent);
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _handleError(dynamic e, StackTrace st, String context) {
    if (kDebugMode) print('$context error: $e\n$st');
    error = 'خطا در برقراری ارتباط';
    _setLoading(false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
