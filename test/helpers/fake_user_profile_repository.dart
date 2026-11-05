import 'dart:async';

import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/profile/domain/body_metrics.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_profile_repository.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';

/// Тестовый репозиторий профилей в памяти.
class FakeUserProfileRepository implements UserProfileRepository {
  /// Создаёт репозиторий с начальными профилями.
  FakeUserProfileRepository({Iterable<UserProfile> profiles = const []}) {
    for (final profile in profiles) {
      _profiles[profile.uid] = profile;
    }
  }

  final Map<String, UserProfile> _profiles = {};
  final _controller = StreamController<void>.broadcast();

  /// Ошибка, которую отдаст поток профиля, если задана.
  Object? watchError;

  /// Профиль пользователя [uid] без подписки.
  UserProfile? profileOf(String uid) => _profiles[uid];

  /// Ники, которые считаются занятыми другими пользователями.
  final Set<String> takenNicknames = {};

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    final error = watchError;
    if (error != null) {
      throw error;
    }
    yield _profiles[uid];
    await for (final _ in _controller.stream) {
      yield _profiles[uid];
    }
  }

  @override
  Future<Result<void>> createProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  }) async {
    if (takenNicknames.contains(nickname)) {
      return const Failure(AppFailure.nicknameTaken);
    }
    _profiles[uid] = UserProfile(uid: uid, nickname: nickname, role: role);
    _controller.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  }) async {
    final profile = _profiles[uid];
    if (profile == null) {
      return const Failure(AppFailure.notFound);
    }
    _profiles[uid] = profile.copyWith(role: role);
    _controller.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> updateProfile(UserProfile profile) async {
    final current = _profiles[profile.uid];
    if (current == null) {
      return const Failure(AppFailure.notFound);
    }
    if (current.nickname != profile.nickname &&
        takenNicknames.contains(profile.nickname)) {
      return const Failure(AppFailure.nicknameTaken);
    }
    _profiles[profile.uid] = profile;
    _controller.add(null);
    return const Success(null);
  }

  /// Данные о теле по uid.
  final Map<String, BodyMetrics> bodies = {};

  /// uid, данные которых удалены.
  final List<String> deletedUids = [];

  @override
  Stream<BodyMetrics> watchBodyMetrics(String uid) async* {
    yield bodies[uid] ?? const BodyMetrics();
    await for (final _ in _controller.stream) {
      yield bodies[uid] ?? const BodyMetrics();
    }
  }

  @override
  Future<Result<void>> saveBodyMetrics(String uid, BodyMetrics metrics) async {
    bodies[uid] = metrics;
    _controller.add(null);
    return const Success(null);
  }

  @override
  Future<Result<Map<String, Object?>>> exportData(String uid) async {
    return Success({'uid': uid, 'profile': _profiles[uid]?.nickname});
  }

  @override
  Future<Result<void>> deleteAllData(String uid) async {
    _profiles.remove(uid);
    bodies.remove(uid);
    deletedUids.add(uid);
    _controller.add(null);
    return const Success(null);
  }
}
