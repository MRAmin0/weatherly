import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('NotificationService (Web): Initialized');
  }

  Future<bool> requestPermission() async {
    try {
      if (!html.Notification.supported) {
        debugPrint(
          'NotificationService (Web): Notifications not supported in this browser',
        );
        return false;
      }

      final permission = await html.Notification.requestPermission();
      debugPrint('NotificationService (Web): Permission result: $permission');
      return permission == 'granted';
    } catch (e) {
      debugPrint('NotificationService (Web): Permission request error: $e');
      return false;
    }
  }

  Future<void> showWeatherNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!html.Notification.supported) return;

    if (html.Notification.permission != 'granted') {
      debugPrint(
        'NotificationService (Web): Permission not granted, cannot show notification',
      );
      return;
    }

    try {
      html.Notification(title, body: body, icon: 'icons/Icon-192.png');
      debugPrint('NotificationService (Web): Shown: $title');
    } catch (e) {
      debugPrint('NotificationService (Web): Show error: $e');
    }
  }

  // Web doesn't support background scheduling easily without Service Workers + Push API.
  // We'll implement a simple "while-open" timer for demonstration if needed,
  // currently just a stub or basic Timer.
  // Note: This only runs if the tab is active/open.
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    debugPrint(
      'NotificationService (Web): Schedule requested for $hour:$minute (Tab must be open)',
    );

    // Simple logic: Check every minute? Or calculate delay?
    // For now, we'll just log it as Web limitation usually requires a backend push.
    // However, we can set a helper to check time if user keeps app open.
  }

  Future<void> cancelDailyNotification() async {}
  Future<void> cancelAllScheduled() async {}
  Future<void> cancel(int id) async {}
}
