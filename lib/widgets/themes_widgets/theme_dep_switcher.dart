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
    super.key,
    required this.duration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.animated90s = defaultBuilderFun,
    this.material = defaultBuilderFun,
    this.glassmorphism = defaultBuilderFun,
    this.child,
  });

  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final Animated90sFun animated90s;
  final MaterialFun material;
  final GlassmorphismFun glassmorphism;
  final Widget? child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return _animatedSwitcher(animated90s(
      context,
      themeWrapper,
      child,
    ));
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return _animatedSwitcher(material(
      context,
      themeWrapper,
      child,
    ));
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return _animatedSwitcher(glassmorphism(
      context,
      themeWrapper,
      child,
    ));
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
}
