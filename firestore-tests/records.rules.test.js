import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const verified = { email_verified: true, firebase: { sign_in_provider: 'password' } };

let env;

/** Firestore от имени пользователя uid с подтверждённым email. */
const as = (uid) => env.authenticatedContext(uid, verified).firestore();

/** Storage от имени пользователя uid с подтверждённым email. */
const storageAs = (uid) => env.authenticatedContext(uid, verified).storage();

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

/** Профиль с ролью, залом и видимостью рекордов. */
const user = (nickname, extra = {}) => ({
  nickname,
  role: 'athlete',
  recordsVisibility: 'everyone',
  gymId: 'g1',
  ...extra,
});

/** Рекорд в формате функции submitRecord. */
const record = (uid, status, extra = {}) => ({
  uid,
  nickname: uid,
  gymId: 'g1',
  gymName: 'Iron',
  exerciseId: 'squat',
  weightKg: 140,
  reps: 3,
  e1rmKg: 154,
  sex: 'male',
  weightClass: 'm83',
  videoPath: `records/${uid}/abcdefghij0123456789.mp4`,
  status,
  appealed: false,
  performedAt: new Date(),
  createdAt: new Date(),
  ...extra,
});

const video = new Uint8Array([0, 0, 0, 24, 102, 116, 121, 112]);
const fileName = 'abcdefghij0123456789.mp4';

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-good-gym',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
    storage: { rules: readFileSync('../storage.rules', 'utf8') },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed('users/alice', user('alice'));
  await seed('users/bob', user('bob'));
  await seed('users/mod', user('mod', { role: 'moderator' }));
});

after(() => env.cleanup());

describe('records', () => {
  test('client cannot create or approve a record', async () => {
    await assertFails(setDoc(doc(as('alice'), 'records/r1'), record('alice', 'pending')));
    await assertFails(setDoc(doc(as('alice'), 'records/r2'), record('alice', 'approved')));
    await seed('records/r3', record('alice', 'pending'));
    await assertFails(updateDoc(doc(as('alice'), 'records/r3'), { status: 'approved' }));
    await assertFails(updateDoc(doc(as('mod'), 'records/r3'), { status: 'approved' }));
    await assertFails(deleteDoc(doc(as('alice'), 'records/r3')));
  });

  test('pending record is visible to the author and moderators only', async () => {
    await seed('records/r1', record('alice', 'pending'));
    await assertSucceeds(getDoc(doc(as('alice'), 'records/r1')));
    await assertSucceeds(getDoc(doc(as('mod'), 'records/r1')));
    await assertFails(getDoc(doc(as('bob'), 'records/r1')));
  });

  test('moderator lists the queue, others cannot', async () => {
    const queue = (db) =>
      getDocs(query(collection(db, 'records'), where('status', '==', 'pending'), orderBy('createdAt')));
    await assertSucceeds(queue(as('mod')));
    await assertFails(queue(as('bob')));
  });

  test('approved history follows records visibility', async () => {
    await seed('records/r1', record('alice', 'approved'));
    const history = (db) =>
      getDocs(
        query(
          collection(db, 'records'),
          where('uid', '==', 'alice'),
          where('status', '==', 'approved'),
          orderBy('performedAt', 'desc'),
        ),
      );
    await assertSucceeds(history(as('bob')));

    await seed('users/alice', user('alice', { recordsVisibility: 'gymMembers' }));
    await assertSucceeds(history(as('bob')));
    await seed('users/bob', user('bob', { gymId: 'g2' }));
    await assertFails(history(as('bob')));

    await seed('users/alice', user('alice', { recordsVisibility: 'onlyMe' }));
    await assertFails(getDoc(doc(as('bob'), 'records/r1')));
    await assertSucceeds(history(as('alice')));
  });

  test('others cannot list all records of a user', async () => {
    await seed('records/r1', record('alice', 'pending'));
    await assertFails(getDocs(query(collection(as('bob'), 'records'), where('uid', '==', 'alice'))));
    await assertSucceeds(getDocs(query(collection(as('alice'), 'records'), where('uid', '==', 'alice'))));
  });
});

describe('leaderboard', () => {
  test('signed-in users read, nobody writes', async () => {
    await seed('leaderboard/e1', { uid: 'alice', bestWeightKg: 140 });
    await assertSucceeds(getDoc(doc(as('bob'), 'leaderboard/e1')));
    await assertFails(setDoc(doc(as('alice'), 'leaderboard/e2'), { uid: 'alice', bestWeightKg: 300 }));
    await assertFails(updateDoc(doc(as('alice'), 'leaderboard/e1'), { bestWeightKg: 300 }));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'leaderboard/e1')));
  });
});

describe('record videos', () => {
  const upload = (uid, path, data = video, contentType = 'video/mp4') =>
    storageAs(uid).ref(path).put(data, { contentType });

  test('owner uploads a video into own folder', async () => {
    await assertSucceeds(upload('alice', `records/alice/${fileName}`));
  });

  test('rejects other folders, other types, bad names and big files', async () => {
    await assertFails(upload('bob', `records/alice/${fileName}`));
    await assertFails(upload('alice', `records/alice/${fileName}`, video, 'image/png'));
    await assertFails(upload('alice', 'records/alice/../bob.mp4'));
    await assertFails(upload('alice', `records/alice/${fileName}`, new Uint8Array(50 * 1024 * 1024 + 1)));
  });

  test('clients cannot read videos directly', async () => {
    await assertFails(
      storageAs('alice').ref(`records/alice/${fileName}`).getDownloadURL(),
    );
  });
});
