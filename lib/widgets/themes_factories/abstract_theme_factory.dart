import 'package:flutter/cupertino.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_factories/animated90s_theme_factory.dart';
import 'package:shop_list/widgets/themes_factories/material_theme_factory.dart';

/// Абстрактная фабрика, которая отображает интерфейс в зависимости от установленной темы
abstract class ThemeFactory {
  static ThemeFactory instance(ThemeDataWrapper themeDataWrapper) {
    if (themeDataWrapper is Animated90sThemeData) {
      return Animated90sFactory();
    } else if (themeDataWrapper is MaterialThemeData) {
      return MaterialThemeFactory();
    } else if (themeDataWrapper is ModernThemeData) {
      // TODO 27.11.2021 пока возвращаем материал тему
      return MaterialThemeFactory();
    }
    throw Exception('Unsupported type of ThemeDataWrapper - $themeDataWrapper');
  }

  /// Метод создания виджета AppBar маршрута
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  });
}
