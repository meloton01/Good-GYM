import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/workout_repository_provider.dart';
import '../domain/personal_record.dart';
import 'exercise_labels.dart';
import 'workout_format.dart';

/// Личные рекорды по упражнениям; касание открывает график прогресса.
class PersonalRecordsList extends ConsumerWidget {
  /// Создаёт список рекордов пользователя [uid].
  const PersonalRecordsList({super.key, required this.uid});

  final String uid;

  /// Строит загрузку, ошибку, пустой список или рекорды по алфавиту.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    return switch (ref.watch(personalRecordsProvider(uid))) {
      AsyncData(:final value) when value.isEmpty => EmptyStateView(
        icon: Icons.emoji_events_outlined,
        title: l10n.recordsEmptyTitle,
        message: l10n.recordsEmptyMessage,
      ),
      AsyncData(:final value) => _buildList(
        context,
        value,
        format,
        ref.watch(authUserProvider).value?.uid == uid ? null : uid,
      ),
      AsyncError(:final error) => ErrorView(
        title: l10n.workoutRecordsTab,
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(personalRecordsProvider(uid)),
      ),
      _ => const LoadingView(),
    };
  }

  /// Строит список по названию упражнения; [owner] задан, если это рекорды ученика.
  Widget _buildList(
    BuildContext context,
    List<PersonalRecord> records,
    WorkoutFormat format,
    String? owner,
  ) {
    final l10n = format.l10n;
    final sorted = [...records]
      ..sort((a, b) => a.exercise.name(l10n).compareTo(b.exercise.name(l10n)));
    return ListView.builder(
      padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final record = sorted[index];
        return ListTile(
          leading: Icon(record.exercise.muscleGroup.icon),
          title: Text(record.exercise.name(l10n)),
          subtitle: Text(_describe(record, format)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(
            AppRoutes.exerciseProgress(record.exercise.id, owner: owner),
          ),
        );
      },
    );
  }

  /// Подпись с расчётным максимумом и лучшим весом или повторами.
  String _describe(PersonalRecord record, WorkoutFormat format) {
    final l10n = format.l10n;
    final e1rm = record.bestE1rmKg;
    final weight = record.maxWeightKg;
    final reps = record.maxReps;
    if (e1rm != null && weight != null) {
      return l10n.recordWeightSummary(
        format.weight(e1rm.value),
        format.weight(weight.value),
      );
    }
    return reps == null ? '' : l10n.recordRepsSummary(reps.value.round());
  }
}
