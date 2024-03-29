import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepFloatingActionButton extends ThemeDepWidgetBase {
  const ThemeDepFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final void Function() onPressed;
  final Widget child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return AnimatedCircleButton90s(
      onPressed: onPressed,
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
      child: child,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return GlassmorphismFloatingActionButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
