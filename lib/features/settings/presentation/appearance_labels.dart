import '../../../l10n/generated/app_localizations.dart';
import '../domain/accent_id.dart';
import '../domain/corner_style.dart';
import '../domain/notification_type.dart';
import '../domain/palette_id.dart';

/// Локализованное название палитры.
extension PaletteLabels on PaletteId {
  /// Название палитры на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    PaletteId.blackYellow => l10n.paletteBlackYellow,
    PaletteId.graphiteOrange => l10n.paletteGraphiteOrange,
    PaletteId.carbonLime => l10n.paletteCarbonLime,
    PaletteId.steelTeal => l10n.paletteSteelTeal,
    PaletteId.inkPink => l10n.paletteInkPink,
    PaletteId.mono => l10n.paletteMono,
  };
}

/// Локализованное название акцента для скринридера.
extension AccentLabels on AccentId {
  /// Название цвета на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    AccentId.yellow => l10n.accentYellow,
    AccentId.orange => l10n.accentOrange,
    AccentId.lime => l10n.accentLime,
    AccentId.teal => l10n.accentTeal,
    AccentId.pink => l10n.accentPink,
    AccentId.silver => l10n.accentSilver,
  };
}

/// Локализованное название стиля скруглений.
extension CornerStyleLabels on CornerStyle {
  /// Название стиля на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    CornerStyle.sharp => l10n.cornerSharp,
    CornerStyle.standard => l10n.cornerStandard,
    CornerStyle.round => l10n.cornerRound,
  };
}

/// Локализованное название типа уведомлений.
extension NotificationTypeLabels on NotificationType {
  /// Название типа на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    NotificationType.recordReview => l10n.notificationRecordReview,
    NotificationType.coachInvites => l10n.notificationCoachInvites,
    NotificationType.workoutReminders => l10n.notificationWorkoutReminders,
  };
}
