import '../../l10n/generated/app_localizations.dart';
import 'app_failure.dart';

/// Перевод ошибки в понятное локализованное сообщение с подсказкой, что делать.
extension AppFailureMessage on AppFailure {
  /// Возвращает текст ошибки на языке интерфейса.
  String message(AppLocalizations l10n) {
    return switch (this) {
      AppFailure.network => l10n.errorNetwork,
      AppFailure.permissionDenied => l10n.errorPermissionDenied,
      AppFailure.notFound => l10n.errorNotFound,
      AppFailure.invalidInput => l10n.errorInvalidInput,
      AppFailure.storage => l10n.errorStorage,
      AppFailure.unknown => l10n.errorUnknown,
    };
  }
}
