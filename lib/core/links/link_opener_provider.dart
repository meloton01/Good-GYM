import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Открывает адрес во внешнем браузере; `false`, если открыть не удалось.
typedef LinkOpener = Future<bool> Function(Uri uri);

/// Открытие внешних ссылок; в тестах подменяется.
final linkOpenerProvider = Provider<LinkOpener>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
