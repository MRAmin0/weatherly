import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    return true; // iOS handles this during initialization
  }

  /// Show a weather notification
  Future<void> showWeatherNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weatherly_weather',
      'Weather Alerts',
      channelDescription: 'Smart weather tips and alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('Notification shown: $title - $body');
  }

  /// Schedule a daily weather notification
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'weatherly_daily',
      'Daily Weather',
      channelDescription: 'Daily morning weather summary',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      0, // ID for daily notification
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    debugPrint('Daily notification scheduled for $hour:$minute');
  }

  /// Cancel daily notification
  Future<void> cancelDailyNotification() async {
    await _notifications.cancel(0);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduled() async {
    await _notifications.cancelAll();
    debugPrint('All notifications cancelled');
  }

  /// Cancel a specific notification by ID
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

// Workmanager callback for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background task executed: $task');

    if (task == 'weatherNotification') {
      // This will be called from the background
      // We'll fetch weather and show notification
      final service = NotificationService();
      await service.initialize();

      // Note: In background, we need to fetch weather data
      // This is a simplified version - actual implementation
      // would need to fetch from API
      await service.showWeatherNotification(
        title: inputData?['title'] ?? 'Weather Update',
        body: inputData?['body'] ?? 'Check the weather today!',
      );
    }

    return true;
  });
}

/// Initialize workmanager for background tasks
Future<void> initializeWorkmanager() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  debugPrint('Workmanager initialized');
}

/// Schedule a periodic background weather check
Future<void> scheduleBackgroundWeatherCheck() async {
  await Workmanager().registerPeriodicTask(
    'weatherCheck',
    'weatherNotification',
    frequency: const Duration(hours: 12), // Check twice a day
    constraints: Constraints(networkType: NetworkType.connected),
  );
  debugPrint('Background weather check scheduled');
}

/// Cancel background weather checks
Future<void> cancelBackgroundWeatherCheck() async {
  await Workmanager().cancelByUniqueName('weatherCheck');
  debugPrint('Background weather check cancelled');
}
