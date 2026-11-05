/** Ключ таблицы за всё время. */
export const allTimeKey = 'all';

/** Ключи таблиц, в которые попадает рекорд с датой [date]: всё время, месяц и ISO-неделя по UTC. */
export function periodKeys(date: Date): string[] {
  return [allTimeKey, monthKey(date), weekKey(date)];
}

/** Ключ месяца, например «m2026-11». */
export function monthKey(date: Date): string {
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  return `m${date.getUTCFullYear()}-${month}`;
}

/** Ключ ISO-недели, например «w2026-45»; неделя относится к году своего четверга. */
export function weekKey(date: Date): string {
  const day = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const weekday = day.getUTCDay() === 0 ? 7 : day.getUTCDay();
  day.setUTCDate(day.getUTCDate() + 4 - weekday);
  const yearStart = Date.UTC(day.getUTCFullYear(), 0, 1);
  const week = Math.ceil(((day.getTime() - yearStart) / 86_400_000 + 1) / 7);
  return `w${day.getUTCFullYear()}-${String(week).padStart(2, '0')}`;
}
