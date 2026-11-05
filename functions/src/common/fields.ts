/** Коллекции и поля рекордов; совпадают с клиентом и firestore.rules. */
export const Collections = {
  users: 'users',
  records: 'records',
  leaderboard: 'leaderboard',
} as const;

/** Значение scope в таблице общего рейтинга. */
export const globalScope = 'global';

/** Путь к видео рекорда в Storage. */
export function videoPath(uid: string, uploadId: string): string {
  return `records/${uid}/${uploadId}.mp4`;
}

/** Папка всех видео пользователя. */
export function videoFolder(uid: string): string {
  return `records/${uid}/`;
}

/** Id строки таблицы: упражнение, период, зал или общий рейтинг, пользователь. */
export function leaderboardId(
  exerciseId: string,
  period: string,
  scope: string,
  uid: string,
): string {
  return `${exerciseId}_${period}_${scope}_${uid}`;
}
