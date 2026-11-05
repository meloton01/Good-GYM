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
const unverified = { email_verified: false, firebase: { sign_in_provider: 'password' } };
const google = { firebase: { sign_in_provider: 'google.com' } };

let env;

/** Firestore от имени пользователя uid с заданными claims токена. */
const as = (uid, claims = verified) => env.authenticatedContext(uid, claims).firestore();

/** Создаёт профиль и ник одним батчем, как транзакция в приложении; поле со значением undefined не пишется. */
const createProfile = (db, uid, nickname, role = 'athlete', extra = {}) => {
  const batch = writeBatch(db);
  batch.set(doc(db, 'nicknames', nickname), { uid });
  batch.set(doc(db, 'users', uid), withoutUndefined({
    nickname,
    role,
    bio: '',
    profileVisibility: 'everyone',
    recordsVisibility: 'everyone',
    consentAt: serverTimestamp(),
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...extra,
  }));
  return batch.commit();
};

/** Копия объекта без полей со значением undefined. */
const withoutUndefined = (data) =>
  Object.fromEntries(Object.entries(data).filter(([, value]) => value !== undefined));

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-good-gym',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(() => env.clearFirestore());

after(() => env.cleanup());

describe('users: create', () => {
  test('verified user creates own profile with nickname', async () => {
    await assertSucceeds(createProfile(as('alice'), 'alice', 'alice.lifts', 'student'));
  });

  test('coach role cannot be chosen at sign-up', async () => {
    await assertFails(createProfile(as('alice'), 'alice', 'alice.lifts', 'coach'));
  });

  test('google user without password is allowed', async () => {
    await assertSucceeds(createProfile(as('bob', google), 'bob', 'bob_g'));
  });

  test('unverified email cannot create profile', async () => {
    await assertFails(createProfile(as('alice', unverified), 'alice', 'alice'));
  });

  test('signed out user cannot create profile', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(createProfile(db, 'alice', 'alice'));
  });

  test('cannot create a profile for someone else', async () => {
    await assertFails(createProfile(as('alice'), 'bob', 'bob.fake'));
  });

  test('cannot self-assign moderator role', async () => {
    await assertFails(createProfile(as('alice'), 'alice', 'alice', 'moderator'));
  });

  test('rejects invalid nickname format', async () => {
    await assertFails(createProfile(as('alice'), 'alice', 'Alice!'));
    await assertFails(createProfile(as('alice'), 'alice', 'ab'));
  });

  test('rejects extra fields', async () => {
    await assertFails(createProfile(as('alice'), 'alice', 'alice', 'athlete', { isAdmin: true }));
  });

  test('profile without nickname reservation is rejected', async () => {
    const db = as('alice');
    await assertFails(
      setDoc(doc(db, 'users', 'alice'), {
        nickname: 'alice',
        role: 'athlete',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('profile without consent or with a client-side consent date is rejected', async () => {
    await assertFails(createProfile(as('alice'), 'alice', 'alice', 'athlete', { consentAt: undefined }));
    await assertFails(createProfile(as('alice'), 'alice', 'alice', 'athlete', { consentAt: new Date(0) }));
  });

  test('nickname taken by another user cannot be reused', async () => {
    await seed('nicknames/iron', { uid: 'bob' });
    await assertFails(createProfile(as('alice'), 'alice', 'iron'));
  });
});

describe('users: update and delete', () => {
  beforeEach(async () => {
    await seed('users/alice', { nickname: 'alice', role: 'athlete', createdAt: new Date(), updatedAt: new Date() });
    await seed('users/mod', { nickname: 'mod', role: 'moderator', createdAt: new Date(), updatedAt: new Date() });
    await seed('users/coach', { nickname: 'coach', role: 'coach', createdAt: new Date(), updatedAt: new Date() });
  });

  test('owner changes role to a selectable one', async () => {
    await assertSucceeds(
      updateDoc(doc(as('alice'), 'users', 'alice'), { role: 'student', updatedAt: serverTimestamp() }),
    );
  });

  test('owner cannot become coach', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), { role: 'coach', updatedAt: serverTimestamp() }),
    );
  });

  test('coach cannot change own role from the client', async () => {
    await assertFails(
      updateDoc(doc(as('coach'), 'users', 'coach'), { role: 'athlete', updatedAt: serverTimestamp() }),
    );
  });

  test('owner cannot become moderator', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), { role: 'moderator', updatedAt: serverTimestamp() }),
    );
  });

  test('moderator cannot change own role from the client', async () => {
    await assertFails(
      updateDoc(doc(as('mod'), 'users', 'mod'), { role: 'athlete', updatedAt: serverTimestamp() }),
    );
  });

  test('owner cannot change nickname without reserving it, or other fields', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), { nickname: 'new', updatedAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(doc(as('alice'), 'users', 'alice'), { createdAt: serverTimestamp() }),
    );
  });

  test('another user cannot change the profile', async () => {
    await assertFails(
      updateDoc(doc(as('bob'), 'users', 'alice'), { role: 'coach', updatedAt: serverTimestamp() }),
    );
  });

  test('only the owner deletes the profile', async () => {
    await assertFails(deleteDoc(doc(as('bob'), 'users', 'alice')));
    await assertSucceeds(deleteDoc(doc(as('alice'), 'users', 'alice')));
  });
});

describe('users and nicknames: read', () => {
  beforeEach(async () => {
    await seed('users/alice', { nickname: 'alice', role: 'athlete', createdAt: new Date(), updatedAt: new Date() });
    await seed('nicknames/alice', { uid: 'alice' });
  });

  test('verified users read profiles and nicknames', async () => {
    await assertSucceeds(getDoc(doc(as('bob'), 'users', 'alice')));
    await assertSucceeds(getDoc(doc(as('bob'), 'nicknames', 'alice')));
  });

  test('unverified and signed out users cannot read', async () => {
    await assertFails(getDoc(doc(as('bob', unverified), 'users', 'alice')));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'users', 'alice')));
  });

  test('nickname cannot be taken over or released by others', async () => {
    await assertFails(setDoc(doc(as('bob'), 'nicknames', 'alice'), { uid: 'bob' }));
    await assertFails(deleteDoc(doc(as('bob'), 'nicknames', 'alice')));
    await assertFails(deleteDoc(doc(as('alice'), 'nicknames', 'alice')));
  });

  test('nickname cannot be reserved without own profile pointing to it', async () => {
    await assertFails(setDoc(doc(as('bob'), 'nicknames', 'squat'), { uid: 'bob' }));
  });
});
