import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firestore_failure_mapper.dart';
import '../../features/auth/data/auth_repository_provider.dart';
import '../../features/profile/data/user_profile_repository_provider.dart';
import 'session_state.dart';

/// Сводит учётную запись и профиль в одно состояние сессии.
final sessionProvider = Provider<SessionState>((ref) {
  final authUser = ref.watch(authUserProvider);
  if (authUser.hasError) {
    return SessionError(failureFromError(authUser.error));
  }
  final user = authUser.value;
  if (user == null) {
    return authUser.isLoading
        ? const SessionLoading()
        : const SessionSignedOut();
  }
  if (user.needsEmailVerification) {
    return SessionEmailUnverified(user);
  }
  final profile = ref.watch(userProfileProvider(user.uid));
  if (profile.hasError) {
    return SessionError(failureFromError(profile.error));
  }
  if (!profile.hasValue) {
    return const SessionLoading();
  }
  final loaded = profile.requireValue;
  return loaded == null
      ? SessionNeedsProfile(user)
      : SessionReady(user, loaded);
});
