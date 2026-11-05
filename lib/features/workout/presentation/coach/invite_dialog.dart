import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/errors/app_failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/widgets/info_snack_bar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/domain/nickname_policy.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../profile/domain/user_role.dart';
import '../../data/coach_repository_providers.dart';

/// Показывает диалог приглашения по нику; ник можно считать с QR-кода.
Future<void> showInviteDialog(BuildContext context, UserProfile me) {
  return showDialog<void>(
    context: context,
    builder: (context) => _InviteDialog(me: me),
  );
}

/// Диалог с полем ника, сканером и отправкой.
class _InviteDialog extends ConsumerStatefulWidget {
  /// Создаёт диалог от имени [me].
  const _InviteDialog({required this.me});

  final UserProfile me;

  /// Создаёт состояние диалога.
  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

/// Хранит поле ника, флаг отправки и текст ошибки.
class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  bool _sending = false;
  String? _error;

  /// Освобождает контроллер поля.
  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  /// Строит поле ника с кнопкой сканера и кнопки диалога.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final asCoach = widget.me.role == UserRole.coach;
    return AlertDialog(
      title: Text(asCoach ? l10n.coachInviteStudent : l10n.coachInviteCoach),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nickname,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.profileNicknameLabel,
                suffixIcon: IconButton(
                  tooltip: l10n.coachScanQr,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: _scan,
                ),
              ),
              validator: (value) =>
                  NicknamePolicy.isValid(NicknamePolicy.normalize(value ?? ''))
                  ? null
                  : l10n.validationNicknameInvalid,
              onFieldSubmitted: (_) => _send(),
            ),
            if (error != null) ...[
              SizedBox(height: context.spacing.md),
              Text(error, style: TextStyle(color: context.colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _sending ? null : _send,
          child: Text(l10n.coachSendInvite),
        ),
      ],
    );
  }

  /// Открывает сканер и подставляет считанный ник.
  Future<void> _scan() async {
    final nickname = await context.push<String>(AppRoutes.coachScan);
    if (nickname != null && mounted) {
      _nickname.text = nickname;
    }
  }

  /// Отправляет приглашение и закрывает диалог; ошибку показывает в диалоге.
  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref
        .read(coachLinkRepositoryProvider)
        .invite(me: widget.me, nickname: _nickname.text);
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case Success():
        Navigator.of(context).pop();
        showInfoSnackBar(context, l10n.coachInviteSent);
      case Failure(:final failure):
        setState(() {
          _sending = false;
          _error = failure.message(l10n);
        });
    }
  }
}
