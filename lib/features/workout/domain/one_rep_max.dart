/// Расчётный максимум на одно повторение по формуле Эпли: вес × (1 + повторы / 30).
double estimateOneRepMax(double weightKg, int reps) {
  return weightKg * (1 + reps / 30);
}
