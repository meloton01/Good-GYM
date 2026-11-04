import 'package:flutter/material.dart';

import '../../core/widgets/loading_view.dart';

/// Экран на время загрузки учётной записи и профиля.
class SplashScreen extends StatelessWidget {
  /// Создаёт экран загрузки сессии.
  const SplashScreen({super.key});

  /// Строит Scaffold с индикатором загрузки.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView());
  }
}
