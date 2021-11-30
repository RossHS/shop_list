import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика кастомного стиля Animated90s
class Animated90sFactory extends ThemeFactory {
  @override
  Animated90IconsFactory get icons => const Animated90IconsFactory();

  @override
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AnimatedAppBar90s(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Widget floatingActionButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return AnimatedCircleButton90s(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget button({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return AnimatedButton90s(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget todoItemBox({Key? key, required Widget child}) {
    // TODO 30.11.2021 использовать Paint90sConfig из Animated90sThemeWrapper
    final theme = Get.theme;
    return AnimatedPainterSquare90s(
      key: key,
      config: Paint90sConfig(backgroundColor: theme.canvasColor),
      child: child,
    );
  }

  @override
  Widget todoElementMsgInputBox({Key? key, required Widget child}) {
    // TODO 30.11.2021 использовать Paint90sConfig из Animated90sThemeWrapper
    final theme = Get.theme;
    return AnimatedPainterSquare90s(
      key: key,
      config: Paint90sConfig(backgroundColor: theme.canvasColor),
      borderPaint: const BorderPaint.top(),
      child: child,
    );
  }

  @override
  Widget infoOverlay({
    String? title,
    required String msg,
    Widget? child,
  }) {
    final theme = Get.theme;
    final textTheme = theme.textTheme;
    // TODO 29.11.2021 использовать Paint90sConfig из Animated90sThemeWrapper
    Paint90sConfig config = Paint90sConfig(backgroundColor: theme.canvasColor);
    return SafeArea(
      // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
      child: Padding(
        padding: EdgeInsets.all(10.0 + config.offset),
        child: AnimatedPainterSquare90s(
          config: config,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headline5,
                  ),
                Text(msg, style: textTheme.bodyText1),
                if (child != null) child
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void showDialog({String? text, List<Widget>? actions}) {
    showGeneralDialog(
      context: Get.context!,
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Get.theme;
        final textTheme = Get.textTheme;
        Widget? titleWidget;
        Widget? actionsWidget;

        if (text != null) {
          titleWidget = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              text,
              style: textTheme.headline6,
            ),
          );
        }

        if (actions != null) {
          actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          );
        }

        return DefaultTextStyle(
          style: Get.textTheme.bodyText2!,
          child: Center(
            child: AnimatedPainterSquare90s(
              config: Paint90sConfig(
                backgroundColor: theme.canvasColor,
                offset: 20,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (titleWidget != null) titleWidget,
                    if (actionsWidget != null) actionsWidget,
                  ],
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

class Animated90IconsFactory extends IconsFactory {
  const Animated90IconsFactory();

  @override
  Widget get create => const AnimatedIcon90s(iconsList: CustomIcons.create);

  @override
  Widget get user => const AnimatedIcon90s(iconsList: CustomIcons.user);
}
