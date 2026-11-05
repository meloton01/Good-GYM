import { onCall } from 'firebase-functions/https';

import { bucket, region } from '../common/app';
import { Collections, videoFolder } from '../common/fields';
import { requireVerifiedUser } from '../common/guards';
import { deleteWhereUid } from './batch_writes';

/** Удаляет рекорды, строки таблиц и видео пользователя перед удалением аккаунта. */
export const deleteRecordData = onCall({ region }, async (request) => {
  const uid = requireVerifiedUser(request);
  await deleteWhereUid(Collections.records, uid);
  await deleteWhereUid(Collections.leaderboard, uid);
  await bucket().deleteFiles({ prefix: videoFolder(uid) });
  return { deleted: true };
});
