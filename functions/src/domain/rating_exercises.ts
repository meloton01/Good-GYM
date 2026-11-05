/** Упражнения рейтинга; id совпадают с библиотекой тренировок. */
export const ratingExercises = ['squat', 'bench_press', 'deadlift', 'pull_up'] as const;

export type RatingExercise = (typeof ratingExercises)[number];

/** Упражнения, где вес означает отягощение сверх веса тела и может быть нулём. */
const bodyWeightExercises: ReadonlySet<string> = new Set(['pull_up']);

/** Проверяет, что упражнение участвует в рейтинге. */
export function isRatingExercise(value: unknown): value is RatingExercise {
  return typeof value === 'string' && (ratingExercises as readonly string[]).includes(value);
}

/** Допускает ли упражнение нулевой вес. */
export function allowsZeroWeight(exerciseId: string): boolean {
  return bodyWeightExercises.has(exerciseId);
}
