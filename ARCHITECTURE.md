# Архитектура Good GYM

## Слои

```
presentation  ->  domain  <-  data
(экраны,          (модели,      (реализации репозиториев,
 виджеты,          интерфейсы    источники данных, DTO)
 провайдеры)       репозиториев)
```

- `domain` не зависит от Flutter-виджетов, Firebase и других фич. Модели на `freezed`, репозитории объявлены как `abstract interface class`.
- `data` реализует интерфейсы из `domain`. Бэкенд (Firebase или другой) подключается только здесь.
- `presentation` работает с интерфейсами через провайдеры Riverpod. Реализация подставляется в `main.dart` через `ProviderScope.overrides`.
- Ошибки: методы `Future` возвращают `Result<T>` (`Success` или `Failure` с `AppFailure`), потоки обрабатываются через `AsyncValue`. Пользователь видит текст из `AppFailureMessage`, а не исключение.

## Структура

```
lib/
  main.dart                 точка входа, загрузка настроек, overrides
  app/
    app.dart                MaterialApp.router: тема, язык, роутер
    tabs_registry.dart      список вкладок нижней навигации
    router/                 GoRouter и каркас с NavigationBar
    theme/                  палитра и токены ThemeExtension
  core/
    constants/              числовые ограничения
    errors/                 Result, AppFailure, локализация ошибок
    navigation/             TabDefinition
    pagination/             PagedResult
    widgets/                общие виджеты
  l10n/                     ARB-файлы, generated/ создаётся автоматически
  features/<name>/
    data/  domain/  presentation/
```

Фичи: `home`, `rating`, `workout`, `profile`, `settings`, `auth`. Фича не импортирует другую фичу; общее выносится в `core/`.

## Правила

1. Цвета, отступы, радиусы, размеры берутся из токенов: `context.colors`, `context.spacing`, `context.radii`, `context.sizes`. Сырые значения цветов есть только в `app/theme/app_palette.dart`.
2. Текст в интерфейсе только из ARB через `AppLocalizations.of(context)`.
3. Отступы и выравнивание через `start`/`end` (`EdgeInsetsDirectional`, `AlignmentDirectional`).
4. Один публичный класс на файл, файл до ~200 строк, над каждым классом и функцией комментарий `///` в одну строку.
5. Длительность анимаций из `AppMotion`, через `AppMotion.resolve`, чтобы учитывать «уменьшить анимацию».
6. Списки данных через `ListView.builder` и пагинацию по `AppLimits.pageSize`.

## Тема

- `AppColors.dark` и `AppColors.light`: палитра Black & Yellow. Жёлтый `accent` только для заливки активных элементов, текст и иконки поверх него берут `onAccent`. Для акцента на фоне служит `accentContent`: в светлой теме он чёрный, потому что жёлтый на светлом фоне не проходит по контрасту.
- `buildAppTheme` собирает `ColorScheme` вручную из токенов, без `ColorScheme.fromSeed`.

## Как добавить вкладку

1. Создай `lib/features/<name>/presentation/<name>_tab.dart` с `final <name>Tab = TabDefinition(...)`: путь, иконки, подпись из ARB, корневой экран.
2. Добавь подпись вкладки в каждый ARB-файл.
3. Добавь `<name>Tab` в список `appTabs` в `lib/app/tabs_registry.dart`.

Чтобы отключить вкладку, убери её из `appTabs`. Остальные вкладки и роутер от неё не зависят.

## Как добавить язык

1. Скопируй `lib/l10n/app_en.arb` в `lib/l10n/app_<код>.arb` (например, `app_de.arb`) и замени `@@locale` на код языка.
2. Переведи значения, в `languageName` впиши название языка на нём самом.
3. Выполни `flutter gen-l10n` (или `flutter pub get`). Язык появится в настройках автоматически.

Для языков с письмом справа налево (арабский, иврит) дополнительных шагов нет: направление берётся из локали.

## Сборка

```
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
flutter run
```

Сгенерированные файлы (`*.freezed.dart`, `*.g.dart`, `lib/l10n/generated/`) в репозиторий не попадают и создаются командами выше.

## Бэкенд

Firebase не подключён. Интерфейсы репозиториев описаны в `domain` каждой фичи:

| Фича | Интерфейс | Назначение |
|---|---|---|
| auth | `AuthRepository` | вход, регистрация, сброс пароля, удаление аккаунта |
| profile | `UserProfileRepository` | профиль, роль, проверка ника |
| rating | `GymRepository` | поиск и создание залов |
| rating | `RecordRepository` | таблицы, подача рекорда, модерация |
| workout | `WorkoutRepository` | история и сохранение тренировок |
| workout | `CoachLinkRepository` | приглашения и связь тренер-ученик |
| settings | `SettingsRepository` | тема и язык (реализован на SharedPreferences) |

Интерфейсы уточняются на этапах ТЗ, где реализуется фича. Критичные операции (одобрение рекорда, расчёт `e1rm`, подтверждение связи) реализация выполняет на сервере.
