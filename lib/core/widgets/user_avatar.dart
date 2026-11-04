import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Аватар пользователя: первая буква ника в круге.
class UserAvatar extends StatelessWidget {
  /// Создаёт аватар для ника.
  const UserAvatar({super.key, required this.nickname});

  final String nickname;

  /// Строит круг поверхности с буквой; для скринридера аватар не озвучивается.
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.sizes.avatarLarge;
    final letter = nickname.isEmpty ? '' : nickname.characters.first;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: FittedBox(
          child: Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.sm),
            child: Text(
              letter.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}
