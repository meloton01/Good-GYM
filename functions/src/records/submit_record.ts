import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/https';

import { fail } from '../common/fail';
import { bucket, db, region } from '../common/app';
import { Collections, videoPath } from '../common/fields';
import { requireVerifiedUser } from '../common/guards';
import { RecordLimits } from '../domain/limits';
import { estimateOneRepMax } from '../domain/one_rep_max';
import { parseRecordInput } from '../domain/record_input';
import { weightClassFor } from '../domain/weight_class';

/** Создаёт рекорд со статусом pending по уже загруженному видео; e1rm и категорию считает сервер. */
export const submitRecord = onCall({ region }, async (request) => {
  const uid = requireVerifiedUser(request);
  const input = parseRecordInput(request.data, new Date());
  if (!input) {
    throw fail('invalid-argument', 'invalid-record');
  }
  const profile = await db.collection(Collections.users).doc(uid).get();
  const gymId = profile.get('gymId');
  const gymName = profile.get('gymName');
  if (typeof gymId !== 'string' || typeof gymName !== 'string') {
    throw fail('failed-precondition', 'no-gym');
  }
  await checkVideo(uid, input.uploadId);
  await checkSubmissionLimits(uid);

  const record = db.collection(Collections.records).doc(input.uploadId);
  try {
    await record.create({
      uid,
      nickname: profile.get('nickname'),
      gymId,
      gymName,
      exerciseId: input.exerciseId,
      weightKg: input.weightKg,
      reps: input.reps,
      e1rmKg: estimateOneRepMax(input.weightKg, input.reps),
      sex: input.sex,
      weightClass: weightClassFor(input.sex, input.bodyWeightKg),
      videoPath: videoPath(uid, input.uploadId),
      status: 'pending',
      appealed: false,
      performedAt: Timestamp.fromDate(input.performedAt),
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    if ((error as { code?: number }).code === 6) {
      throw fail('already-exists', 'record-exists');
    }
    throw error;
  }
  return { recordId: record.id };
});

/** Видео загружено владельцем, это видео и оно не больше лимита; неподходящий файл удаляется. */
async function checkVideo(uid: string, uploadId: string): Promise<void> {
  const file = bucket().file(videoPath(uid, uploadId));
  const [exists] = await file.exists();
  if (!exists) {
    throw fail('failed-precondition', 'video-missing');
  }
  const [metadata] = await file.getMetadata();
  const size = Number(metadata.size ?? 0);
  const isVideo = String(metadata.contentType ?? '').startsWith('video/');
  if (!isVideo || size <= 0 || size > RecordLimits.maxVideoBytes) {
    await file.delete({ ignoreNotFound: true });
    throw fail('invalid-argument', 'video-invalid');
  }
}

/** Ограничивает число рекордов на проверке и подач за сутки. */
async function checkSubmissionLimits(uid: string): Promise<void> {
  const records = db.collection(Collections.records).where('uid', '==', uid);
  const dayAgo = Timestamp.fromMillis(Date.now() - 86_400_000);
  const [pending, today] = await Promise.all([
    records.where('status', '==', 'pending').count().get(),
    records.where('createdAt', '>=', dayAgo).count().get(),
  ]);
  if (
    pending.data().count >= RecordLimits.maxPendingPerUser ||
    today.data().count >= RecordLimits.maxSubmissionsPerDay
  ) {
    throw fail('resource-exhausted', 'too-many-records');
  }
}
