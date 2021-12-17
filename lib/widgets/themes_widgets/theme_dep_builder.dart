import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Динамически возвращает один из прописанных виджетов аргумента в зависимости от типа текущей темы.
/// Полезен, когда необходимо создавать действительно уникальные виджеты в одном конкретном месте,
class ThemeDepBuilder extends ThemeDepWidgetBase {
  const ThemeDepBuilder({
    Key? key,
    this.animated90s = _defaultBuildWidgetFunction,
    this.material = _defaultBuildWidgetFunction,
    this.modern = _defaultBuildWidgetFunction,
    this.child,
  }) : super(key: key);

  final Widget Function(Widget? child, Animated90sThemeDataWrapper themeWrapper) animated90s;
  final Widget Function(Widget? child, MaterialThemeDataWrapper themeWrapper) material;
  final Widget Function(Widget? child, ModernThemeDataWrapper themeWrapper) modern;
  final Widget? child;

  @override
  Widget animated90sWidget(
    BuildContext context,
    Animated90sThemeDataWrapper themeWrapper,
  ) {
    return animated90s(child, themeWrapper);
  }

  @override
  Widget materialWidget(
    BuildContext context,
    MaterialThemeDataWrapper themeWrapper,
  ) {
    return material(child, themeWrapper);
  }

  /// Костыль к конструктору, так как синтаксис Dart не позволяет напрямую указывать в именованном параметре дефолтную функцию.
  /// Т.е. вместо того чтобы разрешить использовать const к типу Function https://github.com/dart-lang/language/issues/1048
  /// и писать напрямую
  /// Widget Function(Widget? child, Animated90sThemeDataWrapper themeWrapper) animated90s = const (child, ThemeDataWrapper dataWrapper) => SizedBox(child: child),
  /// Приходится создавать приватную статическую функцию
  static Widget _defaultBuildWidgetFunction(Widget? child, ThemeDataWrapper dataWrapper) {
    return SizedBox(
      child: child,
    );
  }
}
