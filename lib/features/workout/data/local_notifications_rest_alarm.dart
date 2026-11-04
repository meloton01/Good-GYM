import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/rest_alarm.dart';
import '../domain/rest_alarm_text.dart';

/// Уведомление об окончании отдыха через системный планировщик Android и iOS.
class LocalNotificationsRestAlarm implements RestAlarm {
  /// Создаёт будильник поверх плагина уведомлений.
  LocalNotificationsRestAlarm(this._plugin);

  static const int _notificationId = 1;
  static const String _channelId = 'rest_timer';
  static const String _androidIcon = '@mipmap/ic_launcher';

  final FlutterLocalNotificationsPlugin _plugin;
  bool? _permitted;

  /// Планирует уведомление; при первом вызове инициализирует плагин и спрашивает разрешение.
  @override
  Future<Result<void>> schedule(DateTime at, RestAlarmText text) async {
    if (kIsWeb) {
      return const Failure(AppFailure.notificationsDenied);
    }
    try {
      if (!await _ensurePermission()) {
        return const Failure(AppFailure.notificationsDenied);
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final exact = await android?.canScheduleExactNotifications() ?? false;
      await _plugin.zonedSchedule(
        id: _notificationId,
        title: text.title,
        body: text.body,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            text.channelName,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return const Success(null);
    } on PlatformException catch (error) {
      return Failure(AppFailure.notificationsDenied, cause: error);
    }
  }

  /// Снимает запланированное уведомление.
  @override
  Future<void> cancel() async {
    if (kIsWeb || _permitted == null) {
      return;
    }
    await _plugin.cancel(id: _notificationId);
  }

  /// Инициализирует плагин и запрашивает разрешение на уведомления один раз за запуск.
  Future<bool> _ensurePermission() async {
    final cached = _permitted;
    if (cached != null) {
      return cached;
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        false;
    _permitted = granted;
    return granted;
  }
}
