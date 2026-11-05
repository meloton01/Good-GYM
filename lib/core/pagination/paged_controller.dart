import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/result.dart';
import 'paged_result.dart';
import 'paged_state.dart';

/// Загружает список страницами; наследник задаёт только запрос одной страницы.
abstract class PagedController<T> extends Notifier<PagedState<T>> {
  bool _busy = false;

  /// Запрос страницы после [cursor].
  Future<Result<PagedResult<T>>> fetchPage(String? cursor);

  /// Начинает загрузку первой страницы.
  @override
  PagedState<T> build() {
    _busy = false;
    Future.microtask(loadMore);
    return PagedState<T>(loading: true);
  }

  /// Загружает следующую страницу, если она есть и загрузка не идёт.
  Future<void> loadMore() async {
    if (_busy || !state.hasMore) {
      return;
    }
    _busy = true;
    state = state.copyWith(loading: true);
    final result = await fetchPage(state.cursor);
    if (!ref.mounted) {
      return;
    }
    _busy = false;
    state = switch (result) {
      Success(:final value) => PagedState(
        items: [...state.items, ...value.items],
        cursor: value.nextCursor,
        hasMore: value.hasMore,
      ),
      Failure(:final failure) => state.copyWith(
        loading: false,
        failure: failure,
      ),
    };
  }

  /// Загружает список заново.
  void refresh() => ref.invalidateSelf();
}
