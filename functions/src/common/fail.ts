import { FunctionsErrorCode, HttpsError } from 'firebase-functions/https';

/** Ошибка вызова; [reason] уходит клиенту в details.reason и выбирает понятный текст. */
export function fail(code: FunctionsErrorCode, reason: string): HttpsError {
  return new HttpsError(code, reason, { reason });
}
