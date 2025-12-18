import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherly_app/config/config_reader.dart';
import 'package:weatherly_app/core/utils/weather_tips.dart';
import 'package:weatherly_app/data/models/current_weather.dart';
import 'package:weatherly_app/data/services/notification_service.dart';
import 'package:weatherly_app/data/services/weather_api_service.dart';
import 'package:workmanager/workmanager.dart';

// Workmanager callback for background tasks (Mobile Only)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background task executed: $task');

    if (task == 'weatherNotification') {
      try {
        // Essential initializations for background isolate
        // WidgetsFlutterBinding.ensureInitialized(); // Not needed for this
        await ConfigReader.initialize();
        final prefs = await SharedPreferences.getInstance();

        // 1. Get location
        final position = await _determinePosition();
        if (position == null) {
          debugPrint('Could not determine position. Aborting background task.');
          return true; // Returning true means the task was successful
        }

        // 2. Fetch weather
        final apiService = WeatherApiService();
        if (!apiService.isConfigured) {
          debugPrint('API key not configured. Aborting background task.');
          return true;
        }

        final lang = prefs.getString('lang') ?? 'fa';
        final weatherData = await apiService.fetchCurrentWeather(
          lat: position.latitude,
          lon: position.longitude,
          lang: lang,
        );

        if (weatherData == null) {
          debugPrint('Failed to fetch weather data. Aborting.');
          return true;
        }

        // 3. Generate smart tip
        final currentWeather = CurrentWeather.fromJson(weatherData);
        final isFarsi = lang == 'fa';
        final tip = WeatherTips.generateTip(
          weather: currentWeather,
          isFarsi: isFarsi,
        );

        // 4. Show notification
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.showWeatherNotification(
          title: tip.fullTitle,
          body: tip.message,
        );

        debugPrint('Smart notification sent successfully!');
      } catch (e, st) {
        debugPrint('Error in background task: $e\n$st');
        return false; // Return false to indicate failure and retry
      }
    }

    return true;
  });
}

/// Initialize workmanager for background tasks
Future<void> initializeWorkmanager() async {
  if (kIsWeb) return;

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  debugPrint('Workmanager initialized');
}

/// Schedule a periodic background weather check
Future<void> scheduleBackgroundWeatherCheck() async {
  if (kIsWeb) return;

  // Check if smart notifications are enabled by the user
  final prefs = await SharedPreferences.getInstance();
  final bool smartEnabled = prefs.getBool('smartNotifications') ?? true;

  if (smartEnabled) {
    await Workmanager().registerPeriodicTask(
      'weatherCheck',
      'weatherNotification',
      frequency: const Duration(hours: 3), // Check every 3 hours
      initialDelay: const Duration(minutes: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
    );
    debugPrint('Smart background weather check scheduled');
  } else {
    debugPrint('Smart notifications are disabled, skipping scheduling.');
    // Also cancel any existing task if user disabled it
    await cancelBackgroundWeatherCheck();
  }
}

/// Cancel background weather checks
Future<void> cancelBackgroundWeatherCheck() async {
  if (kIsWeb) return;

  await Workmanager().cancelByUniqueName('weatherCheck');
  debugPrint('Background weather check cancelled');
}


/// Tries to get the current location, with a fallback to the last known one.
/// Returns null if location services are disabled or permissions are denied.
Future<Position?> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    debugPrint('Location permissions are denied. Cannot run background task.');
    return null;
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint('Location permissions are permanently denied. Cannot run background task.');
    return null;
  }

  // When permissions are granted, we can get the position.
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 30),
    );
    return position;
  } catch (e) {
    debugPrint('Could not get current position, trying last known: $e');
    // Fallback to last known position if current fails
    return await Geolocator.getLastKnownPosition();
  }
}
