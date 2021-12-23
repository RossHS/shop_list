import 'package:flutter/material.dart';
import 'package:shop_list/widgets/modern/modern.dart';

class ModernFloatingActionButton extends StatelessWidget {
  const ModernFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.buttonStyle,
  }) : super(key: key);

  final void Function() onPressed;
  final Widget child;
  final ModernButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final colorScheme = theme.colorScheme;
    final foregroundColor = floatingActionButtonTheme.foregroundColor ?? colorScheme.onPrimary;
    var modernStyle = buttonStyle ?? ModernButtonStyle();

    // TODO 23.12.2021 - цвета для SplashEffect?
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 56.0, width: 56.0),
      child: InkWell(
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
          child: IconTheme.merge(
            data: IconThemeData(color: foregroundColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
