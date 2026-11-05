/// Адреса политики конфиденциальности и условий использования.
abstract final class LegalLinks {
  /// Папка с документами; для своего домена задаётся через `--dart-define=LEGAL_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: 'https://github.com/meloton01/Good-GYM/blob/main/docs/legal',
  );

  /// Языки, на которых документы опубликованы.
  static const Set<String> languages = {'en', 'ru', 'uk'};

  /// Язык документа по [languageCode], для остальных языков английский.
  static String _language(String languageCode) =>
      languages.contains(languageCode) ? languageCode : 'en';

  /// Политика конфиденциальности на языке [languageCode].
  static Uri privacyPolicy(String languageCode) =>
      Uri.parse('$baseUrl/privacy-policy.${_language(languageCode)}.md');

  /// Условия использования на языке [languageCode].
  static Uri terms(String languageCode) =>
      Uri.parse('$baseUrl/terms.${_language(languageCode)}.md');
}
