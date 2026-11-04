import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout_fields.dart';

/// Ссылки на тренировочные коллекции пользователя users/{uid}/...
extension WorkoutCollections on FirebaseFirestore {
  /// Документ пользователя.
  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      collection(WorkoutFields.usersCollection).doc(uid);

  /// Завершённые тренировки.
  CollectionReference<Map<String, dynamic>> workouts(String uid) =>
      _user(uid).collection(WorkoutFields.workoutsCollection);

  /// Шаблоны тренировок.
  CollectionReference<Map<String, dynamic>> workoutTemplates(String uid) =>
      _user(uid).collection(WorkoutFields.templatesCollection);

  /// Свои упражнения.
  CollectionReference<Map<String, dynamic>> customExercises(String uid) =>
      _user(uid).collection(WorkoutFields.exercisesCollection);

  /// Личные рекорды, id документа равен id упражнения.
  CollectionReference<Map<String, dynamic>> personalRecords(String uid) =>
      _user(uid).collection(WorkoutFields.recordsCollection);

  /// Все тренировочные коллекции пользователя по названию.
  Map<String, CollectionReference<Map<String, dynamic>>> workoutData(
    String uid,
  ) => {
    WorkoutFields.workoutsCollection: workouts(uid),
    WorkoutFields.templatesCollection: workoutTemplates(uid),
    WorkoutFields.exercisesCollection: customExercises(uid),
    WorkoutFields.recordsCollection: personalRecords(uid),
  };
}
