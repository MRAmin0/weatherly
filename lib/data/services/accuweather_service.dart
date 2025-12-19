import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weatherly_app/config/config_reader.dart';
import 'base_weather_service.dart';
import '../models/hourly_forecast.dart';

class AccuWeatherService implements BaseWeatherService {
  final http.Client _httpClient;

  AccuWeatherService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  String get _apiKey => ConfigReader.accuWeatherApiKey;

  // AccuWeather specific: We need a location key for everything.
  // We can cache it if needed, but for now we'll fetch it.
  Future<String?> _getLocationKey(double lat, double lon) async {
    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/locations/v1/cities/geoposition/search',
      {'apikey': _apiKey, 'q': '$lat,$lon'},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('AccuWeather _getLocationKey error: ${response.statusCode}');
          print(response.body);
        }
        return null;
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['Key'] as String?;
    } catch (e) {
      if (kDebugMode) print('AccuWeather _getLocationKey exception: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> resolveCity(
    String query, {
    String lang = 'en',
  }) async {
    final accuLang = lang == 'fa' ? 'fa-ir' : (lang == 'en' ? 'en-us' : lang);
    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/locations/v1/cities/search',
      {'apikey': _apiKey, 'q': query, 'language': accuLang},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('AccuWeather resolveCity error: ${response.statusCode}');
          print(response.body);
        }
        return null;
      }
      final data = json.decode(response.body) as List<dynamic>;
      if (data.isEmpty) return null;
      final first = data.first as Map<String, dynamic>;

      return {
        'name': first['LocalizedName'],
        'lat': first['GeoPosition']['Latitude'],
        'lon': first['GeoPosition']['Longitude'],
        'country': first['Country']['ID'],
        'state': first['AdministrativeArea']['ID'],
        'key': first['Key'], // AccuWeather specific
      };
    } catch (e) {
      if (kDebugMode) print('AccuWeather resolveCity exception: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
    String query, {
    int limit = 10,
    String lang = 'en',
  }) async {
    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/locations/v1/cities/autocomplete',
      {'apikey': _apiKey, 'q': query, 'language': lang},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as List<dynamic>;

      return data.map((item) {
        final m = item as Map<String, dynamic>;
        return {
          'name': m['LocalizedName'],
          'key': m['Key'],
          'country': m['Country']?['ID'] ?? '',
          'state': m['AdministrativeArea']?['ID'] ?? '',
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
    String lang = 'en',
  }) async {
    String? key;
    String name = cityName ?? '';

    if (lat != null && lon != null) {
      key = await _getLocationKey(lat, lon);
    } else if (cityName != null) {
      final res = await resolveCity(cityName, lang: lang);
      key = res?['key'];
      name = res?['name'] ?? cityName;
    }

    if (key == null) return null;

    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/currentconditions/v1/$key',
      {'apikey': _apiKey, 'details': 'true', 'language': lang},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final dataList = json.decode(response.body) as List<dynamic>;
      if (dataList.isEmpty) return null;
      final data = dataList.first as Map<String, dynamic>;

      // Map AccuWeather to our generic OWM-like structure for now,
      // or rethink the model to be more generic.
      // For speed, let's map to look like OWM for CurrentWeather.fromJson.
      return {
        'name': name,
        'weather': [
          {
            'description': data['WeatherText'],
            'main': _mapAccuIconToMain(data['WeatherIcon']),
          },
        ],
        'main': {
          'temp': data['Temperature']['Metric']['Value'],
          'feels_like': data['RealFeelTemperature']['Metric']['Value'],
          'humidity': data['RelativeHumidity'],
        },
        'wind': {'speed': data['Wind']['Speed']['Metric']['Value']},
        'coord': {'lat': lat ?? 0.0, 'lon': lon ?? 0.0},
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
    String lang = 'en',
  }) async {
    final key = await _getLocationKey(lat, lon);
    if (key == null) return [];

    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/forecasts/v1/daily/5day/$key',
      {
        'apikey': _apiKey,
        'metric': 'true',
        'language': lang,
        'details': 'true',
      },
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['DailyForecasts'] as List<dynamic>;

      // Map to OWM-like structure for DailyForecastEntry.fromJson
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return {
          'dt_txt': m['Date'],
          'main': {
            'temp_min': m['Temperature']['Minimum']['Value'],
            'temp_max': m['Temperature']['Maximum']['Value'],
            'humidity': m['Day']['RelativeHumidityAverage'] ?? 0,
          },
          'wind': {'speed': m['Day']['Wind']['Speed']['Value']},
          'weather': [
            {'main': _mapAccuIconToMain(m['Day']['Icon'])},
          ],
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 24,
    String lang = 'en',
  }) async {
    final key = await _getLocationKey(lat, lon);
    if (key == null) return null;

    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/forecasts/v1/hourly/12hour/$key',
      {'apikey': _apiKey, 'metric': 'true', 'language': lang},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as List<dynamic>;

      final entries = data.map((item) {
        final m = item as Map<String, dynamic>;
        return {
          'dt_txt': m['DateTime'],
          'main': {'temp': m['Temperature']['Value']},
          'weather': [
            {'main': _mapAccuIconToMain(m['WeatherIcon'])},
          ],
        };
      }).toList();

      return HourlyForecastResponse(entries: entries, timezoneOffsetSeconds: 0);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    // AccuWeather Air Quality is often part of the daily forecast or a separate index API.
    // For simplicity and since we want ALL pollutants, OWM is better.
    // However, if we MUST use AccuWeather, we can try their Indices API.
    final key = await _getLocationKey(lat, lon);
    if (key == null) return null;

    final uri = Uri.https(
      'dataservice.accuweather.com',
      '/airquality/v1/observations/$key',
      {'apikey': _apiKey},
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      // Note: AccuWeather structure is very different.
      // We'd need a adapter to make it work with our PM2.5 calculation or return their index directly.
      // For now, let's keep it null and maybe fallback to OWM in ViewModel if needed,
      // or implement the mapping here.
      return null;
    } catch (_) {
      return null;
    }
  }

  String _mapAccuIconToMain(int? iconCode) {
    if (iconCode == null) return 'Clear';
    // Mapping table: https://developer.accuweather.com/weather-icons
    if (iconCode <= 4) return 'Clear';
    if (iconCode == 5) return 'Haze';
    if (iconCode <= 11) return 'Clouds';
    if (iconCode == 11) return 'Fog';
    if (iconCode <= 14) return 'Rain'; // Showers
    if (iconCode <= 17) return 'Thunderstorm';
    if (iconCode == 18) return 'Rain';
    if (iconCode <= 21) return 'Rain'; // Flurries/Snow/Ice
    if (iconCode <= 23) return 'Snow';
    if (iconCode == 24) return 'Snow'; // Ice
    if (iconCode == 25) return 'Rain'; // Sleet
    if (iconCode == 26) return 'Rain'; // Freezing Rain
    if (iconCode == 29) return 'Rain'; // Rain and Snow
    if (iconCode == 30) return 'Clear'; // Hot
    if (iconCode == 31) return 'Clear'; // Cold
    if (iconCode == 32) return 'Squall'; // Windy
    if (iconCode <= 35) return 'Clear'; // Night versions
    if (iconCode == 36) return 'Haze';
    if (iconCode <= 42) return 'Clouds';
    if (iconCode == 43) return 'Snow';
    if (iconCode == 44) return 'Snow';
    return 'Clear';
  }
}
