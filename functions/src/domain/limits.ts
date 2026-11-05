/** Ограничения рекордов; клиент проверяет те же значения до отправки. */
export const RecordLimits = {
  maxWeightKg: 500,
  maxReps: 100,
  minBodyWeightKg: 30,
  maxBodyWeightKg: 300,
  maxVideoBytes: 50 * 1024 * 1024,
  minReasonLength: 3,
  maxReasonLength: 300,
  maxPendingPerUser: 5,
  maxSubmissionsPerDay: 10,
  maxPerformedAgeDays: 365,
  signedUrlMinutes: 15,
  batchSize: 400,
} as const;
