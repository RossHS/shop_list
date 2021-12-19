import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Вызов диалогового окна с заголовком [text], основным контентом [content] и кнопками управления [actions]
/// TODO 16.12.2021 выделить одинаковый код из методов вызов DRY
class ThemeDepDialog extends ThemeBaseClass {
  ThemeDepDialog({
    this.text,
    this.content,
    this.actions,
  }) : super();

  final String? text;
  final Widget? content;
  final List<Widget>? actions;

  @override
  void animated90s(Animated90sThemeDataWrapper themeWrapper) {
    showGeneralDialog(
      context: Get.context!,
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Get.theme;
        // Адаптация цвета текста к фону
        final adaptedTheme = theme.copyWith(
          textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
        );
        Widget? titleWidget;
        Widget? actionsWidget;

        if (text != null) {
          titleWidget = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              text!,
              style: adaptedTheme.textTheme.headline6,
            ),
          );
        }

        if (actions != null) {
          actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!,
          );
        }
        return Theme(
          data: adaptedTheme,
          child: Center(
            child: AnimatedPainterSquare90s(
              duration: themeWrapper.animationDuration,
              config: themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (titleWidget != null) titleWidget,
                      if (content != null) content!,
                      if (actionsWidget != null) actionsWidget,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint).value,
          child: child,
        );
      },
      barrierDismissible: true,
      barrierLabel: '',
    );
  }

  @override
  void material(MaterialThemeDataWrapper themeWrapper) {
    // Продублировал код из Animated90sThemeFactory
    showGeneralDialog(
      context: Get.context!,
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Get.theme;
        // Адаптация цвета текста к фону
        final adaptedTheme = theme.copyWith(
          textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
        );
        Widget? titleWidget;
        Widget? actionsWidget;

        if (text != null) {
          titleWidget = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              text!,
              style: adaptedTheme.textTheme.headline6,
            ),
          );
        }

        if (actions != null) {
          actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!,
          );
        }

        return Theme(
          data: adaptedTheme,
          child: Center(
            child: Container(
              decoration: themeWrapper.buildDefaultBoxDecoration(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (titleWidget != null) titleWidget,
                      if (content != null) content!,
                      if (actionsWidget != null) actionsWidget,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint).value,
          child: child,
        );
      },
      barrierDismissible: true,
      barrierLabel: '',
    );
  }
}
