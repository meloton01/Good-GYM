import '../../../core/errors/result.dart';
import 'exercise.dart';
import 'muscle_group.dart';

/// Пользовательские упражнения; встроенные лежат в BuiltInExercises.
abstract interface class ExerciseRepository {
  /// Поток своих упражнений по алфавиту.
  Stream<List<Exercise>> watchCustomExercises(String ownerId);

  /// Создаёт своё упражнение.
  Future<Result<Exercise>> createExercise(
    String ownerId, {
    required String name,
    required MuscleGroup muscleGroup,
  });
}
