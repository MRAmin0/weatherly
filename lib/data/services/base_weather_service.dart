import '../models/hourly_forecast.dart';

abstract class BaseWeatherService {
  Future<Map<String, dynamic>?> resolveCity(String query, {String lang = 'en'});

  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
    String query, {
    int limit = 10,
    String lang = 'en',
  });

  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
    String lang = 'en',
  });

  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
    String lang = 'en',
  });

  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 24,
    String lang = 'en',
  });

  Future<Map<String, dynamic>?> fetchAirQuality({
    required double lat,
    required double lon,
  });
}
