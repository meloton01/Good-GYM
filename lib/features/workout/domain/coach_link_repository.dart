import '../../../core/errors/result.dart';
import 'coach_link.dart';

/// Приглашения и связи тренер-ученик.
abstract interface class CoachLinkRepository {
  /// Поток связей пользователя в любом статусе.
  Stream<List<CoachLink>> watchLinks(String uid);

  /// Отправляет приглашение пользователю по нику.
  Future<Result<CoachLink>> inviteByNickname(String nickname);

  /// Принимает приглашение; связь становится активной.
  Future<Result<void>> acceptInvite(String linkId);

  /// Отклоняет приглашение.
  Future<Result<void>> declineInvite(String linkId);

  /// Разрывает активную связь любой из сторон.
  Future<Result<void>> endLink(String linkId);
}
