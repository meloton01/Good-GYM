import '../../../l10n/generated/app_localizations.dart';
import '../../profile/domain/profile_visibility.dart';

/// Локализованное название уровня видимости.
extension ProfileVisibilityLabels on ProfileVisibility {
  /// Название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    ProfileVisibility.everyone => l10n.visibilityEveryone,
    ProfileVisibility.gymMembers => l10n.visibilityGymMembers,
    ProfileVisibility.onlyMe => l10n.visibilityOnlyMe,
  };
}
