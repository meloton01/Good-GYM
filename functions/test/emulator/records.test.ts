import assert from 'node:assert/strict';
import { after, before, describe, test } from 'node:test';

import { deleteApp, getApps, initializeApp as initializeAdmin } from 'firebase-admin/app';
import { getAuth as getAdminAuth } from 'firebase-admin/auth';
import { getFirestore as getAdminFirestore } from 'firebase-admin/firestore';
import { deleteApp as deleteClientApp, FirebaseApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import { connectStorageEmulator, getStorage, ref, uploadBytes } from 'firebase/storage';

const projectId = process.env.GCLOUD_PROJECT ?? 'demo-good-gym';
const password = 'secret-password';
const admin = initializeAdmin({ projectId, storageBucket: `${projectId}.appspot.com` });
const db = getAdminFirestore(admin);
const clients: FirebaseApp[] = [];

/** Клиент, вошедший как пользователь uid с подтверждённым email и профилем. */
async function signIn(uid: string, profile: Record<string, unknown>) {
  const email = `${uid}@example.com`;
  await getAdminAuth(admin)
    .createUser({ uid, email, password, emailVerified: true })
    .catch(() => undefined);
  await db.doc(`users/${uid}`).set({ nickname: uid, role: 'athlete', ...profile });
  const app = initializeApp(
    { projectId, apiKey: 'demo-key', storageBucket: `${projectId}.appspot.com` },
    uid,
  );
  clients.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}`, {
    disableWarnings: true,
  });
  await signInWithEmailAndPassword(auth, email, password);
  const functions = getFunctions(app, 'europe-west1');
  const [host, port] = (process.env.FUNCTIONS_EMULATOR_HOST ?? '127.0.0.1:5001').split(':');
  connectFunctionsEmulator(functions, host, Number(port));
  const storage = getStorage(app);
  const [storageHost, storagePort] = process.env.FIREBASE_STORAGE_EMULATOR_HOST!.split(':');
  connectStorageEmulator(storage, storageHost, Number(storagePort));
  const call = (name: string, data: unknown) => httpsCallable(functions, name)(data);
  const upload = async (uploadId: string) => {
    await uploadBytes(ref(storage, `records/${uid}/${uploadId}.mp4`), new Uint8Array(64), {
      contentType: 'video/mp4',
    });
  };
  return { call, upload };
}

/** Ожидает ошибку вызова с кодом [code] и причиной [reason]. */
async function rejects(promise: Promise<unknown>, code: string, reason?: string) {
  await assert.rejects(promise, (error: { code: string; details?: { reason?: string } }) => {
    assert.equal(error.code, `functions/${code}`);
    if (reason) {
      assert.equal(error.details?.reason, reason);
    }
    return true;
  });
}

/** Заявка на рекорд с заменой отдельных полей. */
const submission = (uploadId: string, extra: Record<string, unknown> = {}) => ({
  uploadId,
  exerciseId: 'squat',
  weightKg: 140,
  reps: 3,
  performedAt: Date.now() - 3_600_000,
  sex: 'male',
  bodyWeightKg: 82,
  ...extra,
});

/** Ждёт выполнения условия, пока фоновая функция обрабатывает событие. */
async function eventually(check: () => Promise<boolean>) {
  for (let attempt = 0; attempt < 50; attempt++) {
    if (await check()) {
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 200));
  }
  assert.fail('condition was not met');
}

const gym = { gymId: 'g1', gymName: 'Iron' };
const id = (n: number) => `record${String(n).padStart(14, '0')}`;
let alice: Awaited<ReturnType<typeof signIn>>;
let bob: Awaited<ReturnType<typeof signIn>>;
let mod: Awaited<ReturnType<typeof signIn>>;

before(async () => {
  alice = await signIn('alice', gym);
  bob = await signIn('bob', {});
  mod = await signIn('mod', { ...gym, role: 'moderator' });
});

after(async () => {
  await Promise.all(clients.map((app) => deleteClientApp(app)));
  await Promise.all(getApps().map((app) => deleteApp(app)));
});

describe('records', () => {
  test('submission is pending and the server computes e1rm and class', async () => {
    await alice.upload(id(1));
    await alice.call('submitRecord', submission(id(1)));
    const record = (await db.doc(`records/${id(1)}`).get()).data()!;
    assert.equal(record.status, 'pending');
    assert.equal(record.e1rmKg, 154);
    assert.equal(record.weightClass, 'm83');
    assert.equal(record.bodyWeightKg, undefined);
    assert.equal(record.gymId, 'g1');
    const board = await db.collection('leaderboard').where('uid', '==', 'alice').get();
    assert.equal(board.size, 0);
  });

  test('rejects missing video, missing gym, bad input and reused upload', async () => {
    await rejects(alice.call('submitRecord', submission(id(2))), 'failed-precondition', 'video-missing');
    await rejects(bob.call('submitRecord', submission(id(3))), 'failed-precondition', 'no-gym');
    await rejects(alice.call('submitRecord', submission(id(1), { weightKg: -1 })), 'invalid-argument');
    await rejects(alice.call('submitRecord', submission(id(1))), 'already-exists');
  });

  test('only a moderator approves, and never own records', async () => {
    await rejects(alice.call('approveRecord', { recordId: id(1) }), 'permission-denied', 'moderator-only');
    await mod.upload(id(4));
    await mod.call('submitRecord', submission(id(4)));
    await rejects(mod.call('approveRecord', { recordId: id(4) }), 'permission-denied', 'own-record');
  });

  test('approval fills week, month and all-time tables for the gym and globally', async () => {
    await mod.call('approveRecord', { recordId: id(1) });
    const record = (await db.doc(`records/${id(1)}`).get()).data()!;
    assert.equal(record.status, 'approved');
    assert.equal(record.moderatorId, 'mod');
    const board = await db.collection('leaderboard').where('uid', '==', 'alice').get();
    assert.equal(board.size, 6);
    const scopes = new Set(board.docs.map((doc) => doc.get('scope')));
    assert.deepEqual([...scopes].sort(), ['g1', 'global']);
    assert.ok(board.docs.every((doc) => doc.get('bestWeightKg') === 140));
    await rejects(mod.call('approveRecord', { recordId: id(1) }), 'failed-precondition', 'not-pending');
  });

  test('rejection can be appealed once', async () => {
    await alice.upload(id(5));
    await alice.call('submitRecord', submission(id(5), { weightKg: 150 }));
    await rejects(mod.call('rejectRecord', { recordId: id(5), reason: 'x' }), 'invalid-argument');
    await mod.call('rejectRecord', { recordId: id(5), reason: 'Plates are not visible' });
    await rejects(bob.call('appealRecord', { recordId: id(5) }), 'not-found');
    await alice.call('appealRecord', { recordId: id(5) });
    let record = (await db.doc(`records/${id(5)}`).get()).data()!;
    assert.equal(record.status, 'pending');
    assert.equal(record.appealed, true);
    assert.equal(record.rejectionReason, 'Plates are not visible');
    await mod.call('rejectRecord', { recordId: id(5), reason: 'Still not visible' });
    await rejects(alice.call('appealRecord', { recordId: id(5) }), 'failed-precondition', 'appeal-unavailable');
    record = (await db.doc(`records/${id(5)}`).get()).data()!;
    assert.equal(record.status, 'rejected');
  });

  test('video link for the author, moderators and approved records only', async () => {
    await alice.upload(id(6));
    await alice.call('submitRecord', submission(id(6)));
    await rejects(bob.call('recordVideoUrl', { recordId: id(6) }), 'permission-denied', 'video-hidden');
    for (const caller of [alice, mod]) {
      const result = (await caller.call('recordVideoUrl', { recordId: id(6) })).data as { url: string };
      assert.match(result.url, /records%2Falice%2F/);
    }
    const approved = (await bob.call('recordVideoUrl', { recordId: id(1) })).data as { url: string };
    assert.ok(approved.url.length > 0);
  });

  test('nickname change reaches records and tables', async () => {
    await db.doc('users/alice').update({ nickname: 'alice.new' });
    await eventually(async () => {
      const board = await db.collection('leaderboard').where('uid', '==', 'alice').get();
      const record = await db.doc(`records/${id(1)}`).get();
      return (
        record.get('nickname') === 'alice.new' &&
        board.docs.every((doc) => doc.get('nickname') === 'alice.new')
      );
    });
  });

  test('deleting record data removes records and tables of the user only', async () => {
    await alice.call('deleteRecordData', {});
    assert.equal((await db.collection('records').where('uid', '==', 'alice').get()).size, 0);
    assert.equal((await db.collection('leaderboard').where('uid', '==', 'alice').get()).size, 0);
    assert.equal((await db.collection('records').where('uid', '==', 'mod').get()).size, 1);
  });
});
