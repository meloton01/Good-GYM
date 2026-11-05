/// Упражнение рейтинга; [id] совпадает с библиотекой тренировок и функциями.
enum RatingExercise {
  squat('squat'),
  benchPress('bench_press'),
  deadlift('deadlift'),
  pullUp('pull_up', allowsZeroWeight: true);

  /// Создаёт упражнение; [allowsZeroWeight] для упражнений с весом тела, где вес означает отягощение.
  const RatingExercise(this.id, {this.allowsZeroWeight = false});

  final String id;
  final bool allowsZeroWeight;

  /// Упражнение по id или null для неизвестного.
  static RatingExercise? fromId(String? id) {
    for (final exercise in values) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }
}
