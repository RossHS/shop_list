import 'package:flutter/material.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism_raw_button.dart';

class GlassmorphismFloatingActionButton extends StatelessWidget {
  const GlassmorphismFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.child,
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
      child: GlassmorphismRawButton(
        onPressed: onPressed,
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: child,
        ),
      ),
    );
  }
}
