/** Расчётный 1ПМ по формуле Эпли, округлённый до 0.1 кг; один повтор равен весу. */
export function estimateOneRepMax(weightKg: number, reps: number): number {
  if (reps <= 1) {
    return roundTenth(weightKg);
  }
  return roundTenth(weightKg * (1 + reps / 30));
}

/** Округляет до 0.1. */
export function roundTenth(value: number): number {
  return Math.round(value * 10) / 10;
}
