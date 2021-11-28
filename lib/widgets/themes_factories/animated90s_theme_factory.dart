import 'package:flutter/material.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика кастомного стиля Animated90s
class Animated90sFactory extends ThemeFactory {
  @override
  Animated90IconsFactory get icons => const Animated90IconsFactory();

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

  @override
  Widget floatingActionButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return AnimatedCircleButton90s(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget button({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return AnimatedButton90s(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }
}

class Animated90IconsFactory extends IconsFactory {
  const Animated90IconsFactory();

  @override
  Widget get create => const AnimatedIcon90s(iconsList: CustomIcons.create);

  @override
  Widget get user => const AnimatedIcon90s(iconsList: CustomIcons.user);
}
