import 'package:flutter/foundation.dart';

/// Идущий отдых между подходами.
@immutable
class RestTimerState {
  /// Создаёт состояние отдыха, который закончится в [endsAt].
  const RestTimerState({required this.endsAt, required this.totalSeconds});

  final DateTime endsAt;

  /// Полная длительность отдыха для шкалы прогресса.
  final int totalSeconds;

  /// Сколько осталось отдыхать на момент [now]; не меньше нуля.
  Duration remaining(DateTime now) {
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}
