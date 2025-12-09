import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    debugPrint('NotificationService (Web): Initialize called - No Op');
  }

  Future<bool> requestPermission() async {
    debugPrint('NotificationService (Web): Request Permission called - No Op');
    return false;
  }

  Future<void> showWeatherNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('NotificationService (Web): Show Notification: $title - $body');
    // Here you could implement actual Web Notifications API logic later
    // using dart:html or package:web if desired.
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    debugPrint(
      'NotificationService (Web): Schedule Notification called - No Op',
    );
  }

  Future<void> cancelDailyNotification() async {}
  Future<void> cancelAllScheduled() async {}
  Future<void> cancel(int id) async {}
}
