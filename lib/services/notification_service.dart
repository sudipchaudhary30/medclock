import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart';
import '../config/routes.dart';
import '../services/navigation_service.dart';
import '../../models/notification_model.dart';

class NotificationService {
  final ApiService _apiService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  late final Future<void> _initializationFuture = _doInit();

  NotificationService(this._apiService);

  Future<void> init() => _initializationFuture;

  Future<void> _doInit() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationTap(details.payload!);
          });
        }
      },
      onDidReceiveBackgroundNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationTap(details.payload!);
          });
        }
      },
    );

    final notificationAppLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationTap(payload);
        });
      }
    }

    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initializationFuture;
    }
  }

  void _handleNotificationTap(String payload) {
    Map<String, dynamic> args;
    try {
      args = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      args = {'medicationName': payload};
    }

    final navigator = appNavigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pushNamed(AppRoutes.alarm, arguments: args);
    } else {
      navigator?.pushNamed(AppRoutes.alarm, arguments: args);
    }
  }

  int _notificationIdForReminderDay(String reminderId, int weekday) {
    var hash = 0;
    for (var unit in reminderId.codeUnits) {
      hash = ((hash << 5) - hash) + unit;
      hash &= 0x7fffffff;
    }
    return hash ^ weekday;
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> scheduleWeeklyReminderNotifications({
    required String reminderId,
    required String title,
    required String body,
    required String scheduledTime,
    required List<String> days,
    String? payload,
    // Medication details for the alarm screen
    String? medicationName,
    String? dosage,
    String? form,
    String? pillPhotoUrl,
    String? instruction,
  }) async {
    await _ensureInitialized();

    final parts = scheduledTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    // Build a rich payload containing all medication details the AlarmScreen needs.
    final alarmPayload =
        payload ??
        jsonEncode({
          'reminderId': reminderId,
          'scheduledTime': scheduledTime,
          if (medicationName != null) 'medicationName': medicationName,
          if (dosage != null) 'dosage': dosage,
          if (form != null) 'form': form,
          if (pillPhotoUrl != null) 'pillPhotoUrl': pillPhotoUrl,
          if (instruction != null) 'instruction': instruction,
        });

    const androidDetails = AndroidNotificationDetails(
      'medclock_alarms',
      'Medication Alarms',
      channelDescription: 'Full-screen alarm for medication reminders',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final weekdayMap = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    for (final day in days) {
      final weekday = weekdayMap[day.trim()];
      if (weekday == null) continue;

      final scheduleDate = _nextInstanceOfWeekdayAndTime(weekday, hour, minute);
      final notificationId = _notificationIdForReminderDay(reminderId, weekday);
      try {
        await _localNotifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduleDate,
          notificationDetails,
          payload: alarmPayload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (e) {
        debugPrint('Exact alarm scheduling failed for $reminderId: $e');
        await showLocalNotification(
          id: notificationId,
          title: title,
          body: body,
          payload: alarmPayload,
        );
      }
    }
  }

  Future<void> cancelReminderNotifications(
    String reminderId,
    List<String> days,
  ) async {
    await _ensureInitialized();

    final weekdayMap = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    for (final day in days) {
      final weekday = weekdayMap[day.trim()];
      if (weekday == null) continue;
      final notificationId = _notificationIdForReminderDay(reminderId, weekday);
      await _localNotifications.cancel(notificationId);
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'medclock_reminders',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<List<NotificationModel>> getNotifications() async {
    await _ensureInitialized();

    try {
      final response = await _apiService.client.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }
}
