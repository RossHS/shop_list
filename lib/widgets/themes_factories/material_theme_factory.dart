import 'package:flutter/material.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика классической темы дизайна Material
class MaterialThemeFactory extends ThemeFactory {
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
}
