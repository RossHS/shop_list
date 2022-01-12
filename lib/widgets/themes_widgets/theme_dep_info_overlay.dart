import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepInfoOverlay extends ThemeDepWidgetBase {
  const ThemeDepInfoOverlay({
    Key? key,
    this.title,
    required this.msg,
    this.child,
  }) : super(key: key);
  final String? title;
  final String msg;
  final Widget? child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    final theme = Theme.of(context);
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return SafeArea(
      // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
      child: Padding(
        padding: EdgeInsets.all(10.0 + config.offset),
        child: AnimatedPainterSquare90s(
          duration: themeWrapper.animationDuration,
          config: config,
          child: _OverlayContent(
            title: title,
            msg: msg,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _OverlayContent(
          title: title,
          msg: msg,
          decoration: themeWrapper.buildDefaultBoxDecoration(context),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GlassmorphismBox(
          child: _OverlayContent(
            title: title,
            msg: msg,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Вспомогательный класс компоновки оверлея, дабы не повторяться в методах каждой темы
class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    Key? key,
    this.title,
    required this.msg,
    this.decoration,
    this.child,
  }) : super(key: key);
  final String? title;
  final String msg;
  final Decoration? decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Адаптация цвета текста к фону
    final adaptedTextTheme = theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: adaptedTextTheme.headline5,
            ),
          Text(msg, style: adaptedTextTheme.bodyText1),
          if (child != null) child!
        ],
      ),
    );
  }
}
