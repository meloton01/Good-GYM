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
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const verified = { email_verified: true, firebase: { sign_in_provider: 'password' } };

let env;

/** Firestore от имени пользователя uid с подтверждённым email. */
const as = (uid) => env.authenticatedContext(uid, verified).firestore();

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

/** Профиль с ролью. */
const user = (nickname, role) => ({ nickname, role, createdAt: new Date(), updatedAt: new Date() });

/** Приглашение от inviter в формате приложения. */
const invite = (inviter, extra = {}) => ({
  coachId: 'coach',
  athleteId: 'stu',
  coachNickname: 'coach.max',
  athleteNickname: 'stu.ann',
  status: 'pending',
  invitedBy: inviter,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...extra,
});

/** Принятие связи coach_stu от имени uid: статус, замок и счётчик одним батчем. */
const accept = (uid, { count = 1, lock = true } = {}) => {
  const db = as(uid);
  const batch = writeBatch(db);
  batch.update(doc(db, 'coachLinks/coach_stu'), { status: 'active', updatedAt: serverTimestamp() });
  if (lock) {
    batch.set(doc(db, 'studentCoach/stu'), { coachId: 'coach', linkId: 'coach_stu' });
  }
  batch.set(doc(db, 'coachStudents/coach'), { count, linkId: 'coach_stu' });
  return batch.commit();
};

/** Разрыв связи coach_stu от имени uid. */
const end = (uid) => {
  const db = as(uid);
  const batch = writeBatch(db);
  batch.update(doc(db, 'coachLinks/coach_stu'), { status: 'ended', updatedAt: serverTimestamp() });
  batch.delete(doc(db, 'studentCoach/stu'));
  batch.set(doc(db, 'coachStudents/coach'), { count: 0, linkId: 'coach_stu' });
  return batch.commit();
};

/** Активная связь coach_stu в обход правил. */
const seedActive = async () => {
  await seed('coachLinks/coach_stu', { ...invite('coach'), status: 'active', createdAt: new Date(), updatedAt: new Date() });
  await seed('studentCoach/stu', { coachId: 'coach', linkId: 'coach_stu' });
  await seed('coachStudents/coach', { count: 1, linkId: 'coach_stu' });
};

/** План тренера в формате приложения. */
const plan = (extra = {}) => ({
  coachId: 'coach',
  coachNickname: 'coach.max',
  title: 'Legs A',
  note: '',
  exercises: [{ exerciseId: 'squat', muscleGroup: 'legs', sets: [] }],
  status: 'assigned',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
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
  await seed('users/coach', user('coach.max', 'coach'));
  await seed('users/coach2', user('coach.two', 'coach'));
  await seed('users/stu', user('stu.ann', 'student'));
  await seed('users/ath', user('ath.bob', 'athlete'));
  await seed('users/stu/workouts/w1', { title: 'Legs' });
});

after(() => env.cleanup());

describe('invites', () => {
  test('coach invites a student and a student invites a coach', async () => {
    await assertSucceeds(setDoc(doc(as('coach'), 'coachLinks/coach_stu'), invite('coach')));
    await env.clearFirestore();
    await seed('users/coach', user('coach.max', 'coach'));
    await seed('users/stu', user('stu.ann', 'student'));
    await assertSucceeds(setDoc(doc(as('stu'), 'coachLinks/coach_stu'), invite('stu')));
  });

  test('athlete cannot be invited and roles cannot be swapped', async () => {
    await assertFails(
      setDoc(doc(as('coach'), 'coachLinks/coach_ath'), invite('coach', { athleteId: 'ath', athleteNickname: 'ath.bob' })),
    );
    await assertFails(
      setDoc(doc(as('stu'), 'coachLinks/stu_coach'), invite('stu', {
        coachId: 'stu', athleteId: 'coach', coachNickname: 'stu.ann', athleteNickname: 'coach.max',
      })),
    );
  });

  test('outsider cannot create a link between others or fake a nickname', async () => {
    await assertFails(setDoc(doc(as('ath'), 'coachLinks/coach_stu'), invite('ath')));
    await assertFails(setDoc(doc(as('coach'), 'coachLinks/coach_stu'), invite('coach', { athleteNickname: 'other' })));
  });

  test('invitee declines by deleting, active link cannot be deleted', async () => {
    await seed('coachLinks/coach_stu', { ...invite('coach'), createdAt: new Date(), updatedAt: new Date() });
    await assertFails(deleteDoc(doc(as('ath'), 'coachLinks/coach_stu')));
    await assertSucceeds(deleteDoc(doc(as('stu'), 'coachLinks/coach_stu')));
    await seedActive();
    await assertFails(deleteDoc(doc(as('stu'), 'coachLinks/coach_stu')));
  });
});

