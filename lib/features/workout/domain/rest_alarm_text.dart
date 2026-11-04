/// Локализованные тексты уведомления об окончании отдыха.
class RestAlarmText {
  /// Создаёт тексты уведомления.
  const RestAlarmText({
    required this.title,
    required this.body,
    required this.channelName,
  });

  final String title;
  final String body;

  /// Название канала уведомлений в системных настройках Android.
  final String channelName;
}
