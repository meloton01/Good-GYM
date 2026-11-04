import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../workout/data/workout_repository_provider.dart';
import 'app_settings_controller.dart';

/// Имя файла выгрузки без расширения.
const String _exportFileName = 'good-gym-data';

/// Собирает данные аккаунта и настройки устройства в JSON и сохраняет файл.
Future<void> exportUserData(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authUserProvider).value;
  if (user == null) {
    return;
  }
  final (profile, workouts) = await (
    ref.read(userProfileRepositoryProvider).exportData(user.uid),
    ref.read(workoutRepositoryProvider).exportData(user.uid),
  ).wait;
  if (!context.mounted) {
    return;
  }
  switch ((profile, workouts)) {
    case (Failure(:final failure), _) || (_, Failure(:final failure)):
      showFailureSnackBar(context, failure);
    case (Success(value: final profileData), Success(value: final workoutData)):
      final settings = ref.read(appSettingsProvider);
      final document = {
        ...profileData,
        'workouts': workoutData,
        'email': user.email,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'deviceSettings': {
          'themeMode': settings.themeMode.name,
          'languageCode': settings.languageCode,
          'palette': settings.palette.name,
          'accent': settings.accent?.name,
          'cornerStyle': settings.cornerStyle.name,
          'weightUnit': settings.weightUnit.name,
          'lengthUnit': settings.lengthUnit.name,
          'mutedNotifications': [
            for (final type in settings.mutedNotifications) type.name,
          ],
        },
      };
      await _save(
        context,
        const JsonEncoder.withIndent('  ').convert(document),
      );
  }
}

/// Сохраняет JSON в файл и показывает, где он лежит.
Future<void> _save(BuildContext context, String json) async {
  try {
    final location = await FileSaver.instance.saveFile(
      name: _exportFileName,
      bytes: Uint8List.fromList(utf8.encode(json)),
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
    if (context.mounted) {
      showInfoSnackBar(
        context,
        AppLocalizations.of(context).accountExportSaved(location),
      );
    }
  } on Exception {
    if (context.mounted) {
      showFailureSnackBar(context, AppFailure.storage);
    }
  }
}
