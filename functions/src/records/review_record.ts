import { FieldValue } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/https';

import { fail } from '../common/fail';
import { db, region } from '../common/app';
import { Collections } from '../common/fields';
import { requireModerator, requireVerifiedUser } from '../common/guards';
import { parseReason, parseRecordId } from '../domain/record_input';
import { reviewBlocker } from '../domain/review';
import { writeLeaderboard } from './leaderboard_writer';

/** Одобряет рекорд и обновляет таблицы в одной транзакции. */
export const approveRecord = onCall({ region }, async (request) => {
  const moderatorId = requireVerifiedUser(request);
  const recordId = parseRecordId(request.data);
  if (!recordId) {
    throw fail('invalid-argument', 'invalid-record');
  }
  await requireModerator(moderatorId);
  const ref = db.collection(Collections.records).doc(recordId);
  await db.runTransaction(async (transaction) => {
    const record = await readReviewable(transaction, ref, moderatorId);
    await writeLeaderboard(transaction, recordId, record);
    transaction.update(ref, {
      status: 'approved',
      moderatorId,
      reviewedAt: FieldValue.serverTimestamp(),
    });
  });
  return { recordId };
});

/** Отклоняет рекорд с причиной; автор может обжаловать отказ один раз. */
export const rejectRecord = onCall({ region }, async (request) => {
  const moderatorId = requireVerifiedUser(request);
  const recordId = parseRecordId(request.data);
  const reason = parseReason((request.data as { reason?: unknown } | null)?.reason);
  if (!recordId || !reason) {
    throw fail('invalid-argument', 'invalid-review');
  }
  await requireModerator(moderatorId);
  const ref = db.collection(Collections.records).doc(recordId);
  await db.runTransaction(async (transaction) => {
    await readReviewable(transaction, ref, moderatorId);
    transaction.update(ref, {
      status: 'rejected',
      moderatorId,
      rejectionReason: reason,
      reviewedAt: FieldValue.serverTimestamp(),
    });
  });
  return { recordId };
});

/** Читает рекорд на проверке; свой или уже проверенный рекорд модератор не трогает. */
async function readReviewable(
  transaction: FirebaseFirestore.Transaction,
  ref: FirebaseFirestore.DocumentReference,
  moderatorId: string,
): Promise<FirebaseFirestore.DocumentData> {
  const snapshot = await transaction.get(ref);
  const record = snapshot.data();
  if (!record) {
    throw fail('not-found', 'record-not-found');
  }
  const blocker = reviewBlocker({ uid: record.uid, status: record.status }, moderatorId);
  if (blocker === 'own-record') {
    throw fail('permission-denied', 'own-record');
  }
  if (blocker === 'not-pending') {
    throw fail('failed-precondition', 'not-pending');
  }
  return record;
}
