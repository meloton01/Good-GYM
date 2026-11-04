import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/pagination/paged_result.dart';
import '../domain/gym.dart';
import '../domain/gym_policy.dart';
import '../domain/gym_repository.dart';

/// Залы в Firestore: gyms/{gymId} с полем nameLower для поиска по началу названия.
class FirestoreGymRepository implements GymRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore и uid текущего пользователя.
  FirestoreGymRepository(this._firestore, this._currentUid);

  static const String _collection = 'gyms';
  static const String _name = 'name';
  static const String _nameLower = 'nameLower';
  static const String _city = 'city';
  static const String _creatorId = 'creatorId';
  static const String _createdAt = 'createdAt';

  /// Символ после всех остальных, чтобы ограничить диапазон поиска по префиксу.
  static const String _prefixEnd = '';

  final FirebaseFirestore _firestore;
  final String? Function() _currentUid;

  CollectionReference<Map<String, dynamic>> get _gyms =>
      _firestore.collection(_collection);

  /// Ищет залы по началу названия; пустой запрос возвращает все по алфавиту.
  @override
  Future<Result<PagedResult<Gym>>> searchGyms({
    required String query,
    String? cursor,
    int limit = AppLimits.pageSize,
  }) async {
    try {
      final prefix = query.trim().toLowerCase();
      var request = _gyms.orderBy(_nameLower);
      if (prefix.isNotEmpty) {
        request = request
            .where(_nameLower, isGreaterThanOrEqualTo: prefix)
            .where(_nameLower, isLessThan: '$prefix$_prefixEnd');
      }
      if (cursor != null) {
        request = request.startAfterDocument(await _gyms.doc(cursor).get());
      }
      final snapshot = await request.limit(limit).get();
      final gyms = snapshot.docs.map(_fromDoc).nonNulls.toList();
      return Success(
        PagedResult(
          items: gyms,
          nextCursor: snapshot.docs.length == limit
              ? snapshot.docs.last.id
              : null,
        ),
      );
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Создаёт зал от имени текущего пользователя.
  @override
  Future<Result<Gym>> createGym({
    required String name,
    required String city,
  }) async {
    final uid = _currentUid();
    final cleanName = name.trim();
    final cleanCity = city.trim();
    if (uid == null) {
      return const Failure(AppFailure.permissionDenied);
    }
    if (!GymPolicy.isValidText(cleanName) ||
        !GymPolicy.isValidText(cleanCity)) {
      return const Failure(AppFailure.invalidInput);
    }
    try {
      final doc = _gyms.doc();
      await doc.set({
        _name: cleanName,
        _nameLower: cleanName.toLowerCase(),
        _city: cleanCity,
        _creatorId: uid,
        _createdAt: FieldValue.serverTimestamp(),
      });
      return Success(
        Gym(id: doc.id, name: cleanName, city: cleanCity, creatorId: uid),
      );
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Собирает зал из документа; документ без нужных полей пропускается.
  Gym? _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = data[_name];
    final city = data[_city];
    final creatorId = data[_creatorId];
    if (name is! String || city is! String || creatorId is! String) {
      return null;
    }
    return Gym(id: doc.id, name: name, city: city, creatorId: creatorId);
  }
}
