import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weatherly_app/data/services/notification_service.dart';

// Workmanager callback for background tasks (Mobile Only)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background task executed: $task');

    if (task == 'weatherNotification') {
      final service = NotificationService();
      await service.initialize();

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
  if (kIsWeb) return; // Workmanager not supported on Web

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  debugPrint('Workmanager initialized');
}

/// Schedule a periodic background weather check
Future<void> scheduleBackgroundWeatherCheck() async {
  if (kIsWeb) return;

  await Workmanager().registerPeriodicTask(
    'weatherCheck',
    'weatherNotification',
    frequency: const Duration(hours: 12),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  debugPrint('Background weather check scheduled');
}

/// Cancel background weather checks
Future<void> cancelBackgroundWeatherCheck() async {
  if (kIsWeb) return;

  await Workmanager().cancelByUniqueName('weatherCheck');
  debugPrint('Background weather check cancelled');
}
