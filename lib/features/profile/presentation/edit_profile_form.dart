import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/user_profile_repository_provider.dart';
import '../domain/body_metrics.dart';
import '../domain/nickname_policy.dart';
import '../domain/profile_limits.dart';
import '../domain/user_profile.dart';
import 'gym_field.dart';
import 'measurement_field.dart';
import 'profile_validators.dart';

/// Форма профиля: ник, описание, зал, вес и рост в единицах пользователя.
class EditProfileForm extends ConsumerStatefulWidget {
  /// Создаёт форму с исходными данными.
  const EditProfileForm({
    super.key,
    required this.profile,
    required this.metrics,
  });

  final UserProfile profile;
  final BodyMetrics metrics;

  /// Создаёт состояние формы.
  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

/// Хранит поля формы, выбранный зал и флаг отправки.
class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nickname = TextEditingController(text: widget.profile.nickname);
  late final _bio = TextEditingController(text: widget.profile.bio);
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late ({String? id, String? name}) _gym = (
    id: widget.profile.gymId,
    name: widget.profile.gymName,
  );
  bool _submitting = false;

  /// Заполняет вес и рост в текущих единицах.
  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    final weight = widget.metrics.weightKg;
    final height = widget.metrics.heightCm;
    _weight = TextEditingController(
      text: weight == null
          ? ''
          : _format(settings.weightUnit.fromKilograms(weight)),
    );
    _height = TextEditingController(
      text: height == null
          ? ''
          : _format(settings.lengthUnit.fromCentimeters(height)),
    );
  }

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    for (final controller in [_nickname, _bio, _weight, _height]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Строит поля формы и кнопку сохранения.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final settings = ref.watch(appSettingsProvider);
    final weightUnit = settings.weightUnit;
    final lengthUnit = settings.lengthUnit;
    return Form(
      key: _formKey,
      child: FormScreenBody(
        children: [
          TextFormField(
            controller: _nickname,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.profileNicknameLabel,
              helperText: l10n.profileNicknameHelper,
            ),
            validator: (value) => ProfileValidators.nickname(l10n, value),
          ),
          SizedBox(height: spacing.md),
          TextFormField(
            controller: _bio,
            minLines: 2,
            maxLines: 6,
            maxLength: ProfileLimits.bioMaxLength,
            decoration: InputDecoration(labelText: l10n.profileBioLabel),
            validator: (value) => ProfileValidators.bio(l10n, value),
          ),
          GymField(
            gymName: _gym.name,
            onChanged: (gym) =>
                setState(() => _gym = (id: gym?.id, name: gym?.name)),
          ),
          SizedBox(height: spacing.md),
          MeasurementField(
            controller: _weight,
            label: l10n.profileWeightLabel(weightUnit.shortLabel(l10n)),
            helperText: l10n.profileBodyPrivateNote,
            min: weightUnit.fromKilograms(ProfileLimits.minWeightKg),
            max: weightUnit.fromKilograms(ProfileLimits.maxWeightKg),
          ),
          SizedBox(height: spacing.md),
          MeasurementField(
            controller: _height,
            label: l10n.profileHeightLabel(lengthUnit.shortLabel(l10n)),
            min: lengthUnit.fromCentimeters(ProfileLimits.minHeightCm),
            max: lengthUnit.fromCentimeters(ProfileLimits.maxHeightCm),
          ),
          SizedBox(height: spacing.lg),
          PrimaryButton(
            label: l10n.actionSave,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  /// Сохраняет профиль и данные о теле в метрических единицах.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    final settings = ref.read(appSettingsProvider);
    final weight = MeasurementFormat.parse(_weight.text);
    final height = MeasurementFormat.parse(_height.text);
    final repository = ref.read(userProfileRepositoryProvider);
    setState(() => _submitting = true);
    var result = await repository.updateProfile(
      widget.profile.copyWith(
        nickname: NicknamePolicy.normalize(_nickname.text),
        bio: _bio.text.trim(),
        gymId: _gym.id,
        gymName: _gym.name,
      ),
    );
    if (result is Success<void>) {
      result = await repository.saveBodyMetrics(
        widget.profile.uid,
        BodyMetrics(
          weightKg: weight == null
              ? null
              : settings.weightUnit.toKilograms(weight),
          heightCm: height == null
              ? null
              : settings.lengthUnit.toCentimeters(height),
        ),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    switch (result) {
      case Success():
        showInfoSnackBar(context, AppLocalizations.of(context).profileSaved);
        context.pop();
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  /// Число для поля ввода в формате текущей локали.
  String _format(double value) => MeasurementFormat.format(
    value,
    WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
  );
}
