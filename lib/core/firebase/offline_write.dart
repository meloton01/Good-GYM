import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/result.dart';
import 'firestore_failure_mapper.dart';

/// Ждёт подтверждения записи сервером не дольше [wait]; без сети запись остаётся в очереди Firestore.
///
/// Firestore сразу кладёт запись в локальный кэш и сам отправит её при появлении сети,
/// поэтому по таймауту запись считается принятой. Ошибки после таймаута отбрасывает timeout.
Future<Result<void>> writeWithOfflineQueue(
  Future<void> write, {
  required Duration wait,
}) async {
  try {
    await write.timeout(wait);
    return const Success(null);
  } on TimeoutException {
    return const Success(null);
  } on FirebaseException catch (error) {
    return Failure(mapFirestoreFailure(error), cause: error);
  }
}
