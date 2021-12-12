import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/custom_text_field.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика кастомного стиля Animated90s
class Animated90sFactory extends ThemeFactory {
  Animated90sFactory(this._themeDataWrapper) : super(_themeDataWrapper);
  final Animated90sThemeDataWrapper _themeDataWrapper;

  @override
  Animated90sThemeDataWrapper get themeWrapper => _themeDataWrapper;

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
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
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
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
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
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
      child: child,
    );
  }

  @override
  Widget commonItemBox({Key? key, required Widget child}) {
    final theme = Get.theme;
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
      ),
      child: AnimatedPainterSquare90s(
        key: key,
        duration: themeWrapper.animationDuration,
        config: config,
        child: child,
      ),
    );
  }

  @override
  Widget todoElementMsgInputBox({Key? key, required Widget child}) {
    final theme = Get.theme;
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
      ),
      child: AnimatedPainterSquare90s(
        key: key,
        duration: themeWrapper.animationDuration,
        config: config,
        borderPaint: const BorderPaint.top(),
        child: child,
      ),
    );
  }

  @override
  Widget infoOverlay({
    String? title,
    required String msg,
    Widget? child,
  }) {
    final theme = Get.theme;
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
                    title,
                    textAlign: TextAlign.center,
                    style: adaptedTextTheme.headline5,
                  ),
                Text(msg, style: adaptedTextTheme.bodyText1),
                if (child != null) child
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget textField({
    Key? key,
    required TextEditingController controller,
    bool Function(String p1)? inputValidator,
    String? hint,
    int? maxLines,
    int? minLines,
    Widget? prefixIcon,
    bool obscureText = false,
  }) {
    return CustomTextField(
      key: key,
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
      controller: controller,
      inputValidator: inputValidator,
      hint: hint,
      maxLines: maxLines,
      minLines: minLines,
      prefixIcon: prefixIcon,
      obscureText: obscureText,
    );
  }

  @override
  void showDialog({
    String? text,
    Widget? content,
    List<Widget>? actions,
  }) {
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
              text,
              style: adaptedTheme.textTheme.headline6,
            ),
          );
        }

        if (actions != null) {
          actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
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
                      if (content != null) content,
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

class Animated90IconsFactory extends IconsFactory {
  const Animated90IconsFactory();

  @override
  Widget get create => const AnimatedIcon90s(iconsList: CustomIcons.create);

  @override
  Widget get user => const AnimatedIcon90s(iconsList: CustomIcons.user);

  @override
  Widget get lock => const AnimatedIcon90s(iconsList: CustomIcons.lock);
}
