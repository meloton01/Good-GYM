/// Страница данных и курсор для загрузки следующей.
class PagedResult<T> {
  /// Создаёт страницу; [nextCursor] равен null, если данных больше нет.
  const PagedResult({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;

  /// Есть ли следующая страница.
  bool get hasMore => nextCursor != null;
}