describe('consent', () => {
  beforeEach(() =>
    seed('coachLinks/coach_stu', { ...invite('coach'), createdAt: new Date(), updatedAt: new Date() }));

  test('no access to student data before consent', async () => {
    await assertFails(getDoc(doc(as('coach'), 'users/stu/workouts/w1')));
  });

  test('inviter cannot accept own invite', async () => {
    await assertFails(accept('coach'));
  });

  test('invitee accepts and coach gets access', async () => {
    await assertSucceeds(accept('stu'));
    await assertSucceeds(getDoc(doc(as('coach'), 'users/stu/workouts/w1')));
    await assertFails(getDoc(doc(as('coach2'), 'users/stu/workouts/w1')));
  });

  test('accept without the lock or with a wrong counter is rejected', async () => {
    await assertFails(accept('stu', { lock: false }));
    await assertFails(accept('stu', { count: 5 }));
  });

  test('student with a coach cannot accept a second one', async () => {
    await seed('studentCoach/stu', { coachId: 'coach2', linkId: 'coach2_stu' });
    await assertFails(accept('stu'));
  });

  test('coach with 50 students cannot accept more', async () => {
    await seed('coachStudents/coach', { count: 50, linkId: 'x' });
    await assertFails(accept('stu', { count: 51 }));
  });
});

describe('ending the link', () => {
  beforeEach(seedActive);

  test('either side ends the link and access disappears', async () => {
    await assertSucceeds(end('stu'));
    await assertFails(getDoc(doc(as('coach'), 'users/stu/workouts/w1')));
  });

  test('coach ends the link too', async () => {
    await assertSucceeds(end('coach'));
  });

  test('ending without removing the lock is rejected', async () => {
    await assertFails(
      updateDoc(doc(as('stu'), 'coachLinks/coach_stu'), { status: 'ended', updatedAt: serverTimestamp() }),
    );
  });

  test('student cannot switch to athlete while linked', async () => {
    await assertFails(updateDoc(doc(as('stu'), 'users/stu'), { role: 'athlete', updatedAt: serverTimestamp() }));
  });

  test('outsider cannot end the link', async () => {
    await assertFails(end('ath'));
  });
});

describe('plans and comments', () => {
  test('coach assigns a plan only to an active student', async () => {
    await assertFails(setDoc(doc(as('coach'), 'users/stu/plans/p1'), plan()));
    await seedActive();
    await assertSucceeds(setDoc(doc(as('coach'), 'users/stu/plans/p1'), plan()));
    await assertFails(setDoc(doc(as('coach2'), 'users/stu/plans/p2'), plan({ coachId: 'coach2', coachNickname: 'coach.two' })));
  });

  test('student marks completion but cannot edit content', async () => {
    await seedActive();
    await seed('users/stu/plans/p1', { ...plan(), createdAt: new Date(), updatedAt: new Date() });
    const ref = doc(as('stu'), 'users/stu/plans/p1');
    await assertFails(updateDoc(ref, { title: 'Other', updatedAt: serverTimestamp() }));
    await assertSucceeds(
      updateDoc(ref, { status: 'completed', workoutId: 'w1', completedAt: serverTimestamp(), updatedAt: serverTimestamp() }),
    );
  });

  test('coach lists own plans of the student while linked', async () => {
    await seedActive();
    await seed('users/stu/plans/p1', { ...plan(), createdAt: new Date(), updatedAt: new Date() });
    const plans = query(collection(as('coach'), 'users/stu/plans'), where('coachId', '==', 'coach'));
    await assertSucceeds(getDocs(plans));
    await end('coach');
    await assertFails(getDocs(plans));
  });

  test('both sides comment, outsiders do not', async () => {
    await seedActive();
    await seed('users/stu/plans/p1', { ...plan(), createdAt: new Date(), updatedAt: new Date() });
    const comment = (author, nickname) => ({
      authorId: author, authorNickname: nickname, text: 'Keep the back straight', createdAt: serverTimestamp(),
    });
    await assertSucceeds(setDoc(doc(as('coach'), 'users/stu/plans/p1/comments/c1'), comment('coach', 'coach.max')));
    await assertSucceeds(setDoc(doc(as('stu'), 'users/stu/plans/p1/comments/c2'), comment('stu', 'stu.ann')));
    await assertFails(setDoc(doc(as('ath'), 'users/stu/plans/p1/comments/c3'), comment('ath', 'ath.bob')));
    await assertFails(getDoc(doc(as('ath'), 'users/stu/plans/p1/comments/c1')));
  });
});
