import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// LocalNotificationService
///
/// Handles scheduling and cancellation of local notifications for Android.
/// All methods are no-ops on Chrome/Web (kIsWeb guard) so the app never crashes.
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  static Future<void> init() async {
    if (kIsWeb) return; // Web is not supported by flutter_local_notifications

    if (_initialized) return;

    tz.initializeTimeZones();
    // Use UTC as the local timezone fallback — avoids requiring flutter_native_timezone
    tz.setLocalLocation(tz.UTC);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // Notification Details
  // ---------------------------------------------------------------------------

  static NotificationDetails _buildDetails() {
    const androidDetails = AndroidNotificationDetails(
      'lifeos_reminders', // channel id
      'OSLife Reminders', // channel name
      channelDescription: 'Reminder notifications for tasks, events, goals, and study items',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    return const NotificationDetails(android: androidDetails);
  }

  // ---------------------------------------------------------------------------
  // Schedule a future notification
  // ---------------------------------------------------------------------------

  /// [id] — unique int derived from item.id.hashCode
  /// [scheduledTime] — the DateTime the notification should fire
  static Future<void> scheduleReminder(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    if (kIsWeb || !_initialized) return;

    // Don't schedule notifications for times already in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ---------------------------------------------------------------------------
  // Cancel a specific notification
  // ---------------------------------------------------------------------------

  static Future<void> cancelReminder(int id) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Cancel ALL notifications
  // ---------------------------------------------------------------------------

  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Derive a stable int ID from a String item ID
  // ---------------------------------------------------------------------------

  /// Converts an item's string id to a consistent int notification id.
  static int notificationIdFor(String itemId) => itemId.hashCode.abs();
}
