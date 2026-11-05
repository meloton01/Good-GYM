/// Период, за который строится таблица рекордов.
enum LeaderboardPeriod {
  week,
  month,
  allTime;

  /// Ключ таблицы на дату [now] по UTC; совпадает с функциями: «w2026-45», «m2026-11», «all».
  String keyAt(DateTime now) {
    final date = now.toUtc();
    return switch (this) {
      LeaderboardPeriod.allTime => 'all',
      LeaderboardPeriod.month =>
        'm${date.year}-${date.month.toString().padLeft(2, '0')}',
      LeaderboardPeriod.week => _weekKey(date),
    };
  }

  /// ISO-неделя относится к году своего четверга.
  static String _weekKey(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final thursday = day.add(Duration(days: DateTime.thursday - day.weekday));
    final yearStart = DateTime.utc(thursday.year);
    final week = thursday.difference(yearStart).inDays ~/ 7 + 1;
    return 'w${thursday.year}-${week.toString().padLeft(2, '0')}';
  }
}
