import 'package:flutter/material.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика классической темы дизайна Material
class MaterialThemeFactory extends ThemeFactory {
  @override
  Material90IconsFactory get icons => const Material90IconsFactory();

  @override
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
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
    return FloatingActionButton(
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
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }
}

class Material90IconsFactory extends IconsFactory {
  const Material90IconsFactory();

  @override
  Widget get create => const Icon(Icons.create);

  @override
  Widget get user => const Icon(Icons.account_circle);
}
