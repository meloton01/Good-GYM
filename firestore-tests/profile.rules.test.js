import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const verified = { email_verified: true, firebase: { sign_in_provider: 'password' } };

let env;

/** Firestore от имени пользователя uid с подтверждённым email. */
const as = (uid) => env.authenticatedContext(uid, verified).firestore();

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

/** Профиль в формате приложения. */
const profile = (nickname, extra = {}) => ({
  nickname,
  role: 'athlete',
  bio: '',
  profileVisibility: 'everyone',
  recordsVisibility: 'everyone',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...extra,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-good-gym',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed('gyms/iron', { name: 'Iron Gym', nameLower: 'iron gym', city: 'Kyiv', creatorId: 'carol', createdAt: new Date() });
  await seed('users/alice', profile('alice'));
  await seed('nicknames/alice', { uid: 'alice' });
});

after(() => env.cleanup());

describe('profile visibility', () => {
  test('everyone: any verified user reads', async () => {
    await assertSucceeds(getDoc(doc(as('bob'), 'users', 'alice')));
  });

  test('onlyMe: only the owner reads', async () => {
    await seed('users/alice', profile('alice', { profileVisibility: 'onlyMe' }));
    await assertFails(getDoc(doc(as('bob'), 'users', 'alice')));
    await assertSucceeds(getDoc(doc(as('alice'), 'users', 'alice')));
  });

  test('gymMembers: only members of the same gym read', async () => {
    await seed('users/alice', profile('alice', { profileVisibility: 'gymMembers', gymId: 'iron', gymName: 'Iron Gym' }));
    await seed('users/bob', profile('bob', { gymId: 'iron', gymName: 'Iron Gym' }));
    await seed('users/dave', profile('dave'));
    await assertSucceeds(getDoc(doc(as('bob'), 'users', 'alice')));
    await assertFails(getDoc(doc(as('dave'), 'users', 'alice')));
  });
});

describe('profile edits', () => {
  test('owner sets bio, gym and visibility', async () => {
    await assertSucceeds(
      updateDoc(doc(as('alice'), 'users', 'alice'), {
        bio: 'Powerlifting',
        gymId: 'iron',
        gymName: 'Iron Gym',
        profileVisibility: 'gymMembers',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('gym name must match the gym document', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), {
        gymId: 'iron',
        gymName: 'Fake name',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('bio longer than 300 characters is rejected', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), { bio: 'x'.repeat(301), updatedAt: serverTimestamp() }),
    );
  });

  test('profile from stage 1 without new fields can still change role', async () => {
    await seed('users/legacy', { nickname: 'legacy', role: 'athlete', createdAt: new Date(), updatedAt: new Date() });
    await assertSucceeds(
      updateDoc(doc(as('legacy'), 'users', 'legacy'), { role: 'coach', updatedAt: serverTimestamp() }),
    );
  });

  test('nickname change moves the reservation in one batch', async () => {
    const db = as('alice');
    const batch = writeBatch(db);
    batch.delete(doc(db, 'nicknames', 'alice'));
    batch.set(doc(db, 'nicknames', 'alice.new'), { uid: 'alice' });
    batch.update(doc(db, 'users', 'alice'), { nickname: 'alice.new', updatedAt: serverTimestamp() });
    await assertSucceeds(batch.commit());
  });

  test('nickname change that keeps the old reservation is rejected', async () => {
    const db = as('alice');
    const batch = writeBatch(db);
    batch.set(doc(db, 'nicknames', 'alice.new'), { uid: 'alice' });
    batch.update(doc(db, 'users', 'alice'), { nickname: 'alice.new', updatedAt: serverTimestamp() });
    await assertFails(batch.commit());
  });
});

describe('private body data', () => {
  test('owner writes and reads valid values', async () => {
    const ref = doc(as('alice'), 'users', 'alice', 'private', 'body');
    await assertSucceeds(setDoc(ref, { weightKg: 82.5, heightCm: 180 }));
    await assertSucceeds(getDoc(ref));
  });

  test('values out of range are rejected', async () => {
    const ref = doc(as('alice'), 'users', 'alice', 'private', 'body');
    await assertFails(setDoc(ref, { weightKg: 5, heightCm: 180 }));
    await assertFails(setDoc(ref, { weightKg: 80, heightCm: 400 }));
  });

  test('nobody else reads or writes body data', async () => {
    await seed('users/alice/private/body', { weightKg: 80, heightCm: 180 });
    await assertFails(getDoc(doc(as('bob'), 'users', 'alice', 'private', 'body')));
    await assertFails(setDoc(doc(as('bob'), 'users', 'alice', 'private', 'body'), { weightKg: 90 }));
  });
});

describe('account data deletion', () => {
  test('owner deletes body, nickname and profile in one batch', async () => {
    await seed('users/alice/private/body', { weightKg: 80, heightCm: 180 });
    const db = as('alice');
    const batch = writeBatch(db);
    batch.delete(doc(db, 'users', 'alice', 'private', 'body'));
    batch.delete(doc(db, 'nicknames', 'alice'));
    batch.delete(doc(db, 'users', 'alice'));
    await assertSucceeds(batch.commit());
  });

  test('nickname cannot be released while the profile still uses it', async () => {
    await assertFails(deleteDoc(doc(as('alice'), 'nicknames', 'alice')));
  });
});

describe('gyms', () => {
  test('verified user creates a gym as creator', async () => {
    await assertSucceeds(
      setDoc(doc(as('bob'), 'gyms', 'new'), {
        name: 'Steel Club',
        nameLower: 'steel club',
        city: 'Lviv',
        creatorId: 'bob',
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('gym for another creator or with wrong search field is rejected', async () => {
    const base = { name: 'Steel Club', nameLower: 'steel club', city: 'Lviv', createdAt: serverTimestamp() };
    await assertFails(setDoc(doc(as('bob'), 'gyms', 'a'), { ...base, creatorId: 'alice' }));
    await assertFails(setDoc(doc(as('bob'), 'gyms', 'b'), { ...base, creatorId: 'bob', nameLower: 'other' }));
  });

  test('gyms cannot be changed or deleted from the client', async () => {
    await assertFails(updateDoc(doc(as('carol'), 'gyms', 'iron'), { name: 'Renamed' }));
    await assertFails(deleteDoc(doc(as('carol'), 'gyms', 'iron')));
  });
});
