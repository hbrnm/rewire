import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:rewire/core/navigation/app_navigator.dart';
import 'package:rewire/routes/app_router.dart';

class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const followUpId = 1001;
  static const checkInId = 1002;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      await _configureLocalTimezone();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin);

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onResponse,
      );
      _ready = true;
    } catch (error) {
      debugPrint('Notificările nu au pornit: $error');
    }
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final dynamic info = await FlutterTimezone.getLocalTimezone();
      final name = info is String ? info : (info.identifier as String);
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  void _onResponse(NotificationResponse response) {
    final payload = response.payload;
    final nav = AppNavigator.key.currentState;
    if (nav == null || payload == null) return;
    nav.pushNamed(payload);
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted == true || iosGranted == true || (granted == null && iosGranted == null);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'rewire_care',
          'Check-in-uri blânde',
          channelDescription: 'Memento-uri pe care le-ai cerut tu, nu supraveghere.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> scheduleFollowUp({
    required Duration delay,
    required bool incognito,
  }) async {
    if (!_ready) return;
    await _plugin.cancel(followUpId);
    final when = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      followUpId,
      incognito ? 'Rewire' : 'Cum e acum?',
      incognito
          ? 'Un check-in scurt, când ai o clipă.'
          : 'Fără presiune. Doar un check-in, dacă vrei.',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: AppRouter.followUp,
    );
  }

  Future<void> scheduleDailyCheckIn(int hour, {required bool incognito}) async {
    if (!_ready) return;
    await _plugin.cancel(checkInId);
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      checkInId,
      incognito ? 'Rewire' : 'Spark e aici',
      incognito
          ? 'Un moment pentru tine, dacă vrei.'
          : 'E ora pe care ai ales-o. Fără judecată.',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: AppRouter.home,
    );
  }

  Future<void> cancelDailyCheckIn() => _plugin.cancel(checkInId);

  Future<void> cancelFollowUp() => _plugin.cancel(followUpId);
}
