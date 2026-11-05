import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Включает App Check: Play Integrity и App Attest в релизе, отладочный провайдер в остальных сборках.
///
/// Веб нужен только для предпросмотра интерфейса, поэтому там App Check не включается.
Future<void> activateAppCheck() async {
  if (kIsWeb) {
    return;
  }
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: kReleaseMode
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(),
  );
}
