import { RecordLimits } from './limits';
import { allowsZeroWeight, isRatingExercise, RatingExercise } from './rating_exercises';
import { isSex, Sex } from './weight_class';

/** Проверенная заявка на рекорд. */
export interface RecordInput {
  uploadId: string;
  exerciseId: RatingExercise;
  weightKg: number;
  reps: number;
  performedAt: Date;
  sex: Sex;
  bodyWeightKg: number;
}

const uploadIdPattern = /^[A-Za-z0-9]{20}$/;

/** Разбирает данные вызова; null, если хоть одно поле вне ограничений. */
export function parseRecordInput(data: unknown, now: Date): RecordInput | null {
  if (typeof data !== 'object' || data === null) {
    return null;
  }
  const { uploadId, exerciseId, weightKg, reps, performedAt, sex, bodyWeightKg } = data as Record<
    string,
    unknown
  >;
  if (typeof uploadId !== 'string' || !uploadIdPattern.test(uploadId)) {
    return null;
  }
  if (!isRatingExercise(exerciseId) || !isSex(sex)) {
    return null;
  }
  const weightValid = allowsZeroWeight(exerciseId)
    ? isNumberIn(weightKg, 0, RecordLimits.maxWeightKg)
    : isNumberIn(weightKg, 0, RecordLimits.maxWeightKg) && weightKg > 0;
  if (!weightValid) {
    return null;
  }
  if (!Number.isInteger(reps) || !isNumberIn(reps, 1, RecordLimits.maxReps)) {
    return null;
  }
  if (!isNumberIn(bodyWeightKg, RecordLimits.minBodyWeightKg, RecordLimits.maxBodyWeightKg)) {
    return null;
  }
  if (typeof performedAt !== 'number' || !Number.isFinite(performedAt)) {
    return null;
  }
  const oldest = now.getTime() - RecordLimits.maxPerformedAgeDays * 86_400_000;
  if (performedAt > now.getTime() || performedAt < oldest) {
    return null;
  }
  return {
    uploadId,
    exerciseId,
    weightKg: weightKg as number,
    reps: reps as number,
    performedAt: new Date(performedAt),
    sex,
    bodyWeightKg: bodyWeightKg as number,
  };
}

/** Причина отказа модератора после обрезки пробелов; null, если длина вне ограничений. */
export function parseReason(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null;
  }
  const reason = value.trim();
  return reason.length >= RecordLimits.minReasonLength &&
    reason.length <= RecordLimits.maxReasonLength
    ? reason
    : null;
}

/** Id рекорда из данных вызова; null, если это не id документа. */
export function parseRecordId(data: unknown): string | null {
  if (typeof data !== 'object' || data === null) {
    return null;
  }
  const { recordId } = data as Record<string, unknown>;
  return typeof recordId === 'string' && uploadIdPattern.test(recordId) ? recordId : null;
}

/** Число в диапазоне [min, max]. */
function isNumberIn(value: unknown, min: number, max: number): value is number {
  return typeof value === 'number' && Number.isFinite(value) && value >= min && value <= max;
}
