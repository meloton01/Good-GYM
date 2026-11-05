import 'package:flutter/material.dart';

import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Критерии проверки видео: показываются автору при подаче и модератору при проверке.
class RecordCriteria extends StatelessWidget {
  /// Создаёт список критериев.
  const RecordCriteria({super.key});

  /// Строит заголовок и пункты критериев.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      l10n.criteriaBarVisible,
      l10n.criteriaFullMovement,
      l10n.criteriaNoEditing,
      l10n.criteriaSingleSet,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.criteriaTitle),
        for (final item in items)
          ListTile(
            dense: true,
            leading: const Icon(Icons.check_rounded),
            title: Text(item),
          ),
      ],
    );
  }
}
