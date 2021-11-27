import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика кастомного стиля Animated90s
class Animated90sFactory extends ThemeFactory {
  @override
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AnimatedAppBar90s(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }
}
