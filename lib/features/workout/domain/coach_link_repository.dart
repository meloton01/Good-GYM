import '../../../core/errors/result.dart';
import '../../profile/domain/user_profile.dart';
import 'coach_link.dart';

/// Приглашения и связи тренер-ученик; подтверждение и разрыв проверяют правила.
abstract interface class CoachLinkRepository {
  /// Поток связей пользователя в любом статусе; [asCoach] выбирает сторону.
  Stream<List<CoachLink>> watchLinks(String uid, {required bool asCoach});

  /// Отправляет приглашение пользователю с ником [nickname] от тренера или ученика [me].
  Future<Result<void>> invite({
    required UserProfile me,
    required String nickname,
  });

  /// Принимает приглашение; у ученика не больше одного тренера, у тренера до 50 учеников.
  Future<Result<void>> accept(CoachLink link);

  /// Отклоняет входящее или отзывает своё приглашение.
  Future<Result<void>> remove(CoachLink link);

  /// Разрывает активную связь любой из сторон.
  Future<Result<void>> end(CoachLink link);

  /// Собирает связи пользователя с обеих сторон для выгрузки.
  Future<Result<List<Map<String, Object?>>>> exportData(String uid);

  /// Разрывает активные связи и удаляет все связи пользователя.
  Future<Result<void>> deleteAllData(String uid);
}
