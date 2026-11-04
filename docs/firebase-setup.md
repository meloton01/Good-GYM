# Настройка Firebase

Проект Firebase: `good-gym-1dc5f`. Приложения Android (`com.goodgym.good_gym`) и iOS (`com.goodgym.goodGym`) уже зарегистрированы.

## Обязательно

1. **Authentication → Sign-in method**: включить Email/Password.
2. **Firestore Database**: создать базу в режиме production, регион `eur3`.
3. Задеплоить правила: `firebase deploy --only firestore:rules`.
4. **Authentication → Templates**: при желании поправить отправителя и текст писем. Язык письма приложение передаёт само, по языку интерфейса.

## Вход через Google

1. Authentication → Sign-in method → Google → включить, указать email поддержки.
2. Android: добавить SHA-1 и SHA-256 ключа подписи в Project settings → Your apps → Android.
   - Отладочный ключ: `keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - Релизный ключ: из keystore этапа 7 или из Play Console (App signing).
3. Перезапустить `flutterfire configure --project=good-gym-1dc5f --platforms=android,ios`, чтобы в `google-services.json` попал OAuth-клиент.
4. iOS (на macOS): скачать `GoogleService-Info.plist` в `ios/Runner/` и добавить `REVERSED_CLIENT_ID` из него в `CFBundleURLTypes` файла `ios/Runner/Info.plist`.

## Вход через Apple

Кнопка показывается только на iOS.

1. Apple Developer → Identifiers → App ID `com.goodgym.goodGym`: включить Sign in with Apple.
2. Xcode → Runner → Signing & Capabilities → `+ Sign in with Apple`.
3. Firebase → Authentication → Sign-in method → Apple → включить.
