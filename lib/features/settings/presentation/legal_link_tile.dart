import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/links/link_opener_provider.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Строка настроек, которая открывает юридический документ в браузере.
class LegalLinkTile extends ConsumerWidget {
  /// Создаёт строку с заголовком [title] и адресом [uri].
  const LegalLinkTile({super.key, required this.title, required this.uri});

  /// Название документа.
  final String title;

  /// Адрес документа.
  final Uri uri;

  /// Строит строку; если браузер не открылся, показывает сообщение.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(title),
      onTap: () async {
        final opened = await ref
            .read(linkOpenerProvider)(uri)
            .catchError((Object _) => false);
        if (!opened && context.mounted) {
          showInfoSnackBar(
            context,
            AppLocalizations.of(context).linkOpenFailed,
          );
        }
      },
    );
  }
}
