import { DocumentData, UpdateData } from 'firebase-admin/firestore';

import { db } from '../common/app';
import { RecordLimits } from '../domain/limits';

/** Удаляет пачками все документы коллекции с полем uid. */
export async function deleteWhereUid(collection: string, uid: string): Promise<void> {
  const query = db.collection(collection).where('uid', '==', uid).limit(RecordLimits.batchSize);
  for (;;) {
    const page = await query.get();
    if (page.empty) {
      return;
    }
    const batch = db.batch();
    page.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
}

/** Меняет поля пачками во всех документах коллекции с полем uid. */
export async function updateWhereUid(
  collection: string,
  uid: string,
  fields: UpdateData<DocumentData>,
): Promise<void> {
  const docs = (await db.collection(collection).where('uid', '==', uid).get()).docs;
  for (let start = 0; start < docs.length; start += RecordLimits.batchSize) {
    const batch = db.batch();
    docs
      .slice(start, start + RecordLimits.batchSize)
      .forEach((doc) => batch.update(doc.ref, fields));
    await batch.commit();
  }
}
