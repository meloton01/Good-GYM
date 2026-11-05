import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_repository_provider.dart';
import 'plans_list.dart';

/// Планы, которые тренеры назначили текущему ученику.
class MyPlansScreen extends ConsumerWidget {
  /// Создаёт экран планов ученика.
  const MyPlansScreen({super.key});

  /// Строит список планов ученика.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authUserProvider).value?.uid;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).coachPlansTitle)),
      body: uid == null ? const LoadingView() : PlansList(athleteId: uid),
    );
  }
}
