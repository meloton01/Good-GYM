import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/exercise_repository_provider.dart';
import '../domain/exercise.dart';
import 'create_exercise_dialog.dart';
import 'exercise_labels.dart';

/// Библиотека упражнений с поиском; выбранное упражнение возвращается через pop.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  /// Создаёт экран выбора упражнения.
  const ExercisePickerScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

/// Хранит строку поиска.
class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _query = '';

  /// Строит поиск, список упражнений и кнопку создания своего.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final library = uid == null
        ? const AsyncValue<List<Exercise>>.loading()
        : ref.watch(exerciseLibraryProvider(uid));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exercisePickerTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.exerciseCreate),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.md),
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.exerciseSearchLabel,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: switch (library) {
              AsyncData(:final value) => _buildList(l10n, value),
              AsyncError(:final error) => ErrorView(
                title: l10n.exercisePickerTitle,
                failure: failureFromError(error),
                onRetry: () => ref.invalidate(exerciseLibraryProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }

  /// Строит отфильтрованный список или пустое состояние поиска.
  Widget _buildList(AppLocalizations l10n, List<Exercise> library) {
    final found = library
        .where((item) => item.name(l10n).toLowerCase().contains(_query))
        .toList();
    if (found.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: l10n.exercisePickerTitle,
        message: l10n.exerciseSearchEmpty,
      );
    }
    return ListView.builder(
      padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
      itemCount: found.length,
      itemBuilder: (context, index) {
        final exercise = found[index];
        return ListTile(
          leading: Icon(exercise.muscleGroup.icon),
          title: Text(exercise.name(l10n)),
          subtitle: Text(exercise.muscleGroup.label(l10n)),
          onTap: () => context.pop(exercise),
        );
      },
    );
  }

  /// Создаёт своё упражнение и сразу выбирает его.
  Future<void> _create() async {
    final exercise = await showCreateExerciseDialog(context);
    if (exercise != null && mounted) {
      context.pop(exercise);
    }
  }
}
