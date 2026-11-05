import { onCall } from 'firebase-functions/https';

import { fail } from '../common/fail';
import { bucket, db } from '../common/app';
import { callOptions } from '../common/call_options';
import { Collections } from '../common/fields';
import { isModerator, requireVerifiedUser } from '../common/guards';
import { RecordLimits } from '../domain/limits';
import { parseRecordId } from '../domain/record_input';

/** Временная подписанная ссылка на видео: автору, модератору и всем для одобренного рекорда. */
export const recordVideoUrl = onCall(callOptions, async (request) => {
  const uid = requireVerifiedUser(request);
  const recordId = parseRecordId(request.data);
  if (!recordId) {
    throw fail('invalid-argument', 'invalid-record');
  }
  const record = (await db.collection(Collections.records).doc(recordId).get()).data();
  if (!record) {
    throw fail('not-found', 'record-not-found');
  }
  const allowed =
    record.uid === uid || record.status === 'approved' || (await isModerator(uid));
  if (!allowed) {
    throw fail('permission-denied', 'video-hidden');
  }
  const expiresAt = Date.now() + RecordLimits.signedUrlMinutes * 60_000;
  return { url: await signedUrl(record.videoPath as string, expiresAt), expiresAt };
});

/** Подписанная ссылка; эмулятор Storage подписи не поддерживает и отдаёт файл по прямой ссылке. */
async function signedUrl(path: string, expiresAt: number): Promise<string> {
  const file = bucket().file(path);
  const emulator = process.env.FIREBASE_STORAGE_EMULATOR_HOST;
  if (emulator) {
    return `http://${emulator}/v0/b/${file.bucket.name}/o/${encodeURIComponent(path)}?alt=media`;
  }
  const [url] = await file.getSignedUrl({ version: 'v4', action: 'read', expires: expiresAt });
  return url;
}
