import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../workout/data/coach_repository_providers.dart';
import '../../workout/data/workout_repository_provider.dart';
import 'delete_account_dialog.dart';

/// Подтверждает личность, разрывает связи, удаляет планы, тренировки, профиль и учётную запись.
Future<void> deleteAccount(
  BuildContext context,
  WidgetRef ref,
  DeleteAccountConfirmation confirmation,
) async {
  final uid = ref.read(authUserProvider).value?.uid;
  if (uid == null) {
    return;
  }
  final auth = ref.read(authRepositoryProvider);
  final steps = <Future<Result<void>> Function()>[
    () => auth.reauthenticate(password: confirmation.password),
    () => ref.read(coachLinkRepositoryProvider).deleteAllData(uid),
    () => ref.read(coachPlanRepositoryProvider).deleteAllData(uid),
    () => ref.read(workoutRepositoryProvider).deleteAllData(uid),
    () => ref.read(userProfileRepositoryProvider).deleteAllData(uid),
    auth.deleteAccount,
  ];
  for (final step in steps) {
    final result = await step();
    if (result is Failure<void>) {
      if (context.mounted) {
        showFailureSnackBar(context, result.failure);
      }
      return;
    }
  }
}
