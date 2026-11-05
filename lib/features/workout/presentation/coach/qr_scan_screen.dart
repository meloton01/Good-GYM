import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/coach_limits.dart';

/// Сканер QR-кода приглашения; возвращает ник через pop.
class QrScanScreen extends StatefulWidget {
  /// Создаёт экран сканера.
  const QrScanScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

/// Закрывает экран один раз, на первом подходящем коде.
class _QrScanScreenState extends State<QrScanScreen> {
  bool _done = false;

  /// Строит превью камеры и подсказку; без доступа к камере предлагает ввести ник.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachScanQr)),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onDetect,
              errorBuilder: (context, error) => EmptyStateView(
                icon: Icons.no_photography_outlined,
                title: l10n.coachScanQr,
                message: l10n.coachCameraUnavailable,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.md),
            child: Text(l10n.coachScanHint, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  /// Берёт ник из кода с префиксом приглашения; чужие коды пропускает.
  void _onDetect(BarcodeCapture capture) {
    if (_done) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.startsWith(CoachLimits.qrPrefix)) {
        _done = true;
        context.pop(value.substring(CoachLimits.qrPrefix.length));
        return;
      }
    }
  }
}
