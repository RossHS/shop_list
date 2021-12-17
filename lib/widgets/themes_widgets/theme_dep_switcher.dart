import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Анимированный переход между виджетами при смене темы приложения.
/// Данный виджет появился из-за того, что родитель [ThemeDepWidgetBase] в методе build вызывает
/// GetX<ThemeController>, что приводит к невозможности корректно пользоваться анимированным переходом.
/// Хотя было бы удобно просто воспользоваться виджетом [ThemeDepBuilder] обернутым в [AnimatedSwitcher],
/// но с другой стороны пропадает необходимость в обертке такой связки в GetX<ThemeController>,
/// т.к. [ThemeDepAnimatedSwitcher] делает именно это "под капотом"
class ThemeDepAnimatedSwitcher extends ThemeDepWidgetBase {
  const ThemeDepAnimatedSwitcher({
    Key? key,
    required this.duration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.animated90s = _defaultBuildWidgetFunction,
    this.material = _defaultBuildWidgetFunction,
  }) : super(key: key);
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final Widget? Function(BuildContext context, Animated90sThemeDataWrapper themeWrapper) animated90s;
  final Widget? Function(BuildContext context, MaterialThemeDataWrapper themeWrapper) material;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return _animatedSwitcher(animated90s(context, themeWrapper));
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return _animatedSwitcher(material(context, themeWrapper));
  }

  AnimatedSwitcher _animatedSwitcher(Widget? child) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      child: child,
    );
  }

  static Widget _defaultBuildWidgetFunction(BuildContext context, ThemeDataWrapper dataWrapper) {
    return const SizedBox();
  }
}
