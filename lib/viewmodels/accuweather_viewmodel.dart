import 'package:flutter/foundation.dart';
import '../data/services/accuweather_service.dart';
import '../models/accuweather_current.dart';

class AccuWeatherViewModel extends ChangeNotifier {
  final AccuWeatherService _service;

  AccuWeatherViewModel({AccuWeatherService? service})
    : _service = service ?? AccuWeatherService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AccuCurrentConditions? _data;
  AccuCurrentConditions? get data => _data;

  // Hardcoded location key for Tehran as requested
  static const String _locationKey = '210841';

  Future<void> fetchCurrentConditions() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getCurrentConditions(_locationKey);
      if (result != null) {
        _data = result;
      } else {
        _error = 'Failed to fetch AccuWeather data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
