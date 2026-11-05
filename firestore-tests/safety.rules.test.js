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
} from 'firebase/firestore';

const verified = { email_verified: true, firebase: { sign_in_provider: 'password' } };

let env;

/** Firestore от имени пользователя uid с подтверждённым email. */
const as = (uid) => env.authenticatedContext(uid, verified).firestore();

/** Кладёт данные в обход правил. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), path), data));

/** Профиль с ролью и открытой видимостью. */
const user = (nickname, role = 'athlete') => ({
  nickname,
  role,
  profileVisibility: 'everyone',
  recordsVisibility: 'everyone',
  createdAt: new Date(),
  updatedAt: new Date(),
});

/** Блокировка в формате приложения. */
const block = (nickname) => ({ nickname, createdAt: serverTimestamp() });

/** Жалоба в формате приложения. */
const report = (reporterId, targetUid, extra = {}) => ({
  reporterId,
  targetUid,
  reason: 'spam',
  comment: '',
  status: 'open',
  createdAt: serverTimestamp(),
  ...extra,
});

/** Приглашение тренера coach ученику stu от inviter. */
const invite = (inviter) => ({
  coachId: 'coach',
  athleteId: 'stu',
  coachNickname: 'coach',
  athleteNickname: 'stu',
  status: 'pending',
  invitedBy: inviter,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-good-gym',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed('users/alice', user('alice'));
  await seed('users/bob', user('bob'));
  await seed('users/mod', user('mod', 'moderator'));
  await seed('users/coach', user('coach', 'coach'));
  await seed('users/stu', user('stu', 'student'));
});

after(() => env.cleanup());

describe('blocks', () => {
  test('owner blocks another user with the real nickname', async () => {
    await assertSucceeds(setDoc(doc(as('alice'), 'users/alice/blocks/bob'), block('bob')));
    await assertSucceeds(getDocs(collection(as('alice'), 'users/alice/blocks')));
    await assertSucceeds(deleteDoc(doc(as('alice'), 'users/alice/blocks/bob')));
  });

  test('cannot block self, a missing user or with a fake nickname', async () => {
    await assertFails(setDoc(doc(as('alice'), 'users/alice/blocks/alice'), block('alice')));
    await assertFails(setDoc(doc(as('alice'), 'users/alice/blocks/ghost'), block('ghost')));
    await assertFails(setDoc(doc(as('alice'), 'users/alice/blocks/bob'), block('mod')));
  });

  test('others cannot read or write the block list', async () => {
    await seed('users/alice/blocks/bob', { nickname: 'bob', createdAt: new Date() });
    await assertFails(getDoc(doc(as('bob'), 'users/alice/blocks/bob')));
    await assertFails(deleteDoc(doc(as('bob'), 'users/alice/blocks/bob')));
    await assertFails(setDoc(doc(as('bob'), 'users/alice/blocks/mod'), block('mod')));
  });

  test('blocked user loses access to the profile and record history', async () => {
    await seed('records/r1', {
      uid: 'alice',
      status: 'approved',
      exerciseId: 'squat',
      performedAt: new Date(),
    });
    await assertSucceeds(getDoc(doc(as('bob'), 'users/alice')));
    await assertSucceeds(getDoc(doc(as('bob'), 'records/r1')));
    await seed('users/alice/blocks/bob', { nickname: 'bob', createdAt: new Date() });
    await assertFails(getDoc(doc(as('bob'), 'users/alice')));
    await assertFails(getDoc(doc(as('bob'), 'records/r1')));
    await assertSucceeds(getDoc(doc(as('mod'), 'users/alice')));
  });

  test('no coach invites between blocked users in either direction', async () => {
    await seed('users/stu/blocks/coach', { nickname: 'coach', createdAt: new Date() });
    await assertFails(setDoc(doc(as('coach'), 'coachLinks/coach_stu'), invite('coach')));
    await assertFails(setDoc(doc(as('stu'), 'coachLinks/coach_stu'), invite('stu')));
  });

  test('pending invite cannot be accepted after a block', async () => {
    await assertSucceeds(setDoc(doc(as('coach'), 'coachLinks/coach_stu'), invite('coach')));
    await seed('users/coach/blocks/stu', { nickname: 'stu', createdAt: new Date() });
    await assertFails(
      updateDoc(doc(as('stu'), 'coachLinks/coach_stu'), {
        status: 'active',
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

describe('reports', () => {
  test('user reports another user once', async () => {
    const ref = doc(as('alice'), 'reports/alice_user_bob');
    await assertSucceeds(setDoc(ref, report('alice', 'bob', { comment: 'spam in bio' })));
    await assertFails(setDoc(ref, report('alice', 'bob', { reason: 'abuse' })));
  });

  test('report on a record names its author', async () => {
    await seed('records/r1', { uid: 'bob', status: 'approved' });
    await assertSucceeds(
      setDoc(
        doc(as('alice'), 'reports/alice_record_r1'),
        report('alice', 'bob', { recordId: 'r1', reason: 'cheating' }),
      ),
    );
    await assertFails(
      setDoc(
        doc(as('alice'), 'reports/alice_record_r1x'),
        report('alice', 'mod', { recordId: 'r1' }),
      ),
    );
  });

  test('rejects self reports, fake authors, wrong ids and bad fields', async () => {
    await assertFails(setDoc(doc(as('alice'), 'reports/alice_user_alice'), report('alice', 'alice')));
    await assertFails(setDoc(doc(as('alice'), 'reports/bob_user_mod'), report('bob', 'mod')));
    await assertFails(setDoc(doc(as('alice'), 'reports/any'), report('alice', 'bob')));
    await assertFails(setDoc(doc(as('alice'), 'reports/alice_user_ghost'), report('alice', 'ghost')));
    await assertFails(
      setDoc(doc(as('alice'), 'reports/alice_user_bob'), report('alice', 'bob', { reason: 'boring' })),
    );
    await assertFails(
      setDoc(doc(as('alice'), 'reports/alice_user_bob'), report('alice', 'bob', { status: 'closed' })),
    );
    await assertFails(
      setDoc(
        doc(as('alice'), 'reports/alice_user_bob'),
        report('alice', 'bob', { comment: 'x'.repeat(501) }),
      ),
    );
  });

  test('reporter and moderators read reports, the reported user does not', async () => {
    await seed('reports/alice_user_bob', { ...report('alice', 'bob'), createdAt: new Date() });
    await assertSucceeds(getDoc(doc(as('alice'), 'reports/alice_user_bob')));
    await assertSucceeds(getDoc(doc(as('mod'), 'reports/alice_user_bob')));
    await assertFails(getDoc(doc(as('bob'), 'reports/alice_user_bob')));
    await assertSucceeds(
      getDocs(query(collection(as('alice'), 'reports'), where('reporterId', '==', 'alice'))),
    );
    await assertFails(getDocs(collection(as('bob'), 'reports')));
  });

  test('only the reporter deletes a report, nobody edits it', async () => {
    await seed('reports/alice_user_bob', { ...report('alice', 'bob'), createdAt: new Date() });
    await assertFails(updateDoc(doc(as('mod'), 'reports/alice_user_bob'), { status: 'closed' }));
    await assertFails(deleteDoc(doc(as('bob'), 'reports/alice_user_bob')));
    await assertSucceeds(deleteDoc(doc(as('alice'), 'reports/alice_user_bob')));
  });
});
