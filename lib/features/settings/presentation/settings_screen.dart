import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'about_section.dart';
import 'account_section.dart';
import 'language_section.dart';
import 'notifications_section.dart';
import 'privacy_section.dart';
import 'units_section.dart';

/// Экран настроек: внешний вид, язык, единицы, уведомления, приватность, аккаунт.
class SettingsScreen extends StatelessWidget {
  /// Создаёт экран настроек.
  const SettingsScreen({super.key});

  /// Строит один прокручиваемый список секций.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: EdgeInsetsDirectional.only(bottom: context.spacing.lg),
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearance),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.appearance),
          ),
          const LanguageSection(),
          const UnitsSection(),
          const NotificationsSection(),
          const PrivacySection(),
          const AccountSection(),
          const AboutSection(),
        ],
      ),
    );
  }
}
