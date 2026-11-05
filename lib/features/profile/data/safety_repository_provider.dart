import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository_provider.dart';
import '../domain/safety_repository.dart';
import 'firestore_safety_repository.dart';

/// Репозиторий жалоб и блокировок; в тестах подменяется через overrides.
final safetyRepositoryProvider = Provider<SafetyRepository>(
  (ref) => FirestoreSafetyRepository(FirebaseFirestore.instance),
);

/// Заблокировал ли текущий пользователь пользователя по uid.
final isBlockedProvider = StreamProvider.family<bool, String>((ref, otherUid) {
  final uid = ref.watch(authUserProvider.select((user) => user.value?.uid));
  if (uid == null) {
    return Stream.value(false);
  }
  return ref
      .watch(safetyRepositoryProvider)
      .watchIsBlocked(uid: uid, otherUid: otherUid);
});
