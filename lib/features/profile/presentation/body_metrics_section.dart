import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure_message.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/user_profile_repository_provider.dart';

/// Приватные вес и рост в единицах из настроек.
class BodyMetricsSection extends ConsumerWidget {
  /// Создаёт секцию данных о теле пользователя [uid].
  const BodyMetricsSection({super.key, required this.uid});

  final String uid;

  /// Строит два пункта; при загрузке и ошибке показывает это в подписи.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (weightUnit, lengthUnit) = ref.watch(
      appSettingsProvider.select((s) => (s.weightUnit, s.lengthUnit)),
    );
    final metrics = ref.watch(bodyMetricsProvider(uid));

    String describe(double? value, String unit) {
      return switch (metrics) {
        AsyncError(:final error) => failureFromError(error).message(l10n),
        AsyncData() when value != null =>
          '${MeasurementFormat.format(value, locale)} $unit',
        AsyncData() => l10n.profileNotSet,
        _ => l10n.loadingLabel,
      };
    }

    final weightKg = metrics.value?.weightKg;
    final heightCm = metrics.value?.heightCm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.profileBodyTitle),
        ListTile(
          title: Text(l10n.unitWeight),
          subtitle: Text(
            describe(
              weightKg == null ? null : weightUnit.fromKilograms(weightKg),
              weightUnit.shortLabel(l10n),
            ),
          ),
        ),
        ListTile(
          title: Text(l10n.unitLength),
          subtitle: Text(
            describe(
              heightCm == null ? null : lengthUnit.fromCentimeters(heightCm),
              lengthUnit.shortLabel(l10n),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline_rounded),
          title: Text(
            l10n.profileBodyPrivateNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
