import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService? _instance;

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  static const MethodChannel _defaultBatteryChannel = MethodChannel(
    'com.example.habit_tracker/battery_optimization',
  );

  MethodChannel batteryChannel = _defaultBatteryChannel;

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final identifier = timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(identifier));
      debugPrint('NotificationService: Timezone initialized to $identifier');
    } catch (e) {
      debugPrint('NotificationService: Error getting timezone: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const fln.LinuxInitializationSettings initializationSettingsLinux =
        fln.LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        );

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
      },
    );

    // Create Notification Channels explicitly on Android
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          'daily_reminder_channel',
          'Daily Reminders',
          description: 'Daily reminders for your habits',
          importance: fln.Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          'immediate_channel',
          'Immediate Notifications',
          description: 'Notifications that show immediately',
          importance: fln.Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          'fcm_channel',
          'Firebase Notifications',
          description: 'Notifications received from Firebase Cloud Messaging',
          importance: fln.Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );
    }

    _isInitialized = true;
  }

  /// Checks if the application is exempted from battery optimizations on Android.
  /// On other platforms, returns true.
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final result = await batteryChannel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? true;
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to check battery optimizations: $e',
      );
      return true;
    }
  }

  /// Requests direct battery optimization exemption dialog (ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final result = await batteryChannel.invokeMethod<bool>(
        'requestIgnoreBatteryOptimizations',
      );
      return result ?? false;
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to request battery optimization exemption: $e',
      );
      return false;
    }
  }

  /// Opens system battery optimization settings for manual user review/exemption.
  Future<bool> openBatteryOptimizationSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final result = await batteryChannel.invokeMethod<bool>(
        'openBatteryOptimizationSettings',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('NotificationService: Failed to open battery settings: $e');
      return false;
    }
  }

  /// Opens application details settings in Android OS (useful for HyperOS Autostart/Battery).
  Future<bool> openAppSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      final result = await batteryChannel.invokeMethod<bool>('openAppSettings');
      return result ?? false;
    } catch (e) {
      debugPrint('NotificationService: Failed to open app settings: $e');
      return false;
    }
  }

  Future<bool> requestPermissions({bool requestBatteryExemption = true}) async {
    bool granted = false;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final notifGranted = await androidPlugin.requestNotificationsPermission();

      try {
        final canExact =
            await androidPlugin.canScheduleExactNotifications() ?? false;
        if (!canExact) {
          await androidPlugin.requestExactAlarmsPermission();
        }
      } catch (e) {
        debugPrint(
          'NotificationService: Could not check/request exact alarm permission: $e',
        );
      }

      granted = notifGranted ?? false;

      if (requestBatteryExemption &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android) {
        final ignoring = await isIgnoringBatteryOptimizations();
        if (!ignoring) {
          await requestIgnoreBatteryOptimizations();
        }
      }
    }

    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final iosGranted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = iosGranted ?? false;
    }

    return granted;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'immediate_channel',
    String channelName = 'Immediate Notifications',
    String? payload,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Habit Tracker notifications',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const fln.DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: const fln.LinuxNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  Future<void> showTestNotification({
    String title = 'Habit Tracker',
    String body = 'Notifications are working successfully.',
  }) async {
    await showNotification(
      id: 777,
      title: title,
      body: body,
      channelId: 'immediate_channel',
      channelName: 'Immediate Notifications',
      payload: 'test_notification_payload',
    );
  }

  Future<void> _ensureTimezoneInitialized() async {
    if (tz.local.name == 'UTC' || tz.local.name == 'Etc/UTC') {
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        final identifier = timeZoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(identifier));
        debugPrint('NotificationService: Refreshed timezone to $identifier');
      } catch (e) {
        debugPrint('NotificationService: Could not refresh timezone: $e');
      }
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _ensureTimezoneInitialized();
    final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);
    debugPrint(
      'NotificationService: Scheduling alarm for $scheduledDate (tz: ${tz.local.name})',
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final isIgnoring = await isIgnoringBatteryOptimizations();
      if (!isIgnoring) {
        debugPrint(
          'NotificationService: Battery optimization is active. Exact alarms may be suppressed by OEM systems (Samsung OneUI/Xiaomi HyperOS).',
        );
      }
    }

    const notificationDetails = fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
      ),
      iOS: fln.DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: fln.LinuxNotificationDetails(),
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();

    bool canExact = true;
    if (androidPlugin != null) {
      try {
        canExact = await androidPlugin.canScheduleExactNotifications() ?? false;
      } catch (_) {
        canExact = false;
      }
    }

    final preferredMode = canExact
        ? fln.AndroidScheduleMode.exactAllowWhileIdle
        : fln.AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: preferredMode,
        matchDateTimeComponents: fln.DateTimeComponents.time,
        payload: 'habit_notification_payload',
      );
      debugPrint(
        'NotificationService: Scheduled successfully with mode $preferredMode',
      );
    } catch (e) {
      debugPrint(
        'Failed with exactAllowWhileIdle, falling back to inexact: $e',
      );
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: fln.DateTimeComponents.time,
          payload: 'habit_notification_payload',
        );
        debugPrint('NotificationService: Fallback scheduled successfully.');
      } catch (fallbackError) {
        debugPrint('Failed to schedule notification: $fallbackError');
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final local = tz.local;
    final now = tz.TZDateTime.now(local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }
}
