import 'package:flutter/material.dart';
import 'package:shop_list/widgets/modern/modern.dart';

class ModernButton extends StatelessWidget {
  const ModernButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.buttonStyle,
  }) : super(key: key);
  final void Function() onPressed;
  final Widget child;
  final ModernButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var modernStyle = buttonStyle ?? ModernButtonStyle();

    final content = Center(
      child: DefaultTextStyle(
        style: theme.textTheme.bodyText2!.apply(color: colorScheme.onPrimary),
        child: child,
      ),
    );

    // TODO 23.12.2021 - цвета для SplashEffect?
    return InkWell(
      onTap: onPressed,
      borderRadius: modernStyle.borderRadius,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: modernStyle.borderRadius,
          boxShadow: <BoxShadow>[
            modernStyle.shadow(colorScheme.primary),
          ],
        ),
        child: content,
      ),
    );
  }
}
