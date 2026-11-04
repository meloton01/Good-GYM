import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Тело экрана с формой: прокрутка, отступы и ограничение ширины на планшетах.
class FormScreenBody extends StatelessWidget {
  /// Создаёт тело формы со списком дочерних виджетов.
  const FormScreenBody({super.key, required this.children});

  final List<Widget> children;

  /// Строит прокручиваемую колонку по центру экрана.
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.sizes.formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
