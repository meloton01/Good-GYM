import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/time/clock_provider.dart';
import '../data/active_workout_store_provider.dart';
import '../domain/rest_alarm_text.dart';
import 'rest_timer_state.dart';

/// Таймер отдыха; конец хранится на устройстве, уведомление ставит система.
final restTimerProvider =
    NotifierProvider<RestTimerController, RestTimerState?>(
      RestTimerController.new,
    );

/// Запускает, продлевает и останавливает отдых между подходами.
class RestTimerController extends Notifier<RestTimerState?> {
  Timer? _timer;

  /// Восстанавливает отдых, который ещё не закончился к перезапуску приложения.
  @override
  RestTimerState? build() {
    ref.onDispose(() => _timer?.cancel());
    final saved = ref.read(activeWorkoutStoreProvider).loadRest();
    if (saved == null) {
      return null;
    }
    final (endsAt, total) = saved;
    final restored = RestTimerState(endsAt: endsAt, totalSeconds: total);
    if (restored.remaining(ref.read(clockProvider)()) == Duration.zero) {
      unawaited(ref.read(activeWorkoutStoreProvider).saveRest(null, 0));
      return null;
    }
    _arm(restored);
    return restored;
  }

  /// Начинает отдых на [seconds]; при [notify] ставит системное уведомление.
  Future<Result<void>> start(
    int seconds, {
    required RestAlarmText text,
    required bool notify,
  }) {
    final endsAt = ref.read(clockProvider)().add(Duration(seconds: seconds));
    return _set(
      RestTimerState(endsAt: endsAt, totalSeconds: seconds),
      text: text,
      notify: notify,
    );
  }

  /// Продлевает текущий отдых на [seconds].
  Future<Result<void>> extend(
    int seconds, {
    required RestAlarmText text,
    required bool notify,
  }) {
    final current = state;
    if (current == null) {
      return Future.value(const Success(null));
    }
    return _set(
      RestTimerState(
        endsAt: current.endsAt.add(Duration(seconds: seconds)),
        totalSeconds: current.totalSeconds + seconds,
      ),
      text: text,
      notify: notify,
    );
  }

  /// Останавливает отдых и снимает уведомление.
  Future<void> stop() async {
    _timer?.cancel();
    if (state == null) {
      return;
    }
    state = null;
    await ref.read(activeWorkoutStoreProvider).saveRest(null, 0);
    await ref.read(restAlarmProvider).cancel();
  }

  /// Применяет отдых, сохраняет его и ставит уведомление; ошибка уведомления не мешает таймеру.
  Future<Result<void>> _set(
    RestTimerState next, {
    required RestAlarmText text,
    required bool notify,
  }) async {
    state = next;
    _arm(next);
    final stored = await ref
        .read(activeWorkoutStoreProvider)
        .saveRest(next.endsAt, next.totalSeconds);
    if (stored is Failure<void>) {
      return stored;
    }
    final alarm = ref.read(restAlarmProvider);
    if (!notify) {
      await alarm.cancel();
      return const Success(null);
    }
    return alarm.schedule(next.endsAt, text);
  }

  /// Взводит внутренний таймер, который сбросит состояние в конце отдыха.
  void _arm(RestTimerState next) {
    _timer?.cancel();
    _timer = Timer(next.remaining(ref.read(clockProvider)()), () {
      state = null;
      unawaited(ref.read(activeWorkoutStoreProvider).saveRest(null, 0));
    });
  }
}
