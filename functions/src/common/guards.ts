import { CallableRequest } from 'firebase-functions/https';

import { fail } from './fail';
import { Collections } from './fields';
import { db } from './app';

/** uid вошедшего пользователя; при входе по паролю email должен быть подтверждён. */
export function requireVerifiedUser(request: CallableRequest): string {
  const auth = request.auth;
  if (!auth) {
    throw fail('unauthenticated', 'sign-in-required');
  }
  const provider = auth.token.firebase?.sign_in_provider;
  if (provider === 'password' && auth.token.email_verified !== true) {
    throw fail('permission-denied', 'email-not-verified');
  }
  return auth.uid;
}

/** Проверяет, что у пользователя роль модератора в профиле. */
export async function requireModerator(uid: string): Promise<void> {
  if (!(await isModerator(uid))) {
    throw fail('permission-denied', 'moderator-only');
  }
}

/** Есть ли у пользователя роль модератора. */
export async function isModerator(uid: string): Promise<boolean> {
  const profile = await db.collection(Collections.users).doc(uid).get();
  return profile.get('role') === 'moderator';
}
