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
      AppFailure.invalidCredentials => l10n.errorInvalidCredentials,
      AppFailure.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
      AppFailure.weakPassword => l10n.errorWeakPassword,
      AppFailure.tooManyRequests => l10n.errorTooManyRequests,
      AppFailure.nicknameTaken => l10n.errorNicknameTaken,
      AppFailure.accountExistsWithDifferentCredential =>
        l10n.errorAccountExistsWithDifferentCredential,
      AppFailure.providerUnavailable => l10n.errorProviderUnavailable,
      AppFailure.cancelled => l10n.errorCancelled,
      AppFailure.requiresRecentLogin => l10n.errorRequiresRecentLogin,
      AppFailure.notificationsDenied => l10n.errorNotificationsDenied,
      AppFailure.nothingCompleted => l10n.errorNothingCompleted,
      AppFailure.userNotFound => l10n.errorUserNotFound,
      AppFailure.inviteUnavailable => l10n.errorInviteUnavailable,
      AppFailure.alreadyLinked => l10n.errorAlreadyLinked,
      AppFailure.alreadyInvited => l10n.errorAlreadyInvited,
      AppFailure.coachLimitReached => l10n.errorCoachLimitReached,
      AppFailure.linkUnavailable => l10n.errorLinkUnavailable,
      AppFailure.roleLocked => l10n.errorRoleLocked,
      AppFailure.noGym => l10n.errorNoGym,
      AppFailure.videoInvalid => l10n.errorVideoInvalid,
      AppFailure.videoTooLong => l10n.errorVideoTooLong,
      AppFailure.ownRecord => l10n.errorOwnRecord,
      AppFailure.recordReviewed => l10n.errorRecordReviewed,
      AppFailure.appealUnavailable => l10n.errorAppealUnavailable,
      AppFailure.unknown => l10n.errorUnknown,
    };
  }
}
