/// Расчётный максимум на одно повторение по формуле Эпли: вес × (1 + повторы / 30).
///
/// Один повтор и есть максимум, поэтому он равен весу, как и в Cloud Functions.
double estimateOneRepMax(double weightKg, int reps) {
  if (reps <= 1) {
    return weightKg;
  }
  return weightKg * (1 + reps / 30);
}
