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
  }) : super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? body;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return Scaffold(
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
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
