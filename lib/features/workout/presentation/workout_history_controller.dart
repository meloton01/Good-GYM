import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../data/workout_repository_provider.dart';
import 'workout_history_state.dart';

/// История тренировок пользователя по uid с подгрузкой страниц.
final workoutHistoryProvider =
    NotifierProvider.family<
      WorkoutHistoryController,
      WorkoutHistoryState,
      String
    >(WorkoutHistoryController.new);

/// Загружает историю страницами по AppLimits.pageSize.
class WorkoutHistoryController extends Notifier<WorkoutHistoryState> {
  /// Создаёт контроллер истории пользователя [uid].
  WorkoutHistoryController(this.uid);

  final String uid;
  bool _busy = false;

  /// Начинает загрузку первой страницы.
  @override
  WorkoutHistoryState build() {
    _busy = false;
    Future.microtask(loadMore);
    return const WorkoutHistoryState(loading: true);
  }

  /// Загружает следующую страницу, если она есть и загрузка не идёт.
  Future<void> loadMore() async {
    if (_busy || !state.hasMore) {
      return;
    }
    _busy = true;
    state = state.copyWith(loading: true, failure: null);
    final result = await ref
        .read(workoutRepositoryProvider)
        .fetchHistory(uid, cursor: state.cursor);
    if (!ref.mounted) {
      return;
    }
    _busy = false;
    state = switch (result) {
      Success(:final value) => state.copyWith(
        items: [...state.items, ...value.items],
        cursor: value.nextCursor,
        hasMore: value.hasMore,
        loading: false,
      ),
      Failure(:final failure) => state.copyWith(
        loading: false,
        failure: failure,
      ),
    };
  }

  /// Загружает историю заново.
  void refresh() => ref.invalidateSelf();
}
