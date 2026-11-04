import '../../../core/errors/result.dart';
import 'app_settings.dart';

/// Хранилище локальных настроек интерфейса.
abstract interface class SettingsRepository {
  /// Возвращает сохранённые настройки или значения по умолчанию.
  AppSettings load();

  /// Сохраняет настройки на устройстве.
  Future<Result<void>> save(AppSettings settings);
}
