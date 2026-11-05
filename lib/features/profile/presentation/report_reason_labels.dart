import '../../../l10n/generated/app_localizations.dart';
import '../domain/report_reason.dart';

/// Подписи причин жалобы.
extension ReportReasonLabel on ReportReason {
  /// Локализованное название причины.
  String label(AppLocalizations l10n) => switch (this) {
    ReportReason.spam => l10n.reportReasonSpam,
    ReportReason.abuse => l10n.reportReasonAbuse,
    ReportReason.cheating => l10n.reportReasonCheating,
    ReportReason.inappropriate => l10n.reportReasonInappropriate,
    ReportReason.other => l10n.reportReasonOther,
  };
}
