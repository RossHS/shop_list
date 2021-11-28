import 'package:flutter/material.dart';
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

  /// Получить фабрику создания иконок
  IconsFactory get icons;

  /// Метод создания виджета [AppBar] маршрута
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  });

  /// Создание виджета [FloatingActionButton]
  Widget floatingActionButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  });

  Widget button({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  });

  /// Динамически возвращает один из прописанных виджетов аргумента в зависимости от типа текущей реализации фабрики.
  /// Полезен, когда необходимо создавать действительно уникальные виджеты в одном конкретном месте,
  /// не загружая абстрактную фабрику гигантским числом мелких методов
  /// Метод выходящий за принципы паттерна "абстрактной фабрики" и отчасти нарушающий их и полиморфизм
  Widget buildWidget({
    required Widget Function() animated90s,
    required Widget Function() material,
    required Widget Function() modern,
  }) {
    if (this is Animated90sFactory) return animated90s();
    if (this is MaterialThemeFactory) return material();
    if (this is ModernThemeData) return modern();
    throw Exception('Unsupported type of factory - $runtimeType');
  }
}

/// Фабрика для получения иконок в зависимости от установленной темы
abstract class IconsFactory {
  const IconsFactory();

  Widget get create;

  Widget get user;
}
