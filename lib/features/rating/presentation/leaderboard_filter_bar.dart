import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/option_sheet.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/leaderboard_metric.dart';
import '../domain/leaderboard_period.dart';
import '../domain/leaderboard_query.dart';
import '../domain/rating_exercise.dart';
import '../domain/sex.dart';
import '../domain/weight_class.dart';
import 'leaderboard_controllers.dart';
import 'rating_labels.dart';

/// Строка фильтров таблицы: зал, упражнение, период, показатель, пол и категория.
class LeaderboardFilterBar extends ConsumerWidget {
  /// Создаёт панель; [gymId] — зал пользователя или null, если он не выбран.
  const LeaderboardFilterBar({super.key, required this.gymId});

  final String? gymId;

  /// Строит прокручиваемую по горизонтали строку кнопок-фильтров.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(leaderboardFilterProvider);
    final controller = ref.read(leaderboardFilterProvider.notifier);
    final sex = query.sex;
    final spacing = context.spacing;

    /// Открывает выбор и применяет результат.
    Future<void> choose<T>(
      String title,
      List<T> options,
      T selected,
      String Function(T) label,
      LeaderboardQuery Function(T) apply,
    ) async {
      final picked = await showOptionSheet<T>(
        context,
        title: title,
        options: options,
        selected: selected,
        label: label,
      );
      if (picked != null && picked != selected) {
        controller.update(apply(picked));
      }
    }

    final scopeLabel = query.gymId == null
        ? l10n.ratingScopeAll
        : l10n.ratingScopeMyGym;
    final chips = [
      _FilterChip(
        label: scopeLabel,
        onPressed: () => choose<bool>(
          l10n.ratingScopeTitle,
          const [true, false],
          query.gymId != null,
          (myGym) => myGym ? l10n.ratingScopeMyGym : l10n.ratingScopeAll,
          (myGym) => query.copyWith(gymId: myGym ? gymId ?? '' : null),
        ),
      ),
      _FilterChip(
        label: query.exercise.label(l10n),
        onPressed: () => choose<RatingExercise>(
          l10n.ratingExerciseTitle,
          RatingExercise.values,
          query.exercise,
          (exercise) => exercise.label(l10n),
          (exercise) => query.copyWith(exercise: exercise),
        ),
      ),
      _FilterChip(
        label: query.period.label(l10n),
        onPressed: () => choose<LeaderboardPeriod>(
          l10n.ratingPeriodTitle,
          LeaderboardPeriod.values,
          query.period,
          (period) => period.label(l10n),
          (period) => query.copyWith(period: period),
        ),
      ),
      _FilterChip(
        label: query.metric.label(l10n),
        onPressed: () => choose<LeaderboardMetric>(
          l10n.ratingMetricTitle,
          LeaderboardMetric.values,
          query.metric,
          (metric) => metric.label(l10n),
          (metric) => query.copyWith(metric: metric),
        ),
      ),
      _FilterChip(
        label: sex?.label(l10n) ?? l10n.ratingSexAll,
        onPressed: () => choose<Sex?>(
          l10n.ratingSexTitle,
          const [null, ...Sex.values],
          sex,
          (value) => value?.label(l10n) ?? l10n.ratingSexAll,
          (value) => query.copyWith(sex: value, weightClass: null),
        ),
      ),
      if (sex != null)
        _FilterChip(
          label: query.weightClass?.label(l10n) ?? l10n.ratingWeightClassAll,
          onPressed: () => choose<WeightClass?>(
            l10n.ratingWeightClassTitle,
            [null, ...WeightClass.forSex(sex)],
            query.weightClass,
            (value) => value?.label(l10n) ?? l10n.ratingWeightClassAll,
            (value) => query.copyWith(weightClass: value),
          ),
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(
        children: [
          for (final chip in chips) ...[
            chip,
            if (chip != chips.last) SizedBox(width: spacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Кнопка одного фильтра с текущим значением.
class _FilterChip extends StatelessWidget {
  /// Создаёт кнопку с подписью [label].
  const _FilterChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  /// Строит чип с размером зоны нажатия не меньше 48 dp.
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.expand_more_rounded),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onPressed: onPressed,
    );
  }
}
