/** Лучшие значения пользователя в одной таблице. */
export interface LeaderboardBest {
  bestWeightKg: number;
  bestWeightRecordId: string;
  bestE1rmKg: number;
  bestE1rmRecordId: string;
  sex: string;
  weightClass: string;
}

/** Одобренный рекорд в том виде, который нужен таблицам. */
export interface ApprovedRecord {
  id: string;
  weightKg: number;
  e1rmKg: number;
  sex: string;
  weightClass: string;
}

/** Объединяет текущие лучшие значения с новым рекордом; null, если рекорд ничего не улучшил. */
export function mergeBest(
  current: LeaderboardBest | null,
  record: ApprovedRecord,
): LeaderboardBest | null {
  if (current === null) {
    return {
      bestWeightKg: record.weightKg,
      bestWeightRecordId: record.id,
      bestE1rmKg: record.e1rmKg,
      bestE1rmRecordId: record.id,
      sex: record.sex,
      weightClass: record.weightClass,
    };
  }
  const heavier = record.weightKg > current.bestWeightKg;
  const stronger = record.e1rmKg > current.bestE1rmKg;
  if (!heavier && !stronger) {
    return null;
  }
  return {
    bestWeightKg: heavier ? record.weightKg : current.bestWeightKg,
    bestWeightRecordId: heavier ? record.id : current.bestWeightRecordId,
    bestE1rmKg: stronger ? record.e1rmKg : current.bestE1rmKg,
    bestE1rmRecordId: stronger ? record.id : current.bestE1rmRecordId,
    sex: heavier ? record.sex : current.sex,
    weightClass: heavier ? record.weightClass : current.weightClass,
  };
}
