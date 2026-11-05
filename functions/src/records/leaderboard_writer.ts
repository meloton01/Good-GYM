import { DocumentData, FieldValue, Timestamp, Transaction } from 'firebase-admin/firestore';

import { db } from '../common/app';
import { Collections, globalScope, leaderboardId } from '../common/fields';
import { LeaderboardBest, mergeBest } from '../domain/leaderboard_entry';
import { periodKeys } from '../domain/period_keys';

/** Обновляет строки таблиц (всё время, месяц, неделя; зал и общий) одобренным рекордом. */
export async function writeLeaderboard(
  transaction: Transaction,
  recordId: string,
  record: DocumentData,
): Promise<void> {
  const performedAt = (record.performedAt as Timestamp).toDate();
  const refs = periodKeys(performedAt).flatMap((period) =>
    [globalScope, record.gymId as string].map((scope) => ({
      period,
      scope,
      ref: db
        .collection(Collections.leaderboard)
        .doc(leaderboardId(record.exerciseId, period, scope, record.uid)),
    })),
  );
  const snapshots = await transaction.getAll(...refs.map((item) => item.ref));
  refs.forEach(({ period, scope, ref }, index) => {
    const current = snapshots[index].exists ? (snapshots[index].data() as LeaderboardBest) : null;
    const best = mergeBest(current, {
      id: recordId,
      weightKg: record.weightKg,
      e1rmKg: record.e1rmKg,
      sex: record.sex,
      weightClass: record.weightClass,
    });
    if (best === null) {
      return;
    }
    transaction.set(ref, {
      ...best,
      exerciseId: record.exerciseId,
      period,
      scope,
      uid: record.uid,
      nickname: record.nickname,
      gymName: record.gymName,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
