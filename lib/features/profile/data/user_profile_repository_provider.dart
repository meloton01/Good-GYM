import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/body_metrics.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_repository.dart';
import 'firestore_user_profile_repository.dart';

/// Репозиторий профилей; в тестах подменяется через overrides.
final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => FirestoreUserProfileRepository(FirebaseFirestore.instance),
);

/// Поток профиля пользователя по uid.
final userProfileProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) => ref.watch(userProfileRepositoryProvider).watchProfile(uid),
);

/// Поток приватных данных о теле пользователя по uid.
final bodyMetricsProvider = StreamProvider.family<BodyMetrics, String>(
  (ref, uid) => ref.watch(userProfileRepositoryProvider).watchBodyMetrics(uid),
);
