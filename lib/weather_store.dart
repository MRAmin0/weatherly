import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, kDebugMode, kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/weather_models.dart';
import 'services/weather_api_service.dart';
import 'utils/city_utils.dart';

class WeatherStore extends ChangeNotifier {
  // تغییر مهم: حذف apiKey و ConfigReader از سازنده
  WeatherStore({WeatherApiService? apiService})
      : _apiService = apiService ?? WeatherApiService() {
    Future.microtask(_init);
  }

  final WeatherApiService _apiService;
  final int _recentMax = 10;

  // State variables
  String _currentLang = 'fa';
  bool _showHourly = true;
  bool _showAirQuality = true;
  bool _useCelsius = true;
  String _defaultCity = 'Tehran';
  List<String> _recentSearches = [];
  int _accentColorValue = 0xFF1976D2;
  bool _useSystemColor = true;

  int? _airQualityIndex;
  String _location = 'Tehran';
  double? _temperature;
  int _humidity = 0;
  double _windSpeed = 0.0;

  WeatherType _weatherType = WeatherType.unknown;
  String _weatherDescription = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];
  List<dynamic> _forecast = [];
  List<Map<String, dynamic>> hourlyForecast = [];
  int? _hourlyTimezoneOffsetSeconds;
  double? _currentLat;
  double? _currentLon;
  Timer? _debounce;
  String? _errorMessage;
  bool _locationPermissionDenied = false;
  bool _locationPermissionRejected = false;
  bool _hideLocationPermissionPrompt = false;

  // Getters
  String get currentLang => _currentLang;
  bool get showHourly => _showHourly;
  bool get showAirQuality => _showAirQuality;
  bool get useCelsius => _useCelsius;
  String get defaultCity => _defaultCity;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  int? get airQualityIndex => _airQualityIndex;
  String get location => _location;
  double? get temperature => _temperature;
  int get humidity => _humidity;
  double get windSpeed => _windSpeed;
  WeatherType get weatherType => _weatherType;
  String get weatherDescription => _weatherDescription;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get suggestions => _suggestions;
  List<dynamic> get forecast => _forecast;
  String? get errorMessage => _errorMessage;
  int? get hourlyTimezoneOffsetSeconds => _hourlyTimezoneOffsetSeconds;
  bool get locationPermissionDenied => _locationPermissionDenied;
  bool get hideLocationPermissionPrompt => _hideLocationPermissionPrompt;
  int get accentColorValue => _accentColorValue;
  bool get useSystemColor => _useSystemColor;
  static bool systemColorAvailable = false;

  // حذف _apiReady چون سرویس جدید همیشه آماده است

  Future<void> setLanguage(String lang) async {
    if (lang == _currentLang) return;
    _currentLang = lang;
    notifyListeners();
    await handleRefresh();
  }

  Future<void> _init() async {
    await _loadPreferences();
    final usedLocation = await _attemptStartupLocation();
    if (!usedLocation) {
      await _fetchWeatherAndForecast(cityName: _location);
    }
    if (_currentLat != null && _currentLon != null) {
      await fetchHourlyForecast(_currentLat!, _currentLon!);
    }
  }

  Future<bool> _attemptStartupLocation() async {
    try {
      if (kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _locationPermissionDenied = true;
          notifyListeners();
          return false;
        }
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !_locationPermissionRejected) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _locationPermissionDenied = true;
        await _persistLocationPermissionRejected(true);
        notifyListeners();
        return false;
      }
      await _persistLocationPermissionRejected(false);
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      _locationPermissionDenied = false;
      notifyListeners();
      await _fetchWeatherAndForecast(
        lat: position.latitude,
        lon: position.longitude,
      );
      await fetchAirQuality(position.latitude, position.longitude);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('خطا در دریافت موقعیت: $e');
      }
      _locationPermissionDenied = true;
      await _persistLocationPermissionRejected(true);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  WeatherType _stringToWeatherType(String weatherMain) {
    switch (weatherMain) {
      case 'Clear': return WeatherType.clear;
      case 'Clouds': return WeatherType.clouds;
      case 'Rain': return WeatherType.rain;
      case 'Snow': return WeatherType.snow;
      case 'Drizzle': return WeatherType.drizzle;
      case 'Thunderstorm': return WeatherType.thunderstorm;
      case 'Atmosphere': return WeatherType.atmosphere;
      default: return WeatherType.unknown;
    }
  }

  Future<void> _fetchWeatherAndForecast({
    String? cityName,
    double? lat,
    double? lon,
  }) async {
    // حذف چک کردن _apiReady و ConfigReader

    _setLoading(true);
    _errorMessage = null;
    try {
      double? targetLat = lat;
      double? targetLon = lon;
      String? resolvedLabel;
      final trimmedCity = cityName?.trim();

      if ((targetLat == null || targetLon == null) && trimmedCity != null && trimmedCity.isNotEmpty) {
        final resolved = await _apiService.resolveCity(
          trimmedCity,
          lang: _currentLang,
        );
        if (resolved != null) {
          targetLat = resolved['lat'];
          targetLon = resolved['lon'];
          resolvedLabel = buildCityLabel(resolved, lang: _currentLang);
        }
      }

      final weather = await _apiService.fetchCurrentWeather(
        lat: targetLat,
        lon: targetLon,
        cityName: (targetLat == null || targetLon == null) ? trimmedCity : null,
        lang: _currentLang,
      );

      if (weather == null) {
        _errorMessage = 'City not found or server error.';
        _temperature = null;
        _forecast = [];
        return;
      }

      targetLat ??= (weather['coord']?['lat'] as num?)?.toDouble();
      targetLon ??= (weather['coord']?['lon'] as num?)?.toDouble();

      final forecastList = (targetLat != null && targetLon != null)
          ? await _apiService.fetchForecast(
        lat: targetLat,
        lon: targetLon,
        lang: _currentLang,
      )
          : const <dynamic>[];

      if (resolvedLabel != null) {
        _location = resolvedLabel;
      } else {
        _location = buildCityLabel(weather, lang: _currentLang);
      }

      _temperature = (weather['main']?['temp'] as num?)?.toDouble();
      _humidity = (weather['main']?['humidity'] as num?)?.toInt() ?? 0;
      _windSpeed = (weather['wind']?['speed'] as num?)?.toDouble() ?? 0.0;

      final weatherInfo = weather['weather']?[0];
      if (weatherInfo != null) {
        _weatherType = _stringToWeatherType(weatherInfo['main'] ?? '');
        _weatherDescription = weatherInfo['description'] ?? '';
      }

      _forecast = forecastList;
      _currentLat = targetLat;
      _currentLon = targetLon;
      _suggestions = [];

      if (_currentLat != null && _currentLon != null) {
        await fetchAirQuality(_currentLat!, _currentLon!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while fetching weather: $e');
      }
      _errorMessage = 'Failed to load data. Check network connection.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchAndFetchByCityName(String cityName) async {
    final text = cityName.trim();
    if (text.isEmpty) return;
    await _fetchWeatherAndForecast(cityName: text);
    unawaited(_addRecent(text));
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      if (query.trim().isNotEmpty) {
        await _fetchCitySuggestions(query);
      } else {
        _suggestions = [];
        notifyListeners();
      }
    });
  }

  Future<void> _fetchCitySuggestions(String query) async {
    final results = await _apiService.fetchCitySuggestions(
      query,
      lang: _currentLang,
    );
    _suggestions = results;
    notifyListeners();
  }

  void selectCity(Map<String, dynamic> cityData) {
    final lat = (cityData['lat'] as num?)?.toDouble();
    final lon = (cityData['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) return;
    _location = buildCityLabel(cityData, lang: _currentLang);
    unawaited(_addRecent(_location));
    _suggestions = [];
    notifyListeners();
    unawaited(_fetchWeatherAndForecast(lat: lat, lon: lon));
    unawaited(fetchHourlyForecast(lat, lon));
    unawaited(fetchAirQuality(lat, lon));
  }

  Future<void> handleRefresh() async {
    if (_currentLat != null && _currentLon != null) {
      await _fetchWeatherAndForecast(lat: _currentLat, lon: _currentLon);
      await fetchAirQuality(_currentLat!, _currentLon!);
      await fetchHourlyForecast(_currentLat!, _currentLon!);
    } else {
      await _fetchWeatherAndForecast(cityName: _location);
    }
  }

  Future<void> fetchHourlyForecast(double lat, double lon) async {
    final response = await _apiService.fetchHourlyForecast(
      lat: lat,
      lon: lon,
      lang: _currentLang,
    );
    if (response == null) return;
    hourlyForecast = response.entries;
    _hourlyTimezoneOffsetSeconds = response.timezoneOffsetSeconds;
    notifyListeners();
  }

  Future<void> fetchByCurrentLocation() async {
    try {
      if (kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _errorMessage = 'Location service is disabled.';
          notifyListeners();
          return;
        }
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !_locationPermissionRejected) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permission denied.';
        await _persistLocationPermissionRejected(true);
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied.';
        await _persistLocationPermissionRejected(true);
        notifyListeners();
        return;
      }
      await _persistLocationPermissionRejected(false);
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      await _fetchWeatherAndForecast(
        lat: position.latitude,
        lon: position.longitude,
      );
      await fetchHourlyForecast(position.latitude, position.longitude);
      await fetchAirQuality(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) {
        print('خطا در دریافت مکان فعلی: $e');
      }
      _errorMessage = 'Failed to get current location.';
      notifyListeners();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _showHourly = prefs.getBool('showHourly') ?? true;
    _showAirQuality = prefs.getBool('showAirQuality') ?? true;
    _useCelsius = prefs.getBool('useCelsius') ?? true;
    _defaultCity = prefs.getString('defaultCity') ?? 'Tehran';
    _recentSearches = prefs.getStringList('recentSearches') ?? [];
    _accentColorValue = prefs.getInt('accentColor') ?? _accentColorValue;
    _useSystemColor = prefs.getBool('useSystemColor') ?? true;
    if (!WeatherStore.systemColorAvailable && _useSystemColor) {
      _useSystemColor = false;
      await prefs.setBool('useSystemColor', false);
    }
    _locationPermissionRejected = prefs.getBool('locationPermissionRejected') ?? false;
    _hideLocationPermissionPrompt = prefs.getBool('hideLocationPermissionPrompt') ?? false;
    notifyListeners();
  }

  Future<void> updatePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is num) {
      await prefs.setDouble(key, value.toDouble());
    }
    switch (key) {
      case 'showHourly': _showHourly = value as bool; break;
      case 'showAirQuality': _showAirQuality = value as bool; break;
      case 'useCelsius': _useCelsius = value as bool; break;
      case 'defaultCity': _defaultCity = value as String; break;
      case 'useSystemColor':
        final desired = value as bool;
        if (!WeatherStore.systemColorAvailable && desired) {
          await prefs.setBool('useSystemColor', false);
          _useSystemColor = false;
          notifyListeners();
          return;
        }
        _useSystemColor = desired;
        break;
    }
    notifyListeners();
  }

  Future<void> setAccentColor(int colorValue) async {
    if (_accentColorValue == colorValue) return;
    _accentColorValue = colorValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', colorValue);
    notifyListeners();
  }

  Future<void> _addRecent(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = label.trim();
    if (normalized.isEmpty) return;
    _recentSearches.removeWhere(
          (entry) => entry.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);
    if (_recentSearches.length > _recentMax) {
      _recentSearches = _recentSearches.sublist(0, _recentMax);
    }
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.clear();
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentAt(int index) async {
    if (index < 0 || index >= _recentSearches.length) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.removeAt(index);
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> _persistLocationPermissionRejected(bool value) async {
    _locationPermissionRejected = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationPermissionRejected', value);
  }

  Future<void> setHideLocationPermissionPrompt(bool value) async {
    if (_hideLocationPermissionPrompt == value) return;
    _hideLocationPermissionPrompt = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hideLocationPermissionPrompt', value);
    notifyListeners();
  }

  Future<void> goToDefaultCity() async {
    await searchAndFetchByCityName(_defaultCity);
  }

  Future<void> fetchAirQuality(double lat, double lon) async {
    // حذف چک کردن _apiReady
    final data = await _apiService.fetchAirQuality(lat: lat, lon: lon);
    if (data != null) {
      _airQualityIndex = data['aqi'] as int?;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}