import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/gym_record.dart';
import '../domain/record_repository.dart';
import '../domain/video_source.dart';
import 'firebase_record_repository.dart';
import 'picker_video_source.dart';
import 'record_fields.dart';

/// Репозиторий рекордов; в тестах подменяется через overrides.
final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => FirebaseRecordRepository(
    FirebaseFirestore.instance,
    functions: () =>
        FirebaseFunctions.instanceFor(region: RecordFields.functionsRegion),
    storage: () => FirebaseStorage.instance,
  ),
);

/// Выбор и сжатие видео; в тестах подменяется через overrides.
final videoSourceProvider = Provider<VideoSource>((ref) => PickerVideoSource());

/// Свои рекорды пользователя в любом статусе.
final myRecordsProvider = StreamProvider.family<List<GymRecord>, String>(
  (ref, uid) => ref.watch(recordRepositoryProvider).watchMyRecords(uid),
);

/// Один рекорд по id.
final recordProvider = StreamProvider.family<GymRecord?, String>(
  (ref, recordId) => ref.watch(recordRepositoryProvider).watchRecord(recordId),
);
