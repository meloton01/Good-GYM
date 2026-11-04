/// Имена коллекций и полей тренировочных данных в Firestore.
abstract final class WorkoutFields {
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String templatesCollection = 'workoutTemplates';
  static const String exercisesCollection = 'exercises';
  static const String recordsCollection = 'personalRecords';

  static const String id = 'id';
  static const String ownerId = 'ownerId';
  static const String title = 'title';
  static const String titleLower = 'titleLower';
  static const String note = 'note';
  static const String startedAt = 'startedAt';
  static const String finishedAt = 'finishedAt';
  static const String exerciseIds = 'exerciseIds';
  static const String exercises = 'exercises';
  static const String exerciseId = 'exerciseId';
  static const String muscleGroup = 'muscleGroup';
  static const String customName = 'customName';
  static const String sets = 'sets';
  static const String reps = 'reps';
  static const String restSeconds = 'restSeconds';
  static const String weightKg = 'weightKg';
  static const String completed = 'completed';
  static const String name = 'name';
  static const String nameLower = 'nameLower';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String maxWeightKg = 'maxWeightKg';
  static const String bestE1rmKg = 'bestE1rmKg';
  static const String maxReps = 'maxReps';
  static const String value = 'value';
  static const String workoutId = 'workoutId';
  static const String achievedAt = 'achievedAt';
}
