import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/legal_links.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'legal_link_tile.dart';

/// Версия приложения из сборки.
final _packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Секция «О приложении»: версия, политика конфиденциальности, условия и лицензии.
class AboutSection extends ConsumerWidget {
  /// Создаёт секцию «О приложении».
  const AboutSection({super.key});

  /// Строит версию сборки, ссылки на документы и список лицензий.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_packageInfoProvider).value;
    final version = info == null ? '' : '${info.version} (${info.buildNumber})';
    final languageCode = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsAbout),
        ListTile(title: Text(l10n.aboutVersion), subtitle: Text(version)),
        LegalLinkTile(
          title: l10n.aboutPrivacyPolicy,
          uri: LegalLinks.privacyPolicy(languageCode),
        ),
        LegalLinkTile(
          title: l10n.aboutTerms,
          uri: LegalLinks.terms(languageCode),
        ),
        ListTile(
          title: Text(l10n.aboutLicenses),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appTitle,
            applicationVersion: version,
          ),
        ),
      ],
    );
  }
}
