import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Предпросмотр текущей темы на настоящих элементах интерфейса.
class AppearancePreview extends StatefulWidget {
  /// Создаёт блок предпросмотра.
  const AppearancePreview({super.key});

  /// Создаёт состояние предпросмотра.
  @override
  State<AppearancePreview> createState() => _AppearancePreviewState();
}

/// Хранит положение переключателя в предпросмотре.
class _AppearancePreviewState extends State<AppearancePreview> {
  bool _switchOn = true;

  /// Строит поверхность с полем, переключателем и кнопками.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.appearancePreview),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.md),
          child: Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.radii.large),
              side: BorderSide(color: context.colors.border),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.profileNicknameLabel,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsetsDirectional.zero,
                    title: Text(l10n.appearancePreviewSwitch),
                    value: _switchOn,
                    onChanged: (value) => setState(() => _switchOn = value),
                  ),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(l10n.actionCancel),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: Text(l10n.actionSave),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
