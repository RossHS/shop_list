import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Динамически возвращает один из прописанных виджетов аргумента в зависимости от типа текущей темы.
/// Полезен, когда необходимо создавать действительно уникальные виджеты в одном конкретном месте,
class ThemeDepBuilder extends ThemeDepWidgetBase {
  const ThemeDepBuilder({
    Key? key,
    this.animated90s = defaultBuilderFun,
    this.material = defaultBuilderFun,
    this.modern = defaultBuilderFun,
    this.child,
  }) : super(key: key);

  final Animated90sFun animated90s;
  final MaterialFun material;
  final ModernFun modern;
  final Widget? child;

  @override
  Widget animated90sWidget(
    BuildContext context,
    Animated90sThemeDataWrapper themeWrapper,
  ) {
    return animated90s(
      context,
      themeWrapper,
      child,
    );
  }

  @override
  Widget materialWidget(
    BuildContext context,
    MaterialThemeDataWrapper themeWrapper,
  ) {
    return material(
      context,
      themeWrapper,
      child,
    );
  }

  @override
  Widget modernWidget(BuildContext context, ModernThemeDataWrapper themeWrapper) {
    // TODO 23.12.2021 implement modernWidget
    return materialWidget(context, MaterialThemeDataWrapper.fromGetStorage(GetStorage()));
  }
}
