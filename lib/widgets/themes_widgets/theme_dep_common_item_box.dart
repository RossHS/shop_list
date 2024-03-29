import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepCommonItemBox extends ThemeDepWidgetBase {
  const ThemeDepCommonItemBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    final theme = Theme.of(context);
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return _CustomThemeWrapper(
      child: AnimatedPainterSquare90s(
        duration: themeWrapper.animationDuration,
        config: config,
        child: child,
      ),
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return _CustomThemeWrapper(
      child: Container(
        decoration: themeWrapper.buildDefaultBoxDecoration(context),
        child: child,
      ),
    );
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    // Нет необходимости в обертке [_CustomThemeWrapper], т.к. фон всегда статический
    return GlassmorphismBox(
      child: child,
    );
  }
}

/// Дополнительная обертка, т.к. виджет [ThemeDepCommonItemBox] имеет особый цвет фона, для которого нужно адаптировать цвет текста.
/// Конечно, можно было бы ограничится одним виджетом [Theme], но виджет [Text] ищет по дереву ближайший [DefaultTextStyle],
/// т.е. для корректного использования [ThemeDepCommonItemBox] все равно приходилось переопределять стандартный стиль или
/// задавать стиль напрямую в виджет [Text]
class _CustomThemeWrapper extends StatelessWidget {
  const _CustomThemeWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
    );
    return Theme(
      data: customTheme,
      child: DefaultTextStyle(
        style: customTheme.textTheme.bodyText2!,
        child: child,
      ),
    );
  }
}
