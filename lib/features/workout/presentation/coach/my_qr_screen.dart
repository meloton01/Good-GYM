import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_repository_provider.dart';
import '../../../profile/data/user_profile_repository_provider.dart';
import '../../domain/coach_limits.dart';

/// Свой QR-код: второй стороне не нужно вводить ник вручную.
class MyQrScreen extends ConsumerWidget {
  /// Создаёт экран кода приглашения.
  const MyQrScreen({super.key});

  /// Строит код с ником; код всегда тёмный на светлом, чтобы его читала любая камера.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid ?? '';
    final profile = ref.watch(userProfileProvider(uid));
    final spacing = context.spacing;
    const qrColors = AppColors.light;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachMyQr)),
      body: switch (profile) {
        AsyncData(:final value?) => Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(spacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.sizes.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: qrColors.surface,
                      borderRadius: BorderRadius.circular(context.radii.large),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.all(spacing.md),
                      child: QrImageView(
                        data: '${CoachLimits.qrPrefix}${value.nickname}',
                        semanticsLabel: l10n.coachMyQr,
                        eyeStyle: QrEyeStyle(color: qrColors.textPrimary),
                        dataModuleStyle: QrDataModuleStyle(
                          color: qrColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    value.nickname,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    l10n.coachMyQrHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        AsyncError(:final error) => ErrorView(
          title: l10n.coachMyQr,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(userProfileProvider(uid)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
