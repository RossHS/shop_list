import 'package:flutter/material.dart';

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

    // TODO 23.12.2021 - цвета для SplashEffect?
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(200),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(200),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary,
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
