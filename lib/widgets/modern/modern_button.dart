import 'package:flutter/material.dart';
import 'package:shop_list/widgets/modern/modern_raw_button.dart';

class ModernButton extends StatelessWidget {
  const ModernButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Center(
      child: DefaultTextStyle(
        style: theme.textTheme.bodyText2!.apply(color: colorScheme.onPrimary),
        child: child,
      ),
    );

    return ModernRawButton(
      onPressed: onPressed,
      child: content,
    );
  }
}
