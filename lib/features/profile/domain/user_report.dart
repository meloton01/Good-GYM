import 'package:freezed_annotation/freezed_annotation.dart';

import 'report_reason.dart';

part 'user_report.freezed.dart';

/// Жалоба на пользователя [targetUid] или на его рекорд [recordId].
@freezed
abstract class UserReport with _$UserReport {
  const UserReport._();

  /// Создаёт жалобу; без [recordId] жалоба относится к пользователю.
  const factory UserReport({
    required String reporterId,
    required String targetUid,
    String? recordId,
    required ReportReason reason,
    @Default('') String comment,
  }) = _UserReport;

  /// Id документа: одна жалоба от автора на одну цель.
  String get id => recordId == null
      ? '${reporterId}_user_$targetUid'
      : '${reporterId}_record_$recordId';
}
