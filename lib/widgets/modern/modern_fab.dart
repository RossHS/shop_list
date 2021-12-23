import 'package:flutter/material.dart';
import 'package:shop_list/widgets/modern/modern_raw_button.dart';

class ModernFloatingActionButton extends StatelessWidget {
  const ModernFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final colorScheme = theme.colorScheme;
    final foregroundColor = floatingActionButtonTheme.foregroundColor ?? colorScheme.onPrimary;

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 56.0, width: 56.0),
      child: ModernRawButton(
        onPressed: onPressed,
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: child,
        ),
      ),
    );
  }
}
