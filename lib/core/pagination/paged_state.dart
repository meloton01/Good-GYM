import '../errors/app_failure.dart';

/// Загруженные страницы списка, курсор следующей и итог последней загрузки.
class PagedState<T> {
  /// Создаёт состояние; [failure] задан, если последняя загрузка не удалась.
  const PagedState({
    this.items = const [],
    this.cursor,
    this.hasMore = true,
    this.loading = false,
    this.failure,
  });

  final List<T> items;
  final String? cursor;
  final bool hasMore;
  final bool loading;
  final AppFailure? failure;

  /// Копия с изменёнными полями; [failure] сбрасывается, если не передан.
  PagedState<T> copyWith({
    List<T>? items,
    String? cursor,
    bool? hasMore,
    bool? loading,
    AppFailure? failure,
  }) {
    return PagedState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      failure: failure,
    );
  }
}
