import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/gym_repository.dart';
import 'firestore_gym_repository.dart';

/// Репозиторий залов; в тестах подменяется через overrides.
final gymRepositoryProvider = Provider<GymRepository>(
  (ref) => FirestoreGymRepository(
    FirebaseFirestore.instance,
    () => FirebaseAuth.instance.currentUser?.uid,
  ),
);
