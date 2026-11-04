import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'firebase_auth_repository.dart';

/// Репозиторий авторизации; в тестах подменяется через overrides.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance, GoogleSignIn.instance),
);

/// Текущая учётная запись; null, если вход не выполнен.
final authUserProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchAuthUser(),
);
