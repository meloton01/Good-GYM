import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/user_profile_repository_provider.dart';
import '../domain/nickname_policy.dart';
import '../domain/user_role.dart';
import 'role_selector.dart';

/// Первый шаг после входа: выбор ника и роли.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  /// Создаёт экран создания профиля.
  const ProfileSetupScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

/// Хранит ник, выбранную роль и флаг отправки.
class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  UserRole _role = UserRole.athlete;
  bool _submitting = false;

  /// Освобождает контроллер поля.
  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  /// Строит поле ника, выбор роли и кнопку продолжения.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSetupTitle),
        actions: [
          TextButton(onPressed: _signOut, child: Text(l10n.authSignOut)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: FormScreenBody(
          children: [
            TextFormField(
              controller: _nickname,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(
                labelText: l10n.profileNicknameLabel,
                helperText: l10n.profileNicknameHelper,
              ),
              validator: (value) =>
                  NicknamePolicy.isValid(NicknamePolicy.normalize(value ?? ''))
                  ? null
                  : l10n.validationNicknameInvalid,
            ),
            SectionHeader(title: l10n.profileRoleLabel),
            RoleSelector(
              selected: _role,
              onSelected: (role) => setState(() => _role = role),
            ),
            SizedBox(height: spacing.lg),
            PrimaryButton(
              label: l10n.actionContinue,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  /// Создаёт профиль; после записи роутер откроет вкладки.
  Future<void> _submit() async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null || _submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final result = await ref
        .read(userProfileRepositoryProvider)
        .createProfile(
          uid: uid,
          nickname: NicknamePolicy.normalize(_nickname.text),
          role: _role,
        );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (result is Failure<void>) {
      showFailureSnackBar(context, result.failure);
    }
  }

  /// Выходит из аккаунта, если пользователь передумал создавать профиль.
  Future<void> _signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result is Failure<void> && mounted) {
      showFailureSnackBar(context, result.failure, onRetry: _signOut);
    }
  }
}
