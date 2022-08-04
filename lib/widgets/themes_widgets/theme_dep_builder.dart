import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Динамически возвращает один из прописанных виджетов аргумента в зависимости от типа текущей темы.
/// Полезен, когда необходимо создавать действительно уникальные виджеты в одном конкретном месте,
class ThemeDepBuilder extends ThemeDepWidgetBase {
  const ThemeDepBuilder({
    super.key,
    this.animated90s = defaultBuilderFun,
    this.material = defaultBuilderFun,
    this.glassmorphism = defaultBuilderFun,
    this.child,
  });

  final Animated90sFun animated90s;
  final MaterialFun material;
  final GlassmorphismFun glassmorphism;
  final Widget? child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return animated90s(
      context,
      themeWrapper,
      child,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return material(
      context,
      themeWrapper,
      child,
    );
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return glassmorphism(
      context,
      themeWrapper,
      child,
    );
  }
}
