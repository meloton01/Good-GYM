import { FieldValue } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/https';

import { fail } from '../common/fail';
import { db } from '../common/app';
import { callOptions } from '../common/call_options';
import { Collections } from '../common/fields';
import { requireVerifiedUser } from '../common/guards';
import { parseRecordId } from '../domain/record_input';
import { canAppeal } from '../domain/review';

/** Возвращает отклонённый рекорд на проверку; причина прошлого отказа сохраняется. */
export const appealRecord = onCall(callOptions, async (request) => {
  const uid = requireVerifiedUser(request);
  const recordId = parseRecordId(request.data);
  if (!recordId) {
    throw fail('invalid-argument', 'invalid-record');
  }
  const ref = db.collection(Collections.records).doc(recordId);
  await db.runTransaction(async (transaction) => {
    const record = (await transaction.get(ref)).data();
    if (!record || record.uid !== uid) {
      throw fail('not-found', 'record-not-found');
    }
    if (!canAppeal({ uid: record.uid, status: record.status, appealed: record.appealed }, uid)) {
      throw fail('failed-precondition', 'appeal-unavailable');
    }
    transaction.update(ref, {
      status: 'pending',
      appealed: true,
      appealedAt: FieldValue.serverTimestamp(),
    });
  });
  return { recordId };
});
