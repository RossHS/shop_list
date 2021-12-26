import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Обоснованием для появления данного виджета служит задача установить градиентный задний фон темы [ModernThemeDataWrapper].
/// Конечно есть "простой" вариант: просто проверять текущую тему в каждом маршруте и после устанавливать градиентный фон
/// в зависимости от темы, но данный подход чреват ошибками из-за постоянного дублирования.
/// Поэтому я выбрал текущее решение, которое чуть менее производительное/ для других тем рудиментарное,
/// но упрощает/очищает вызывающий код, а также лучше вписывается в концепцию ThemeDepWidgets
class ThemeDepScaffold extends ThemeDepWidgetBase {
  const ThemeDepScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.scaffoldGlobalKey,
  })  : assert(key == null || key != scaffoldGlobalKey),
        super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? body;

  /// Т.к. в методе [modernWidget] добавляется новый виджет в дереве, что приводит к пересозданию всего поддерева
  /// (новые element subtree, renderObjects, state и т.д.), то для сохранения поддерева при смене родителя я использую
  /// GlobalKey [scaffoldGlobalKey].
  ///
  /// Передавать одинаковый [GlobalKey] в [key] и [scaffoldGlobalKey] нельзя, т.к. это прямое нарушения правила
  /// использования [GlobalKey], которые запрещает использовать один ключ в нескольких местах внутри одного дерева
  final GlobalKey? scaffoldGlobalKey;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return Scaffold(
      key: scaffoldGlobalKey,
      appBar: appBar,
      body: body,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return Scaffold(
      key: scaffoldGlobalKey,
      appBar: appBar,
      body: body,
    );
  }

  @override
  Widget modernWidget(BuildContext context, ModernThemeDataWrapper themeWrapper) {
    // TODO 25.12.2021 брать градиенту из ModernThemeDataWrapper
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.red,
          ],
        ),
      ),
      child: Scaffold(
        key: scaffoldGlobalKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
