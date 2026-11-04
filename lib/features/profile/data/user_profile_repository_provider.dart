import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
