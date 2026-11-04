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
- `presentation` работает с интерфейсами через провайдеры Riverpod. Провайдер репозитория лежит в `data/<name>_repository_provider.dart` и создаёт реализацию на Firebase. В тестах она подменяется через `ProviderScope.overrides`.
- Ошибки: методы `Future` возвращают `Result<T>` (`Success` или `Failure` с `AppFailure`), потоки обрабатываются через `AsyncValue`. Пользователь видит текст из `AppFailureMessage`, а не исключение.

## Структура

```
lib/
  main.dart                 точка входа: Firebase, локальные настройки
  firebase_options.dart     создаётся flutterfire configure, не в git
  app/
    app.dart                MaterialApp.router: тема, язык, роутер
    tabs_registry.dart      список вкладок нижней навигации
    router/                 GoRouter, перенаправления по сессии, каркас с NavigationBar
    session/                состояние сессии: вход, подтверждение email, профиль
    theme/                  палитра и токены ThemeExtension
  core/
    constants/              числовые ограничения
    errors/                 Result, AppFailure, локализация ошибок
    firebase/               перевод ошибок Firestore в AppFailure
    navigation/             TabDefinition
    pagination/             PagedResult
    widgets/                общие виджеты
  l10n/                     ARB-файлы, generated/ создаётся автоматически
  features/<name>/
    data/  domain/  presentation/
```

Фичи: `home`, `rating`, `workout`, `profile`, `settings`, `auth`. Фича может брать у другой фичи только `domain` и провайдеры репозиториев из `data`. Её экраны и виджеты не импортируются. Общие виджеты лежат в `core/widgets/`, сборка фич в одно приложение — в `app/`.

## Сессия и маршруты

`sessionProvider` сводит учётную запись (`authUserProvider`) и профиль (`userProfileProvider`) в одно состояние. Роутер перенаправляет по нему функцией `sessionRedirect`:

| Состояние | Экран |
|---|---|
| `SessionLoading` | `/splash` |
| `SessionSignedOut` | `/sign-in`, `/sign-up`, `/reset-password` |
| `SessionEmailUnverified` | `/verify-email` (только вход по паролю) |
| `SessionNeedsProfile` | `/profile-setup`: ник и роль |
| `SessionReady` | вкладки |
| `SessionError` | `/session-error` с повтором |

Экраны не вызывают навигацию после входа или выхода: роутер сам реагирует на смену сессии.

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
flutterfire configure --project=good-gym-1dc5f --platforms=android,ios
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
flutter run
```

Сгенерированные файлы (`*.freezed.dart`, `*.g.dart`, `lib/l10n/generated/`) в репозиторий не попадают и создаются командами выше. Конфигурация Firebase (`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) тоже не коммитится: её создаёт `flutterfire configure`.

## Правила Firestore

Правила лежат в `firestore.rules`, тесты к ним в `firestore-tests/`. Тесты запускаются на эмуляторе (нужны Node.js и Java 11+):

```
npm --prefix firestore-tests install
firebase emulators:exec --only firestore --project demo-good-gym "npm --prefix firestore-tests test"
```

Деплой: `firebase deploy --only firestore:rules`.

Ник уникален за счёт коллекции `nicknames/{nickname}` с полем `uid`. Профиль и ник создаются одной транзакцией, а правила через `getAfter` проверяют, что обе записи ссылаются друг на друга.

## Бэкенд

Бэкенд: Firebase (Auth, Firestore). Интерфейсы репозиториев описаны в `domain` каждой фичи:

| Фича | Интерфейс | Назначение | Реализация |
|---|---|---|---|
| auth | `AuthRepository` | вход, регистрация, подтверждение email, сброс пароля | `FirebaseAuthRepository` |
| profile | `UserProfileRepository` | профиль, ник, роль | `FirestoreUserProfileRepository` |
| rating | `GymRepository` | поиск и создание залов | этап 5 |
| rating | `RecordRepository` | таблицы, подача рекорда, модерация | этап 5 |
| workout | `WorkoutRepository` | история и сохранение тренировок | этап 3 |
| workout | `CoachLinkRepository` | приглашения и связь тренер-ученик | этап 4 |
| settings | `SettingsRepository` | тема и язык | `SharedPreferencesSettingsRepository` |

Вход через Google и Apple требует настройки консолей: см. `docs/firebase-setup.md`.

Интерфейсы уточняются на этапах ТЗ, где реализуется фича. Критичные операции (одобрение рекорда, расчёт `e1rm`, подтверждение связи) реализация выполняет на сервере.
