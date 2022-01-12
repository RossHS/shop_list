import 'package:flutter/material.dart';

/// Обычная Material [Icon], но с добавление glow эффекта
class GlassmorphismIcon extends StatelessWidget {
  const GlassmorphismIcon(
    this.icon, {
    Key? key,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);
    final iconSize = iconTheme.size;
    final iconColor = iconTheme.color ?? theme.colorScheme.primary;

    return SizedBox(
      height: iconSize,
      width: iconSize,
      child: Center(
        child: RichText(
          overflow: TextOverflow.visible,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              inherit: false,
              color: iconColor,
              fontSize: iconSize,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              shadows: <Shadow>[
                Shadow(
                  color: iconColor,
                  offset: const Offset(0, 0),
                  blurRadius: 15,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
