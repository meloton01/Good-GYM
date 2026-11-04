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
} from 'firebase/firestore';

const verified = { email_verified: true, firebase: { sign_in_provider: 'password' } };

let env;

/** Firestore от имени пользователя uid с подтверждённым email. */
const as = (uid) => env.authenticatedContext(uid, verified).firestore();

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

/** Завершённая тренировка в формате приложения. */
const workout = (extra = {}) => ({
  title: 'Legs',
  note: '',
  startedAt: new Date(Date.now() - 3600 * 1000),
  finishedAt: new Date(),
  exerciseIds: ['squat'],
  exercises: [
    {
      exerciseId: 'squat',
      muscleGroup: 'legs',
      sets: [{ reps: 5, restSeconds: 90, weightKg: 100, completed: true }],
    },
  ],
  ...extra,
});

/** Личный рекорд в формате приложения. */
const record = (extra = {}) => ({
  exerciseId: 'squat',
  muscleGroup: 'legs',
  maxWeightKg: { value: 100, workoutId: 'w1', achievedAt: new Date() },
  bestE1rmKg: { value: 116.7, workoutId: 'w1', achievedAt: new Date() },
  maxReps: { value: 5, workoutId: 'w1', achievedAt: new Date() },
  ...extra,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-good-gym',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(() => env.clearFirestore());

after(() => env.cleanup());

describe('workouts', () => {
  test('owner saves, reads and deletes a workout', async () => {
    const ref = doc(as('alice'), 'users/alice/workouts/w1');
    await assertSucceeds(setDoc(ref, workout()));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(deleteDoc(ref));
  });

  test('other users cannot read or write workouts', async () => {
    await seed('users/alice/workouts/w1', workout());
    await assertFails(getDoc(doc(as('bob'), 'users/alice/workouts/w1')));
    await assertFails(setDoc(doc(as('bob'), 'users/alice/workouts/w2'), workout()));
    await assertFails(deleteDoc(doc(as('bob'), 'users/alice/workouts/w1')));
  });

  test('unverified email cannot write', async () => {
    const unverified = env
      .authenticatedContext('alice', { email_verified: false, firebase: { sign_in_provider: 'password' } })
      .firestore();
    await assertFails(setDoc(doc(unverified, 'users/alice/workouts/w1'), workout()));
  });

  test('rejects finish before start, empty plan and unknown fields', async () => {
    const ref = doc(as('alice'), 'users/alice/workouts/w1');
    await assertFails(setDoc(ref, workout({ finishedAt: new Date(Date.now() - 7200 * 1000) })));
    await assertFails(setDoc(ref, workout({ exercises: [], exerciseIds: [] })));
    await assertFails(setDoc(ref, workout({ approved: true })));
    await assertFails(setDoc(ref, workout({ title: '' })));
  });
});

describe('templates', () => {
  test('owner saves a template with server time', async () => {
    const ref = doc(as('alice'), 'users/alice/workoutTemplates/t1');
    await assertSucceeds(
      setDoc(ref, { title: 'Push', titleLower: 'push', exercises: [{}], updatedAt: serverTimestamp() }),
    );
    await assertFails(getDoc(doc(as('bob'), 'users/alice/workoutTemplates/t1')));
  });

  test('rejects mismatched lowercase title', async () => {
    const ref = doc(as('alice'), 'users/alice/workoutTemplates/t1');
    await assertFails(
      setDoc(ref, { title: 'Push', titleLower: 'pull', exercises: [{}], updatedAt: serverTimestamp() }),
    );
  });
});

describe('custom exercises', () => {
  test('owner creates an exercise but cannot rename it', async () => {
    const ref = doc(as('alice'), 'users/alice/exercises/e1');
    await assertSucceeds(
      setDoc(ref, { name: 'Hip thrust', nameLower: 'hip thrust', muscleGroup: 'legs', createdAt: serverTimestamp() }),
    );
    await assertFails(updateDoc(ref, { name: 'Other', nameLower: 'other' }));
  });

  test('rejects unknown muscle group', async () => {
    const ref = doc(as('alice'), 'users/alice/exercises/e1');
    await assertFails(
      setDoc(ref, { name: 'Hip thrust', nameLower: 'hip thrust', muscleGroup: 'neck', createdAt: serverTimestamp() }),
    );
  });
});

describe('personal records', () => {
  test('owner writes a record keyed by exercise id', async () => {
    await assertSucceeds(setDoc(doc(as('alice'), 'users/alice/personalRecords/squat'), record()));
    await assertFails(setDoc(doc(as('alice'), 'users/alice/personalRecords/deadlift'), record()));
  });

  test('other users cannot read records', async () => {
    await seed('users/alice/personalRecords/squat', record());
    await assertFails(getDoc(doc(as('bob'), 'users/alice/personalRecords/squat')));
  });

  test('rejects malformed values', async () => {
    const ref = doc(as('alice'), 'users/alice/personalRecords/squat');
    await assertFails(setDoc(ref, record({ maxWeightKg: { value: -1, workoutId: 'w1', achievedAt: new Date() } })));
    await assertFails(setDoc(ref, record({ maxReps: 5 })));
  });
});
