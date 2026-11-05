import 'package:cloud_functions/cloud_functions.dart' hide Result;

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import 'functions_failure_mapper.dart';
import 'record_fields.dart';

/// Вызовы функций рекордов с переводом ошибок в ошибки приложения.
class RecordFunctionsClient {
  /// Создаёт клиента; экземпляр Functions создаётся при первом вызове.
  RecordFunctionsClient(this._functions);

  final FirebaseFunctions Function() _functions;

  /// Вызывает функцию [name] без полезного ответа.
  Future<Result<void>> call(String name, Map<String, Object> data) async {
    try {
      await _functions().httpsCallable(name).call<Object?>(data);
      return const Success(null);
    } on FirebaseFunctionsException catch (error) {
      return Failure(mapFunctionsFailure(error), cause: error);
    }
  }

  /// Временная ссылка на видео рекорда [recordId].
  Future<Result<Uri>> videoUrl(String recordId) async {
    try {
      final result = await _functions()
          .httpsCallable(RecordFields.recordVideoUrl)
          .call<Map<String, dynamic>>({RecordFields.recordId: recordId});
      final url = Uri.tryParse('${result.data[RecordFields.url]}');
      return url == null || !url.hasScheme
          ? const Failure(AppFailure.unknown)
          : Success(url);
    } on FirebaseFunctionsException catch (error) {
      return Failure(mapFunctionsFailure(error), cause: error);
    }
  }
}
