import '../../../l10n/generated/app_localizations.dart';
import '../domain/user_role.dart';

/// Локализованные названия и пояснения ролей.
extension UserRoleLabels on UserRole {
  /// Название роли на языке интерфейса.
  String label(AppLocalizations l10n) {
    return switch (this) {
      UserRole.athlete => l10n.roleAthlete,
      UserRole.student => l10n.roleStudent,
      UserRole.coach => l10n.roleCoach,
      UserRole.moderator => l10n.roleModerator,
    };
  }

  /// Короткое пояснение роли; у служебной роли его нет.
  String? description(AppLocalizations l10n) {
    return switch (this) {
      UserRole.athlete => l10n.roleAthleteDescription,
      UserRole.student => l10n.roleStudentDescription,
      UserRole.coach => l10n.roleCoachDescription,
      UserRole.moderator => null,
    };
  }
}
