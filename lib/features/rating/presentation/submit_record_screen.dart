import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/record_repository_providers.dart';
import '../domain/record_submission.dart';
import 'record_criteria.dart';
import 'record_form_fields.dart';
import 'record_upload_controller.dart';
import 'record_upload_panel.dart';

/// Подача рекорда: результат, дата, категория, видео и критерии проверки.
class SubmitRecordScreen extends ConsumerStatefulWidget {
  /// Создаёт экран подачи.
  const SubmitRecordScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<SubmitRecordScreen> createState() => _SubmitRecordScreenState();
}

/// Хранит значения формы и флаг отправки.
class _SubmitRecordScreenState extends ConsumerState<SubmitRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _values = RecordFormValues();
  bool _sending = false;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  /// Строит форму или подсказку выбрать зал.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final profile = uid == null
        ? null
        : ref.watch(userProfileProvider(uid)).value;
    final ready = ref.watch(recordUploadProvider.select((s) => s.isReady));
    final Widget body;
    if (uid == null || profile == null) {
      body = const LoadingView();
    } else if (profile.gymId == null) {
      body = EmptyStateView(
        icon: Icons.location_city_rounded,
        title: l10n.ratingNoGymTitle,
        message: l10n.ratingNoGymMessage,
      );
    } else {
      final bodyWeight = ref.watch(bodyMetricsProvider(uid)).value?.weightKg;
      body = Form(
        key: _formKey,
        child: FormScreenBody(
          children: [
            RecordFormFields(values: _values, bodyWeightKg: bodyWeight),
            const RecordUploadPanel(),
            const RecordCriteria(),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: context.spacing.md,
              ),
              child: Text(
                l10n.submitRecordPublicNote,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            PrimaryButton(
              label: l10n.submitRecordSend,
              loading: _sending,
              onPressed: ready ? _submit : null,
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.submitRecordTitle)),
      body: body,
    );
  }

  /// Проверяет форму и отправляет рекорд на проверку.
  Future<void> _submit() async {
    final uploadId = ref.read(recordUploadProvider).uploadId;
    if (uploadId == null || !_formKey.currentState!.validate()) {
      return;
    }
    final unit = ref.read(appSettingsProvider).weightUnit;
    final exercise = _values.exercise;
    final sex = _values.sex;
    if (sex == null) {
      return;
    }
    final submission = RecordSubmission(
      uploadId: uploadId,
      exercise: exercise,
      weightKg: unit.toKilograms(MeasurementFormat.parse(_values.weight.text)!),
      reps: int.parse(_values.reps.text.trim()),
      performedAt: _values.performedAt(ref.read(clockProvider)()),
      sex: sex,
      bodyWeightKg: unit.toKilograms(
        MeasurementFormat.parse(_values.bodyWeight.text)!,
      ),
    );
    setState(() => _sending = true);
    final result = await ref
        .read(recordRepositoryProvider)
        .submitRecord(submission);
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case Success():
        showInfoSnackBar(context, l10n.submitRecordSent);
        context.pop();
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
