import 'package:flutter/foundation.dart';
import '../data/services/openweathermap_service.dart';
import '../models/openweathermap/owm_current.dart';
import '../models/openweathermap/owm_forecast.dart';

class OpenWeatherMapViewModel extends ChangeNotifier {
  final OpenWeatherMapService _service;

  OpenWeatherMapViewModel({OpenWeatherMapService? service})
    : _service = service ?? OpenWeatherMapService();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OwmCurrent? _current;
  OwmCurrent? get current => _current;

  List<OwmForecast> _forecast = [];
  List<OwmForecast> get forecast => _forecast;

  // Default coordinates for Tehran
  static const double _defaultLat = 35.6892;
  static const double _defaultLon = 51.3890;

  Future<void> fetchWeatherData({
    double lat = _defaultLat,
    double lon = _defaultLon,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch both current and forecast in parallel
      final results = await Future.wait([
        _service.getCurrent(lat, lon),
        _service.getForecast(lat, lon),
      ]);

      _current = results[0] as OwmCurrent?;
      _forecast = results[1] as List<OwmForecast>;

      if (_current == null && _forecast.isEmpty) {
        _errorMessage = 'Failed to fetch OpenWeatherMap data';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchWeatherData();
  }
}
