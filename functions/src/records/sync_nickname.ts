import { onDocumentUpdated } from 'firebase-functions/firestore';

import { region } from '../common/app';
import { Collections } from '../common/fields';
import { updateWhereUid } from './batch_writes';

/** После смены ника переписывает его в рекордах и строках таблиц пользователя. */
export const syncRecordNickname = onDocumentUpdated(
  { document: `${Collections.users}/{uid}`, region },
  async (event) => {
    const before = event.data?.before.get('nickname');
    const after = event.data?.after.get('nickname');
    if (typeof after !== 'string' || before === after) {
      return;
    }
    const uid = event.params.uid;
    await updateWhereUid(Collections.records, uid, { nickname: after });
    await updateWhereUid(Collections.leaderboard, uid, { nickname: after });
  },
);
