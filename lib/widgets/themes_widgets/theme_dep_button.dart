import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_button.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Самая распространенная кнопка
class ThemeDepButton extends ThemeDepWidgetBase {
  const ThemeDepButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final void Function() onPressed;
  final Widget child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return AnimatedButton90s(
      onPressed: onPressed,
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
      child: child,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return GlassmorphismButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
