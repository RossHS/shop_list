import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
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
    // Адаптация цвета текста к фону
    final adaptedTextTheme = theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor);
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return SafeArea(
      // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
      child: Padding(
        padding: EdgeInsets.all(10.0 + config.offset),
        child: AnimatedPainterSquare90s(
          duration: themeWrapper.animationDuration,
          config: config,
          child: SizedBox(
            width: double.infinity,
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
          ),
        ),
      ),
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    final theme = Theme.of(context);
    // Адаптация цвета текста к фону
    final adaptedTextTheme = theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor);
    return SafeArea(
      // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: themeWrapper.buildDefaultBoxDecoration(context),
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
        ),
      ),
    );
  }

  @override
  Widget modernWidget(BuildContext context, ModernThemeDataWrapper themeWrapper) {
    // TODO 23.12.2021 implement modernWidget
    return materialWidget(context, MaterialThemeDataWrapper.fromGetStorage(GetStorage()));
  }
}
