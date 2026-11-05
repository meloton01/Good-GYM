/** Почему модератор не может проверить рекорд; null, если может. */
export function reviewBlocker(
  record: { uid: unknown; status: unknown },
  moderatorId: string,
): 'own-record' | 'not-pending' | null {
  if (record.uid === moderatorId) {
    return 'own-record';
  }
  return record.status === 'pending' ? null : 'not-pending';
}

/** Можно ли обжаловать отказ: только автор, только отказ и только один раз. */
export function canAppeal(
  record: { uid: unknown; status: unknown; appealed: unknown },
  uid: string,
): boolean {
  return record.uid === uid && record.status === 'rejected' && record.appealed !== true;
}
