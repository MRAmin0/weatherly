import 'package:flutter/foundation.dart';
import '../data/services/accuweather_service.dart';
import '../models/accuweather/accuweather_current.dart';
import '../models/accuweather/accuweather_forecast.dart';

class AccuWeatherViewModel extends ChangeNotifier {
  final AccuWeatherService _service;

  AccuWeatherViewModel({AccuWeatherService? service})
    : _service = service ?? AccuWeatherService();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AccuCurrentConditions? _current;
  AccuCurrentConditions? get current => _current;

  List<AccuDailyForecast> _forecast = [];
  List<AccuDailyForecast> get forecast => _forecast;

  // Hardcoded location key for Tehran
  static const String _locationKey = '210841';

  Future<void> fetchWeatherData() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch both current and forecast in parallel
      final results = await Future.wait([
        _service.getCurrent(_locationKey),
        _service.getForecast5Day(_locationKey),
      ]);

      _current = results[0] as AccuCurrentConditions?;
      _forecast = results[1] as List<AccuDailyForecast>;

      if (_current == null && _forecast.isEmpty) {
        _errorMessage = 'Failed to fetch AccuWeather data';
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
