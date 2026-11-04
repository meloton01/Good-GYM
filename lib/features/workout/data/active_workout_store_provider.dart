import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_preferences_provider.dart';
import '../domain/rest_alarm.dart';
import 'local_active_workout_store.dart';
import 'local_notifications_rest_alarm.dart';

/// Хранилище идущей тренировки на устройстве.
final activeWorkoutStoreProvider = Provider<LocalActiveWorkoutStore>(
  (ref) => LocalActiveWorkoutStore(ref.watch(sharedPreferencesProvider)),
);

/// Уведомление об окончании отдыха; в тестах подменяется через overrides.
final restAlarmProvider = Provider<RestAlarm>(
  (ref) => LocalNotificationsRestAlarm(FlutterLocalNotificationsPlugin()),
);
