import 'package:flutter/material.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism_raw_button.dart';

class GlassmorphismButton extends StatelessWidget {
  const GlassmorphismButton({
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

    return GlassmorphismRawButton(
      onPressed: onPressed,
      child: content,
    );
  }
}
